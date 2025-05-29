package model

import (
	"time"
)

// TransactionType 定义交易类型枚举
type TransactionType string

const (
	Expense string = "expense" // 支出
	Income  string = "income"  // 收入
)

// Transaction 记账记录模型
type Transaction struct {
	ID              uint      `json:"id" gorm:"primaryKey"`
	UserID          uint      `json:"user_id" gorm:"index;comment:用户ID"` // 添加索引以优化查询
	Type            string    `json:"type" gorm:"type:varchar(10);not null;index;comment:交易类型(expense/income)"`
	Amount          float64   `json:"amount" gorm:"not null;comment:金额"`
	IconID          int       `json:"icon_id" gorm:"comment:关联的图标ID"`
	CategoryID      int       `json:"category_id" gorm:"index;comment:交易分类ID"`
	Date            time.Time `json:"date" gorm:"not null;index;comment:交易日期"` // 添加索引以优化按日期查询
	Merchant        string    `json:"merchant" gorm:"type:varchar(100);comment:商家名称"`
	Notes           string    `json:"notes" gorm:"type:text;comment:备注"`
	RecorderID      uint      `json:"recorder_id" gorm:"index;comment:记账人(家庭成员)ID"` // 添加索引
	IsFamilyExpense bool      `json:"is_family_expense" gorm:"default:false;comment:是否记为家庭支出"`
	ImageURL        string    `json:"image_url" gorm:"type:varchar(255);comment:关联图片URL"` // 用于存储上传图片的路径
	FamilyId        int       `json:"family_id" gorm:"index;comment:家庭ID"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
	GoalId          int       `json:"goal_id" gorm:"index;comment:<UNK>ID"`

	// 关联关系 (可选，如果需要预加载)
	// User         User         `gorm:"foreignKey:UserID"`
	// Recorder     FamilyMember `gorm:"foreignKey:RecorderID"`
	// Icon         Icon         `gorm:"foreignKey:IconID"` // 注意：Icon模型需要定义ID为int类型
}

// AddTransactionRequest 添加记账记录的请求结构体
type AddTransactionRequest struct {
	Type            string    `json:"type" binding:"required,oneof=expense income"`
	Amount          float64   `json:"amount" binding:"required,gt=0"`
	IconID          int       `json:"icon_id" binding:"required"`
	Date            time.Time `json:"date" binding:"required"`
	Merchant        string    `json:"merchant"`
	Notes           string    `json:"notes"`
	RecorderID      uint      `json:"recorder_id" binding:"required"`
	IsFamilyExpense bool      `json:"is_family_expense"`
	ImageURL        string    `json:"image_url"`
	FamilyId        int       `json:"family_id" gorm:"index;comment:家庭ID"`
	GoalId          int       `json:"goal_id" gorm:"index;comment:<UNK>ID"`
}

// TableName 指定Transaction模型对应的数据库表名
func (Transaction) TableName() string {
	return "transactions" // 显式指定表名
}

// TransactionQueryParams 交易记录查询参数
type TransactionQueryParams struct {
	UserID     uint      `form:"user_id"`
	Type       string    `form:"type"`
	CategoryID []int     `form:"category_id"`
	MemberID   uint      `form:"member_id"`
	StartDate  time.Time `form:"start_date"`
	EndDate    time.Time `form:"end_date"`
	Page       int       `form:"page" binding:"min=1"`
	PageSize   int       `form:"page_size" binding:"min=1,max=100"`
	SortBy     string    `form:"sort_by"`
	SortOrder  string    `form:"sort_order"`
}

// TransactionResponse 交易记录响应结构体，包含分页信息和汇总统计
type TransactionResponse struct {
	Transactions []Transaction `json:"transactions"`
	Pagination   Pagination    `json:"pagination"`
	Summary      struct {
		TotalCount   int     `json:"total_count"`
		TotalIncome  float64 `json:"total_income"`
		TotalExpense float64 `json:"total_expense"`
		NetAmount    float64 `json:"net_amount"`
	} `json:"summary"`
}

// TrendDataPoint 趋势数据点
type TrendDataPoint struct {
	Label     string  `json:"label"`
	Income    float64 `json:"income"`
	Expense   float64 `json:"expense"`
	NetAmount float64 `json:"net_amount"`
	Date      string  `json:"date"`
}

// MemberExpenseStats 成员支出统计
type MemberExpenseStats struct {
	MemberID     uint    `json:"member_id"`
	MemberName   string  `json:"member_name"`
	MemberRole   string  `json:"member_role"`
	TotalExpense float64 `json:"total_expense"`
	Percentage   float64 `json:"percentage"`
}

// TransactionDateGroup 按日期分组的交易记录
type TransactionDateGroup struct {
	Date         time.Time     `json:"date"`
	Transactions []Transaction `json:"transactions"`
	TotalIncome  float64       `json:"total_income"`
	TotalExpense float64       `json:"total_expense"`
	NetAmount    float64       `json:"net_amount"`
}

// CategoryExpenseStats 按类别统计的支出数据
type CategoryExpenseStats struct {
	IconID       int     `json:"icon_id"`       // 图标ID
	CategoryName string  `json:"category_name"` // 类别名称
	Amount       float64 `json:"amount"`        // 支出金额
	Percentage   float64 `json:"percentage"`    // 占总支出的百分比
}
