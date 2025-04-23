package service

import (
	"life_app_back/internal/model"
	"life_app_back/internal/repository"
)

type IconService struct {
}

// GetUserAvailableIcons 获取用户可用的图标
func (s IconService) GetUserAvailableIcons(userID int) ([]model.IconResponse, error) {
	return repository.IconRepository{}.GetUserAvailableIcons(userID)
}

// DeleteUserIcon 删除用户自定义图标
func (s IconService) DeleteUserIcon(userID, iconID int) error {
	return repository.IconRepository{}.DeleteUserIcon(userID, iconID)
}

// CreateUserIcon 创建用户自定义图标
func (s IconService) CreateIcon(userID int, req model.CreateUserIconRequest) error {
	// 检查图标是否存在
	var icon model.Icon
	if err := model.DB.First(&icon, req.IconID).Error; err != nil {
		return err
	}

	// 创建用户自定义图标
	return repository.IconRepository{}.CreateIcon(userID, req, icon)
}
