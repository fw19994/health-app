package model

import (
	"time"

	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Phone     string         `gorm:"uniqueIndex;size:20;not null" json:"phone"`
	Nickname  string         `gorm:"size:50" json:"nickname"`
	Avatar    string         `gorm:"size:255" json:"avatar"`
	Status    int            `gorm:"default:1" json:"status"` // 0-禁用,1-正常
	LastLogin *time.Time     `json:"last_login"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// TableName 指定表名
func (User) TableName() string {
	return "user"
}

// UserRole 用户角色枚举
const (
	UserRoleNormal  = 1 // 普通用户
	UserRoleAdmin   = 2 // 管理员
	UserRolePremium = 3 // 高级用户
)

// UserStatus 用户状态枚举
const (
	UserStatusDisabled = 0 // 禁用
	UserStatusNormal   = 1 // 正常
)

// AuthTokens 认证令牌响应
type AuthTokens struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int    `json:"expires_in"` // 秒
	TokenType    string `json:"token_type"` // Bearer
}

// UserResponse 用户响应数据
type UserResponse struct {
	ID        uint       `json:"id"`
	Phone     string     `json:"phone"`
	Nickname  string     `json:"nickname"`
	Avatar    string     `json:"avatar"`
	Status    int        `json:"status"`
	LastLogin *time.Time `json:"last_login,omitempty"`
	CreatedAt time.Time  `json:"created_at"`
}

// ToResponse 转换为响应格式
func (u *User) ToResponse() UserResponse {
	return UserResponse{
		ID:        u.ID,
		Phone:     u.Phone,
		Nickname:  u.Nickname,
		Avatar:    u.Avatar,
		Status:    u.Status,
		LastLogin: u.LastLogin,
		CreatedAt: u.CreatedAt,
	}
}
