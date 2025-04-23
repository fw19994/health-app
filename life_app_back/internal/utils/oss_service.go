package utils

import (
	"fmt"
	"life_app_back/internal/config"
	"mime/multipart"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/aliyun/aliyun-oss-go-sdk/oss"
)

// OSSService 阿里云OSS服务
type OSSService struct {
	client      *oss.Client
	bucket      *oss.Bucket
	ossConfig   config.OSSConfig
	initialized bool
}

var (
	// 单例模式
	ossServiceInstance *OSSService
)

// GetOSSService 获取OSS服务实例
func GetOSSService() (*OSSService, error) {
	if ossServiceInstance == nil {
		ossServiceInstance = &OSSService{
			ossConfig: config.ConfigData.OSS,
		}
		err := ossServiceInstance.initialize()
		if err != nil {
			return nil, err
		}
	}

	return ossServiceInstance, nil
}

// 初始化OSS客户端
func (s *OSSService) initialize() error {
	if s.initialized {
		return nil
	}

	client, err := oss.New(s.ossConfig.Endpoint, s.ossConfig.AccessKeyID, s.ossConfig.AccessKeySecret)
	if err != nil {
		return fmt.Errorf("初始化OSS客户端失败: %w", err)
	}

	bucket, err := client.Bucket(s.ossConfig.BucketName)
	if err != nil {
		return fmt.Errorf("获取OSS Bucket失败: %w", err)
	}

	s.client = client
	s.bucket = bucket
	s.initialized = true

	return nil
}

// UploadAvatar 上传头像到OSS
func (s *OSSService) UploadAvatar(file *multipart.FileHeader, userID uint) (string, error) {
	if err := s.initialize(); err != nil {
		return "", err
	}

	// 打开文件
	src, err := file.Open()
	if err != nil {
		return "", fmt.Errorf("打开文件失败: %w", err)
	}
	defer src.Close()

	// 构建OSS对象名
	fileExt := filepath.Ext(file.Filename)
	timestamp := strconv.FormatInt(time.Now().Unix(), 10)
	objectName := fmt.Sprintf("avatars/user_%d_%s%s", userID, timestamp, fileExt)

	// 上传文件到OSS
	err = s.bucket.PutObject(objectName, src)
	if err != nil {
		return "", fmt.Errorf("上传到OSS失败: %w", err)
	}

	// 返回可访问的URL
	return s.ossConfig.URLPrefix + "/" + objectName, nil
}

// UploadImage 上传图片到OSS
func (s *OSSService) UploadImage(file *multipart.FileHeader, userID uint, directory string) (string, error) {
	if err := s.initialize(); err != nil {
		return "", err
	}

	// 打开文件
	src, err := file.Open()
	if err != nil {
		return "", fmt.Errorf("打开文件失败: %w", err)
	}
	defer src.Close()

	// 构建OSS对象名
	fileExt := filepath.Ext(file.Filename)
	timestamp := strconv.FormatInt(time.Now().Unix(), 10)
	
	// 确保目录路径以/结尾
	if directory != "" && !strings.HasSuffix(directory, "/") {
		directory = directory + "/"
	}
	
	objectName := fmt.Sprintf("%suser_%d_%s%s", directory, userID, timestamp, fileExt)

	// 上传文件到OSS
	err = s.bucket.PutObject(objectName, src)
	if err != nil {
		return "", fmt.Errorf("上传到OSS失败: %w", err)
	}

	// 返回可访问的URL
	return s.ossConfig.URLPrefix + "/" + objectName, nil
}

// 检查OSS配置是否有效
func (s *OSSService) IsConfigValid() bool {
	return s.ossConfig.Endpoint != "" &&
		s.ossConfig.AccessKeyID != "" &&
		s.ossConfig.AccessKeySecret != "" &&
		s.ossConfig.BucketName != ""
}
