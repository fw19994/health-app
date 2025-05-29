package repository

import (
	"errors"
	"fmt"
	"life_app_back/internal/model"
	"time"
)

// FinanceRepository 财务数据仓库
type FinanceRepository struct{}

// AddTransaction 添加一笔交易记录
func (r FinanceRepository) AddTransaction(transaction *model.Transaction) error {
	// 使用 GORM 创建记录
	result := model.DB.Create(transaction)
	return result.Error
}

// GetRecentTransactions 获取近期交易记录
func (r FinanceRepository) GetRecentTransactions(userID uint, transactionType string, limit, memberId, familyId int) ([]model.Transaction, error) {
	var transactions []model.Transaction

	// 构建查询
	query := model.DB.Where("1 = 1")

	// 如果指定了交易类型，添加交易类型过滤条件
	if transactionType == "expense" || transactionType == "income" {
		query = query.Where("type = ?", transactionType)
	}
	if memberId > 0 {
		query = query.Where("recorder_id = ?", memberId)
	}
	if familyId > 0 {
		query = query.Where("family_id = ?", familyId)
	}
	if memberId == 0 && familyId == 0 {
		query = query.Where("user_id = ?", userID)
	}
	// 按时间倒序排序并限制结果数量
	result := query.Order("date DESC").Limit(limit).Find(&transactions)

	return transactions, result.Error
}

// GetTransactionsByFilters 根据筛选条件获取交易记录
func (r FinanceRepository) GetTransactionsByFilters(params model.TransactionQueryParams) (int64, error) {
	var count int64

	// 构建基础查询
	query := model.DB.Model(&model.Transaction{})

	// 添加用户ID筛选条件（必须）
	query = query.Where("user_id = ?", params.UserID)

	// 添加可选的筛选条件
	if params.Type != "" {
		query = query.Where("type = ?", params.Type)
	}

	//if params.CategoryID > 0 {
	//	query = query.Where("category_id = ?", params.CategoryID)
	//}
	if len(params.CategoryID) > 0 {
		query = query.Where("icon_id in (?)", params.CategoryID)
	}

	if params.MemberID > 0 {
		query = query.Where("recorder_id = ?", params.MemberID)
	}

	// 添加日期范围筛选
	if !params.StartDate.IsZero() {
		query = query.Where("date >= ?", params.StartDate)
	}

	if !params.EndDate.IsZero() {
		query = query.Where("date <= ?", params.EndDate)
	}

	// 获取记录总数
	err := query.Count(&count).Error
	if err != nil {
		return 0, err
	}

	return count, err
}

// GetTransactionStats 获取交易统计数据
func (r FinanceRepository) GetTransactionStats(memberID uint, startDate, endDate time.Time, types string, iconIds []int, userId uint) (int, float64, float64, error) {
	var totalCount int64
	var totalIncome, totalExpense float64
	baseQuery := model.DB.Debug().Model(&model.Transaction{}).Where(" 1=1")

	if memberID > 0 {
		// 构建基础查询
		baseQuery = baseQuery.Where("recorder_id = ?", memberID)

	} else {
		baseQuery = baseQuery.Where("user_id = ?", userId)

	}

	// 添加日期范围筛选
	if !startDate.IsZero() {
		baseQuery = baseQuery.Where("date >= ?", startDate)
	}

	if !endDate.IsZero() {
		baseQuery = baseQuery.Where("date <= ?", endDate)
	}

	if types != "" {
		baseQuery = baseQuery.Where("type = ?", types)
	}
	if len(iconIds) > 0 {
		baseQuery = baseQuery.Where("icon_id IN (?)", iconIds)
	}
	// 获取总记录数
	err := baseQuery.Count(&totalCount).Error
	if err != nil {
		return 0, 0, 0, err
	}
	baseQuery1 := *baseQuery
	// 获取总收入
	err = baseQuery1.Where("type = ?", model.Income).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalIncome).Error
	if err != nil {
		return 0, 0, 0, err
	}
	baseQuery2 := *baseQuery

	// 获取总支出
	err = baseQuery2.Where("type = ?", model.Expense).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalExpense).Error
	if err != nil {
		return 0, 0, 0, err
	}
	totalExpense, err = r.getTotalExpense(memberID, startDate, endDate, types, iconIds, userId)
	if err != nil {
		return 0, 0, 0, err
	}
	return int(totalCount), totalIncome, totalExpense, nil
}

