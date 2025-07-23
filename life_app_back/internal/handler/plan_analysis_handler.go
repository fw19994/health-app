package handler

import (
	"github.com/gin-gonic/gin"
	"life_app_back/internal/model"
	"life_app_back/internal/repository"
	"life_app_back/internal/utils"
	"strconv"
	"time"
)

// PlanAnalysisResponse 计划分析响应结构
type PlanAnalysisResponse struct {
	Summary         PlanSummary      `json:"summary"`
	CompletionStats CompletionStats  `json:"completion_stats"`
	TrendAnalysis   TrendAnalysis    `json:"trend_analysis"`
	Recommendations []Recommendation `json:"recommendations"`
	HabitAnalysis   []HabitAnalysis  `json:"habit_analysis"`
}

// PlanSummary AI总结部分
type PlanSummary struct {
	Text        string    `json:"text"`
	Suggestions []string  `json:"suggestions"`
	Warnings    []string  `json:"warnings"`
	LastUpdated time.Time `json:"last_updated"`
}

// CompletionStats 完成情况统计
type CompletionStats struct {
	TotalCompletionRate float64                  `json:"total_completion_rate"`
	GrowthRate          float64                  `json:"growth_rate"`
	CompletedCount      int                      `json:"completed_count"`
	UncompletedCount    int                      `json:"uncompleted_count"`
	CategoryStats       []CategoryCompletionStat `json:"category_stats"`
	HeatmapData         [][]int                  `json:"heatmap_data"`
}

// CategoryCompletionStat 类别完成情况
type CategoryCompletionStat struct {
	Category       string  `json:"category"`
	CompletionRate float64 `json:"completion_rate"`
}

// TrendAnalysis 趋势分析
type TrendAnalysis struct {
	ChartData   []ChartPoint `json:"chart_data"`
	KeyFindings []string     `json:"key_findings"`
}

// ChartPoint 图表数据点
type ChartPoint struct {
	Date       string             `json:"date"`
	Categories map[string]float64 `json:"categories"`
}

