package service

import (
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"life_app_back/internal/config"
	"life_app_back/internal/model"
	"life_app_back/internal/repository"
)

// LoginWithSMS 使用短信验证码登录
func LoginWithSMS(phone string, code string, jwtConfig config.JWTConfig) (user model.User, tokens model.AuthTokens, err error) {
	// 验证短信验证码
	verified, err := VerifySMSCode(phone, code)
	if err != nil {
		return user, tokens, err
	}

	if !verified {
		return user, tokens, fmt.Errorf("验证码验证失败")
	}

	// 查找用户
	user, err = repository.FindUserByPhone(phone)
	if err != nil {
		return user, tokens, err
	}

	// 如果用户不存在，自动创建新用户
	if user.ID == 0 {
		newUser := &model.User{
			Phone:    phone,
			Nickname: fmt.Sprintf("用户%s", phone[len(phone)-4:]),
			Status:   model.UserStatusNormal,
		}

		if err := repository.CreateUser(newUser); err != nil {
			return user, tokens, err
		}

		user = *newUser
	}

	// 更新最后登录时间
	repository.UpdateUserLastLogin(user.ID)

	// 生成JWT令牌
	tokens, err = generateTokens(user, jwtConfig)
	if err != nil {
		return user, tokens, err
	}

	return user, tokens, err
}

// RegisterUser 注册新用户
func RegisterUser(phone string, code string, nickname string, jwtConfig config.JWTConfig) (re model.User, tokens model.AuthTokens, err error) {
	// 验证短信验证码
	verified, err := VerifySMSCode(phone, code)
	if err != nil {
		return re, tokens, err
	}

	if !verified {
		return re, tokens, fmt.Errorf("验证码验证失败")
	}

	// 检查用户是否已存在
	exists, err := repository.UserExists(phone)
	if err != nil {
		return re, tokens, err
	}

	if exists {
		return re, tokens, fmt.Errorf("该手机号已注册")
	}

	// 创建新用户
	user := &model.User{
		Phone:    phone,
		Nickname: nickname,
		Status:   model.UserStatusNormal,
	}

	if err := repository.CreateUser(user); err != nil {
		return re, tokens, err
	}

	// 更新最后登录时间
	repository.UpdateUserLastLogin(user.ID)

	// 生成JWT令牌
	tokens, err = generateTokens(*user, jwtConfig)
	if err != nil {
		return re, tokens, err
	}

	return *user, tokens, nil
}

// 生成JWT访问令牌和刷新令牌
func generateTokens(user model.User, jwtConfig config.JWTConfig) (re model.AuthTokens, err error) {
	// 创建访问令牌
	accessClaims := jwt.MapClaims{
		"sub":   fmt.Sprintf("%d", user.ID),
		"name":  user.Nickname,
		"phone": user.Phone,
		"iss":   jwtConfig.Issuer,
		"iat":   time.Now().Unix(),
		"exp":   time.Now().Add(jwtConfig.AccessExpiry).Unix(),
		"type":  "access",
	}

	accessToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims).SignedString([]byte(jwtConfig.Secret))
	if err != nil {
		return re, err
	}

	// 创建刷新令牌
	refreshClaims := jwt.MapClaims{
		"sub":  fmt.Sprintf("%d", user.ID),
		"iss":  jwtConfig.Issuer,
		"iat":  time.Now().Unix(),
		"exp":  time.Now().Add(jwtConfig.RefreshExpiry).Unix(),
		"type": "refresh",
	}

	refreshToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims).SignedString([]byte(jwtConfig.Secret))
	if err != nil {
		return re, err
	}

	// 构建令牌响应
	authTokens := model.AuthTokens{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int(jwtConfig.AccessExpiry.Seconds()),
		TokenType:    "Bearer",
	}

	return authTokens, nil
}

// VerifyToken 验证JWT令牌
func VerifyToken(tokenString string, jwtConfig config.JWTConfig) (jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// 验证签名方法
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("非法的签名方法: %v", token.Header["alg"])
		}

		return []byte(jwtConfig.Secret), nil
	})

	if err != nil {
		return nil, err
	}

	// 验证令牌是否有效
	if !token.Valid {
		return nil, fmt.Errorf("无效的令牌")
	}

	// 获取令牌中的声明
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, fmt.Errorf("无法获取令牌声明")
	}

	return claims, nil
}

// RefreshToken 刷新访问令牌
func RefreshToken(refreshToken string, jwtConfig config.JWTConfig) (re model.AuthTokens, err error) {
	// 验证刷新令牌
	claims, err := VerifyToken(refreshToken, jwtConfig)
	if err != nil {
		return re, err
	}

	// 确保是刷新令牌
	tokenType, ok := claims["type"].(string)
	if !ok || tokenType != "refresh" {
		return re, fmt.Errorf("无效的刷新令牌类型")
	}

	// 获取用户ID
	userIDStr, ok := claims["sub"].(string)
	if !ok {
		return re, fmt.Errorf("无法获取用户ID")
	}

	// 将用户ID字符串转换为uint
	var userID uint
	fmt.Sscanf(userIDStr, "%d", &userID)

	// 查找用户
	user, err := repository.FindUserByID(userID)
	if err != nil {
		return re, err
	}

	if user.ID == 0 {
		return re, fmt.Errorf("用户不存在")
	}

	// 生成新的令牌
	return generateTokens(user, jwtConfig)
}
