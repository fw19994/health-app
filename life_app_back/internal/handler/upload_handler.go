package handler

import (
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"life_app_back/internal/utils"
)

// UploadImageRequest 上传图片请求
type UploadImageRequest struct {
	Directory string `form:"directory"` // 可选参数，指定存储目录
}

// UploadImage 上传图片
func UploadImage(c *gin.Context) {
	// 获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 解析目录参数
	var req UploadImageRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.ParameterError(c, "参数错误")
		return
	}

	// 设置默认目录
	directory := req.Directory
	if directory == "" {
		directory = "common"
	}

	// 验证目录名合法性
	if !isValidDirectoryName(directory) {
		utils.ParameterError(c, "目录名称不合法")
		return
	}

	// 获取上传的文件
	file, err := c.FormFile("image")
	if err != nil {
		utils.ParameterError(c, "未找到上传的文件")
		return
	}

	// 验证文件类型
	if !isValidImageFile(file) {
		utils.ParameterError(c, "文件类型不支持，请上传图片格式文件")
		return
	}

	// 使用OSS服务上传文件
	ossService, err := utils.GetOSSService()
	if err != nil {
		utils.ServerError(c, fmt.Errorf("初始化OSS服务失败: %w", err))
		return
	}

	var imageURL string

	// 判断OSS服务是否配置有效
	if !ossService.IsConfigValid() {
		// OSS配置无效，切换为本地存储
		imageURL, err = saveImageFile(file, uint(userID), directory)
		if err != nil {
			utils.ServerError(c, err)
			return
		}
	} else {
		// 使用OSS服务上传图片
		imageURL, err = ossService.UploadImage(file, uint(userID), directory)
		if err != nil {
			utils.ServerError(c, fmt.Errorf("上传图片到OSS失败: %w", err))
			return
		}
	}

	// 返回成功响应
	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "图片上传成功",
		"data": gin.H{
			"url": imageURL,
		},
	})
}

// isValidDirectoryName 验证目录名是否合法
func isValidDirectoryName(name string) bool {
	// 不允许带有路径分隔符，避免路径遍历问题
	if filepath.Base(name) != name {
		return false
	}

	// 只允许字母、数字、下划线和中划线
	for _, char := range name {
		if !((char >= 'a' && char <= 'z') || 
			(char >= 'A' && char <= 'Z') || 
			(char >= '0' && char <= '9') || 
			char == '_' || char == '-') {
			return false
		}
	}

	return true
}

// saveImageFile 保存图片文件到本地并返回访问路径 (仅在OSS配置无效时使用)
func saveImageFile(file *multipart.FileHeader, userID uint, directory string) (string, error) {
	// 创建文件名: image_{directory}_{userID}_{timestamp}{ext}
	fileExt := filepath.Ext(file.Filename)
	timestamp := strconv.FormatInt(time.Now().Unix(), 10)
	filename := "image_" + directory + "_" + strconv.FormatUint(uint64(userID), 10) + "_" + timestamp + fileExt

	// 文件保存路径，确保目录存在
	savePath := filepath.Join("./static/uploads/images/", directory)
	if err := os.MkdirAll(savePath, 0755); err != nil {
		return "", err
	}

	// 完整保存路径
	fullPath := filepath.Join(savePath, filename)
	
	// 保存文件
	dst, err := os.Create(fullPath)
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
	imageURL := "/static/uploads/images/" + directory + "/" + filename

	return imageURL, nil
}

// isValidImageFile 验证是否为合法的图片文件
func isValidImageFile(file *multipart.FileHeader) bool {
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