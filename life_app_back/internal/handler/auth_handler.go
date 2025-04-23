package handler

import (
	"github.com/gin-gonic/gin"
	"life_app_back/internal/config"
	"life_app_back/internal/service"
	"life_app_back/internal/utils"
)

// 全局配置变量
var Cfg *config.Config

// SendSMSCodeRequest 发送验证码请求
type SendSMSCodeRequest struct {
	Phone string `json:"phone" binding:"required,len=11"`
}

// LoginSMSRequest 短信登录请求
type LoginSMSRequest struct {
	Phone      string `json:"phone" binding:"required,len=11"`
	Code       string `json:"code" binding:"required"`
	DeviceInfo struct {
		DeviceID string `json:"deviceId"`
		Platform string `json:"platform"`
		Version  string `json:"version"`
	} `json:"deviceInfo"`
}

// RegisterRequest 注册请求
type RegisterRequest struct {
	Phone    string `json:"phone" binding:"required,len=11"`
	Code     string `json:"code" binding:"required"`
	Nickname string `json:"nickname" binding:"required"`
}

// SendSMSCode 发送短信验证码
func SendSMSCode(c *gin.Context) {
	var req SendSMSCodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ParameterError(c, "请求参数错误")
		return
	}

	// 发送验证码
	code, expireIn, err := service.SendSMSCode(req.Phone, Cfg.SMS)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 准备响应数据
	respData := gin.H{
		"expireIn": expireIn,
	}

	// 仅在开发环境下返回验证码（方便测试）
	if Cfg.App.Debug {
		respData["code"] = code
	}

	// 使用统一的响应工具
	utils.Success(c, respData, "验证码发送成功")
}

// LoginWithSMS 使用短信验证码登录
func LoginWithSMS(c *gin.Context) {
	var req LoginSMSRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ParameterError(c, "请求参数错误")
		return
	}

	// 登录验证
	user, tokens, err := service.LoginWithSMS(req.Phone, req.Code, Cfg.JWT)
	if err != nil {
		utils.AuthFailed(c, "登录失败") // 统一使用认证失败错误
		return
	}

	// 构建响应数据
	respData := gin.H{
		"token":        tokens.AccessToken,
		"refreshToken": tokens.RefreshToken,
		"expiresIn":    tokens.ExpiresIn,
		"tokenType":    tokens.TokenType,
		"user":         user.ToResponse(),
	}

	utils.Success(c, respData, "登录成功")
}

// Register 注册新用户
func Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ParameterError(c, "请求参数错误")
		return
	}

	// 注册用户
	user, tokens, err := service.RegisterUser(req.Phone, req.Code, req.Nickname, Cfg.JWT)
	if err != nil {
		// 根据错误类型返回相应的响应
		utils.ServerError(c, err)
		return
	}

	// 构建响应数据
	respData := gin.H{
		"token":        tokens.AccessToken,
		"refreshToken": tokens.RefreshToken,
		"expiresIn":    tokens.ExpiresIn,
		"tokenType":    tokens.TokenType,
		"user":         user.ToResponse(),
	}

	utils.Success(c, respData, "注册成功")
}

// RefreshTokenRequest 刷新令牌请求
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// RefreshToken 刷新访问令牌
func RefreshToken(c *gin.Context) {
	var req RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ParameterError(c, "请求参数错误")
		return
	}

	// 刷新令牌
	newTokens, err := service.RefreshToken(req.RefreshToken, Cfg.JWT)
	if err != nil {
		utils.AuthFailed(c, "刷新令牌失败")
		return
	}

	// 构建响应数据
	respData := gin.H{
		"token":        newTokens.AccessToken,
		"refreshToken": newTokens.RefreshToken,
		"expiresIn":    newTokens.ExpiresIn,
		"tokenType":    newTokens.TokenType,
	}

	utils.Success(c, respData, "令牌刷新成功")
}
