package service

import (
	"errors"
	"life_app_back/internal/model"
	"life_app_back/internal/repository"
	"time"
)

// PlanService 计划服务
type PlanService struct {
	repo repository.PlanRepository
}

// CreatePlanRequest 创建计划请求
type CreatePlanRequest struct {
	Title           string  `json:"title" binding:"required"`
	Description     string  `json:"description"`
	Date            string  `json:"date" binding:"required"`
	StartTime       string  `json:"start_time"`
	EndTime         string  `json:"end_time"`
	Category        string  `json:"category" binding:"required"`
	Priority        int     `json:"priority"`
	ReminderType    string  `json:"reminder_type"`
	ReminderMinutes int     `json:"reminder_minutes"`
	RecurrenceType  string  `json:"recurrence_type" binding:"required"`
	RecurrenceDays  []int   `json:"recurrence_days"`
	IsPinned        bool    `json:"is_pinned"`
	ProjectPhaseID  uint    `json:"project_phase_id"`
	Cost            float64 `json:"cost"`
}

// CreatePlan 创建计划
func (s *PlanService) CreatePlan(userID uint, req CreatePlanRequest) (model.PlanResponse, error) {
	// 参数验证
	if req.Title == "" {
		return model.PlanResponse{}, errors.New("计划标题不能为空")
	}

	// 验证重复类型
	if !isValidRecurrenceType(req.RecurrenceType) {
		return model.PlanResponse{}, errors.New("无效的重复类型")
	}

	// 将日期字符串转换为时间对象
	date, err := time.Parse("2006-01-02", req.Date)
	if err != nil {
		return model.PlanResponse{}, errors.New("无效的日期格式，请使用YYYY-MM-DD格式")
	}

	// 创建计划模型
	plan := model.Plan{
		UserID:         userID,
		Title:          req.Title,
		Description:    req.Description,
		Date:           date,
		StartTime:      req.StartTime,
		EndTime:        req.EndTime,
		Category:       req.Category,
		Priority:       req.Priority,
		Status:         "pending",
		ProjectPhaseID: req.ProjectPhaseID,
		RecurrenceType: req.RecurrenceType,
		Cost:           req.Cost,
		CompletedAt:    time.Now(),
	}

	// 调用仓库层创建计划
	err = s.repo.CreatePlan(&plan)
	if err != nil {
		return model.PlanResponse{}, err
	}

	// 获取创建后的计划
	createdPlan, err := s.repo.GetPlanByID(plan.ID)
	if err != nil {
		return model.PlanResponse{}, err
	}

	// 转换为响应模型
	response := createdPlan.ToResponse()

	return response, nil
}

// GetPlanByID 根据ID获取计划
func (s *PlanService) GetPlanByID(planID uint) (model.PlanResponse, error) {
	// 查询计划
	plan, err := s.repo.GetPlanByID(planID)
	if err != nil {
		return model.PlanResponse{}, err
	}

	// 转换为响应模型
	response := plan.ToResponse()

	return response, nil
}

// GetUserPlans 获取用户的所有计划
func (s *PlanService) GetUserPlans(userID uint) ([]model.PlanResponse, error) {
	// 查询用户的所有计划（使用当前日期获取当天的计划）
	plans, err := s.repo.GetDailyPlans(userID, time.Now())
	if err != nil {
		return nil, err
	}

	// 转换为响应模型
	responses := make([]model.PlanResponse, len(plans))
	for i, plan := range plans {
		responses[i] = plan.ToResponse()
	}

	return responses, nil
}

// GetPlansByDate 获取指定日期的计划
func (s *PlanService) GetPlansByDate(userID uint, date time.Time) ([]model.PlanResponse, error) {
	// 查询指定日期的计划
	plans, err := s.repo.GetDailyPlans(userID, date)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型并检查重复计划的完成状态
	responses := make([]model.PlanResponse, len(plans))
	for i, plan := range plans {
		responses[i] = plan.ToResponse()

		// 如果是重复类型的计划，检查指定日期是否已完成
		isCompletedToday, err := s.repo.CheckPlanCompletionToday(plan.ID, date)
		if err == nil && isCompletedToday {
			responses[i].IsCompletedToday = true
			responses[i].Status = "completed" // 在UI上显示为已完成
		}
	}
	return responses, nil
}

// GetFamilyPlansByDate 获取指定家庭指定日期的计划
func (s *PlanService) GetFamilyPlansByDate(familyID uint, date time.Time) ([]model.PlanResponse, error) {
	// 查询指定家庭指定日期的计划
	plans, err := s.repo.GetFamilyDailyPlans(familyID, date)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型并检查重复计划的完成状态
	responses := make([]model.PlanResponse, len(plans))
	for i, plan := range plans {
		responses[i] = plan.ToResponse()

		// 检查指定日期是否已完成
		isCompletedToday, err := s.repo.CheckPlanCompletionToday(plan.ID, date)
		if err == nil && isCompletedToday {
			responses[i].IsCompletedToday = true
			responses[i].Status = "completed" // 在UI上显示为已完成
		}
	}

	return responses, nil
}

// UpdatePlanRequest 更新计划请求
type UpdatePlanRequest struct {
	Title          string  `json:"title"`
	Description    string  `json:"description"`
	Date           string  `json:"date"`
	StartTime      string  `json:"start_time"`
	EndTime        string  `json:"end_time"`
	Category       string  `json:"category"`
	Priority       int     `json:"priority"`
	RecurrenceType string  `json:"recurrence_type"`
	ProjectPhaseID uint    `json:"project_phase_id"`
	Cost           float64 `json:"cost"`
}

