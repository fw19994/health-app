package service

import (
	"fmt"

	"life_app_back/internal/model"
	"life_app_back/internal/repository"
)

// GetUserByPhone 根据手机号获取用户信息
func GetUserByPhone(phone string) (model.UserResponse, error) {
	// 参数验证
	if phone == "" {
		return model.UserResponse{}, fmt.Errorf("手机号不能为空")
	}

	// 查询用户
	user, err := repository.FindUserByPhone(phone)
	if err != nil {
		return model.UserResponse{}, err
	}

	// 用户不存在
	if user.ID == 0 {
		return model.UserResponse{}, fmt.Errorf("用户不存在")
	}

	// 转换为响应对象
	return user.ToResponse(), nil
}
