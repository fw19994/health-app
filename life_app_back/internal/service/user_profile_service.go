package service

import (
	"fmt"
	"life_app_back/internal/model"
	"life_app_back/internal/repository"
)

// GetUserProfile 获取用户基本信息
func GetUserProfile(userID uint) (re model.UserProfileResponse, err error) {
	// 通过仓库获取用户和资料信息
	profile, user, err := repository.GetUserProfileWithUser(userID)
	if err != nil {
		return re, err
	}

	// 转换为响应对象
	return profile.ToResponse(user), nil
}

// UpdateUserProfile 更新用户基本信息
func UpdateUserProfile(userID uint, updateData map[string]interface{}) (re model.UserProfileResponse, err error) {
	// 获取用户信息
	user, err := repository.FindUserByID(userID)
	if err != nil {
		return re, err
	}
	if user.ID == 0 {
		return re, fmt.Errorf("用户不存在")
	}

	// 获取用户资料
	profile, err := repository.GetUserProfileByUserID(userID)
	if err != nil {
		return re, err
	}
	
	// 判断用户资料是否存在（通过检查ID是否为0）
	if profile.ID == 0 {
		// 用户资料不存在，创建新的资料记录
		newProfile := model.UserProfile{
			UserID: userID,
		}
		
		// 创建资料
		if err := repository.CreateUserProfile(newProfile); err != nil {
			return re, fmt.Errorf("创建用户资料失败: %w", err)
		}
		
		// 重新获取新创建的资料
		profile, err = repository.GetUserProfileByUserID(userID)
		if err != nil {
			return re, err
		}
	}
	
	// 更新用户资料
	if err := repository.UpdateUserProfile(profile, updateData); err != nil {
		return re, err
	}

	// 返回更新后的用户资料
	return profile.ToResponse(user), nil
}

// CreateUserProfile 创建用户资料
func CreateUserProfile(userID uint, profileData map[string]interface{}) (re model.UserProfileResponse, err error) {
	// 检查用户是否存在
	user, err := repository.FindUserByID(userID)
	if err != nil {
		return re, err
	}
	if user.ID == 0 {
		return re, fmt.Errorf("用户不存在")
	}

	// 创建用户资料
	profile := model.UserProfile{
		UserID: userID,
		Gender: "other", // 默认值
	}

	// 如果有生日字段，需要转换
	if birthdayStr, ok := profileData["birthday"].(string); ok && birthdayStr != "" {
		delete(profileData, "birthday") // 删除字符串类型的生日字段
	}

	// 创建用户资料
	if err := repository.CreateUserProfile(profile); err != nil {
		return re, err
	}

	// 如果有额外的字段需要更新
	if len(profileData) > 0 {
		if err := repository.UpdateUserProfile(profile, profileData); err != nil {
			return re, err
		}
	}

	// 获取更新后的完整资料
	updatedProfile, err := repository.GetUserProfileByID(profile.ID)
	if err != nil {
		return re, err
	}

	// 返回创建后的用户资料
	return updatedProfile.ToResponse(user), nil
}
