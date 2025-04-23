package model

import (
	"strings"
	"time"

	"gorm.io/gorm"
)

// UserProfile 用户基本信息模型
type UserProfile struct {
	ID           uint           `gorm:"primaryKey;comment:'主键ID'" json:"id"`
	UserID       uint           `gorm:"uniqueIndex;not null;comment:'关联的用户ID'" json:"user_id"`
	User         User           `gorm:"foreignKey:UserID" json:"-"`
	Gender       string         `gorm:"size:10;comment:'性别：male-男性, female-女性, other-其他'" json:"gender"`
	Birthday     *time.Time     `gorm:"comment:'生日，格式为YYYY-MM-DD'" json:"birthday,omitempty"`
	Height       *float64       `gorm:"comment:'身高(cm)'" json:"height,omitempty"`
	Weight       *float64       `gorm:"comment:'体重(kg)'" json:"weight,omitempty"`
	BloodType    *string        `gorm:"size:10;comment:'血型，如A、B、AB、O、A+、A-等'" json:"blood_type,omitempty"`
	Occupation   *string        `gorm:"size:50;comment:'职业'" json:"occupation,omitempty"`
	Address      *string        `gorm:"size:255;comment:'居住地址'" json:"address,omitempty"`
	EmergContact *string        `gorm:"size:50;comment:'紧急联系人姓名'" json:"emerg_contact,omitempty"`
	EmergPhone   *string        `gorm:"size:20;comment:'紧急联系人电话'" json:"emerg_phone,omitempty"`
	Bio          *string        `gorm:"size:500;comment:'个人简介'" json:"bio,omitempty"`
	CreatedAt    time.Time      `gorm:"comment:'创建时间'" json:"created_at"`
	UpdatedAt    time.Time      `gorm:"comment:'更新时间'" json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index;comment:'删除时间（软删除）'" json:"-"`
}

// TableName 指定表名
func (UserProfile) TableName() string {
	return "user_profile" // 用户基本信息表
}

// UserProfileResponse 用户基本信息响应结构
type UserProfileResponse struct {
	ID           uint     `json:"id"`
	UserID       uint     `json:"user_id"`
	Nickname     string   `json:"nickname"`      // 从User表获取
	Phone        string   `json:"phone"`         // 从User表获取
	Avatar       string   `json:"avatar"`        // 从User表获取
	Gender       string   `json:"gender"`        // male-男性, female-女性, other-其他
	Birthday     *string  `json:"birthday"`      // 格式化为YYYY-MM-DD
	Age          *int     `json:"age"`           // 根据生日计算的年龄
	Height       *float64 `json:"height"`        // 身高(cm)
	Weight       *float64 `json:"weight"`        // 体重(kg)
	BMI          *float64 `json:"bmi"`           // 根据身高体重计算的BMI
	BloodType    *string  `json:"blood_type"`    // 血型
	Occupation   *string  `json:"occupation"`    // 职业
	Address      *string  `json:"address"`       // 地址
	EmergContact *string  `json:"emerg_contact"` // 紧急联系人
	EmergPhone   *string  `json:"emerg_phone"`   // 紧急联系电话
	Bio          *string  `json:"bio"`           // 个人简介
}

// 将UserProfile转换为响应对象
func (p UserProfile) ToResponse(user User) UserProfileResponse {
	// 手机号脱敏处理
	maskedPhone := user.Phone
	if len(user.Phone) >= 7 { // 至少要有7位才脱敏
		// 保留前3位和后4位，中间用星号代替
		phoneLen := len(user.Phone)
		maskedPhone = user.Phone[:3] + strings.Repeat("*", phoneLen-7) + user.Phone[phoneLen-4:]
	}
	
	resp := UserProfileResponse{
		ID:           p.ID,
		UserID:       p.UserID,
		Nickname:     user.Nickname,
		Phone:        maskedPhone,
		Avatar:       user.Avatar,
		Gender:       p.Gender,
		Height:       p.Height,
		Weight:       p.Weight,
		BloodType:    p.BloodType,
		Occupation:   p.Occupation,
		Address:      p.Address,
		EmergContact: p.EmergContact,
		EmergPhone:   p.EmergPhone,
		Bio:          p.Bio,
	}

	// 处理生日和年龄
	if p.Birthday != nil {
		birthday := p.Birthday.Format("2006-01-02")
		resp.Birthday = &birthday

		// 计算年龄
		now := time.Now()
		age := now.Year() - p.Birthday.Year()
		// 如果今年的生日还没到，年龄减1
		if now.Month() < p.Birthday.Month() || (now.Month() == p.Birthday.Month() && now.Day() < p.Birthday.Day()) {
			age--
		}
		resp.Age = &age
	}

	// 计算BMI
	if p.Height != nil && p.Weight != nil && *p.Height > 0 {
		heightInMeters := *p.Height / 100
		bmi := *p.Weight / (heightInMeters * heightInMeters)
		bmi = float64(int(bmi*10)) / 10 // 保留一位小数
		resp.BMI = &bmi
	}

	return resp
}
