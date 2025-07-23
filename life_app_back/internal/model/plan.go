package model

import (
	"strconv"
	"strings"
	"time"
)

// Plan 计划模型
type Plan struct {
	ID             uint      `json:"id" gorm:"primaryKey"`
	UserID         uint      `json:"user_id"`          // 所属用户ID
	FamilyID       uint      `json:"family_id"`        // 所属家庭ID，0表示个人计划
	Title          string    `json:"title"`            // 计划标题
	Description    string    `json:"description"`      // 计划描述
	Date           time.Time `json:"date"`             // 计划日期
	StartTime      string    `json:"start_time"`       // 开始时间 (HH:MM格式)
	EndTime        string    `json:"end_time"`         // 结束时间 (HH:MM格式)
	Category       string    `json:"category"`         // 计划类别
	Priority       int       `json:"priority"`         // 优先级 (1-5)
	Status         string    `json:"status"`           // 状态 (pending, completed, canceled)
	CompletedAt    time.Time `json:"completed_at"`     // 完成时间
	ProjectPhaseID uint      `json:"project_phase_id"` // 关联的专项阶段ID，0表示普通计划
	RecurrenceType string    `json:"recurrence_type"` // 重复类型 (once, daily, weekly, monthly, weekdays, weekends)
	Cost           float64   `json:"cost"`            // 费用
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

// TableName 指定表名
func (Plan) TableName() string {
	return "plan"
}

// PlanCompletionRecord 计划完成记录表
type PlanCompletionRecord struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	PlanID    uint      `json:"plan_id"`    // 关联的计划ID
	UserID    uint      `json:"user_id"`    // 完成用户ID
	Date      time.Time `json:"date"`       // 完成日期
	CreatedAt time.Time `json:"created_at"` // 创建时间
}

// TableName 指定表名
func (PlanCompletionRecord) TableName() string {
	return "plan_completion_records"
}

// PlanResponse 计划响应结构
type PlanResponse struct {
	ID             uint      `json:"id"`
	UserID         uint      `json:"user_id"`
	FamilyID       uint      `json:"family_id"`
	Title          string    `json:"title"`
	Description    string    `json:"description"`
	Date           time.Time `json:"date"`
	StartTime      string    `json:"start_time"`
	EndTime        string    `json:"end_time"`
	Category       string    `json:"category"`
	Priority       int       `json:"priority"`
	Status         string    `json:"status"`
	CompletedAt    time.Time `json:"completed_at"`
	ProjectPhaseID uint      `json:"project_phase_id"`
	PhaseName      string    `json:"phase_name,omitempty"`   // 阶段名称（如果有）
	ProjectName    string    `json:"project_name,omitempty"` // 专项计划名称（如果有）
	IsOverdue      bool      `json:"is_overdue"`             // 是否已过期
	RecurrenceType string    `json:"recurrence_type"`       // 重复类型
	IsCompletedToday bool    `json:"is_completed_today"`    // 今日是否已完成（针对重复任务）
	Cost           float64   `json:"cost"`                  // 费用
	CreatedAt      time.Time `json:"created_at"`
}

