package repository

import (
	"life_app_back/internal/model"
)

// SavingsGoalRepository 储蓄目标仓库
type SavingsGoalRepository struct{}

// GetSavingsGoalsByUser 获取用户的储蓄目标列表
func (r *SavingsGoalRepository) GetSavingsGoalsByUser(userID uint) ([]model.SavingsGoal, error) {
	var goals []model.SavingsGoal
	db := model.DB
	if err := db.Where("user_id = ? AND is_family_goal = ? AND status != ?",
		userID, false, model.SavingsGoalStatusDeleted).Order("created_at DESC").
		Find(&goals).Error; err != nil {
		return nil, err
	}
	return goals, nil
}

// GetFamilySavingsGoals 获取家庭的储蓄目标列表
func (r *SavingsGoalRepository) GetFamilySavingsGoals(familyID uint) ([]model.SavingsGoal, error) {
	var goals []model.SavingsGoal
	db := model.DB
	if err := db.Where("family_id = ? AND is_family_goal = ? AND status != ?",
		familyID, true, model.SavingsGoalStatusDeleted).Order("created_at DESC").
		Find(&goals).Error; err != nil {
		return nil, err
	}
	return goals, nil
}

// GetSavingsGoalsByStatus 根据状态获取用户的储蓄目标列表
func (r *SavingsGoalRepository) GetSavingsGoalsByStatus(userID uint, status string) ([]model.SavingsGoal, error) {
	var goals []model.SavingsGoal
	db := model.DB
	if err := db.Where("user_id = ? AND status = ?", userID, status).
		Find(&goals).Order("created_at DESC").Error; err != nil {
		return nil, err
	}
	return goals, nil
}

// GetFamilySavingsGoalsByStatus 根据状态获取家庭的储蓄目标列表
func (r *SavingsGoalRepository) GetFamilySavingsGoalsByStatus(familyID uint, status string) ([]model.SavingsGoal, error) {
	var goals []model.SavingsGoal
	db := model.DB
	if err := db.Where("family_id = ? AND is_family_goal = ? AND status = ?",
		familyID, true, status).Order("created_at DESC").
		Find(&goals).Error; err != nil {
		return nil, err
	}
	return goals, nil
}

// GetSavingsGoalByID 根据ID获取储蓄目标
func (r *SavingsGoalRepository) GetSavingsGoalByID(id uint) (*model.SavingsGoal, error) {
	var goal model.SavingsGoal
	db := model.DB
	if err := db.First(&goal, id).Error; err != nil {
		return nil, err
	}
	return &goal, nil
}

// CreateSavingsGoal 创建储蓄目标
func (r *SavingsGoalRepository) CreateSavingsGoal(goal *model.SavingsGoal) error {
	db := model.DB
	return db.Create(goal).Error
}

// UpdateSavingsGoal 更新储蓄目标
func (r *SavingsGoalRepository) UpdateSavingsGoal(goal *model.SavingsGoal) error {
	db := model.DB
	return db.Save(goal).Error
}

// DeleteSavingsGoal 删除储蓄目标
func (r *SavingsGoalRepository) DeleteSavingsGoal(id uint) error {
	db := model.DB
	return db.Delete(&model.SavingsGoal{}, id).Error
}

// GetFamilyGoalsByUserID 通过用户ID获取该用户所在家庭的所有储蓄目标
func (r *SavingsGoalRepository) GetFamilyGoalsByUserID(userID uint) ([]model.SavingsGoal, error) {
	var goals []model.SavingsGoal
	db := model.DB

	// 先查询用户所在的家庭ID
	var familyMember model.FamilyMember
	if err := db.Where("user_id = ?", userID).First(&familyMember).Error; err != nil {
		return nil, err
	}

	// 根据家庭ID查询储蓄目标
	if err := db.Where("family_id = ? AND is_family_goal = ?", familyMember.OwnerID, true).Order("created_at DESC").Find(&goals).Error; err != nil {
		return nil, err
	}

	return goals, nil
}
