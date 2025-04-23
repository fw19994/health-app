package repository

import (
	"errors"
	"fmt"
	"life_app_back/internal/model"
	"time"

	"gorm.io/gorm"
)

// GetUserProfileByID 通过ID获取用户资料
func GetUserProfileByID(id uint) (*model.UserProfile, error) {
	var profile model.UserProfile
	if err := model.DB.First(&profile, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &profile, nil
}

// GetUserProfileByUserID 通过用户ID获取用户资料
func GetUserProfileByUserID(userID uint) (model.UserProfile, error) {
	profile := model.UserProfile{}
	err := model.DB.Where("user_id = ?", userID).First(&profile).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return profile, nil
	} else if err != nil {
		return profile, err
	}
	return profile, nil
}

// GetUserProfileWithUser 获取用户资料及用户信息
func GetUserProfileWithUser(userID uint) (re model.UserProfile, user model.User, err error) {
	// 获取用户信息
	user, err = FindUserByID(userID)
	if err != nil {
		return re, user, err
	}
	if user.ID == 0 {
		return re, user, fmt.Errorf("用户不存在")
	}

	// 获取用户资料
	profile, err := GetUserProfileByUserID(userID)
	if err != nil {
		return re, user, err
	}

	return profile, user, nil
}

// CreateUserProfile 创建用户资料
func CreateUserProfile(profile model.UserProfile) error {
	return model.DB.Create(&profile).Error
}

// UpdateUserProfile 更新用户资料
func UpdateUserProfile(profile model.UserProfile, updateData map[string]interface{}) error {
	// 处理生日字段（如果存在）
	if birthdayStr, ok := updateData["birthday"].(string); ok && birthdayStr != "" {
		birthTime, err := time.Parse("2006-01-02", birthdayStr)
		if err != nil {
			return fmt.Errorf("生日格式错误，请使用YYYY-MM-DD格式")
		}
		updateData["birthday"] = birthTime
	}

	// 更新用户资料
	if err := model.DB.Model(profile).Updates(updateData).Error; err != nil {
		return err
	}

	return nil
}

// DeleteUserProfile 删除用户资料
func DeleteUserProfile(id uint) error {
	return model.DB.Delete(&model.UserProfile{}, id).Error
}
