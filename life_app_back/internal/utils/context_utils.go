package utils

import (
	"errors"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// GetUserIDFromContext 从Gin上下文中获取用户ID
// 此函数假设用户ID已通过JWTAuth中间件被设置到context中
func GetUserIDFromContext(c *gin.Context) (uint, error) {
	// 从上下文获取用户ID
	userIDInterface, exists := c.Get("userID")
	if !exists {
		return 0, errors.New("未找到用户ID，请确保用户已登录")
	}

	// 转换为uint类型
	switch v := userIDInterface.(type) {
	case string:
		// 如果是字符串，需要转换为数字
		id, err := strconv.ParseUint(v, 10, 32)
		if err != nil {
			return 0, fmt.Errorf("无法解析用户ID: %w", err)
		}
		return uint(id), nil
	case float64:
		// JSON解析数字可能会作为float64
		return uint(v), nil
	case int:
		return uint(v), nil
	case int64:
		return uint(v), nil
	case uint:
		return v, nil
	case uint64:
		return uint(v), nil
	default:
		return 0, fmt.Errorf("不支持的用户ID类型: %T", userIDInterface)
	}
}

// MustGetUserID 从上下文获取用户ID，如果失败则中断请求并返回错误
// 此函数用于处理程序中，当用户ID是必须的情况
func MustGetUserID(c *gin.Context) (uint, bool) {
	userID, err := GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"code":    401,
			"message": err.Error(),
		})
		return 0, false
	}
	return userID, true
}

// ParseIntWithDefault 将字符串解析为整数，并在解析失败时提供默认值
// 可以指定最小值和最大值进行范围限制，如果解析出的值超出范围，则返回默认值
// 例如: ParseIntWithDefault("10", 5, 1, 100) 将返回 10
// 例如: ParseIntWithDefault("invalid", 5) 将返回 5
// 例如: ParseIntWithDefault("200", 5, 1, 100) 将返回 5，因为200超出了限制的最大值100
func ParseIntWithDefault(str string, defaultValue int, limits ...int) int {
	if str == "" {
		return defaultValue
	}

	// 尝试解析字符串为整数
	val, err := strconv.Atoi(str)
	if err != nil {
		return defaultValue
	}

	// 如果提供了限制参数，检查值是否在范围内
	if len(limits) >= 1 {
		minVal := limits[0]
		if val < minVal {
			return defaultValue
		}
	}

	if len(limits) >= 2 {
		maxVal := limits[1]
		if val > maxVal {
			return defaultValue
		}
	}

	return val
}
