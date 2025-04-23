package middleware

import (
	"life_app_back/internal/utils"
	"strings"

	"github.com/gin-gonic/gin"
	"life_app_back/internal/handler"
	"life_app_back/internal/service"
)

// JWTAuth JWT认证中间件
func JWTAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 从请求头获取token
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			utils.AuthFailed(c, "未提供认证令牌")
			c.Abort()
			return
		}

		// 检查格式
		parts := strings.SplitN(authHeader, " ", 2)
		if !(len(parts) == 2 && parts[0] == "Bearer") {
			utils.AuthFailed(c, "认证格式无效")
			c.Abort()
			return
		}

		token := parts[1]

		// 验证令牌
		claims, err := service.VerifyToken(token, handler.Cfg.JWT)
		if err != nil {
			utils.AuthFailed(c, "无效的令牌")
			c.Abort()
			return
		}

		// 确保是访问令牌
		tokenType, ok := claims["type"].(string)
		if !ok || tokenType != "access" {
			utils.AuthFailed(c, "令牌类型无效")
			c.Abort()
			return
		}

		// 将用户信息存储在上下文中
		userID, _ := claims["sub"].(string)
		userName, _ := claims["name"].(string)
		userPhone, _ := claims["phone"].(string)

		c.Set("userID", userID)
		c.Set("userName", userName)
		c.Set("userPhone", userPhone)

		c.Next()
	}
}