// GetTransactionStats 获取交易统计数据
func (r FinanceRepository) getTotalExpense(memberID uint, startDate, endDate time.Time, types string, iconIds []int, userId uint) (float64, error) {
	totalExpense := 0.0
	baseQuery := model.DB.Debug().Model(&model.Transaction{}).Where(" 1=1")

	if memberID > 0 {
		// 构建基础查询
		baseQuery = baseQuery.Where("recorder_id = ? ", memberID)

	} else {
		baseQuery = baseQuery.Where("user_id = ?", userId)

	}

	// 添加日期范围筛选
	if !startDate.IsZero() {
		baseQuery = baseQuery.Where("date >= ?", startDate)
	}

	if !endDate.IsZero() {
		baseQuery = baseQuery.Where("date <= ?", endDate)
	}

	if types != "" {
		baseQuery = baseQuery.Where("type = ?", types)
	}
	if len(iconIds) > 0 {
		baseQuery = baseQuery.Where("icon_id IN (?)", iconIds)
	}

	// 获取总支出
	err := baseQuery.Where("type = ?", model.Expense).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalExpense).Error
	if err != nil {
		return 0, err
	}

	return totalExpense, nil
}

// GetTransactionsByDate 按日期分组获取交易记录
func (r FinanceRepository) GetTransactionsByDate(userID uint, startDate, endDate time.Time, limit int, page int, types string, memberID uint, categoryID []int) ([]model.TransactionDateGroup, error) {
	var result []model.TransactionDateGroup

	// 获取日期列表
	var dates []time.Time
	query := model.DB.Model(&model.Transaction{}).Debug()
	querySql := "1=1"
	queryArgs := make([]interface{}, 0)
	if types != "" {
		querySql += " and type = ?"
		queryArgs = append(queryArgs, types)
	}
	if len(categoryID) > 0 {
		querySql += " and icon_id IN (?) "
		queryArgs = append(queryArgs, categoryID)
	}

	if memberID > 0 {
		querySql += " and recorder_id = ? "
		queryArgs = append(queryArgs, memberID)
	} else {
		querySql += " and user_id = ? "
		queryArgs = append(queryArgs, userID)
	}

	if querySql != "1=1" {
		query = query.Where(querySql, queryArgs...)
	}
	err := query.
		Where(" date BETWEEN ? AND ?", startDate, endDate).
		Select("DISTINCT DATE(date) as date").
		Order("date DESC").
		Offset((page-1)*limit).Limit(limit).
		Pluck("DATE(date)", &dates).Error
	if err != nil {
		return nil, err
	}

	// 对每个日期查询交易记录
	for _, date := range dates {
		var dayStart = time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
		var dayEnd = time.Date(date.Year(), date.Month(), date.Day(), 23, 59, 59, 999999999, date.Location())
		query1 := model.DB.Debug()
		var transactions []model.Transaction
		if querySql != "1=1" {
			query1 = query1.Where(querySql, queryArgs...)
		}
		err := query1.Where(" date BETWEEN ? AND ?", dayStart, dayEnd).
			Order("date DESC").
			Find(&transactions).Error
		if err != nil {
			return nil, err
		}

		// 计算日收入和支出
		var dayIncome, dayExpense float64
		for _, t := range transactions {
			if t.Type == model.Income {
				dayIncome += t.Amount
			} else {
				dayExpense += t.Amount
			}
		}

		// 添加到结果
		result = append(result, model.TransactionDateGroup{
			Date:         dayStart,
			Transactions: transactions,
			TotalIncome:  dayIncome,
			TotalExpense: dayExpense,
			NetAmount:    dayIncome - dayExpense,
		})
	}

	return result, nil
}