// Recommendation 改进建议
type Recommendation struct {
	Type        string `json:"type"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Icon        string `json:"icon"`
}

// HabitAnalysis 习惯分析
type HabitAnalysis struct {
	Title       string  `json:"title"`
	Description string  `json:"description"`
	Status      string  `json:"status"`
	Icon        string  `json:"icon"`
	Streak      int     `json:"streak"`
	Rate        float64 `json:"rate"`
}

// GetPlanAnalysis 获取计划分析数据
func GetPlanAnalysis(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取查询参数
	year, _ := strconv.Atoi(c.DefaultQuery("year", strconv.Itoa(time.Now().Year())))
	month, _ := strconv.Atoi(c.DefaultQuery("month", strconv.Itoa(int(time.Now().Month()))))
	familyIDStr := c.DefaultQuery("family_id", "0")
	familyID, _ := strconv.ParseUint(familyIDStr, 10, 32)

	// 获取指定月份的所有计划
	planRepo := &repository.PlanRepository{}
	var plans []model.Plan
	var err error

	if familyID > 0 {
		plans, err = planRepo.GetFamilyMonthlyPlans(uint(familyID), year, month)
	} else {
		plans, err = planRepo.GetMonthlyPlans(userID, year, month)
	}

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 计算各种统计数据
	totalPlans := len(plans)
	completedPlans := 0
	canceledPlans := 0
	pendingPlans := 0
	overduePlans := 0
	categoryStats := make(map[string]int)
	priorityStats := make(map[int]int)
	dailyCompletionStats := make(map[string]int)
	now := time.Now()

	for _, plan := range plans {
		// 统计状态
		switch plan.Status {
		case "completed":
			completedPlans++
			// 记录完成日期的统计
			if !plan.CompletedAt.IsZero() {
				dateStr := plan.CompletedAt.Format("2006-01-02")
				dailyCompletionStats[dateStr]++
			}
		case "canceled":
			canceledPlans++
		case "pending":
			pendingPlans++
			// 检查是否已过期
			if plan.Date.Before(now) {
				overduePlans++
		}
	}

		// 统计类别
		categoryStats[plan.Category]++

		// 统计优先级
		priorityStats[plan.Priority]++
	}

	// 计算完成率
	completionRate := 0.0
	if totalPlans > 0 {
		completionRate = float64(completedPlans) / float64(totalPlans) * 100
	}

	// 构建响应数据
	response := gin.H{
		"total_plans":      totalPlans,
		"completed_plans":  completedPlans,
		"canceled_plans":   canceledPlans,
		"pending_plans":    pendingPlans,
		"overdue_plans":    overduePlans,
		"completion_rate":  completionRate,
		"category_stats":   categoryStats,
		"priority_stats":   priorityStats,
		"daily_completion": dailyCompletionStats,
	}

	utils.Success(c, response, "获取计划分析数据成功")
}

// GetSpecialProjectAnalysis 获取专项计划分析数据
func GetSpecialProjectAnalysis(c *gin.Context) {
	// 获取专项计划ID
	projectID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的专项计划ID")
		return
	}

	// 获取专项计划信息
	projectRepo := &repository.SpecialProjectRepository{}
	project, err := projectRepo.GetSpecialProjectByID(uint(projectID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 获取专项计划的所有阶段
	phaseRepo := &repository.ProjectPhaseRepository{}
	phases, err := phaseRepo.GetPhasesByProjectID(uint(projectID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 计算各种统计数据
	totalTasks := 0
	completedTasks := 0
	phaseStats := make([]gin.H, 0)
	now := time.Now()

	// 计算已经过去的天数和剩余天数
	daysPassed := int(now.Sub(project.StartDate).Hours() / 24)
	if daysPassed < 0 {
		daysPassed = 0
	}
	
	totalDays := int(project.EndDate.Sub(project.StartDate).Hours() / 24)
	if totalDays <= 0 {
		totalDays = 1 // 避免除以零
	}
	
	daysRemaining := int(project.EndDate.Sub(now).Hours() / 24)
	if daysRemaining < 0 {
		daysRemaining = 0
	}

	// 计算时间进度百分比
	timeProgress := float64(daysPassed) / float64(totalDays) * 100
	if timeProgress > 100 {
		timeProgress = 100
}

	// 分析每个阶段
	for _, phase := range phases {
		// 获取阶段的所有计划
		planRepo := &repository.PlanRepository{}
		plans, err := planRepo.GetPlansByPhaseID(phase.ID)
		if err != nil {
			continue
		}

		phaseTotalTasks := len(plans)
		phaseCompletedTasks := 0

		for _, plan := range plans {
			if plan.Status == "completed" {
				phaseCompletedTasks++
		}
	}

		totalTasks += phaseTotalTasks
		completedTasks += phaseCompletedTasks

		// 计算阶段进度
		phaseProgress := 0.0
		if phaseTotalTasks > 0 {
			phaseProgress = float64(phaseCompletedTasks) / float64(phaseTotalTasks) * 100
		}

		phaseStats = append(phaseStats, gin.H{
			"phase_id":        phase.ID,
			"name":            phase.Name,
			"total_tasks":     phaseTotalTasks,
			"completed_tasks": phaseCompletedTasks,
			"progress":        phaseProgress,
		})
}

	// 计算总进度
	taskProgress := 0.0
	if totalTasks > 0 {
		taskProgress = float64(completedTasks) / float64(totalTasks) * 100
}

	// 计算进度差异 (任务进度 - 时间进度)
	progressDifference := taskProgress - timeProgress

	// 构建响应数据
	response := gin.H{
		"project_id":          project.ID,
		"title":               project.Title,
		"start_date":          project.StartDate,
		"end_date":            project.EndDate,
		"days_passed":         daysPassed,
		"days_remaining":      daysRemaining,
		"total_days":          totalDays,
		"time_progress":       timeProgress,
		"task_progress":       taskProgress,
		"progress_difference": progressDifference,
		"total_tasks":         totalTasks,
		"completed_tasks":     completedTasks,
		"budget":              project.Budget,
		"actual_cost":         project.ActualCost,
		"phase_stats":         phaseStats,
		"is_overdue":          project.EndDate.Before(now) && project.Status != "completed" && project.Status != "canceled",
	}

	utils.Success(c, response, "获取专项计划分析数据成功")
}