// ToResponse 将模型转换为响应
func (p *Plan) ToResponse() PlanResponse {
	now := time.Now()
	planDate := p.Date
	isOverdue := false

	// 如果状态是待完成，则检查是否过期
	if p.Status == "pending" {
		// 先判断日期
		if planDate.Year() < now.Year() || 
		   (planDate.Year() == now.Year() && planDate.Month() < now.Month()) || 
		   (planDate.Year() == now.Year() && planDate.Month() == now.Month() && planDate.Day() < now.Day()) {
			// 如果日期已过，则标记为已过期
			isOverdue = true
		} else if planDate.Year() == now.Year() && planDate.Month() == now.Month() && planDate.Day() == now.Day() {
			// 如果是当天，则比较结束时间
			if p.EndTime != "" {
				// 解析结束时间
				parts := strings.Split(p.EndTime, ":")
				if len(parts) == 2 {
					endHour, errHour := strconv.Atoi(parts[0])
					endMinute, errMinute := strconv.Atoi(parts[1])
					
					if errHour == nil && errMinute == nil {
						// 如果当前时间已经超过了结束时间，则标记为已过期
						if now.Hour() > endHour || (now.Hour() == endHour && now.Minute() > endMinute) {
							isOverdue = true
						}
					}
				}
			}
		}
	}
	
	return PlanResponse{
		ID:             p.ID,
		UserID:         p.UserID,
		FamilyID:       p.FamilyID,
		Title:          p.Title,
		Description:    p.Description,
		Date:           p.Date,
		StartTime:      p.StartTime,
		EndTime:        p.EndTime,
		Category:       p.Category,
		Priority:       p.Priority,
		Status:         p.Status,
		CompletedAt:    p.CompletedAt,
		ProjectPhaseID: p.ProjectPhaseID,
		IsOverdue:      isOverdue,
		RecurrenceType: p.RecurrenceType,
		Cost:           p.Cost,
		CreatedAt:      p.CreatedAt,
	}
}

// SpecialProject 专项计划模型
type SpecialProject struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	UserID      uint      `json:"user_id"`     // 所属用户ID
	FamilyID    uint      `json:"family_id"`   // 所属家庭ID，0表示个人专项计划
	Title       string    `json:"title"`       // 专项计划标题
	Description string    `json:"description"` // 专项计划描述
	StartDate   time.Time `json:"start_date"`  // 开始日期
	EndDate     time.Time `json:"end_date"`    // 结束日期
	Status      string    `json:"status"`      // 状态 (planning, in_progress, completed, canceled)
	Budget      float64   `json:"budget"`      // 预算金额
	ActualCost  float64   `json:"actual_cost"` // 实际花费
	Progress    float64   `json:"progress"`    // 进度百分比
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// TableName 指定表名
func (SpecialProject) TableName() string {
	return "special_projects"
}

// SpecialProjectResponse 专项计划响应结构
type SpecialProjectResponse struct {
	ID             uint                   `json:"id"`
	UserID         uint                   `json:"user_id"`
	FamilyID       uint                   `json:"family_id"`
	Title          string                 `json:"title"`
	Description    string                 `json:"description"`
	StartDate      time.Time              `json:"start_date"`
	EndDate        time.Time              `json:"end_date"`
	Status         string                 `json:"status"`
	Budget         float64                `json:"budget"`
	ActualCost     float64                `json:"actual_cost"`
	Progress       float64                `json:"progress"`
	TotalTasks     int                    `json:"total_tasks"`
	CompletedTasks int                    `json:"completed_tasks"`
	Phases         []ProjectPhaseResponse `json:"phases,omitempty"`
	DaysRemaining  int                    `json:"days_remaining"`
	IsOverdue      bool                   `json:"is_overdue"`
	CreatedAt      time.Time              `json:"created_at"`
}

// ToResponse 将模型转换为响应
func (sp *SpecialProject) ToResponse() SpecialProjectResponse {
	now := time.Now()
	daysRemaining := int(sp.EndDate.Sub(now).Hours() / 24)
	if daysRemaining < 0 {
		daysRemaining = 0
	}

	isOverdue := sp.EndDate.Before(now) && sp.Status != "completed" && sp.Status != "canceled"

	return SpecialProjectResponse{
		ID:            sp.ID,
		UserID:        sp.UserID,
		FamilyID:      sp.FamilyID,
		Title:         sp.Title,
		Description:   sp.Description,
		StartDate:     sp.StartDate,
		EndDate:       sp.EndDate,
		Status:        sp.Status,
		Budget:        sp.Budget,
		ActualCost:    sp.ActualCost,
		Progress:      sp.Progress,
		DaysRemaining: daysRemaining,
		IsOverdue:     isOverdue,
		CreatedAt:     sp.CreatedAt,
	}
}

