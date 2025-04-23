package model

import (
	"time"
)

// 储蓄目标状态常量
const (
	SavingsGoalStatusInProgress = "in_progress" // 进行中
	SavingsGoalStatusCompleted  = "completed"   // 已完成
	SavingsGoalStatusDeleted    = "deleted"     // 已删除
)

// SavingsGoal 储蓄目标模型
type SavingsGoal struct {
	ID            uint       `json:"id" gorm:"primaryKey"`
	UserID        uint       `json:"user_id"`        // 所属用户ID
	IsFamilyGoal  bool       `json:"is_family_goal"` // 是否为家庭储蓄目标
	FamilyID      uint       `json:"family_id"`      // 家庭ID，当is_family_goal为true时有效
	Name          string     `json:"name"`           // 目标名称
	IconID        uint       `json:"icon_id"`        // 图标ID
	TargetAmount  float64    `json:"target_amount"`  // 目标金额
	CurrentAmount float64    `json:"current_amount"` // 当前金额
	Description   string     `json:"description"`
	MonthlyTarget float64    `json:"monthly_target"`                      // 每月目标存款
	TargetDate    time.Time  `json:"target_date"`                         // 目标日期
	Note          string     `json:"note"`                                // 备注
	Status        string     `json:"status" gorm:"default:'in_progress'"` // 状态：进行中、已完成、已删除
	CompletedAt   *time.Time `json:"completed_at"`                        // 完成时间
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
}

// TableName 指定表名
func (SavingsGoal) TableName() string {
	return "savings_goals"
}

// SavingsGoalResponse 储蓄目标响应结构
type SavingsGoalResponse struct {
	ID            uint    `json:"id"`
	UserID        uint    `json:"user_id"`
	IsFamilyGoal  bool    `json:"is_family_goal"`
	FamilyID      uint    `json:"family_id"`
	Name          string  `json:"name"`
	IconID        uint    `json:"icon_id"`
	Color         string  `json:"color"`
	TargetAmount  float64 `json:"target_amount"`
	CurrentAmount float64 `json:"current_amount"`
	MonthlyTarget float64 `json:"monthly_target"`
	TargetDate    string  `json:"target_date"`
	Note          string  `json:"note"`
	Progress      float64 `json:"progress"`     // 完成进度百分比
	MonthsLeft    int     `json:"months_left"`  // 剩余月数
	IsCompleted   bool    `json:"is_completed"` // 是否已完成
	Status        string  `json:"status"`       // 状态：进行中、已完成、已删除
	CompletedAt   string  `json:"completed_at"` // 完成时间，格式化为字符串
}

// ToResponse 将模型转换为响应
func (sg *SavingsGoal) ToResponse() SavingsGoalResponse {
	progress := 0.0
	if sg.TargetAmount > 0 {
		progress = (sg.CurrentAmount / sg.TargetAmount) * 100
	}

	// 计算剩余月数
	now := time.Now()
	monthsLeft := (sg.TargetDate.Year()-now.Year())*12 + int(sg.TargetDate.Month()-now.Month())
	if monthsLeft < 0 {
		monthsLeft = 0
	}

	// 确保状态字段有效
	status := sg.Status
	if status == "" {
		status = SavingsGoalStatusInProgress
	}

	// 处理完成时间
	var completedAtStr string
	if sg.CompletedAt != nil {
		completedAtStr = sg.CompletedAt.Format("2006-01-02")
	}

	return SavingsGoalResponse{
		ID:            sg.ID,
		UserID:        sg.UserID,
		IsFamilyGoal:  sg.IsFamilyGoal,
		FamilyID:      sg.FamilyID,
		Name:          sg.Name,
		IconID:        sg.IconID,
		TargetAmount:  sg.TargetAmount,
		CurrentAmount: sg.CurrentAmount,
		MonthlyTarget: sg.MonthlyTarget,
		TargetDate:    sg.TargetDate.Format("2006-01-02"),
		Note:          sg.Description,
		Progress:      progress,
		MonthsLeft:    monthsLeft,
		IsCompleted:   sg.CurrentAmount >= sg.TargetAmount,
		Status:        status,
		CompletedAt:   completedAtStr,
	}
}
