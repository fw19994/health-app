package middleware

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
	"runtime/debug"
)

// 标准响应结构
type Response struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// ErrorHandler 全局错误处理中间件
func ErrorHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 使用defer在请求处理完成后执行
		defer func() {
			// 捕获panic
			if err := recover(); err != nil {
				// 获取堆栈信息
				stackTrace := string(debug.Stack())
				errorMsg := fmt.Sprintf("%v", err)

				// 记录详细错误到日志
				fmt.Printf("[ERROR] Panic recovered: %s\nStack: %s\n", errorMsg, stackTrace)

				// 从堆栈中提取调用来源（跳过中间件和框架的调用）
				//var source string
				//stackLines := strings.Split(stackTrace, "\n")
				//for i, line := range stackLines {
				//	if i > 3 && strings.Contains(line, "life_app_back") {
				//		source = strings.TrimSpace(line)
				//		break
				//	}
				//}

				// 对客户端隐藏技术细节
				c.AbortWithStatusJSON(http.StatusInternalServerError, Response{
					Code:    500,
					Message: "系统繁忙，请稍后再试",
					Error:   "Internal Server Error",
				})
			}
		}()

		// 继续处理请求
		c.Next()

		// 处理常见的状态码
		if c.Writer.Status() >= 400 && !c.Writer.Written() {
			statusCode := c.Writer.Status()
			var msg string

			switch statusCode {
			case http.StatusNotFound:
				msg = "请求的资源不存在"
			case http.StatusUnauthorized:
				msg = "请先登录"
			case http.StatusForbidden:
				msg = "没有操作权限"
			case http.StatusBadRequest:
				msg = "无效的请求参数"
			case http.StatusMethodNotAllowed:
				msg = "不支持的请求方法"
			case http.StatusRequestTimeout:
				msg = "请求超时"
			default:
				msg = "系统繁忙，请稍后再试"
			}

			c.AbortWithStatusJSON(statusCode, Response{
				Code:    statusCode,
				Message: msg,
				Error:   c.Errors.String(),
			})
		}
	}
}

// ResponseHandler 统一响应处理
func ResponseHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		// 如果响应已经写入，则不再处理
		if c.Writer.Written() {
			return
		}

		// 检查是否有错误
		if len(c.Errors) > 0 {
			// 如果是已知错误类型，使用对应的状态码
			c.JSON(c.Writer.Status(), Response{
				Code:    c.Writer.Status(),
				Message: "请求处理失败",
				Error:   c.Errors.String(),
			})
			return
		}

		// 处理成功情况
		if c.Keys != nil {
			if response, exists := c.Keys["response"]; exists {
				c.JSON(http.StatusOK, response)
				return
			}
		}
	}
}

// NotFound 处理404错误
func NotFound(c *gin.Context) {
	c.JSON(http.StatusNotFound, Response{
		Code:    404,
		Message: "请求的资源不存在",
		Error:   "Not Found",
	})
}

// MethodNotAllowed 处理405错误
func MethodNotAllowed(c *gin.Context) {
	c.JSON(http.StatusMethodNotAllowed, Response{
		Code:    405,
		Message: "不支持的请求方法",
		Error:   "Method Not Allowed",
	})
}
