package handler

import (
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"life_app_back/internal/model"
	"life_app_back/internal/repository"
	"life_app_back/internal/service"
	"life_app_back/internal/utils"
)

// GetPlan 获取单个计划详情
func GetPlan(c *gin.Context) {
	// 获取计划ID
	planID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的计划ID")
		return
	}

	// 调用服务
	planService := &service.PlanService{}
	plan, err := planService.GetPlanByID(uint(planID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, plan, "获取计划成功")
}

// CreatePlan 创建计划
func CreatePlan(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request service.CreatePlanRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 调用服务创建计划
	planService := &service.PlanService{}
	plan, err := planService.CreatePlan(userID, request)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, plan, "创建计划成功")
}

// UpdatePlan 更新计划
func UpdatePlan(c *gin.Context) {
	// 获取计划ID
	planID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的计划ID")
		return
	}

	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request service.UpdatePlanRequest

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 调用服务
	planService := &service.PlanService{}
	plan, err := planService.UpdatePlan(uint(planID), userID, request)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, plan, "更新计划成功")
}

// DeletePlan 删除计划
func DeletePlan(c *gin.Context) {
	// 获取计划ID
	planID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的计划ID")
		return
	}

	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 调用服务
	planService := &service.PlanService{}
	if err := planService.DeletePlan(uint(planID), userID); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "删除计划成功")
}

