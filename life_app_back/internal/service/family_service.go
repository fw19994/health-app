package service

import (
	"errors"
	"life_app_back/internal/model"
	"life_app_back/internal/repository"
	"time"
)

// FamilyService 家庭服务
type FamilyService struct {
	repo       repository.FamilyRepository
	userRepo   repository.UserRepository
	memberRepo repository.FamilyMemberRepository
}

// CreateFamily 创建家庭
func (s *FamilyService) CreateFamily(userID uint, name, description string) (model.FamilyResponse, error) {
	// 参数验证
	if name == "" {
		return model.FamilyResponse{}, errors.New("家庭名称不能为空")
	}

	// 创建家庭模型
	family := model.Family{
		UserID:      userID,
		Name:        name,
		Description: description,
		IsActive:    true,
	}

	// 调用仓库层创建家庭
	id, err := s.repo.Create(family)
	if err != nil {
		return model.FamilyResponse{}, err
	}

	userRepository := repository.UserRepository{}
	userInfo, err := userRepository.GetUserByID(userID)
	if err != nil {
		return model.FamilyResponse{}, err
	}
	familyMember := new(model.FamilyMember)
	familyMember.OwnerID = id
	familyMember.UserID = userID
	familyMember.Name = userInfo.Nickname
	familyMember.JoinTime = time.Now()
	familyMember.AvatarURL = userInfo.Avatar
	familyMember.Phone = userInfo.Phone
	familyMemberRepository := repository.FamilyMemberRepository{}
	err = familyMemberRepository.CreateFamilyMember(familyMember)
	if err != nil {
		return model.FamilyResponse{}, err
	}
	// 转换为响应模型
	response := family.ToResponse()
	response.OwnerName = userInfo.Nickname
	response.MemberCount = 1 // 新建家庭初始只有创建者

	return response, nil
}

// GetFamilies 获取用户关联的所有家庭
func (s *FamilyService) GetFamilies(userID uint) ([]model.FamilyResponse, error) {
	// 查询用户关联的所有家庭
	families, err := s.repo.FindUserFamilies(userID)
	if err != nil {
		return nil, err
	}

	// 处理空结果
	if len(families) == 0 {
		return []model.FamilyResponse{}, nil
	}

	// 转换为响应模型
	responses := make([]model.FamilyResponse, len(families))
	for i, family := range families {
		// 获取成员数量
		memberCount, _ := s.repo.GetMemberCount(family.ID)
		family.MemberCount = memberCount

		// 获取创建者信息
		user, err := s.userRepo.GetUserByID(family.UserID)
		var ownerName string
		if err != nil || user == nil {
			ownerName = "未知用户"
		} else {
			ownerName = user.Nickname
		}

		// 转换为响应模型
		responses[i] = family.ToResponse()
		responses[i].OwnerName = ownerName
	}

	return responses, nil
}

// GetFamilyByID 根据ID获取家庭详情
func (s *FamilyService) GetFamilyByID(familyID uint) (model.FamilyResponse, error) {
	// 查询家庭信息
	family, err := s.repo.FindByID(familyID)
	if err != nil {
		return model.FamilyResponse{}, err
	}

	// 获取成员数量
	memberCount, _ := s.repo.GetMemberCount(family.ID)
	family.MemberCount = memberCount

	// 获取创建者信息
	user, err := s.userRepo.GetUserByID(family.UserID)
	var ownerName string
	if err != nil || user == nil {
		ownerName = "未知用户"
	} else {
		ownerName = user.Nickname
	}

	// 转换为响应模型
	response := family.ToResponse()
	response.OwnerName = ownerName

	return response, nil
}

// UpdateFamily 更新家庭信息
func (s *FamilyService) UpdateFamily(familyID uint, name, description string) (model.FamilyResponse, error) {
	// 参数验证
	if name == "" {
		return model.FamilyResponse{}, errors.New("家庭名称不能为空")
	}

	// 检查家庭是否存在
	family, err := s.repo.FindByID(familyID)
	if err != nil {
		return model.FamilyResponse{}, err
	}

	// 更新字段
	family.Name = name
	family.Description = description

	// 调用仓库层更新家庭
	if err := s.repo.Update(family); err != nil {
		return model.FamilyResponse{}, err
	}

	// 获取更新后的家庭信息
	updatedFamily, err := s.repo.FindByID(familyID)
	if err != nil {
		return model.FamilyResponse{}, err
	}

	// 获取成员数量
	memberCount, _ := s.repo.GetMemberCount(updatedFamily.ID)
	updatedFamily.MemberCount = memberCount

	// 获取创建者信息
	user, err := s.userRepo.GetUserByID(updatedFamily.UserID)
	var ownerName string
	if err != nil || user == nil {
		ownerName = "未知用户"
	} else {
		ownerName = user.Nickname
	}

	// 转换为响应模型
	response := updatedFamily.ToResponse()
	response.OwnerName = ownerName

	return response, nil
}

// SetFamilyStatus 设置家庭状态
func (s *FamilyService) SetFamilyStatus(familyID uint, isActive bool) error {
	// 检查家庭是否存在
	_, err := s.repo.FindByID(familyID)
	if err != nil {
		return err
	}

	// 调用仓库层更新状态
	return s.repo.SetStatus(familyID, isActive)
}

// DeleteFamily 删除家庭
func (s *FamilyService) DeleteFamily(familyID uint) error {
	// 检查家庭是否存在
	_, err := s.repo.FindByID(familyID)
	if err != nil {
		return err
	}

	// 删除家庭成员
	if err := s.memberRepo.DeleteByOwnerID(familyID); err != nil {
		return err
	}

	// 调用仓库层删除家庭
	return s.repo.Delete(familyID)
}

// JoinFamily 加入家庭
func (s *FamilyService) JoinFamily(userID uint, inviteCode string) (model.FamilyResponse, error) {
	// 验证邀请码
	family, err := s.repo.FindByInviteCode(inviteCode)
	if err != nil {
		return model.FamilyResponse{}, err
	}

	// 检查用户是否已经是家庭成员
	members, err := s.memberRepo.GetFamilyMembers(family.ID)
	if err == nil {
		for _, member := range members {
			if member.UserID == userID {
				return model.FamilyResponse{}, errors.New("您已经是该家庭成员")
			}
		}
	}

	// 创建家庭成员
	member := &model.FamilyMember{
		OwnerID:    family.ID,
		UserID:     userID,
		Permission: "member", // 普通成员权限
	}

	// 添加成员
	memberService := &FamilyMemberService{}
	if err := memberService.AddFamilyMember(member); err != nil {
		return model.FamilyResponse{}, err
	}

	// 获取创建者信息
	user, err := s.userRepo.GetUserByID(family.UserID)
	var ownerName string
	if err != nil || user == nil {
		ownerName = "未知用户"
	} else {
		ownerName = user.Nickname
	}

	// 获取成员数量
	memberCount, _ := s.repo.GetMemberCount(family.ID)

	// 转换为响应模型
	response := family.ToResponse()
	response.OwnerName = ownerName
	response.MemberCount = memberCount

	return response, nil
}
