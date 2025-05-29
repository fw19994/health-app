package service

import (
	"errors"
	"time"

	"life_app_back/internal/model"
	"life_app_back/internal/repository"
)

// SavingsGoalService 储蓄目标服务
type SavingsGoalService struct{}

// GetUserSavingsGoals 获取用户的储蓄目标列表
func (s *SavingsGoalService) GetUserSavingsGoals(userID uint) ([]model.SavingsGoalResponse, error) {
	repo := &repository.SavingsGoalRepository{}

	// 获取个人储蓄目标
	goals, err := repo.GetSavingsGoalsByUser(userID)
	if err != nil {
		return nil, err
	}

	// 转换为响应结构
	var responses []model.SavingsGoalResponse
	for _, goal := range goals {
		// 查询与该储蓄目标相关的收入交易总额
		var totalIncome float64
		query := model.DB.Model(&model.Transaction{}).Where("user_id = ? AND type = ? AND goal_id = ?", userID, model.Income, goal.ID)
		query.Select("COALESCE(SUM(amount), 0)").Scan(&totalIncome)

		// 更新当前金额为收入交易总额
		goal.CurrentAmount = totalIncome
		responses = append(responses, goal.ToResponse())
	}

	return responses, nil
}

// GetFamilySavingsGoals 获取家庭的储蓄目标列表
func (s *SavingsGoalService) GetFamilySavingsGoals(userID uint) ([]model.SavingsGoalResponse, error) {
	repo := &repository.SavingsGoalRepository{}

	// 先获取用户所在的家庭ID
	familyMemberRepo := &repository.FamilyMemberRepository{}
	familyMember, err := familyMemberRepo.GetFamilyMemberByUserIDDirect(userID)
	if err != nil {
		return nil, errors.New("未找到用户所属家庭")
	}

	familyID := familyMember.OwnerID

	// 获取家庭储蓄目标
	goals, err := repo.GetFamilySavingsGoals(familyID)
	if err != nil {
		return nil, err
	}

	// 转换为响应结构
	var responses []model.SavingsGoalResponse
	for _, goal := range goals {
		// 查询与该储蓄目标相关的家庭收入交易总额
		var totalIncome float64
		query := model.DB.Model(&model.Transaction{}).Where("family_id = ? AND type = ? AND goal_id = ?", familyID, model.Income, goal.ID)
		query.Select("COALESCE(SUM(amount), 0)").Scan(&totalIncome)

		// 更新当前金额为收入交易总额
		goal.CurrentAmount = totalIncome
		responses = append(responses, goal.ToResponse())
	}

	return responses, nil
}

// GetAllSavingsGoalsForUser 获取用户的所有储蓄目标（包括个人和家庭）
func (s *SavingsGoalService) GetAllSavingsGoalsForUser(userID uint) ([]model.SavingsGoalResponse, error) {
	// 获取个人储蓄目标
	personalGoals, err := s.GetUserSavingsGoals(userID)
	if err != nil {
		return nil, err
	}

	// 获取家庭储蓄目标
	familyGoals, err := s.GetFamilySavingsGoals(userID)
	if err != nil {
		// 如果获取家庭目标失败，不影响主流程，只返回个人目标
		return personalGoals, nil
	}

	// 合并目标列表
	return append(personalGoals, familyGoals...), nil
}

// CreateSavingsGoal 创建储蓄目标
func (s *SavingsGoalService) CreateSavingsGoal(goal *model.SavingsGoal) error {
	repo := &repository.SavingsGoalRepository{}

	// 设置创建时间
	now := time.Now()
	goal.CreatedAt = now
	goal.UpdatedAt = now

	// 如果没有设置当前金额，默认为0
	if goal.CurrentAmount < 0 {
		goal.CurrentAmount = 0
	}

	// 验证目标日期是否在未来
	if goal.TargetDate.Before(now) {
		return errors.New("目标日期必须在未来")
	}

	// 如果是家庭目标，验证用户是否属于该家庭
	if goal.IsFamilyGoal && goal.FamilyID > 0 {
		familyMemberRepo := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepo.GetFamilyMemberByUserIDDirect(goal.UserID)
		if err != nil || familyMember.OwnerID != goal.FamilyID {
			return errors.New("无权为该家庭创建储蓄目标")
		}
	}

	return repo.CreateSavingsGoal(goal)
}

