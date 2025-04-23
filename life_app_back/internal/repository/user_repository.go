package repository

import (
	"errors"
	"time"

	"gorm.io/gorm"
	"life_app_back/internal/model"
)

// CreateUser 创建新用户
func CreateUser(user *model.User) error {
	return model.DB.Create(user).Error
}

// FindUserByID 通过ID查找用户
func FindUserByID(id uint) (user model.User, err error) {
	if err := model.DB.First(&user, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return user, nil
		}
		return user, err
	}
	return user, nil
}

// FindUserByPhone 通过手机号查找用户
func FindUserByPhone(phone string) (model.User, error) {
	var user model.User
	err := model.DB.Where("phone = ?", phone).First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return user, nil // 返回空用户和nil错误
		}
		return user, err
	}
	return user, nil
}

// UpdateUser 更新用户信息
func UpdateUser(user model.User) error {
	return model.DB.Save(&user).Error
}

// UpdateUserLastLogin 更新用户最后登录时间
func UpdateUserLastLogin(userID uint) error {
	now := time.Now()
	return model.DB.Model(&model.User{}).Where("id = ?", userID).Update("last_login", &now).Error
}

// UserExists 检查用户是否存在
func UserExists(phone string) (bool, error) {
	var count int64
	if err := model.DB.Model(&model.User{}).Where("phone = ?", phone).Count(&count).Error; err != nil {
		return false, err
	}
	return count > 0, nil
}

// UserRepository 用户仓库
type UserRepository struct{}

// GetUserByID 根据ID获取用户
func (r *UserRepository) GetUserByID(id uint) (*model.User, error) {
	var user model.User
	db := model.DB
	
	if err := db.First(&user, id).Error; err != nil {
		return nil, errors.New("用户不存在")
	}
	
	return &user, nil
}

// GetUserByPhone 根据手机号获取用户
func (r *UserRepository) GetUserByPhone(phone string) (*model.User, error) {
	var user model.User
	db := model.DB
	
	if err := db.Where("phone = ?", phone).First(&user).Error; err != nil {
		return nil, errors.New("用户不存在")
	}
	
	return &user, nil
}
