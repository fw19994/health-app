package handler

import (
	"life_app_back/internal/model"
	"life_app_back/internal/service"
	"life_app_back/internal/utils"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

// 依赖注入 FinanceService
var financeService = service.NewFinanceService()

// GetFinanceSummary 获取财务摘要
func GetFinanceSummary(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID 内部已处理错误响应
	}

	// 解析时间范围参数
	var startDate, endDate time.Time
	var err error

	startDateStr := c.Query("start_date")
	if startDateStr != "" {
		startDate, err = time.Parse("2006-01-02 15:04:05", startDateStr)
		if err != nil {
			utils.ParameterError(c, "无效的开始日期格式，请使用YYYY-MM-DD")
			return
		}
	}

	endDateStr := c.Query("end_date")
	if endDateStr != "" {
		endDate, err = time.Parse("2006-01-02 15:04:05", endDateStr)
		if err != nil {
			utils.ParameterError(c, "无效的结束日期格式，请使用YYYY-MM-DD")
			return
		}
	}

	// 调用服务方法获取财务摘要
	summary, err := financeService.GetFinanceSummary(userID, startDate, endDate)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, summary, "获取成功")
}

// AddTransaction 添加交易记录 (支出或收入)
func AddTransaction(c *gin.Context) {
	var req model.AddTransactionRequest

	// 解析请求体
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ParameterError(c, "请求参数错误: "+err.Error())
		return
	}

	// 从上下文中获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID 内部已处理错误响应
	}

	// 调用服务添加交易记录
	if err := financeService.AddTransaction(userID, req); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "添加成功")
}

// GetExpenses 获取支出列表
func GetExpenses(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID 内部已处理错误响应
	}

	// 创建查询参数，仅支出类型
	var params model.TransactionQueryParams
	params.Type = model.Expense

	// 解析其他查询参数
	if err := c.ShouldBindQuery(&params); err != nil {
		utils.ParameterError(c, "无效的查询参数: "+err.Error())
		return
	}

	// 调用服务方法获取支出列表
	result, err := financeService.GetTransactions(userID, params)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, result, "获取成功")
}

// GetExpenseCategories 获取支出类别
func GetExpenseCategories(c *gin.Context) {
	// TODO: 实现获取支出类别的逻辑
	// 根据记忆中的配置返回支出类别
	utils.Success(c, []string{
		"食品", "住房", "交通", "娱乐",
		"医疗", "教育", "购物", "其他",
	}, "获取成功")
}

// GenerateFinancialReport 生成财务报告
func GenerateFinancialReport(c *gin.Context) {
	// TODO: 实现生成财务报告的逻辑
	utils.Success(c, gin.H{
		"reportUrl": "",
	}, "生成成功")
}

// GetRecentTransactions 获取近期交易记录
func GetRecentTransactions(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID 内部已处理错误响应
	}

	// 获取交易类型参数（支出/收入）
	transactionType := c.Query("type") // expense 或 income
	if transactionType != "expense" && transactionType != "income" && transactionType != "" {
		utils.ParameterError(c, "无效的交易类型，必须是'expense'或'income'")
		return
	}
	limit := 5
	// 获取限制数量参数
	if limitParam := c.Query("limit"); limitParam != "" {
		limit, _ = strconv.Atoi(limitParam)
	}

	// 调用服务获取近期交易
	transactions, err := financeService.GetRecentTransactions(userID, transactionType, limit)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 转换为响应格式
	utils.Success(c, transactions, "获取成功")
}

// GetTransactions 获取交易记录，支持筛选和分页
func GetTransactions(c *gin.Context) {
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		utils.AuthFailed(c, "")
		return
	}
	// 定义请求参数结构体
	type TransactionQuery struct {
		Type       string `form:"type"`   // 交易类型: expense, income
		MemberID   uint   `form:"member"` // 成员ID
		Categories []int  `form:"categories"`
		StartDate  string `form:"start_date"` // 开始日期
		EndDate    string `form:"end_date"`   // 结束日期
	}

	// 绑定请求参数
	var query TransactionQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		utils.ParameterError(c, "参数解析错误")
		return
	}
	categories := c.QueryMap("categories")
	for _, start := range categories {
		// 处理每个start值、
		value, _ := strconv.Atoi(start)
		query.Categories = append(query.Categories, value)
	}
	// 构造查询参数
	queryParams := model.TransactionQueryParams{
		UserID:     userID,
		Type:       query.Type,
		MemberID:   query.MemberID,
		CategoryID: query.Categories,
	}

	// 解析日期范围
	if query.StartDate != "" {
		if startDate, err := time.Parse("2006-01-02 15:04:05", query.StartDate); err == nil {
			queryParams.StartDate = startDate
		}
	}

	if query.EndDate != "" {
		if endDate, err := time.Parse("2006-01-02 15:04:05", query.EndDate); err == nil {
			queryParams.EndDate = endDate
		}
	}

	// 调用服务获取交易记录
	response, err := financeService.GetTransactions(userID, queryParams)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, response, "")
}

