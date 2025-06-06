package model

import "time"

type Family struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	UserID      uint      `json:"user_id" gorm:"index"` // 创建者ID
	Name        string    `json:"name"`
	Description string    `json:"description"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	IsActive    bool      `json:"is_active" gorm:"default:true"` // 家庭状态
	Code        string    `json:"code" gorm:"size:10;uniqueIndex"` // 邀请码
	MemberCount int       `json:"member_count" gorm:"-"` // 成员数量，不存储到数据库
}

// TableName 指定表名
func (Family) TableName() string {
	return "family"
}

// FamilyResponse 家庭响应模型
type FamilyResponse struct {
	ID          uint      `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	CreatedAt   time.Time `json:"created_at"`
	IsActive    bool      `json:"is_active"`
	OwnerName   string    `json:"owner_name"`
	MemberCount int       `json:"member_count"`
}

// ToResponse 转换为响应模型
func (f *Family) ToResponse() FamilyResponse {
	return FamilyResponse{
		ID:          f.ID,
		Name:        f.Name,
		Description: f.Description,
		CreatedAt:   f.CreatedAt,
		IsActive:    f.IsActive,
		MemberCount: f.MemberCount,
		// OwnerName由service层填充
	}
}