// CompletePlan 完成计划
func CompletePlan(c *gin.Context) {
	// 获取计划ID
	planID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的计划ID")
		return
	}

	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 解析请求体
	var req struct {
		Date string `json:"date"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		// 如果没有提供日期，使用当前日期
		req.Date = time.Now().Format("2006-01-02")
	}

	// 解析日期
	date, err := time.Parse("2006-01-02", req.Date)
	if err != nil {
		// 如果日期解析失败，使用当前日期
		date = time.Now()
	}

	// 调用服务
	planService := &service.PlanService{}
	if err := planService.MarkPlanAsCompleted(uint(planID), userID, date); err != nil {
		utils.ServerError(c, err)
		return
	}

	// 获取计划信息
	plan, err := planService.GetPlanByID(uint(planID))
	if err == nil && plan.ProjectPhaseID > 0 {
		// 获取阶段所属的专项计划
		phaseService := &service.ProjectPhaseService{}
		phase, err := phaseService.GetPhaseByID(plan.ProjectPhaseID)
		if err == nil {
			// 更新专项计划进度
			projectService := &service.SpecialProjectService{}
			projectService.UpdateSpecialProjectProgress(phase.SpecialProjectID)
		}
	}

	utils.Success(c, nil, "完成计划成功")
}

// CancelPlan 取消计划
func CancelPlan(c *gin.Context) {
	// 获取计划ID
	planID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的计划ID")
		return
	}

	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 调用服务
	planService := &service.PlanService{}
	if err := planService.CancelPlan(uint(planID), userID); err != nil {
		utils.ServerError(c, err)
		return
	}

	// 如果计划属于专项阶段，更新专项计划进度
	plan, err := planService.GetPlanByID(uint(planID))
	if err == nil && plan.ProjectPhaseID > 0 {
		// 获取阶段所属的专项计划
		phaseService := &service.ProjectPhaseService{}
		phase, err := phaseService.GetPhaseByID(plan.ProjectPhaseID)
		if err == nil {
			// 更新专项计划进度
			projectService := &service.SpecialProjectService{}
			projectService.UpdateSpecialProjectProgress(phase.SpecialProjectID)
		}
	}

	utils.Success(c, nil, "取消计划成功")
}

// GetDailyPlans 获取指定日期的计划列表
func GetDailyPlans(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取查询参数
	dateStr := c.DefaultQuery("date", time.Now().Format("2006-01-02"))
	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		utils.ParameterError(c, "无效的日期格式，请使用YYYY-MM-DD格式")
		return
	}

	// 调用服务获取用户个人计划
	planService := &service.PlanService{}
	plans, err := planService.GetPlansByDate(userID, date)

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, plans, "获取日计划成功")
}

// GetMonthlyPlans 获取指定月份的计划列表
func GetMonthlyPlans(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取查询参数
	year, _ := strconv.Atoi(c.DefaultQuery("year", strconv.Itoa(time.Now().Year())))
	month, _ := strconv.Atoi(c.DefaultQuery("month", strconv.Itoa(int(time.Now().Month()))))

	// 判断是否需要按日期分组
	groupByDateStr := c.DefaultQuery("group_by_date", "true")
	groupByDate := groupByDateStr == "true"

	// 调用仓库层
	planRepo := &repository.PlanRepository{}

	if groupByDate {
		// 使用按日期分组的方法
		groupedPlans, err := planRepo.GetMonthlyPlansGroupedByDate(userID, year, month)

		if err != nil {
			utils.ServerError(c, err)
			return
		}

		utils.Success(c, groupedPlans, "获取月计划成功")
	} else {
		// 使用原始方法（不按日期分组）
		plans, err := planRepo.GetMonthlyPlans(userID, year, month)

		if err != nil {
			utils.ServerError(c, err)
			return
		}

		// 转换为响应结构
		var responses []model.PlanResponse
		for _, plan := range plans {
			response := plan.ToResponse()

			// 检查每个计划当天是否完成
			isCompletedToday, err := planRepo.CheckPlanCompletionToday(plan.ID, plan.Date)
			if err == nil {
				response.IsCompletedToday = isCompletedToday
			}

			responses = append(responses, response)
		}

		utils.Success(c, responses, "获取月计划成功")
	}
}

// GetSpecialProject 获取专项计划详情
func GetSpecialProject(c *gin.Context) {
	// 获取专项计划ID
	projectID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的专项计划ID")
		return
	}

	// 调用服务
	projectService := &service.SpecialProjectService{}
	project, err := projectService.GetSpecialProjectByID(uint(projectID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, project, "获取专项计划成功")
}

// CreateSpecialProject 创建专项计划
func CreateSpecialProject(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request struct {
		Title       string  `json:"title" binding:"required"`
		Description string  `json:"description"`
		StartDate   string  `json:"start_date" binding:"required"` // 改为string类型
		EndDate     string  `json:"end_date" binding:"required"`   // 改为string类型
		Status      string  `json:"status"`
		Budget      float64 `json:"budget"`
		FamilyID    uint    `json:"family_id"`
		Phases      []struct {
			Name        string `json:"name" binding:"required"`
			Description string `json:"description"`
		} `json:"phases"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 解析日期字符串
	startDate, err := time.Parse("2006-01-02", request.StartDate)
	if err != nil {
		utils.ParameterError(c, "开始日期格式错误，请使用YYYY-MM-DD格式")
		return
	}

	endDate, err := time.Parse("2006-01-02", request.EndDate)
	if err != nil {
		utils.ParameterError(c, "结束日期格式错误，请使用YYYY-MM-DD格式")
		return
	}

	// 验证开始日期和结束日期
	if endDate.Before(startDate) {
		utils.ParameterError(c, "结束日期不能早于开始日期")
		return
	}

	// 构建专项计划模型
	project := &model.SpecialProject{
		UserID:      userID,
		FamilyID:    request.FamilyID,
		Title:       request.Title,
		Description: request.Description,
		StartDate:   startDate,
		EndDate:     endDate,
		Status:      request.Status,
		Budget:      request.Budget,
	}

	// 调用服务创建专项计划
	projectService := &service.SpecialProjectService{}
	projectID, err := projectService.CreateSpecialProject(project)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, gin.H{
		"id": projectID,
	}, "创建专项计划成功")
}

