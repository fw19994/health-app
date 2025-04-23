package handler

import (
	"fmt"
	"io"
	"life_app_back/internal/repository"
	"life_app_back/internal/service"
	"life_app_back/internal/utils"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

// UpdateNicknameRequest 修改昵称请求
type UpdateNicknameRequest struct {
	Nickname string `json:"nickname" binding:"required,max=50"`
}

// UpdateNickname 修改昵称
func UpdateNickname(c *gin.Context) {
	// 获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 解析请求参数
	var req UpdateNicknameRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ParameterError(c, "昵称格式不正确")
		return
	}

	// 检查昵称是否为空
	if req.Nickname == "" {
		utils.ParameterError(c, "昵称不能为空")
		return
	}

	// 获取用户信息
	user, err := repository.FindUserByID(uint(userID))
	if err != nil {
		utils.ServerError(c, err)
		return
	}
	if user.ID == 0 {
		utils.NotFound(c, "用户不存在")
		return
	}

	// 更新昵称
	user.Nickname = req.Nickname
	if err := repository.UpdateUser(user); err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回成功响应
	utils.Success(c, user.ToResponse(), "昵称修改成功")
}

// UploadAvatar 上传头像
func UploadAvatar(c *gin.Context) {
	// 获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取上传的文件
	file, err := c.FormFile("avatar")
	if err != nil {
		utils.ParameterError(c, "未找到上传的文件")
		return
	}

	// 验证文件类型
	if !isValidAvatarFile(file) {
		utils.ParameterError(c, "文件类型不支持，请上传图片格式文件")
		return
	}

	// 使用OSS服务上传文件
	ossService, err := utils.GetOSSService()
	if err != nil {
		utils.ServerError(c, fmt.Errorf("初始化OSS服务失败: %w", err))
		return
	}

	// 判断OSS服务是否配置有效
	if !ossService.IsConfigValid() {
		// OSS配置无效，切换为本地存储
		avatarURL, err := saveAvatarFile(file, uint(userID))
		if err != nil {
			utils.ServerError(c, err)
			return
		}

		// 更新用户头像地址
		updateUserAvatar(c, uint(userID), avatarURL)
		return
	}

	// 使用OSS服务上传头像
	avatarURL, err := ossService.UploadAvatar(file, uint(userID))
	if err != nil {
		utils.ServerError(c, fmt.Errorf("上传头像到OSS失败: %w", err))
		return
	}

	// 更新用户头像地址
	updateUserAvatar(c, uint(userID), avatarURL)
}

// ChangePassword 修改密码
func ChangePassword(c *gin.Context) {
	// TODO: 实现修改密码的逻辑
	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "修改成功",
	})
}

// Logout 退出登录
func Logout(c *gin.Context) {
	// TODO: 实现退出登录的逻辑
	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "退出成功",
	})
}

// isValidAvatarFile 验证是否为合法的头像图片文件
func isValidAvatarFile(file *multipart.FileHeader) bool {
	// 获取文件后缀名
	ext := filepath.Ext(file.Filename)

	// 允许的图片格式
	allowedExts := map[string]bool{
		".jpg":  true,
		".jpeg": true,
		".png":  true,
		".gif":  true,
		".webp": true,
	}

	// 检查文件大小 (最大5MB)
	maxSize := int64(5 * 1024 * 1024)
	if file.Size > maxSize {
		return false
	}

	// 检查文件类型
	return allowedExts[ext]
}

// saveAvatarFile 保存头像文件到本地并返回访问路径 (仅在OSS配置无效时使用)
func saveAvatarFile(file *multipart.FileHeader, userID uint) (string, error) {
	// 创建文件名: avatar_{userID}_{timestamp}{ext}
	fileExt := filepath.Ext(file.Filename)
	timestamp := strconv.FormatInt(time.Now().Unix(), 10)
	filename := "avatar_" + strconv.FormatUint(uint64(userID), 10) + "_" + timestamp + fileExt

	// 文件保存路径
	savePath := filepath.Join("./static/uploads/avatars/", filename)

	// 确保目录存在
	if err := os.MkdirAll("./static/uploads/avatars/", 0755); err != nil {
		return "", err
	}

	// 保存文件
	dst, err := os.Create(savePath)
	if err != nil {
		return "", err
	}
	defer dst.Close()

	src, err := file.Open()
	if err != nil {
		return "", err
	}
	defer src.Close()

	// 复制文件内容
	if _, err = io.Copy(dst, src); err != nil {
		return "", err
	}

	// 返回可访问的URL路径
	avatarURL := "/static/uploads/avatars/" + filename

	return avatarURL, nil
}

// updateUserAvatar 更新用户头像地址
func updateUserAvatar(c *gin.Context, userID uint, avatarURL string) {
	// 获取用户信息
	user, err := repository.FindUserByID(userID)
	if err != nil {
		utils.ServerError(c, err)
		return
	}
	if user.ID == 0 {
		utils.NotFound(c, "用户不存在")
		return
	}

	// 更新头像地址
	user.Avatar = avatarURL
	if err := repository.UpdateUser(user); err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回成功响应
	utils.Success(c, gin.H{
		"avatar_url": avatarURL,
	}, "头像上传成功")
}

// GetUserByPhone 根据手机号查询用户信息
func GetUserByPhone(c *gin.Context) {
	// 获取手机号参数
	phone := c.Query("phone")
	if phone == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": "手机号不能为空",
		})
		return
	}

	// 调用服务层获取用户信息
	userResp, err := service.GetUserByPhone(phone)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    400,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    200,
		"message": "success",
		"data":    userResp,
	})
}
