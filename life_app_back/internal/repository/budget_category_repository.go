package repository

import (
	"life_app_back/internal/model"
)

// BudgetCategoryRepository 预算仓库
type BudgetCategoryRepository struct{}

// GetBudgetCategoriesByUserAndMonth 获取用户某月的预算列表
func (r *BudgetCategoryRepository) GetBudgetCategoriesByUserAndMonth(userID uint, year, month int) ([]model.BudgetCategory, error) {
	var categories []model.BudgetCategory
	db := model.DB
	if err := db.Where("user_id = ? AND year = ? AND month = ? AND is_family_budget = ?", userID, year, month, false).Order("created_at desc").Find(&categories).Error; err != nil {
		return nil, err
	}
	return categories, nil
}

// GetFamilyBudgetCategoriesByMonth 获取家庭某月的预算列表
func (r *BudgetCategoryRepository) GetFamilyBudgetCategoriesByMonth(familyID uint, year, month int) ([]model.BudgetCategory, error) {
	var categories []model.BudgetCategory
	db := model.DB
	if err := db.Debug().Where("family_id = ? AND year = ? AND month = ? AND is_family_budget = ?", familyID, year, month, true).Order("created_at desc").Find(&categories).Error; err != nil {
		return nil, err
	}
	return categories, nil
}

// GetBudgetCategoryByID 根据ID获取预算
func (r *BudgetCategoryRepository) GetBudgetCategoryByID(id uint) (*model.BudgetCategory, error) {
	var category model.BudgetCategory
	db := model.DB
	if err := db.First(&category, id).Error; err != nil {
		return nil, err
	}
	return &category, nil
}

// CreateBudgetCategory 创建预算
func (r *BudgetCategoryRepository) CreateBudgetCategory(category *model.BudgetCategory) error {
	db := model.DB
	return db.Create(category).Error
}

// UpdateBudgetCategory 更新预算
func (r *BudgetCategoryRepository) UpdateBudgetCategory(category *model.BudgetCategory) error {
	db := model.DB
	return db.Save(category).Error
}

// DeleteBudgetCategory 删除预算
func (r *BudgetCategoryRepository) DeleteBudgetCategory(id uint) error {
	db := model.DB
	return db.Delete(&model.BudgetCategory{}, id).Error
}

// CopyFromPreviousMonth 复制上月预算到当前月
func (r *BudgetCategoryRepository) CopyFromPreviousMonth(userID uint, targetYear, targetMonth, sourceYear, sourceMonth int, isFamily bool) error {
	db := model.DB

	// 获取源月份的预算
	var sourceCategories []model.BudgetCategory
	query := db.Where("year = ? AND month = ?", sourceYear, sourceMonth)

	if isFamily {
		// 从属于同一个家庭的预算
		query = query.Where("is_family_budget = ? AND family_id = (SELECT family_id FROM budget_categories WHERE user_id = ? AND is_family_budget = true LIMIT 1)", true, userID)
	} else {
		// 个人预算
		query = query.Where("user_id = ? AND is_family_budget = ?", userID, false)
	}

	if err := query.Find(&sourceCategories).Error; err != nil {
		return err
	}

	// 开始事务
	tx := db.Begin()

	// 复制预算到目标月份
	for _, source := range sourceCategories {
		newCategory := model.BudgetCategory{
			UserID:            source.UserID,
			IsFamilyBudget:    source.IsFamilyBudget,
			FamilyID:          source.FamilyID,
			Name:              source.Name,
			Description:       source.Description,
			IconID:            source.IconID,
			Budget:            source.Budget,
			Spent:             0, // 新月份已使用金额初始化为0
			Year:              targetYear,
			Month:             targetMonth,
			ReminderThreshold: source.ReminderThreshold,
		}

		if err := tx.Create(&newCategory).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	return tx.Commit().Error
}

// GetPreviousMonthStats 获取上月预算统计，用于计算环比
func (r *BudgetCategoryRepository) GetPreviousMonthStats(userID uint, year, month int, familyId int) (map[string]float64, error) {
	// 计算上个月的年月
	prevMonth := month - 1
	prevYear := year
	if prevMonth == 0 {
		prevMonth = 12
		prevYear--
	}

	var categories []model.BudgetCategory
	db := model.DB
	var query = db.Where("year = ? AND month = ?", prevYear, prevMonth)

	if familyId > 0 {
		query = query.Where("is_family_budget = ? AND family_id = ?", true, familyId)
	} else {
		query = query.Where("user_id = ? AND is_family_budget = ?", userID, false)
	}

	if err := query.Find(&categories).Error; err != nil {
		return nil, err
	}

	// 构建名称到使用百分比的映射
	result := make(map[string]float64)
	for _, cat := range categories {
		var percentage float64 = 0
		if cat.Budget > 0 {
			percentage = (cat.Spent / cat.Budget) * 100
		}
		result[cat.Name] = percentage
	}

	return result, nil
}
