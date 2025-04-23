package service

import (
	"errors"
	"math/rand"
	"time"

	"life_app_back/internal/model"
	"life_app_back/internal/repository"
)

// FamilyMemberService 家庭成员服务
type FamilyMemberService struct{}

// GetFamilyMembers 获取家庭成员列表
func (s *FamilyMemberService) GetFamilyMembers(ownerID, currentUserID uint) ([]model.FamilyMemberResponse, error) {
	repo := &repository.FamilyMemberRepository{}
	members, err := repo.GetFamilyMembers(ownerID)
	if err != nil {
		return nil, err
	}
	
	var responses []model.FamilyMemberResponse
	for _, member := range members {
		member.IsCurrentUser = (member.UserID == currentUserID)
		responses = append(responses, member.ToResponse())
	}
	
	return responses, nil
}

// GetUserFamilyMembers 获取当前用户所属家庭的所有成员
func (s *FamilyMemberService) GetUserFamilyMembers(userID uint) ([]model.FamilyMemberResponse, error) {
	repo := &repository.FamilyMemberRepository{}
	db := model.DB
	
	// 直接检查用户是否存在于任何家庭（无论是作为家主还是成员）
	var member model.FamilyMember
	if err := db.Where("user_id = ? AND user_id != 0", userID).First(&member).Error; err != nil {
		// 用户不在任何家庭中，创建一个新的家庭记录，用户为家主
		var user model.User
		if err := db.First(&user, userID).Error; err != nil {
			return []model.FamilyMemberResponse{}, errors.New("获取用户信息失败")
		}
		
		// 创建新的家庭成员记录
		newMember := &model.FamilyMember{
			OwnerID:     userID,  // 自己是家主
			UserID:      userID,  // 自己是成员
			Name:        user.Nickname,
			Phone:       user.Phone,
			Role:        "家庭主账户",
			AvatarURL:   user.Avatar,
			Permission:  "管理员",
			JoinTime:    time.Now(),
		}
		
		// 保存到数据库
		if err := repo.CreateFamilyMember(newMember); err != nil {
			return []model.FamilyMemberResponse{}, errors.New("创建家庭失败: " + err.Error())
		}
		
		// 将自己标记为当前用户
		newMember.IsCurrentUser = true
		return []model.FamilyMemberResponse{newMember.ToResponse()}, nil
	}
	
	// 用户已存在于某个家庭中，获取该家庭的所有成员
	ownerID := member.OwnerID
	return s.GetFamilyMembers(ownerID, userID)
}

// AddFamilyMember 添加家庭成员
func (s *FamilyMemberService) AddFamilyMember(member *model.FamilyMember) error {
	// 设置加入时间为当前时间
	member.JoinTime = time.Now()
	
	repo := &repository.FamilyMemberRepository{}
	return repo.CreateFamilyMember(member)
}

// UpdateFamilyMember 更新家庭成员
func (s *FamilyMemberService) UpdateFamilyMember(member *model.FamilyMember) error {
	repo := &repository.FamilyMemberRepository{}
	// 确保成员存在
	existingMember, err := repo.GetFamilyMemberByID(member.ID)
	if err != nil {
		return errors.New("成员不存在")
	}
	
	// 更新成员信息
	existingMember.Name = member.Name
	existingMember.Nickname = member.Nickname
	existingMember.Description = member.Description
	existingMember.Role = member.Role
	existingMember.Gender = member.Gender
	existingMember.Permission = member.Permission
	existingMember.AvatarURL = member.AvatarURL
	
	return repo.UpdateFamilyMember(existingMember)
}

// RemoveFamilyMember 删除家庭成员
func (s *FamilyMemberService) RemoveFamilyMember(id, currentUserID uint) error {
	repo := &repository.FamilyMemberRepository{}
	
	// 确保成员存在
	member, err := repo.GetFamilyMemberByID(id)
	if err != nil {
		return errors.New("成员不存在")
	}
	
	// 检查是否为家主角色，家主不能被删除
	if member.Role == "家庭主账户" {
		return errors.New("家主不能被移除")
	}
	
	// 检查当前用户是否有权限删除该成员
	// 1. 找到当前用户所属的家庭成员记录
	currentMember, err := repo.GetFamilyMemberByUserIDDirect(currentUserID)
	if err != nil {
		return errors.New("无法验证权限")
	}
	
	// 2. 检查是否是同一家庭 或 当前用户是管理员
	if currentMember.OwnerID != member.OwnerID && currentMember.Permission != "管理员" {
		return errors.New("无权操作该成员")
	}
	
	// 检查是否为当前用户（不能删除自己）
	if member.UserID == currentUserID {
		return errors.New("不能删除自己")
	}
	
	return repo.DeleteFamilyMember(id)
}

// CreateInvitation 创建家庭邀请
func (s *FamilyMemberService) CreateInvitation(ownerID uint) (*model.Invitation, error) {
	// 生成随机邀请码
	inviteCode := generateInviteCode(6)
	
	// 设置过期时间（7天后）
	expireTime := time.Now().Add(7 * 24 * time.Hour)
	
	invitation := &model.Invitation{
		OwnerID:    ownerID,
		InviteCode: inviteCode,
		ExpireTime: expireTime,
	}
	
	repo := &repository.FamilyMemberRepository{}
	if err := repo.CreateInvitation(invitation); err != nil {
		return nil, err
	}
	
	return invitation, nil
}

// GetFamilyRoles 获取家庭角色
func (s *FamilyMemberService) GetFamilyRoles() map[string]interface{} {
	return map[string]interface{}{
		"roles": []string{
			"家庭主账户", "配偶", "子女", "其他",
		},
		"roleColors": map[string]string{
			"家庭主账户": "#7A29FF", // 紫色
			"配偶":     "#FF5286", // 粉色
			"子女":     "#4D7CFE", // 蓝色
			"其他":     "#7A29FF", // 紫色
		},
		"permissions": []string{
			"管理员", "编辑者", "查看者",
		},
	}
}

// 生成随机邀请码
func generateInviteCode(length int) string {
	const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	
	rand.Seed(time.Now().UnixNano())
	code := make([]byte, length)
	for i := range code {
		code[i] = charset[rand.Intn(len(charset))]
	}
	
	return string(code)
}