// UpdatePlan 更新计划
func (s *PlanService) UpdatePlan(planID uint, userID uint, req UpdatePlanRequest) (model.PlanResponse, error) {
	// 查询计划
	plan, err := s.repo.GetPlanByID(planID)
	if err != nil {
		return model.PlanResponse{}, err
	}

	// 验证所有权
	if plan.UserID != userID {
		return model.PlanResponse{}, errors.New("无权操作此计划")
	}

	// 更新字段
	if req.Title != "" {
		plan.Title = req.Title
	}
	plan.Description = req.Description

	if req.Date != "" {
		// 将日期字符串转换为时间对象
		date, err := time.Parse("2006-01-02", req.Date)
		if err != nil {
			return model.PlanResponse{}, errors.New("无效的日期格式，请使用YYYY-MM-DD格式")
		}
		plan.Date = date
	}

	if req.StartTime != "" {
		plan.StartTime = req.StartTime
	}

	if req.EndTime != "" {
		plan.EndTime = req.EndTime
	}

	if req.Category != "" {
		if !isValidCategory(req.Category) {
			return model.PlanResponse{}, errors.New("无效的计划类别")
		}
		plan.Category = req.Category
	}

	if req.Priority > 0 {
		plan.Priority = req.Priority
	}

	if req.RecurrenceType != "" {
		if !isValidRecurrenceType(req.RecurrenceType) {
			return model.PlanResponse{}, errors.New("无效的重复类型")
		}
		plan.RecurrenceType = req.RecurrenceType
	}

	if req.ProjectPhaseID > 0 {
		plan.ProjectPhaseID = req.ProjectPhaseID
	}
	
	// 更新费用字段
	plan.Cost = req.Cost

	// 调用仓库层更新计划
	if err := s.repo.UpdatePlan(plan); err != nil {
		return model.PlanResponse{}, err
	}

	// 获取更新后的计划
	updatedPlan, err := s.repo.GetPlanByID(planID)
	if err != nil {
		return model.PlanResponse{}, err
	}

	// 转换为响应模型
	response := updatedPlan.ToResponse()

	// 如果是重复类型的计划，检查今天是否已完成
	if updatedPlan.RecurrenceType != "once" && updatedPlan.RecurrenceType != "" {
		isCompletedToday, err := s.repo.CheckPlanCompletionToday(updatedPlan.ID, time.Now())
		if err == nil && isCompletedToday {
			response.IsCompletedToday = true
			response.Status = "completed" // 在UI上显示为已完成
		}
	}

	return response, nil
}

// DeletePlan 删除计划
func (s *PlanService) DeletePlan(planID uint, userID uint) error {
	// 查询计划
	plan, err := s.repo.GetPlanByID(planID)
	if err != nil {
		return err
	}

	// 验证所有权
	if plan.UserID != userID {
		return errors.New("无权操作此计划")
	}

	// 如果是重复类型的计划，删除所有完成记录
	if plan.RecurrenceType != "once" && plan.RecurrenceType != "" {
		if err := s.repo.DeletePlanCompletionRecords(planID); err != nil {
			return err
		}
	}

	// 调用仓库层删除计划
	return s.repo.DeletePlan(planID)
}

// MarkPlanAsCompleted 标记计划为已完成
func (s *PlanService) MarkPlanAsCompleted(planID uint, userID uint, date time.Time) error {
	// 查询计划
	plan, err := s.repo.GetPlanByID(planID)
	if err != nil {
		return err
	}

	// 验证所有权
	if plan.UserID != userID {
		return errors.New("无权操作此计划")
	}

	// 调用仓库层更新计划状态
	return s.repo.CompletePlan(planID, userID, date)
}

// CancelPlan 取消计划
func (s *PlanService) CancelPlan(planID uint, userID uint) error {
	// 查询计划
	plan, err := s.repo.GetPlanByID(planID)
	if err != nil {
		return err
	}

	// 验证所有权
	if plan.UserID != userID {
		return errors.New("无权操作此计划")
	}

	// 调用仓库层更新计划状态
	return s.repo.CancelPlan(planID)
}

// GetPlanCompletionHistory 获取计划的完成历史记录
func (s *PlanService) GetPlanCompletionHistory(planID uint, userID uint) ([]model.PlanCompletionRecord, error) {
	// 查询计划
	plan, err := s.repo.GetPlanByID(planID)
	if err != nil {
		return nil, err
	}

	// 验证所有权
	if plan.UserID != userID {
		return nil, errors.New("无权查看此计划")
	}

	// 获取完成记录
	return s.repo.GetPlanCompletionRecords(planID)
}

// 辅助函数：验证计划类别
func isValidCategory(category string) bool {
	validCategories := map[string]bool{
		"work":     true,
		"personal": true,
		"health":   true,
		"family":   true,
	}
	return validCategories[category]
}

// 辅助函数：验证重复类型
func isValidRecurrenceType(recurrenceType string) bool {
	validTypes := map[string]bool{
		"once":     true,
		"daily":    true,
		"weekly":   true,
		"monthly":  true,
		"weekdays": true,
		"weekends": true,
	}
	return validTypes[recurrenceType]
}