// GetTransactionTrend 获取交易趋势数据
func (r FinanceRepository) GetTransactionTrend(userID uint, startDate, endDate time.Time, interval string, memberID uint, CategoryID []int) ([]model.TrendDataPoint, error) {
	var result []model.TrendDataPoint

	// 根据不同的时间间隔构建不同的SQL
	var timeFormat, groupBy string
	switch interval {
	case "day":
		timeFormat = "2006-01-02"
		groupBy = "DATE_FORMAT(date, '%Y-%m-%d')"
	case "week":
		timeFormat = "2006-W%V"       // ISO周格式
		groupBy = "YEARWEEK(date, 1)" // ISO周格式
	case "month":
		timeFormat = "2006-01"
		groupBy = "DATE_FORMAT(date, '%Y-%m')"
	default:
		return nil, errors.New("不支持的时间间隔类型")
	}
	fmt.Println(timeFormat)
	// 使用原生SQL查询聚合数据
	type AggregateResult struct {
		Date    string
		Income  float64
		Expense float64
	}

	sql := " %s AS date,SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) AS income,SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS expense"
	sql = fmt.Sprintf(sql, groupBy)

	baseQuery := model.DB.Debug().Model(&model.Transaction{}).Where(" date BETWEEN ? AND ?", startDate, endDate)
	if memberID > 0 {
		baseQuery = baseQuery.Where("recorder_id IN (?)", memberID)
	} else {
		baseQuery = baseQuery.Where("user_id = ? ", userID)
	}

	if len(CategoryID) > 0 {
		baseQuery = baseQuery.Where("icon_id IN (?)", CategoryID)
	}

	baseQuery.Select(sql).Group(groupBy).Order("date").Scan(&result)
	var aggregates []AggregateResult
	// 生成SQL查询

	// 转换为响应格式
	for _, a := range aggregates {

		result = append(result, model.TrendDataPoint{
			Label:     a.Date,
			Income:    a.Income,
			Expense:   a.Expense,
			NetAmount: a.Income - a.Expense,
			Date:      a.Date,
		})
	}

	return result, nil
}

// GetMemberExpenseStats 获取成员支出统计
func (r FinanceRepository) GetMemberExpenseStats(userID uint, startDate, endDate time.Time) ([]model.MemberExpenseStats, error) {
	var result []model.MemberExpenseStats

	// 使用原生SQL查询聚合数据
	sql := `
		SELECT 
			m.id AS member_id,
			m.name AS member_name,
			m.role AS member_role,
			COALESCE(SUM(t.amount), 0) AS total_expense
		FROM family_members m
		LEFT JOIN transactions t ON m.id = t.recorder_id AND t.type = 'expense' AND t.date BETWEEN ? AND ?
		WHERE m.user_id = ?
		GROUP BY m.id
		ORDER BY total_expense DESC
	`

	err := model.DB.Raw(sql, startDate, endDate, userID).Scan(&result).Error
	if err != nil {
		return nil, err
	}

	// 计算总支出
	var totalExpense float64
	for _, stat := range result {
		totalExpense += stat.TotalExpense
	}

	// 计算百分比
	if totalExpense > 0 {
		for i := range result {
			result[i].Percentage = result[i].TotalExpense / totalExpense * 100
		}
	}

	return result, nil
}