// UpdateSpecialProject 更新专项计划
func UpdateSpecialProject(c *gin.Context) {
	// 获取专项计划ID
	projectID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的专项计划ID")
		return
	}

	// 绑定请求参数
	var request struct {
		Title       string  `json:"title"`
		Description string  `json:"description"`
		StartDate   string  `json:"start_date"` // 改为string类型
		EndDate     string  `json:"end_date"`   // 改为string类型
		Status      string  `json:"status"`
		Budget      float64 `json:"budget"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 初始化日期变量
	var startDate, endDate time.Time

	// 解析开始日期（如果提供）
	if request.StartDate != "" {
		startDate, err = time.Parse("2006-01-02", request.StartDate)
		if err != nil {
			utils.ParameterError(c, "开始日期格式错误，请使用YYYY-MM-DD格式")
			return
		}
	}

	// 解析结束日期（如果提供）
	if request.EndDate != "" {
		endDate, err = time.Parse("2006-01-02", request.EndDate)
		if err != nil {
			utils.ParameterError(c, "结束日期格式错误，请使用YYYY-MM-DD格式")
			return
		}
	}

	// 验证开始日期和结束日期
	if !endDate.IsZero() && !startDate.IsZero() && endDate.Before(startDate) {
		utils.ParameterError(c, "结束日期不能早于开始日期")
		return
	}

	// 构建专项计划模型
	project := &model.SpecialProject{
		ID:          uint(projectID),
		Title:       request.Title,
		Description: request.Description,
		StartDate:   startDate,
		EndDate:     endDate,
		Status:      request.Status,
		Budget:      request.Budget,
	}

	// 调用服务
	projectService := &service.SpecialProjectService{}
	if err := projectService.UpdateSpecialProject(project); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "更新专项计划成功")
}

// DeleteSpecialProject 删除专项计划
func DeleteSpecialProject(c *gin.Context) {
	// 获取专项计划ID
	projectID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的专项计划ID")
		return
	}

	// 调用服务
	projectService := &service.SpecialProjectService{}
	if err := projectService.DeleteSpecialProject(uint(projectID)); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "删除专项计划成功")
}

// GetUserSpecialProjects 获取用户的专项计划列表
func GetUserSpecialProjects(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 调用服务
	projectService := &service.SpecialProjectService{}
	projects, err := projectService.GetUserSpecialProjects(userID)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, projects, "获取用户专项计划成功")
}

// GetFamilySpecialProjects 获取家庭的专项计划列表
func GetFamilySpecialProjects(c *gin.Context) {
	// 获取家庭ID
	familyID, err := strconv.ParseUint(c.Param("family_id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的家庭ID")
		return
	}

	// 调用服务
	projectService := &service.SpecialProjectService{}
	projects, err := projectService.GetFamilySpecialProjects(uint(familyID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, projects, "获取家庭专项计划成功")
}

// UpdateSpecialProjectStatus 更新专项计划状态
func UpdateSpecialProjectStatus(c *gin.Context) {
	// 获取专项计划ID
	projectID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的专项计划ID")
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
	validStatuses := map[string]bool{
		"planning":    true,
		"in_progress": true,
		"completed":   true,
		"canceled":    true,
	}

	if !validStatuses[request.Status] {
		utils.ParameterError(c, "无效的状态值")
		return
	}

	// 调用服务
	projectService := &service.SpecialProjectService{}
	if err := projectService.UpdateSpecialProjectStatus(uint(projectID), request.Status); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "更新专项计划状态成功")
}

// GetProjectPhases 获取专项计划的所有阶段
func GetProjectPhases(c *gin.Context) {
	// 获取专项计划ID
	projectID, err := strconv.ParseUint(c.Param("project_id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的专项计划ID")
		return
	}

	// 调用服务
	phaseService := &service.ProjectPhaseService{}
	phases, err := phaseService.GetPhasesByProjectID(uint(projectID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, phases, "获取专项计划阶段成功")
}

// GetPhase 获取阶段详情
func GetPhase(c *gin.Context) {
	// 获取阶段ID
	phaseID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的阶段ID")
		return
	}

	// 调用服务
	phaseService := &service.ProjectPhaseService{}
	phase, err := phaseService.GetPhaseByID(uint(phaseID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, phase, "获取阶段详情成功")
}

// CreatePhase 创建阶段
func CreatePhase(c *gin.Context) {
	// 绑定请求参数
	var request struct {
		SpecialProjectID uint   `json:"special_project_id" binding:"required"`
		Name             string `json:"name" binding:"required"`
		Description      string `json:"description"`
		ReferencePhaseID uint   `json:"reference_phase_id"` // 参考阶段ID，用于在指定阶段前后添加
		Position         string `json:"position"`           // 位置：before - 在参考阶段前添加，after - 在参考阶段后添加
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 验证 position 参数
	if request.ReferencePhaseID > 0 && request.Position != "" && request.Position != "before" && request.Position != "after" {
		utils.ParameterError(c, "position 参数必须是 'before' 或 'after'")
		return
	}

	// 构建阶段模型
	phase := &model.ProjectPhase{
		SpecialProjectID: request.SpecialProjectID,
		Name:             request.Name,
		Description:      request.Description,
	}

	// 调用服务
	phaseService := &service.ProjectPhaseService{}
	phaseID, err := phaseService.CreatePhase(phase, request.ReferencePhaseID, request.Position)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, gin.H{
		"id": phaseID,
	}, "创建阶段成功")
}

// UpdatePhase 更新阶段
func UpdatePhase(c *gin.Context) {
	// 获取阶段ID
	phaseID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的阶段ID")
		return
	}

	// 绑定请求参数
	var request struct {
		Name        string `json:"name"`
		Description string `json:"description"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 构建阶段模型
	phase := &model.ProjectPhase{
		ID:          uint(phaseID),
		Name:        request.Name,
		Description: request.Description,
	}

	// 调用服务
	phaseService := &service.ProjectPhaseService{}
	if err := phaseService.UpdatePhase(phase); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "更新阶段成功")
}

