package model

import (
	"time"
)

// BudgetCategory 预算类别模型
type BudgetCategory struct {
	ID                uint      `json:"id" gorm:"primaryKey"`
	UserID            uint      `json:"user_id"`            // 所属用户ID
	IsFamilyBudget    bool      `json:"is_family_budget"`   // 是否为家庭预算
	FamilyID          uint      `json:"family_id"`          // 家庭ID，当is_family_budget为true时有效
	Name              string    `json:"name"`               // 预算名称
	Description       string    `json:"description"`        // 预算描述
	IconID            uint      `json:"icon_id"`            // 图标ID
	Budget            float64   `json:"budget"`             // 预算金额
	Spent             float64   `json:"spent"`              // 已使用金额
	Year              int       `json:"year"`               // 预算年份
	Month             int       `json:"month"`              // 预算月份
	ReminderThreshold int       `json:"reminder_threshold"` // 提醒阈值，70/80/90/100或null
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
}

// TableName 指定表名
func (BudgetCategory) TableName() string {
	return "budget_categories"
}

// BudgetCategoryResponse 预算类别响应结构
type BudgetCategoryResponse struct {
	ID                uint    `json:"id"`
	UserID            uint    `json:"user_id"`
	IsFamilyBudget    bool    `json:"is_family_budget"`
	FamilyID          uint    `json:"family_id"`
	Name              string  `json:"name"`
	Description       string  `json:"description"`
	IconID            uint    `json:"icon_id"`
	Color             string  `json:"color"`
	Budget            float64 `json:"budget"`
	Spent             float64 `json:"spent"`
	Year              int     `json:"year"`
	Month             int     `json:"month"`
	ReminderThreshold int     `json:"reminder_threshold"`
	MonthOverMonth    float64 `json:"month_over_month"` // 环比变化百分比
	UsagePercentage   float64 `json:"usage_percentage"` // 使用百分比
	IsOverBudget      bool    `json:"is_over_budget"`   // 是否超出预算
}

// ToResponse 将模型转换为响应
func (bc *BudgetCategory) ToResponse() BudgetCategoryResponse {
	usagePercentage := 0.0
	if bc.Budget > 0 {
		usagePercentage = (bc.Spent / bc.Budget) * 100
	}

	return BudgetCategoryResponse{
		ID:                bc.ID,
		UserID:            bc.UserID,
		IsFamilyBudget:    bc.IsFamilyBudget,
		FamilyID:          bc.FamilyID,
		Name:              bc.Name,
		Description:       bc.Description,
		IconID:            bc.IconID,
		Budget:            bc.Budget,
		Spent:             bc.Spent,
		Year:              bc.Year,
		Month:             bc.Month,
		ReminderThreshold: bc.ReminderThreshold,
		MonthOverMonth:    0, // 需要在service层计算
		UsagePercentage:   usagePercentage,
		IsOverBudget:      bc.Spent > bc.Budget,
	}
}
