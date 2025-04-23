package repository

import (
	"gorm.io/gorm"
)

// DB 数据库连接实例
var DB *gorm.DB

// SetupRepositories 初始化所有仓库
func SetupRepositories(db *gorm.DB) {
	DB = db
}

// GetDB 获取数据库连接
func GetDB() *gorm.DB {
	return DB
}
