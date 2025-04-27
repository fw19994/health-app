package repository

import (
	"life_app_back/internal/model"
)

type IconRepository struct {
}

// GetUserAvailableIcons 获取用户可用的图标（包括公共图标和用户自定义图标）
func (r IconRepository) GetUserAvailableIcons(userID int) ([]model.IconResponse, error) {
	var icons []model.IconResponse

	// 查询公共图标
	err := model.DB.Model(&model.Icon{}).
		Select("icons.id, icons.name, icons.code, icons.icon_type, icons.icon_code, icons.color_code, icons.category_id, icon_categories.name as category").
		Joins("LEFT JOIN icon_categories ON icons.category_id = icon_categories.id").
		Where("icons.is_public = ?", true).Or("icons.user_id = ?", userID).
		Order("icons.sort_order").
		Scan(&icons).Error

	if err != nil {
		return nil, err
	}

	return icons, nil
}

// CreateUserIcon 创建用户自定义图标
func (r IconRepository) CreateIcon(userID int, req model.CreateUserIconRequest, icon model.Icon) error {
	userIcon := &model.Icon{
		UserID:     userID,
		CategoryID: req.CategoryID,
		Name:       req.CustomName,
		Code:       icon.Code,
		IconType:   icon.IconType,
		IconCode:   icon.IconCode,
		ColorCode:  icon.ColorCode,
		IsPublic:   false,
	}

	return model.DB.Create(userIcon).Error
}

// DeleteUserIcon 删除用户自定义图标
func (r IconRepository) DeleteUserIcon(userID, iconID int) error {
	return model.DB.Where("user_id = ? AND icon_id = ?", userID, iconID).
		Delete(&model.UserIcon{}).Error
}

func (r IconRepository) GetIcon(iconID int) (re model.Icon, err error) {
	model.DB.Model(&model.Icon{}).Where("id = ?", iconID).Find(&re)
	return
}
