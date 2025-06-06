package service

import (
	"errors"
	"time"

	"life_app_back/internal/model"
	"life_app_back/internal/repository"
)

// BudgetService 预算服务
type BudgetService struct{}

// GetUserBudgetCategories 获取用户某月的预算列表
func (s *BudgetService) GetUserBudgetCategories(userID uint, year, month int) ([]model.BudgetCategoryResponse, error) {
	repo := &repository.BudgetCategoryRepository{}

	// 获取预算列表
	categories, err := repo.GetBudgetCategoriesByUserAndMonth(userID, year, month)
	if err != nil {
		return nil, err
	}

	// 获取上月统计数据用于计算环比
	prevStats, err := repo.GetPreviousMonthStats(userID, year, month, 0)
	if err != nil {
		// 如果获取环比数据失败，不影响主流程，继续执行
		prevStats = make(map[string]float64)
	}
	// 转换为响应结构并计算环比数据
	var responses []model.BudgetCategoryResponse
	for _, category := range categories {
		response := category.ToResponse()

		// 计算环比变化
		if prevUsage, exists := prevStats[category.Name]; exists {
			if prevUsage > 0 {
				currentUsage := 0.0
				if category.Budget > 0 {
					currentUsage = (category.Spent / category.Budget) * 100
				}
				response.MonthOverMonth = currentUsage - prevUsage
			}
		}

		// 计算实际支出金额
		spent, err := s.CalculateCategorySpent(uint(category.IconID), userID, year, month, false, 0)
		if err == nil {
			response.Spent = spent
			// 重新计算使用百分比
			if category.Budget > 0 {
				response.UsagePercentage = (spent / category.Budget) * 100
			}
			// 重新计算是否超出预算
			response.IsOverBudget = spent > category.Budget
		}

		responses = append(responses, response)
	}

	return responses, nil
}

// GetFamilyBudgetCategories 获取家庭某月的预算列表
func (s *BudgetService) GetFamilyBudgetCategories(familyId int, year, month int) ([]model.BudgetCategoryResponse, error) {
	repo := &repository.BudgetCategoryRepository{}

	// 获取预算列表
	categories, err := repo.GetFamilyBudgetCategoriesByMonth(uint(familyId), year, month)
	if err != nil {
		return nil, err
	}

	// 获取上月统计数据用于计算环比
	prevStats, err := repo.GetPreviousMonthStats(0, year, month, familyId)
	if err != nil {
		// 如果获取环比数据失败，不影响主流程，继续执行
		prevStats = make(map[string]float64)
	}

	// 转换为响应结构并计算环比数据
	var responses []model.BudgetCategoryResponse
	for _, category := range categories {
		response := category.ToResponse()

		// 计算环比变化
		if prevUsage, exists := prevStats[category.Name]; exists {
			if prevUsage > 0 {
				currentUsage := 0.0
				if category.Budget > 0 {
					currentUsage = (category.Spent / category.Budget) * 100
				}
				response.MonthOverMonth = currentUsage - prevUsage
			}
		}

		// 计算实际支出金额
		spent, err := s.CalculateCategorySpent(uint(category.IconID), 0, year, month, true, uint(familyId))
		if err == nil {
			response.Spent = spent
			// 重新计算使用百分比
			if category.Budget > 0 {
				response.UsagePercentage = (spent / category.Budget) * 100
			}
			// 重新计算是否超出预算
			response.IsOverBudget = spent > category.Budget
		}

		responses = append(responses, response)
	}

	return responses, nil
}

// CreateBudgetCategory 创建预算
func (s *BudgetService) CreateBudgetCategory(category *model.BudgetCategory) error {
	repo := &repository.BudgetCategoryRepository{}

	// 设置创建时间
	now := time.Now()
	category.CreatedAt = now
	category.UpdatedAt = now

	// 默认已使用金额为0
	category.Spent = 0

	return repo.CreateBudgetCategory(category)
}

// UpdateBudgetCategory 更新预算
func (s *BudgetService) UpdateBudgetCategory(category *model.BudgetCategory, userID uint) error {
	repo := &repository.BudgetCategoryRepository{}

	// 获取现有预算
	existingCategory, err := repo.GetBudgetCategoryByID(category.ID)
	if err != nil {
		return errors.New("预算不存在")
	}

	// 验证权限（只有自己的预算或家庭预算且自己是家庭成员才能修改）
	if existingCategory.UserID != userID && !existingCategory.IsFamilyBudget {
		return errors.New("无权修改该预算")
	}

	// 如果是家庭预算，还需要验证用户是否属于同一个家庭
	if existingCategory.IsFamilyBudget {
		familyMemberRepo := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepo.GetFamilyMemberByUserIDDirect(userID)
		if err != nil || familyMember.OwnerID != existingCategory.FamilyID {
			return errors.New("无权修改该家庭预算")
		}
	}

	// 更新允许修改的字段
	existingCategory.Name = category.Name
	existingCategory.Description = category.Description
	existingCategory.IconID = category.IconID
	existingCategory.Budget = category.Budget
	existingCategory.ReminderThreshold = category.ReminderThreshold
	existingCategory.UpdatedAt = time.Now()

	return repo.UpdateBudgetCategory(existingCategory)
}

// DeleteBudgetCategory 删除预算
func (s *BudgetService) DeleteBudgetCategory(id uint) error {
	repo := &repository.BudgetCategoryRepository{}
	return repo.DeleteBudgetCategory(id)
}

// CopyFromPreviousMonth 复制上月预算到当前月
func (s *BudgetService) CopyFromPreviousMonth(userID uint, targetYear, targetMonth int, isFamily bool) error {
	// 计算上月年月
	sourceMonth := targetMonth - 1
	sourceYear := targetYear
	if sourceMonth == 0 {
		sourceMonth = 12
		sourceYear--
	}

	repo := &repository.BudgetCategoryRepository{}
	return repo.CopyFromPreviousMonth(userID, targetYear, targetMonth, sourceYear, sourceMonth, isFamily)
}

// UpdateBudgetSpent 更新预算已使用金额
func (s *BudgetService) UpdateBudgetSpent(categoryID uint, amount float64) error {
	repo := &repository.BudgetCategoryRepository{}

	// 获取预算
	category, err := repo.GetBudgetCategoryByID(categoryID)
	if err != nil {
		return errors.New("预算不存在")
	}

	// 更新已使用金额
	category.Spent += amount
	if category.Spent < 0 {
		category.Spent = 0
	}

	return repo.UpdateBudgetCategory(category)
}

// CalculateCategorySpent 计算预算类别的实际支出金额
func (s *BudgetService) CalculateCategorySpent(categoryID uint, userID uint, year int, month int, isFamilyBudget bool, familyID uint) (float64, error) {
	// 计算日期范围
	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := time.Date(year, time.Month(month+1), 0, 23, 59, 59, 0, time.Local)

	// 构建查询
	query := model.DB.Model(&model.Transaction{}).
		Where("type = ? AND date BETWEEN ? AND ? AND icon_id = ?",
			"expense", startDate, endDate, categoryID)

	// 根据是否为家庭预算添加不同的条件
	if isFamilyBudget {
		query = query.Where("family_id = ?", familyID)
	} else {
		query = query.Where("user_id = ? and family_id =0", userID)
	}

	// 计算总支出
	var totalSpent float64
	err := query.Select("COALESCE(SUM(amount), 0)").Scan(&totalSpent).Error

	return totalSpent, err
}