// GetTransactionGroups 获取按日期分组的交易记录
func GetTransactionGroups(c *gin.Context) {
	// 获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		utils.AuthFailed(c, "用户未认证")
		return
	}

	// 构造请求参数结构体
	type QueryRequest struct {
		Type       string `form:"type"`
		MemberID   uint   `form:"member"`
		CategoryID []int  `form:"category"`
		StartDate  string `form:"start_date"`
		EndDate    string `form:"end_date"`
		Page       int    `form:"page,default=1"`
		Limit      int    `form:"limit,default=20"`
	}

	var req QueryRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		utils.ParameterError(c, "参数解析错误")
		return
	}
	categories := c.QueryMap("categories")
	for _, start := range categories {
		// 处理每个start值、
		value, _ := strconv.Atoi(start)
		req.CategoryID = append(req.CategoryID, value)
	}

	// 构造查询参数
	queryParams := model.TransactionQueryParams{
		UserID:     userID,
		Type:       req.Type,
		MemberID:   req.MemberID,
		CategoryID: req.CategoryID,
	}

	// 解析并验证日期范围
	if req.StartDate != "" {
		if parsedStart, err := time.Parse("2006-01-02 15:04:05", req.StartDate); err == nil {
			queryParams.StartDate = parsedStart
		} else {
			utils.ParameterError(c, "开始日期格式错误")
			return
		}
	}

	if req.EndDate != "" {
		if parsedEnd, err := time.Parse("2006-01-02 15:04:05", req.EndDate); err == nil {
			queryParams.EndDate = parsedEnd
		} else {
			utils.ParameterError(c, "结束日期格式错误")
			return
		}
	}

	// 解析并验证分页参数

	// 获取分组数据
	transactionGroups, err := financeService.GetTransactionGroups(queryParams.UserID, queryParams.StartDate, queryParams.EndDate, req.Limit, req.Page, req.Type, req.MemberID, req.CategoryID)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回成功响应
	utils.Success(c, transactionGroups, "获取交易记录分组成功")
}

// GetTransactionTrend 获取交易趋势数据
func GetTransactionTrend(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID 内部已处理错误响应
	}
	// 定义请求参数结构体
	type TransactionQuery struct {
		Type       string `form:"type"`       // 交易类型: expense, income
		MemberID   int    `form:"member"`     // 成员ID
		CategoryID []int  `form:"categories"` // 类别ID
		StartDate  string `form:"start_date"` // 开始日期
		EndDate    string `form:"end_date"`   // 结束日期
		Interval   string `form:"interval"`
	}

	// 绑定请求参数
	var query TransactionQuery
	if err := c.ShouldBindQuery(&query); err != nil {
		utils.ParameterError(c, "参数解析错误")
		return
	}
	categories := c.QueryMap("categories")
	for _, start := range categories {
		// 处理每个start值、
		value, _ := strconv.Atoi(start)
		query.CategoryID = append(query.CategoryID, value)
	}
	// 解析日期范围参数
	var startDate, endDate time.Time
	var err error

	if query.StartDate != "" {
		startDate, err = time.Parse("2006-01-02 15:04:05", query.StartDate)
		if err != nil {
			utils.ParameterError(c, "无效的开始日期格式，请使用YYYY-MM-DD")
			return
		}
	}

	if query.EndDate != "" {
		endDate, err = time.Parse("2006-01-02 15:04:05", query.EndDate)
		if err != nil {
			utils.ParameterError(c, "无效的结束日期格式，请使用YYYY-MM-DD")
			return
		}
	}

	// 获取趋势数据
	trendData, err := financeService.GetTransactionTrend(userID, startDate, endDate, query.Interval, uint(query.MemberID), query.CategoryID)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, gin.H{
		"data": trendData,
	}, "获取成功")
}

// GetMemberExpenseStats 获取成员支出统计
func GetMemberExpenseStats(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID 内部已处理错误响应
	}

	// 解析日期范围参数
	var startDate, endDate time.Time
	var err error

	startDateStr := c.Query("start_date")
	if startDateStr != "" {
		startDate, err = time.Parse("2006-01-02 15:04:05", startDateStr)
		if err != nil {
			utils.ParameterError(c, "无效的开始日期格式，请使用YYYY-MM-DD")
			return
		}
	}

	endDateStr := c.Query("end_date")
	if endDateStr != "" {
		endDate, err = time.Parse("2006-01-02 15:04:05", endDateStr)
		if err != nil {
			utils.ParameterError(c, "无效的结束日期格式，请使用YYYY-MM-DD")
			return
		}
	}

	// 获取成员支出统计
	memberStats, err := financeService.GetMemberExpenseStats(userID, startDate, endDate)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, gin.H{
		"data": memberStats,
	}, "获取成功")
}

// GetExpenseAnalysis 获取支出分析数据，按图标/类别分组统计
func GetExpenseAnalysis(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID 内部已处理错误响应
	}

	// 定义请求参数结构体
	type AnalysisRequest struct {
		StartDate string `form:"start_date"` // 开始日期
		EndDate   string `form:"end_date"`   // 结束日期
		MemberID  int    `form:"member_id"`  // 成员ID，可选
	}

	// 绑定请求参数
	var req AnalysisRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		utils.ParameterError(c, "参数解析错误")
		return
	}

	// 解析日期范围参数
	var startDate, endDate time.Time
	var err error

	if req.StartDate != "" {
		startDate, err = time.Parse("2006-01-02 15:04:05", req.StartDate)
		if err != nil {
			utils.ParameterError(c, "无效的开始日期格式，请使用YYYY-MM-DD HH:MM:SS")
			return
		}
	} else {
		// 默认为当月第一天
		now := time.Now()
		startDate = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	}

	if req.EndDate != "" {
		endDate, err = time.Parse("2006-01-02 15:04:05", req.EndDate)
		if err != nil {
			utils.ParameterError(c, "无效的结束日期格式，请使用YYYY-MM-DD HH:MM:SS")
			return
		}
	} else {
		// 默认为当前时间
		endDate = time.Now()
	}

	// 调用服务获取支出分析数据
	analysisData, err := financeService.GetExpenseAnalysis(userID, startDate, endDate, uint(req.MemberID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, gin.H{
		"data": analysisData,
	}, "获取成功")
}
