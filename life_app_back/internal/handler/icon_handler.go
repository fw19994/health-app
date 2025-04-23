package handler

import (
	"github.com/gin-gonic/gin"
	"life_app_back/internal/model"
	"life_app_back/internal/service"
	"life_app_back/internal/utils"
)

// IconHandler 图标处理器
type IconHandler struct{}

// NewIconHandler 创建图标处理器
func NewIconHandler() *IconHandler {
	return &IconHandler{}
}

// GetUserAvailableIcons 获取用户可用的图标
func (h *IconHandler) GetUserAvailableIcons(c *gin.Context) {
	// 从上下文获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return
	}

	// 获取用户可用的图标
	icons, err := service.IconService{}.GetUserAvailableIcons(int(userID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回成功响应
	utils.Success(c, icons, "获取图标成功")
}

// CreateUserIconRequest 创建用户图标请求
type CreateUserIconRequest struct {
	IconID      int    `json:"icon_id" binding:"required"`     // 基础图标ID
	CustomName  string `json:"custom_name" binding:"required"` // 自定义名称
	CustomColor string `json:"custom_color"`                   // 自定义颜色
	CategoryId  int    `json:"category_id" binding:"required"`
}

// CreateUserIcon 创建用户自定义图标
func (h *IconHandler) CreateUserIcon(c *gin.Context) {
	// 从上下文获取用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return
	}

	// 解析请求数据
	var req CreateUserIconRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ParameterError(c, "请求参数错误")
		return
	}

	// 验证自定义名称长度
	if len(req.CustomName) < 1 || len(req.CustomName) > 50 {
		utils.ParameterError(c, "自定义名称长度应在1-50个字符之间")
		return
	}

	// 验证自定义颜色格式（如果提供）
	if req.CustomColor != "" {
		if len(req.CustomColor) != 7 || req.CustomColor[0] != '#' {
			utils.ParameterError(c, "无效的颜色格式，应为十六进制颜色代码（如：#FF0000）")
			return
		}
	}

	// 创建用户图标请求
	iconReq := model.CreateUserIconRequest{
		IconID:      req.IconID,
		CustomName:  req.CustomName,
		CustomColor: req.CustomColor,
		CategoryID:  req.CategoryId,
		UserID:      int(userID),
	}
	err := service.IconService{}.CreateIcon(int(userID), iconReq)
	// 保存图标
	if err != nil {
		utils.ServerError(c, err)
		return
	}
	// 返回成功响应
	utils.Success(c, nil, "创建图标成功")
}
