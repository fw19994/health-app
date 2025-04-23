package service

import (
	"context"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"

	"life_app_back/internal/config"
	"life_app_back/internal/model"
)

// 验证码相关的Redis键前缀
const (
	SMSCodePrefix  = "sms:code:"
	SMSLimitPrefix = "sms:limit:"
)

// 初始化随机数生成器
func init() {
	rand.Seed(time.Now().UnixNano())
}

// SendSMSCode 发送短信验证码
func SendSMSCode(phone string, cfg config.SMSConfig) (string, int, error) {
	// 检查是否频繁发送
	if err := checkSMSLimit(phone); err != nil {
		return "", 0, err
	}

	// 生成随机验证码
	code := generateCode(cfg.CodeLength)

	// 设置验证码过期时间
	expireTime := cfg.ExpireTime

	// 存储验证码到Redis
	if err := saveSMSCode(phone, code, expireTime); err != nil {
		return "", 0, err
	}

	// 发送验证码短信
	if !cfg.MockInDev {
		// 调用真实的短信发送API
		if err := sendSMSAPI(phone, code, cfg); err != nil {
			return "", 0, err
		}
	} else {
		// 开发环境下，只打印验证码
		fmt.Printf("【模拟短信】手机号: %s, 验证码: %s\n", phone, code)
	}

	// 设置发送频率限制
	setSMSLimit(phone)

	return code, expireTime, nil
}

// VerifySMSCode 验证短信验证码
func VerifySMSCode(phone string, inputCode string) (bool, error) {
	// 检查当前环境
	env := os.Getenv("APP_ENV")
	env = strings.ToLower(env)
	
	// 开发环境特殊处理，允许固定验证码 "6666"
	if env == "dev" || env == "development" || env == "local" {
		if inputCode == "6666" {
			fmt.Println("开发环境使用默认验证码6666")
			return true, nil
		}
	}
	
	// 非开发环境或非固定验证码，从 Redis 获取存储的验证码
	ctx := context.Background()
	key := SMSCodePrefix + phone

	storedCode, err := model.Redis.Get(ctx, key).Result()
	if err != nil {
		return false, fmt.Errorf("验证码已过期或不存在")
	}

	// 比较验证码
	if storedCode != inputCode {
		return false, fmt.Errorf("验证码错误")
	}

	// 验证成功后删除验证码
	model.Redis.Del(ctx, key)

	return true, nil
}

// 生成随机验证码
func generateCode(length int) string {
	if length <= 0 {
		length = 6
	}

	// 生成指定长度的随机数字
	code := ""
	for i := 0; i < length; i++ {
		code += strconv.Itoa(rand.Intn(10))
	}

	return code
}

// 将验证码保存到Redis
func saveSMSCode(phone, code string, expireTime int) error {
	ctx := context.Background()
	key := SMSCodePrefix + phone

	// 设置验证码，并设定过期时间
	return model.Redis.Set(ctx, key, code, time.Duration(expireTime)*time.Second).Err()
}

// 设置短信发送频率限制
func setSMSLimit(phone string) error {
	ctx := context.Background()
	key := SMSLimitPrefix + phone

	// 设置1分钟内不能重复发送
	return model.Redis.Set(ctx, key, 1, time.Minute).Err()
}

// 检查是否频繁发送短信
func checkSMSLimit(phone string) error {
	ctx := context.Background()
	key := SMSLimitPrefix + phone

	// 检查是否存在限制记录
	exists, err := model.Redis.Exists(ctx, key).Result()
	if err != nil {
		return err
	}

	if exists > 0 {
		return fmt.Errorf("发送过于频繁，请稍后再试")
	}

	return nil
}

// 调用实际的短信API发送短信
func sendSMSAPI(phone, code string, cfg config.SMSConfig) error {
	// 这里根据配置的短信提供商调用不同的API
	// 比如阿里云短信、腾讯云短信等
	// 实际实现时需要集成相应的SDK

	// 本例中仅演示一个模拟实现
	fmt.Printf("发送短信到 %s，验证码: %s，签名: %s，模板ID: %s\n",
		phone, code, cfg.SignName, cfg.TemplateID)

	return nil
}
