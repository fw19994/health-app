package handler

import (
	"math"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"life_app_back/internal/model"
	"life_app_back/internal/service"
	"life_app_back/internal/utils"
)

// GetBudgetCategories 获取预算列表（支持个人和家庭）
func GetBudgetCategories(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取查询参数
	year, _ := strconv.Atoi(c.DefaultQuery("year", strconv.Itoa(time.Now().Year())))
	month, _ := strconv.Atoi(c.DefaultQuery("month", strconv.Itoa(int(time.Now().Month()))))
	categoryType := c.DefaultQuery("is_family_budget", "false") // all, personal 或 family

	// 调用服务
	budgetService := &service.BudgetService{}
	var categories []model.BudgetCategoryResponse
	var err error
	ss, _ := strconv.ParseBool(categoryType)

	// 根据类型获取不同的预算列表
	switch ss {
	case false:
		categories, err = budgetService.GetUserBudgetCategories(userID, year, month)
	case true:
		categories, err = budgetService.GetFamilyBudgetCategories(userID, year, month)
	default: // "all"
		categories, err = budgetService.GetAllBudgetCategoriesForUser(userID, year, month)
	}

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, categories, "获取预算成功")
}

// GetAllBudgetCategories 获取所有预算（当前月，包括个人和家庭）
func GetAllBudgetCategories(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}
	year, _ := strconv.Atoi(c.DefaultQuery("year", strconv.Itoa(time.Now().Year())))
	month, _ := strconv.Atoi(c.DefaultQuery("month", strconv.Itoa(int(time.Now().Month()))))

	// 调用服务
	budgetService := &service.BudgetService{}
	categories, err := budgetService.GetAllBudgetCategoriesForUser(userID, year, month)

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, categories, "获取预算成功")
}

// CreateBudgetCategory 创建预算
func CreateBudgetCategory(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request struct {
		Name              string  `json:"name" binding:"required"`
		Description       string  `json:"description"`
		IconID            uint    `json:"icon_id" binding:"required"`
		Budget            float64 `json:"budget" binding:"required,gt=0"`
		Year              int     `json:"year" binding:"required"`
		Month             int     `json:"month" binding:"required,min=1,max=12"`
		ReminderThreshold int     `json:"reminder_threshold" binding:"required,min=0,max=100"`
		IsFamilyBudget    bool    `json:"is_family_budget"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 构建预算模型
	category := &model.BudgetCategory{
		UserID:            userID,
		Name:              request.Name,
		Description:       request.Description,
		IconID:            request.IconID,
		Budget:            request.Budget,
		Spent:             0, // 新建时已花费为0
		Year:              request.Year,
		Month:             request.Month,
		ReminderThreshold: request.ReminderThreshold,
		IsFamilyBudget:    request.IsFamilyBudget,
	}
	if request.IsFamilyBudget {
		userFamilyMembers, err := new(service.FamilyMemberService).GetUserFamilyMembers(userID)
		if err != nil {
			utils.ServerError(c, err)
			return
		}
		if len(userFamilyMembers) > 0 {
			category.FamilyID = userFamilyMembers[0].OwnerID
		}
	}
	// 调用服务
	budgetService := &service.BudgetService{}
	if err := budgetService.CreateBudgetCategory(category); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, gin.H{
		"id": category.ID,
	}, "创建预算成功")
}

// UpdateBudgetCategory 更新预算
func UpdateBudgetCategory(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取预算ID
	categoryIDStr := c.Param("id")
	categoryID, err := strconv.ParseUint(categoryIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的预算ID")
		return
	}

	// 绑定请求参数
	var request struct {
		Name              string  `json:"name"`
		Description       string  `json:"description"`
		IconID            uint    `json:"icon_id"`
		Color             string  `json:"color"`
		Budget            float64 `json:"budget" binding:"omitempty,gt=0"`
		ReminderThreshold int     `json:"reminder_threshold" binding:"omitempty,min=0,max=100"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 构建预算模型
	category := &model.BudgetCategory{
		ID:                uint(categoryID),
		Name:              request.Name,
		Description:       request.Description,
		IconID:            request.IconID,
		Budget:            request.Budget,
		ReminderThreshold: request.ReminderThreshold,
	}

	// 调用服务
	budgetService := &service.BudgetService{}
	if err := budgetService.UpdateBudgetCategory(category, userID); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "更新预算成功")
}

