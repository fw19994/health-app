package model

import (
	"time"
)

// FamilyMember 家庭成员模型
type FamilyMember struct {
	ID            uint      `json:"id" gorm:"primaryKey"`
	OwnerID       uint      `json:"owner_id"` // 家主用户ID
	UserID        uint      `json:"user_id"`
	Name          string    `json:"name"`
	Nickname      string    `json:"nickname"` // 家庭称呼
	Description   string    `json:"description"`
	Phone         string    `json:"phone"`
	Role          string    `json:"role"`
	Gender        string    `json:"gender"` // 性别
	AvatarURL     string    `json:"avatar_url"`
	JoinTime      time.Time `json:"join_time"`
	Permission    string    `json:"permission"`
	IsCurrentUser bool      `json:"is_current_user" gorm:"-"` // 不存储到数据库
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
	Status        int       `json:"status" gorm:"status"`
}

// TableName 指定表名
func (FamilyMember) TableName() string {
	return "family_members"
}

// FamilyMemberResponse 家庭成员响应结构
type FamilyMemberResponse struct {
	ID            uint   `json:"id"`
	OwnerID       uint   `json:"owner_id"`
	UserID        uint   `json:"user_id"`
	Name          string `json:"name"`
	Nickname      string `json:"nickname"`
	Description   string `json:"description"`
	Phone         string `json:"phone"`
	Role          string `json:"role"`
	Gender        string `json:"gender"`
	AvatarURL     string `json:"avatar"`
	JoinTime      string `json:"joinTime"`
	Permission    string `json:"permission"`
	IsCurrentUser bool   `json:"isCurrentUser"`
	Status        int    `json:"status" gorm:"status"`
}

// ToResponse 将模型转换为响应
func (fm *FamilyMember) ToResponse() FamilyMemberResponse {
	return FamilyMemberResponse{
		ID:            fm.ID,
		OwnerID:       fm.OwnerID,
		UserID:        fm.UserID,
		Name:          fm.Name,
		Nickname:      fm.Nickname,
		Description:   fm.Description,
		Phone:         fm.Phone,
		Role:          fm.Role,
		Gender:        fm.Gender,
		AvatarURL:     fm.AvatarURL,
		JoinTime:      fm.JoinTime.Format("2006-01-02"),
		Permission:    fm.Permission,
		IsCurrentUser: fm.IsCurrentUser,
	}
}

// Invitation 家庭邀请模型
type Invitation struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	OwnerID    uint      `json:"owner_id"` // 家主用户ID
	InviteCode string    `json:"invite_code"`
	ExpireTime time.Time `json:"expire_time"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// TableName 指定表名
func (Invitation) TableName() string {
	return "family_invitations"
}
