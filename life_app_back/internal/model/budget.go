// MonthlyBudgetRequest 按月查询预算请求
package model

type MonthlyBudgetRequest struct {
	Year           int  `form:"year" json:"year"`
	Month          int  `form:"month" json:"month"`
	IsFamilyBudget bool `form:"is_family_budget" json:"is_family_budget"`
	FamilyId       int  `form:"family_id" json:"family_id"`
}

// MonthlyBudgetResponse 月度预算响应
type MonthlyBudgetResponse struct {
	TotalBudget     float64                   `json:"total_budget"`     // 总预算
	TotalSpent      float64                   `json:"total_spent"`      // 总支出
	RemainingAmount float64                   `json:"remaining_amount"` // 剩余金额
	UsagePercent    float64                   `json:"usage_percent"`    // 使用百分比
	Categories      []BudgetCategoryWithUsage `json:"categories"`       // 预算及使用情况
}

// BudgetCategoryWithUsage 带使用情况的预算
type BudgetCategoryWithUsage struct {
	ID           int     `json:"id"`
	Name         string  `json:"name"`
	Amount       float64 `json:"amount"`        // 预算金额
	SpentAmount  float64 `json:"spent_amount"`  // 已使用金额
	IconId       string  `json:"icon_id"`       // 图标代码
	Notes        string  `json:"notes"`         // 备注
	UsagePercent float64 `json:"usage_percent"` // 使用百分比
}