// GetCategoryExpenseStats 获取按图标/类别统计的支出数据
func (r FinanceRepository) GetCategoryExpenseStats(userID uint, startDate, endDate time.Time, memberIDs []uint, types string) ([]model.CategoryExpenseStats, error) {
	db := model.DB

	// 查询总支出金额
	var totalExpense float64
	totalQuery := db.Debug().Model(&model.Transaction{}).
		Where("user_id = ? AND type = ? AND date BETWEEN ? AND ?", userID, types, startDate, endDate)

	if len(memberIDs) > 0 {
		totalQuery = totalQuery.Where("recorder_id IN ?", memberIDs)
	}

	if err := totalQuery.Select("COALESCE(SUM(amount), 0) as total_expense").Scan(&totalExpense).Error; err != nil {
		return nil, err
	}

	// 如果总支出为0，直接返回空结果
	if totalExpense == 0 {
		return []model.CategoryExpenseStats{}, nil
	}

	// 查询按图标ID分组的支出数据
	type Result struct {
		IconID      int     `gorm:"column:icon_id"`
		TotalAmount float64 `gorm:"column:total_amount"`
	}

	var results []Result
	query := db.Debug().Model(&model.Transaction{}).
		Select("icon_id, SUM(amount) as total_amount").
		Where("type = ? AND date BETWEEN ? AND ?", types, startDate, endDate).
		Group("icon_id").
		Order("total_amount DESC")

	if len(memberIDs) > 0 {
		query = query.Where("recorder_id IN ?", memberIDs)
	} else {
		query = query.Where("user_id = ? ", userID)
	}

	if err := query.Find(&results).Error; err != nil {
		return nil, err
	}

	// 转换为CategoryExpenseStats结构
	stats := make([]model.CategoryExpenseStats, 0, len(results))
	for _, res := range results {
		// 获取分类名称 (假设有一个图标服务)
		categoryName, _ := IconRepository{}.GetIcon(res.IconID) // 这个方法需要实现或调整

		// 计算百分比
		percentage := (res.TotalAmount / totalExpense) * 100

		stats = append(stats, model.CategoryExpenseStats{
			IconID:       res.IconID,
			CategoryName: categoryName.Name,
			Amount:       res.TotalAmount,
			Percentage:   percentage,
		})
	}

	return stats, nil
}

// GetCategoryNameByIconID 根据图标ID获取分类名称
func GetCategoryNameByIconID(iconID int) string {
	// 默认分类名称
	defaultName := fmt.Sprintf("分类%d", iconID)

	// 查询预算分类表获取分类名称
	var category model.BudgetCategory
	if err := model.DB.Where("icon_id = ?", iconID).First(&category).Error; err != nil {
		return defaultName
	}

	return category.Name
}

// GetMembersFinanceData 批量获取多个用户的财务数据
// 返回一个map，key为用户ID，value为包含收入和支出的map
func (r FinanceRepository) GetMembersFinanceData(userIDs []int64, startTime, endTime time.Time) (map[int64]map[string]float64, error) {
	if len(userIDs) == 0 {
		return make(map[int64]map[string]float64), nil
	}

	// 结果map，key是用户ID，value是包含income和expense的map
	result := make(map[int64]map[string]float64)

	// 初始化结果map，确保每个用户ID都有一个条目
	for _, id := range userIDs {
		result[id] = map[string]float64{
			"income":  0,
			"expense": 0,
		}
	}

	// 定义查询结果的结构
	type QueryResult struct {
		RecorderID uint    `gorm:"column:recorder_id"`
		Total      float64 `gorm:"column:total"`
	}

	// 批量查询收入数据 - 使用GORM构建器而非原生SQL
	var incomeResults []QueryResult
	if err := model.DB.Debug().Model(&model.Transaction{}).
		Select("recorder_id, COALESCE(SUM(amount), 0) as total").
		Where("recorder_id IN ?", userIDs).
		Where("type = ?", model.Income).
		Where("date BETWEEN ? AND ?", startTime, endTime).
		Group("recorder_id").
		Find(&incomeResults).Error; err != nil {
		return nil, fmt.Errorf("查询收入数据失败: %w", err)
	}

	// 处理收入查询结果
	for _, item := range incomeResults {
		if data, exists := result[int64(item.RecorderID)]; exists {
			data["income"] = item.Total
		}
	}

	// 批量查询支出数据 - 使用GORM构建器而非原生SQL
	var expenseResults []QueryResult
	if err := model.DB.Debug().Model(&model.Transaction{}).
		Select("recorder_id, COALESCE(SUM(amount), 0) as total").
		Where("recorder_id IN ?", userIDs).
		Where("type = ?", model.Expense).
		Where("date BETWEEN ? AND ?", startTime, endTime).
		Group("recorder_id").
		Find(&expenseResults).Error; err != nil {
		return nil, fmt.Errorf("查询支出数据失败: %w", err)
	}

	// 处理支出查询结果
	for _, item := range expenseResults {
		if data, exists := result[int64(item.RecorderID)]; exists {
			data["expense"] = item.Total
		}
	}

	return result, nil
}