// ProjectPhase 专项计划阶段模型
type ProjectPhase struct {
	ID               uint      `json:"id" gorm:"primaryKey"`
	SpecialProjectID uint      `json:"special_project_id"` // 所属专项计划ID
	Name             string    `json:"name"`               // 阶段名称
	Description      string    `json:"description"`        // 阶段描述
	OrderIndex       int       `json:"order_index"`        // 阶段顺序
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

// TableName 指定表名
func (ProjectPhase) TableName() string {
	return "project_phases"
}

// ProjectPhaseResponse 专项计划阶段响应结构
type ProjectPhaseResponse struct {
	ID               uint           `json:"id"`
	SpecialProjectID uint           `json:"special_project_id"`
	Name             string         `json:"name"`
	Description      string         `json:"description"`
	OrderIndex       int            `json:"order_index"`
	TotalTasks       int            `json:"total_tasks"`
	CompletedTasks   int            `json:"completed_tasks"`
	Progress         float64        `json:"progress"`
	Plans            []PlanResponse `json:"plans,omitempty"`
	CreatedAt        time.Time      `json:"created_at"`
}

// ToResponse 将模型转换为响应
func (pp *ProjectPhase) ToResponse() ProjectPhaseResponse {
	return ProjectPhaseResponse{
		ID:               pp.ID,
		SpecialProjectID: pp.SpecialProjectID,
		Name:             pp.Name,
		Description:      pp.Description,
		OrderIndex:       pp.OrderIndex,
		CreatedAt:        pp.CreatedAt,
	}
}

// PlanReminder 计划提醒模型
type PlanReminder struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	PlanID    uint      `json:"plan_id"`   // 关联的计划ID
	UserID    uint      `json:"user_id"`   // 所属用户ID
	RemindAt  time.Time `json:"remind_at"` // 提醒时间
	IsRead    bool      `json:"is_read"`   // 是否已读
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// TableName 指定表名
func (PlanReminder) TableName() string {
	return "plan_reminders"
}

// PlanReminderResponse 计划提醒响应结构
type PlanReminderResponse struct {
	ID       uint         `json:"id"`
	PlanID   uint         `json:"plan_id"`
	UserID   uint         `json:"user_id"`
	RemindAt time.Time    `json:"remind_at"`
	IsRead   bool         `json:"is_read"`
	Plan     PlanResponse `json:"plan,omitempty"`
}

// ToResponse 将模型转换为响应
func (pr *PlanReminder) ToResponse() PlanReminderResponse {
	return PlanReminderResponse{
		ID:       pr.ID,
		PlanID:   pr.PlanID,
		UserID:   pr.UserID,
		RemindAt: pr.RemindAt,
		IsRead:   pr.IsRead,
	}
}

// DailyPlanSummary 每日计划摘要
type DailyPlanSummary struct {
	Date           time.Time `json:"date"`
	TotalPlans     int       `json:"total_plans"`
	CompletedPlans int       `json:"completed_plans"`
	Progress       float64   `json:"progress"`
}

// MonthlyPlanSummary 月度计划摘要
type MonthlyPlanSummary struct {
	Year           int                `json:"year"`
	Month          int                `json:"month"`
	TotalPlans     int                `json:"total_plans"`
	CompletedPlans int                `json:"completed_plans"`
	Progress       float64            `json:"progress"`
	DailySummaries []DailyPlanSummary `json:"daily_summaries"`
}

// DailyPlansGroup 按日期分组的计划列表
type DailyPlansGroup struct {
	Date  string        `json:"date"`           // YYYY-MM-DD格式的日期
	Day   int           `json:"day"`            // 日期中的天（1-31）
	Plans []PlanResponse `json:"plans"`         // 该日期的计划列表
}

// MonthlyPlansGrouped 按日期分组的月度计划
type MonthlyPlansGrouped struct {
	Year       int              `json:"year"`
	Month      int              `json:"month"`
	DailyPlans []DailyPlansGroup `json:"daily_plans"` // 按日期分组的计划
}