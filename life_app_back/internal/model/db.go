package model

import (
	"context"
	"fmt"
	"time"

	"github.com/go-redis/redis/v8"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"life_app_back/internal/config"
)

// 全局数据库变量
var (
	DB    *gorm.DB
	Redis *redis.Client
)

// InitDB 初始化数据库连接
func InitDB(cfg config.DatabaseConfig) error {
	// 构建DSN
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?%s",
		cfg.Username,
		cfg.Password,
		cfg.Host,
		cfg.Port,
		cfg.Database,
		cfg.Options,
	)

	// 配置GORM
	gormConfig := &gorm.Config{}

	// 创建数据库连接
	var err error
	DB, err = gorm.Open(mysql.Open(dsn), gormConfig)
	if err != nil {
		return err
	}

	// 获取底层的SQL DB以配置连接池
	sqlDB, err := DB.DB()
	if err != nil {
		return err
	}

	// 配置连接池
	sqlDB.SetMaxOpenConns(cfg.MaxOpenConns)
	sqlDB.SetMaxIdleConns(cfg.MaxIdleConns)
	sqlDB.SetConnMaxLifetime(cfg.ConnMaxLifetime)

	// 自动迁移模型
	if err := DB.AutoMigrate(
		&Family{},
	); err != nil {
		return err
	}

	return nil
}

// InitRedis 初始化Redis连接
func InitRedis(cfg config.RedisConfig) error {
	Redis = redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%s:%s", cfg.Host, cfg.Port),
		Password: cfg.Password,
		DB:       cfg.DB,
	})

	// 测试连接
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	_, err := Redis.Ping(ctx).Result()
	if err != nil {
		return err
	}

	return nil
}