// UpdateSavingsGoal 更新储蓄目标
func (s *SavingsGoalService) UpdateSavingsGoal(goal *model.SavingsGoal, userID uint) error {
	repo := &repository.SavingsGoalRepository{}

	// 获取现有储蓄目标
	existingGoal, err := repo.GetSavingsGoalByID(goal.ID)
	if err != nil {
		return errors.New("储蓄目标不存在")
	}

	// 验证权限（只有自己的目标或家庭目标且自己是家庭成员才能修改）
	if existingGoal.UserID != userID && !existingGoal.IsFamilyGoal {
		return errors.New("无权修改该储蓄目标")
	}

	// 如果是家庭目标，还需要验证用户是否属于同一个家庭
	if existingGoal.IsFamilyGoal {
		familyMemberRepo := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepo.GetFamilyMemberByUserIDDirect(userID)
		if err != nil || familyMember.OwnerID != existingGoal.FamilyID {
			return errors.New("无权修改该家庭储蓄目标")
		}
	}

	// 更新允许修改的字段
	existingGoal.Name = goal.Name
	existingGoal.IconID = goal.IconID
	existingGoal.TargetAmount = goal.TargetAmount
	existingGoal.MonthlyTarget = goal.MonthlyTarget
	existingGoal.TargetDate = goal.TargetDate
	existingGoal.Note = goal.Note
	existingGoal.UpdatedAt = time.Now()
	existingGoal.Description = goal.Description
	// 验证目标日期是否在未来
	if existingGoal.TargetDate.Before(time.Now()) {
		return errors.New("目标日期必须在未来")
	}

	// 不允许直接修改当前金额，应该通过UpdateProgress方法修改

	return repo.UpdateSavingsGoal(existingGoal)
}

// DeleteSavingsGoal 删除储蓄目标
func (s *SavingsGoalService) DeleteSavingsGoal(id, userID uint) error {
	repo := &repository.SavingsGoalRepository{}

	// 获取储蓄目标
	goal, err := repo.GetSavingsGoalByID(id)
	if err != nil {
		return errors.New("储蓄目标不存在")
	}

	// 验证权限（只有自己的目标或家庭目标且自己是家庭成员才能删除）
	if goal.UserID != userID && !goal.IsFamilyGoal {
		return errors.New("无权删除该储蓄目标")
	}

	// 如果是家庭目标，还需要验证用户是否属于同一个家庭
	if goal.IsFamilyGoal {
		familyMemberRepo := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepo.GetFamilyMemberByUserIDDirect(userID)
		if err != nil || familyMember.OwnerID != goal.FamilyID {
			return errors.New("无权删除该家庭储蓄目标")
		}
	}

	return repo.DeleteSavingsGoal(id)
}

// UpdateSavingsGoalProgress 更新储蓄目标进度
func (s *SavingsGoalService) UpdateSavingsGoalProgress(id, userID uint, amount float64) error {
	repo := &repository.SavingsGoalRepository{}

	// 获取储蓄目标
	goal, err := repo.GetSavingsGoalByID(id)
	if err != nil {
		return errors.New("储蓄目标不存在")
	}

	// 验证权限（只有自己的目标或家庭目标且自己是家庭成员才能更新）
	if goal.UserID != userID && !goal.IsFamilyGoal {
		return errors.New("无权更新该储蓄目标进度")
	}

	// 如果是家庭目标，还需要验证用户是否属于同一个家庭
	if goal.IsFamilyGoal {
		familyMemberRepo := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepo.GetFamilyMemberByUserIDDirect(userID)
		if err != nil || familyMember.OwnerID != goal.FamilyID {
			return errors.New("无权更新该家庭储蓄目标进度")
		}
	}

	// 更新当前金额
	goal.CurrentAmount += amount

	// 如果达到或超过目标金额，则更新状态为已完成
	if goal.CurrentAmount >= goal.TargetAmount && goal.Status != model.SavingsGoalStatusCompleted {
		goal.Status = model.SavingsGoalStatusCompleted

		// 设置完成时间
		now := time.Now()
		goal.CompletedAt = &now
	}

	// 保存更新
	goal.UpdatedAt = time.Now()
	return repo.UpdateSavingsGoal(goal)
}