// DeletePhase 删除阶段
func DeletePhase(c *gin.Context) {
	// 获取阶段ID
	phaseID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的阶段ID")
		return
	}

	// 调用服务
	phaseService := &service.ProjectPhaseService{}
	if err := phaseService.DeletePhase(uint(phaseID)); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "删除阶段成功")
}

// ReorderPhases 重新排序阶段
func ReorderPhases(c *gin.Context) {
	// 获取专项计划ID
	projectID, err := strconv.ParseUint(c.Param("project_id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的专项计划ID")
		return
	}

	// 绑定请求参数
	var request struct {
		PhaseIDs []uint `json:"phase_ids" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "参数错误: "+err.Error())
		return
	}

	// 调用服务
	phaseService := &service.ProjectPhaseService{}
	if err := phaseService.ReorderPhases(uint(projectID), request.PhaseIDs); err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, nil, "重新排序阶段成功")
}

// GetPlansByPhaseID 获取阶段的所有计划
func GetPlansByPhaseID(c *gin.Context) {
	// 获取阶段ID
	phaseID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的阶段ID")
		return
	}

	// 调用服务
	planRepo := &repository.PlanRepository{}
	plans, err := planRepo.GetPlansByPhaseID(uint(phaseID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 转换为响应结构
	var responses []model.PlanResponse
	for _, plan := range plans {
		responses = append(responses, plan.ToResponse())
	}

	utils.Success(c, responses, "获取阶段计划成功")
}

// GetPlanCompletionHistory 获取计划的完成历史记录
func GetPlanCompletionHistory(c *gin.Context) {
	// 获取计划ID
	planID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的计划ID")
		return
	}

	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 调用服务
	planService := &service.PlanService{}
	records, err := planService.GetPlanCompletionHistory(uint(planID), userID)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	utils.Success(c, records, "获取计划完成历史成功")
}
