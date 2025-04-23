package config

import (
	"fmt"
	"os"
	"strings"
)

// CurrentEnv 当前运行环境
var CurrentEnv string

// GetEnvironment 获取并规范化当前环境
func GetEnvironment() string {
	// 从环境变量读取当前环境
	env := os.Getenv("APP_ENV")
	if env == "" {
		env = "local" // 默认为本地环境
	}

	// 规范化环境名称
	switch env {
	case "dev", "development":
		env = "dev"
	case "prod", "production":
		env = "prod"
	case "local":
		// 保持不变
	default:
		fmt.Printf("Warning: Unknown environment '%s', falling back to 'local'\n", env)
		env = "local"
	}

	// 存储当前环境供其他模块使用
	CurrentEnv = env
	return env
}

// IsProduction 检查是否为生产环境
func IsProduction() bool {
	return CurrentEnv == "prod"
}

// IsDevelopment 检查是否为开发环境
func IsDevelopment() bool {
	return CurrentEnv == "dev"
}

// IsLocal 检查是否为本地环境
func IsLocal() bool {
	return CurrentEnv == "local"
}

// GetEnvVar 获取环境变量值，支持默认值设置
func GetEnvVar(key string, defaultValue string) string {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	return val
}

// ReplaceEnvVars 替换字符串中的环境变量引用
func ReplaceEnvVars(value string) string {
	if strings.HasPrefix(value, "${") && strings.HasSuffix(value, "}") {
		envVar := value[2 : len(value)-1]
		
		// 检查是否有默认值设置 ${ENV_VAR:-default}
		if strings.Contains(envVar, ":-") {
			parts := strings.SplitN(envVar, ":-", 2)
			envVarName := parts[0]
			defaultVal := parts[1]
			
			envVal := os.Getenv(envVarName)
			if envVal != "" {
				return envVal
			}
			return defaultVal
		} else {
			// 没有默认值的情况
			envVal := os.Getenv(envVar)
			if envVal != "" {
				return envVal
			}
			fmt.Printf("Warning: Environment variable '%s' referenced but not set\n", envVar)
			return value
		}
	}
	return value
}
