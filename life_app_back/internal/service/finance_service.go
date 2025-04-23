package service

import (
	"life_app_back/internal/model"
	"life_app_back/internal/repository"
	"time"
)

// FinanceService 财务服务
type FinanceService struct {
	repo repository.FinanceRepository // 依赖注入 FinanceRepository
}

// NewFinanceService 创建 FinanceService 实例
func NewFinanceService() *FinanceService {
	return &FinanceService{
		repo: repository.FinanceRepository{},
	}
}

// AddTransaction 添加一笔交易记录
func (s *FinanceService) AddTransaction(userID uint, req model.AddTransactionRequest) error {
	// 构造 Transaction 模型
	transaction := model.Transaction{
		UserID:          userID,
		Type:            req.Type,
		Amount:          req.Amount,
		IconID:          req.IconID,
		Date:            req.Date,
		Merchant:        req.Merchant,
		Notes:           req.Notes,
		RecorderID:      req.RecorderID,
		IsFamilyExpense: req.IsFamilyExpense,
		ImageURL:        req.ImageURL,
	}

	// 调用 Repository 保存交易记录
	return s.repo.AddTransaction(&transaction)
}

// GetRecentTransactions 获取近期交易记录
func (s *FinanceService) GetRecentTransactions(userID uint, transactionType string, limit int) ([]model.Transaction, error) {
	// 调用 Repository 获取近期交易记录
	return s.repo.GetRecentTransactions(userID, transactionType, limit)
}

// GetTransactions 获取交易记录列表，支持分页和筛选
func (s *FinanceService) GetTransactions(userID uint, params model.TransactionQueryParams) (*model.TransactionResponse, error) {
	// 确保用户ID被设置
	params.UserID = userID

	// 设置默认分页参数
	if params.Page <= 0 {
		params.Page = 1
	}
	if params.PageSize <= 0 {
		params.PageSize = 20
	}
	memberIDs := make([]uint, 0)
	if params.MemberID == 0 {
		familyMemberRepository := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepository.GetFamilyMemberByUserIDDirect(userID)
		if err != nil {
			return nil, err
		}
		familyMembers, err := familyMemberRepository.GetFamilyMembers(familyMember.OwnerID)
		if err != nil {
			return nil, err
		}
		for _, tmp := range familyMembers {
			memberIDs = append(memberIDs, tmp.ID)
		}
	} else {
		memberIDs = append(memberIDs, params.MemberID)
	}

	// 获取统计数据
	totalRecords, totalIncome, totalExpense, err := s.repo.GetTransactionStats(
		memberIDs,
		params.StartDate,
		params.EndDate,
		params.Type,
		params.CategoryID,
		userID,
	)
	if err != nil {
		return nil, err
	}
	// 构造响应
	response := &model.TransactionResponse{
		Summary: struct {
			TotalCount   int     `json:"total_count"`
			TotalIncome  float64 `json:"total_income"`
			TotalExpense float64 `json:"total_expense"`
			NetAmount    float64 `json:"net_amount"`
		}{
			TotalCount:   totalRecords,
			TotalIncome:  totalIncome,
			TotalExpense: totalExpense,
			NetAmount:    totalIncome - totalExpense,
		},
	}

	return response, nil
}

// GetTransactionGroups 获取按日期分组的交易记录
func (s *FinanceService) GetTransactionGroups(userID uint, startDate, endDate time.Time, limit, page int, types string, memberID uint, categoryID []int) ([]model.TransactionDateGroup, error) {
	// 使用当前时间作为默认结束日期
	if endDate.IsZero() {
		endDate = time.Now()
	}

	// 如果未指定开始日期，则默认为30天前
	if startDate.IsZero() {
		startDate = endDate.AddDate(0, 0, -30)
	}

	// 使用默认limit
	if limit <= 0 {
		limit = 10
	}
	memberIDs := make([]uint, 0)
	if memberID == 0 {
		familyMemberRepository := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepository.GetFamilyMemberByUserIDDirect(userID)
		if err != nil {
			return nil, err
		}
		familyMembers, err := familyMemberRepository.GetFamilyMembers(familyMember.OwnerID)
		if err != nil {
			return nil, err
		}
		for _, tmp := range familyMembers {
			memberIDs = append(memberIDs, tmp.ID)
		}
	} else {
		memberIDs = append(memberIDs, memberID)
	}

	// 调用Repository方法
	return s.repo.GetTransactionsByDate(userID, startDate, endDate, limit, page, types, memberIDs, categoryID)
}