// UpdateSavingsGoalStatus 更新储蓄目标状态
func (s *SavingsGoalService) UpdateSavingsGoalStatus(id, userID uint, status string) error {
	repo := &repository.SavingsGoalRepository{}

	// 验证状态值是否有效
	if status != model.SavingsGoalStatusInProgress &&
		status != model.SavingsGoalStatusCompleted &&
		status != model.SavingsGoalStatusDeleted {
		return errors.New("无效的状态值")
	}

	// 获取储蓄目标
	goal, err := repo.GetSavingsGoalByID(id)
	if err != nil {
		return errors.New("储蓄目标不存在")
	}

	// 验证权限（只有自己的目标或家庭目标且自己是家庭成员才能更新）
	if goal.UserID != userID && !goal.IsFamilyGoal {
		return errors.New("无权更新该储蓄目标状态")
	}

	// 如果是家庭目标，还需要验证用户是否属于同一个家庭
	if goal.IsFamilyGoal {
		familyMemberRepo := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepo.GetFamilyMemberByUserIDDirect(userID)
		if err != nil || familyMember.OwnerID != goal.FamilyID {
			return errors.New("无权更新该家庭储蓄目标状态")
		}
	}

	// 更新状态
	goal.Status = status

	// 如果状态变为已完成，设置完成时间
	if status == model.SavingsGoalStatusCompleted {
		now := time.Now()
		goal.CompletedAt = &now
	} else if status == model.SavingsGoalStatusInProgress {
		// 如果重新设置为进行中，清除完成时间
		goal.CompletedAt = nil
	}

	// 更新时间戳
	goal.UpdatedAt = time.Now()

	return repo.UpdateSavingsGoal(goal)
}

// GetMonthlyContributionRequirement 计算每月需要存款金额以实现目标
func (s *SavingsGoalService) GetMonthlyContributionRequirement(goalID, userID uint) (float64, error) {
	repo := &repository.SavingsGoalRepository{}

	// 获取储蓄目标
	goal, err := repo.GetSavingsGoalByID(goalID)
	if err != nil {
		return 0, errors.New("储蓄目标不存在")
	}

	// 验证权限
	if goal.UserID != userID && !goal.IsFamilyGoal {
		return 0, errors.New("无权访问该储蓄目标")
	}

	// 如果是家庭目标，验证用户是否属于同一个家庭
	if goal.IsFamilyGoal {
		familyMemberRepo := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepo.GetFamilyMemberByUserIDDirect(userID)
		if err != nil || familyMember.OwnerID != goal.FamilyID {
			return 0, errors.New("无权访问该家庭储蓄目标")
		}
	}

	// 计算剩余金额
	remainingAmount := goal.TargetAmount - goal.CurrentAmount
	if remainingAmount <= 0 {
		return 0, nil // 目标已完成
	}

	// 计算剩余月数
	now := time.Now()
	monthsLeft := (goal.TargetDate.Year()-now.Year())*12 + int(goal.TargetDate.Month()-now.Month())
	if monthsLeft <= 0 {
		return remainingAmount, nil // 目标日期已过，需要一次性存入
	}

	// 计算每月需要存款金额
	return remainingAmount / float64(monthsLeft), nil
}
