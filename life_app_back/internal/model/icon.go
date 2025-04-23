package model

import "time"

// IconCategory 图标分类
type IconCategory struct {
	ID          int       `json:"id" gorm:"primaryKey"`
	Name        string    `json:"name"`
	Code        string    `json:"code" gorm:"unique"`
	Description string    `json:"description"`
	SortOrder   int       `json:"sort_order"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// Icon 图标
type Icon struct {
	ID         int          `json:"id" gorm:"primaryKey"`
	CategoryID int          `json:"category_id"`
	UserID     int          `json:"user_id"`
	Name       string       `json:"name"`
	Code       string       `json:"code"`
	IconType   string       `json:"icon_type"`
	IconCode   string       `json:"icon_code"`
	ColorCode  string       `json:"color_code"`
	IsPublic   bool         `json:"is_public"`
	SortOrder  int          `json:"sort_order"`
	CreatedAt  time.Time    `json:"created_at"`
	UpdatedAt  time.Time    `json:"updated_at"`
	Category   IconCategory `json:"category" gorm:"foreignKey:CategoryID"`
}

// UserIcon 用户自定义图标
type UserIcon struct {
	ID          int       `json:"id" gorm:"primaryKey"`
	UserID      int       `json:"user_id"`
	IconID      int       `json:"icon_id"`
	CustomName  string    `json:"custom_name"`
	CategoryID  int       `json:"category_id"`
	CustomColor string    `json:"custom_color"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// IconResponse 图标响应
type IconResponse struct {
	ID         int    `json:"id"`
	Name       string `json:"name"`
	Code       string `json:"code"`
	IconType   string `json:"icon_type"`
	IconCode   string `json:"icon_code"`
	ColorCode  string `json:"color_code"`
	CategoryID int    `json:"category_id"`
	Category   string `json:"category"`
	IsCustom   bool   `json:"is_custom"`
}

// CreateUserIconRequest 创建用户图标请求
type CreateUserIconRequest struct {
	IconID      int    `json:"icon_id" binding:"required"`
	CustomName  string `json:"custom_name"`
	CustomColor string `json:"custom_color"`
	CategoryID  int    `json:"category_id"`
	UserID      int    `json:"user_id"`
}