// GetTransactionTrend 获取交易趋势数据
func (s *FinanceService) GetTransactionTrend(userID uint, startDate, endDate time.Time, interval string, memberID uint, CategoryID []int) ([]model.TrendDataPoint, error) {
	memberIDs := make([]uint, 0)
	if memberID == 0 {
		familyMemberRepository := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepository.GetFamilyMemberByUserIDDirect(userID)
		if err != nil {
			return nil, err
		}
		familyMembers, err := familyMemberRepository.GetFamilyMembers(familyMember.OwnerID)
		if err != nil {
			return nil, err
		}
		for _, tmp := range familyMembers {
			memberIDs = append(memberIDs, tmp.ID)
		}
	} else {
		memberIDs = append(memberIDs, memberID)
	}
	// 调用Repository方法
	return s.repo.GetTransactionTrend(userID, startDate, endDate, interval, memberIDs, CategoryID)
}

// GetMemberExpenseStats 获取成员支出统计
func (s *FinanceService) GetMemberExpenseStats(userID uint, startDate, endDate time.Time) ([]model.MemberExpenseStats, error) {
	// 使用当前时间作为默认结束日期
	if endDate.IsZero() {
		endDate = time.Now()
	}

	// 如果未指定开始日期，则默认为30天前
	if startDate.IsZero() {
		startDate = endDate.AddDate(0, 0, -30)
	}

	// 调用Repository方法
	return s.repo.GetMemberExpenseStats(userID, startDate, endDate)
}

// GetFinanceSummary 获取财务摘要
func (s *FinanceService) GetFinanceSummary(userID uint, startDate, endDate time.Time) (map[string]interface{}, error) {
	// 使用当前时间作为默认结束日期
	if endDate.IsZero() {
		endDate = time.Now()
	}

	// 如果未指定开始日期，则默认为30天前
	if startDate.IsZero() {
		startDate = endDate.AddDate(0, 0, -30)
	}

	// 获取统计数据
	totalCount, totalIncome, totalExpense, err := s.repo.GetTransactionStats([]uint{}, startDate, endDate, "", []int{}, userID)
	if err != nil {
		return nil, err
	}

	// 获取成员支出统计
	memberStats, err := s.repo.GetMemberExpenseStats(userID, startDate, endDate)
	if err != nil {
		return nil, err
	}

	// 获取每周趋势
	trendData, err := s.repo.GetTransactionTrend(userID, startDate, endDate, "week", []uint{}, []int{})
	if err != nil {
		return nil, err
	}

	// 构造响应
	summary := map[string]interface{}{
		"totalCount":   totalCount,
		"totalIncome":  totalIncome,
		"totalExpense": totalExpense,
		"balance":      totalIncome - totalExpense,
		"memberStats":  memberStats,
		"trendData":    trendData,
		"periodStart":  startDate.Format("2006-01-02"),
		"periodEnd":    endDate.Format("2006-01-02"),
	}

	return summary, nil
}

// GetExpenseAnalysis 获取按类别统计的支出分析数据
func (s *FinanceService) GetExpenseAnalysis(userID uint, startDate, endDate time.Time, memberID uint) ([]model.CategoryExpenseStats, error) {
	// 使用当前时间作为默认结束日期
	if endDate.IsZero() {
		endDate = time.Now()
	}

	// 如果未指定开始日期，则默认为当月第一天
	if startDate.IsZero() {
		now := time.Now()
		startDate = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	}

	// 处理成员ID，如果未指定则获取所有家庭成员
	memberIDs := make([]uint, 0)
	if memberID == 0 {
		familyMemberRepository := &repository.FamilyMemberRepository{}
		familyMember, err := familyMemberRepository.GetFamilyMemberByUserIDDirect(userID)
		if err != nil {
			return nil, err
		}
		familyMembers, err := familyMemberRepository.GetFamilyMembers(familyMember.OwnerID)
		if err != nil {
			return nil, err
		}
		for _, tmp := range familyMembers {
			memberIDs = append(memberIDs, tmp.ID)
		}
	} else {
		memberIDs = append(memberIDs, memberID)
	}

	// 调用Repository方法获取按类别统计的支出数据
	return s.repo.GetCategoryExpenseStats(userID, startDate, endDate, memberIDs)
}
