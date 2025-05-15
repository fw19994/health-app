package handler

import (
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"life_app_back/internal/model"
	"life_app_back/internal/service"
	"life_app_back/internal/utils"
)

// GetSavingsGoals 获取储蓄目标列表（支持个人和家庭）
func GetSavingsGoals(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取查询参数
	goalType := c.DefaultQuery("is_family_savings", "false") // all, personal 或 family
	status := c.DefaultQuery("status", "")                   // 可选: in_progress, completed, deleted

	// 调用服务
	savingsService := &service.SavingsGoalService{}
	var goals []model.SavingsGoalResponse
	var err error

	// 根据类型获取不同的储蓄目标列表
	ss, _ := strconv.ParseBool(goalType)
	switch ss {
	case false:
		goals, err = savingsService.GetUserSavingsGoals(userID)
	case true:
		goals, err = savingsService.GetFamilySavingsGoals(userID)
	default: // "all"
		goals, err = savingsService.GetAllSavingsGoalsForUser(userID)
	}

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 如果指定了状态，则过滤结果
	if status != "" {
		var filteredGoals []model.SavingsGoalResponse
		for _, goal := range goals {
			if goal.Status == status {
				filteredGoals = append(filteredGoals, goal)
			}
		}
		goals = filteredGoals
	}

	utils.Success(c, goals, "获取储蓄目标成功")
}

// CreateSavingsGoal 创建储蓄目标
func CreateSavingsGoal(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request struct {
		Name            string    `json:"name" binding:"required"`
		Description     string    `json:"description"`
		IconID          uint      `json:"icon_id" binding:"required"`
		Color           string    `json:"color" binding:"required"`
		TargetAmount    float64   `json:"target_amount" binding:"required,gt=0"`
		TargetDate      time.Time `json:"target_date" binding:"required"`
		IsFamilySavings bool      `json:"is_family_savings"`
		FamilyID        uint      `json:"family_id"`
		MonthlyTarget   float64   `json:"monthly_target"` // 每月目标存款
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 验证目标日期是否在未来
	if request.TargetDate.Before(time.Now()) {
		utils.ParameterError(c, "目标日期必须在未来")
		return
	}

	// 构建储蓄目标模型
	goal := &model.SavingsGoal{
		UserID:        userID,
		Name:          request.Name,
		Description:   request.Description,
		IconID:        request.IconID,
		TargetAmount:  request.TargetAmount,
		MonthlyTarget: request.MonthlyTarget,
		TargetDate:    request.TargetDate,
		IsFamilyGoal:  request.IsFamilySavings,
	}
	if request.IsFamilySavings {
		userFamilyMembers, err := new(service.FamilyMemberService).GetUserFamilyMembers(userID)
		if err != nil {
			utils.ServerError(c, err)
			return
		}
		if len(userFamilyMembers) > 0 {
			goal.FamilyID = userFamilyMembers[0].OwnerID
		}
	} // 调用服务
	savingsService := &service.SavingsGoalService{}
	if err := savingsService.CreateSavingsGoal(goal); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, gin.H{
		"id": goal.ID,
	}, "创建储蓄目标成功")
}

// UpdateSavingsGoal 更新储蓄目标
func UpdateSavingsGoal(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取储蓄目标ID
	goalIDStr := c.Param("id")
	goalID, err := strconv.ParseUint(goalIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的储蓄目标ID")
		return
	}

	// 绑定请求参数
	var request struct {
		Name          string    `json:"name"`
		Description   string    `json:"description"`
		IconID        uint      `json:"icon_id"`
		Color         string    `json:"color"`
		TargetAmount  float64   `json:"target_amount" binding:"omitempty,gt=0"`
		CurrentAmount float64   `json:"current_amount" binding:"omitempty,gte=0"`
		TargetDate    time.Time `json:"target_date"`
		MonthlyTarget float64   `json:"monthly_target"` // 每月目标存款
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 如果提供了目标日期，验证是否在未来
	if !request.TargetDate.IsZero() && request.TargetDate.Before(time.Now()) {
		utils.ParameterError(c, "目标日期必须在未来")
		return
	}

	// 构建储蓄目标模型
	goal := &model.SavingsGoal{
		ID:            uint(goalID),
		Name:          request.Name,
		Description:   request.Description,
		IconID:        request.IconID,
		TargetAmount:  request.TargetAmount,
		CurrentAmount: request.CurrentAmount,
		TargetDate:    request.TargetDate,
		MonthlyTarget: request.MonthlyTarget,
	}

	// 调用服务
	savingsService := &service.SavingsGoalService{}
	if err := savingsService.UpdateSavingsGoal(goal, userID); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "更新储蓄目标成功")
}

// DeleteSavingsGoal 删除储蓄目标
func DeleteSavingsGoal(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取储蓄目标ID
	goalIDStr := c.Param("id")
	goalID, err := strconv.ParseUint(goalIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的储蓄目标ID")
		return
	}

	// 调用服务
	savingsService := &service.SavingsGoalService{}
	if err := savingsService.DeleteSavingsGoal(uint(goalID), userID); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "删除储蓄目标成功")
}

// UpdateSavingsGoalProgress 更新储蓄目标进度
func UpdateSavingsGoalProgress(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取储蓄目标ID
	goalIDStr := c.Param("id")
	goalID, err := strconv.ParseUint(goalIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的储蓄目标ID")
		return
	}

	// 绑定请求参数
	var request struct {
		CurrentAmount float64 `json:"current_amount" binding:"required,gte=0"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 调用服务
	savingsService := &service.SavingsGoalService{}
	if err := savingsService.UpdateSavingsGoalProgress(uint(goalID), userID, request.CurrentAmount); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "更新储蓄目标进度成功")
}

// GetSavingsGoalMonthlyRequirement 获取每月所需金额
func GetSavingsGoalMonthlyRequirement(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取储蓄目标ID
	goalIDStr := c.Param("id")
	goalID, err := strconv.ParseUint(goalIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的储蓄目标ID")
		return
	}

	// 调用服务
	savingsService := &service.SavingsGoalService{}
	result, err := savingsService.GetMonthlyContributionRequirement(uint(goalID), userID)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, result, "获取每月所需金额成功")
}

// UpdateSavingsGoalStatus 更新储蓄目标状态
func UpdateSavingsGoalStatus(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取储蓄目标ID
	goalIDStr := c.Param("id")
	goalID, err := strconv.ParseUint(goalIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的储蓄目标ID")
		return
	}

	// 绑定请求参数
	var request struct {
		Status string `json:"status" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 验证状态值
	if request.Status != model.SavingsGoalStatusInProgress &&
		request.Status != model.SavingsGoalStatusCompleted &&
		request.Status != model.SavingsGoalStatusDeleted {
		utils.ParameterError(c, "无效的状态值，允许的值为: in_progress, completed, deleted")
		return
	}

	// 调用服务
	savingsService := &service.SavingsGoalService{}
	if err := savingsService.UpdateSavingsGoalStatus(uint(goalID), userID, request.Status); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "更新储蓄目标状态成功")
}