// DeleteBudgetCategory 删除预算
func DeleteBudgetCategory(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取预算ID
	categoryIDStr := c.Param("id")
	categoryID, err := strconv.ParseUint(categoryIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的预算ID")
		return
	}

	// 调用服务
	budgetService := &service.BudgetService{}
	if err := budgetService.DeleteBudgetCategory(uint(categoryID), userID); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "删除预算成功")
}

// CopyBudgetFromPreviousMonth 从上月复制预算
func CopyBudgetFromPreviousMonth(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request struct {
		Year         int  `json:"year" binding:"required"`
		Month        int  `json:"month" binding:"required,min=1,max=12"`
		IsFamilyMode bool `json:"is_family_mode"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 调用服务
	budgetService := &service.BudgetService{}
	if err := budgetService.CopyFromPreviousMonth(userID, request.Year, request.Month, request.IsFamilyMode); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "从上月复制预算成功")
}

// GetMonthlyBudget 获取指定月份的预算数据和消费数据
func GetMonthlyBudget(c *gin.Context) {
	// 获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 解析请求参数（年月）
	var req model.MonthlyBudgetRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		// 如果没有提供年月参数，默认使用当前月
		currentTime := time.Now()
		req.Year = currentTime.Year()
		req.Month = int(currentTime.Month())
	}

	// 验证月份参数
	if req.Month < 1 || req.Month > 12 {
		utils.ParameterError(c, "无效的月份参数")
		return
	}

	// 计算日期范围
	startDate := time.Date(req.Year, time.Month(req.Month), 1, 0, 0, 0, 0, time.Local)
	endDate := time.Date(req.Year, time.Month(req.Month+1), 0, 23, 59, 59, 0, time.Local)

	// 查询预算
	var categories []model.BudgetCategory
	err := model.DB.Where("user_id = ? AND year = ? AND month = ?", userID, req.Year, req.Month).
		Find(&categories).Error

	if err != nil {
		utils.ServerError(c, err)
		return
	}
	totalBudget := float64(0)
	for _, category := range categories {
		totalBudget += category.Budget
	}

	// 查询当月总消费
	var totalSpent float64
	err = model.DB.Model(&model.Transaction{}).
		Where("user_id = ? AND type = ? AND date BETWEEN ? AND ?",
			userID, "expense", startDate, endDate).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalSpent).Error

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 准备响应数据
	var response model.MonthlyBudgetResponse
	response.TotalBudget = totalBudget
	response.TotalSpent = totalSpent
	response.RemainingAmount = totalBudget - totalSpent

	// 计算使用百分比，避免除以零
	if totalBudget > 0 {
		response.UsagePercent = math.Round((totalSpent/totalBudget)*10000) / 100 // 保留两位小数
	} else {
		response.UsagePercent = 0
	}

	// 查询各分类的消费数据并组装
	categoriesWithUsage := make([]model.BudgetCategoryWithUsage, 0, len(categories))

	for _, category := range categories {
		// 查询该分类的消费
		var categorySpent float64
		err = model.DB.Model(&model.Transaction{}).
			Where("user_id = ? AND type = ? AND icon_id = ? AND date BETWEEN ? AND ?",
				userID, "expense", category.IconID, startDate, endDate).
			Select("COALESCE(SUM(amount), 0)").
			Scan(&categorySpent).Error

		if err != nil {
			utils.ServerError(c, err)
			return
		}

		// 计算分类使用百分比
		var usagePercent float64
		if category.Budget > 0 {
			usagePercent = math.Round((categorySpent/category.Budget)*10000) / 100 // 保留两位小数
		}

		// 添加到结果集
		categoryWithUsage := model.BudgetCategoryWithUsage{
			ID:           int(category.ID),
			Name:         category.Name,
			Amount:       category.Budget,
			SpentAmount:  categorySpent,
			UsagePercent: usagePercent,
		}

		categoriesWithUsage = append(categoriesWithUsage, categoryWithUsage)
	}

	response.Categories = categoriesWithUsage
	utils.Success(c, response, "获取预算数据成功")
}
