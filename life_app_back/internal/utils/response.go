package utils

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Response 标准API响应结构
type Response struct {
	Code    int         `json:"code"`    // 状态码
	Message string      `json:"message"` // 消息
	Data    interface{} `json:"data,omitempty"`    // 数据
	Error   string      `json:"error,omitempty"`   // 错误详情
}

// 预定义的状态码
const (
	CodeSuccess = 0
	CodeError   = 500
	CodeAuthFailed = 401
	CodeInvalidParams = 400
	CodeNotFound = 404
	CodeForbidden = 403
)

// Success 返回成功响应
func Success(c *gin.Context, data interface{}, msg string) {
	if msg == "" {
		msg = "操作成功"
	}
	c.JSON(http.StatusOK, Response{
		Code:    CodeSuccess,
		Message: msg,
		Data:    data,
	})
}

// Fail 返回失败响应
func Fail(c *gin.Context, code int, msg string, err error) {
	httpStatus := http.StatusOK
	
	// 根据业务码确定HTTP状态码
	switch code {
	case CodeInvalidParams:
		httpStatus = http.StatusBadRequest
	case CodeAuthFailed:
		httpStatus = http.StatusUnauthorized
	case CodeForbidden:
		httpStatus = http.StatusForbidden
	case CodeNotFound:
		httpStatus = http.StatusNotFound
	case CodeError:
		httpStatus = http.StatusInternalServerError
	}
	
	errorMsg := ""
	if err != nil {
		errorMsg = err.Error()
	}
	
	// 如果是内部服务器错误，统一显示友好提示
	if code == CodeError {
		if msg == "" {
			msg = "系统繁忙，请稍后再试"
		}
	}
	
	c.JSON(httpStatus, Response{
		Code:    code,
		Message: msg,
		Error:   errorMsg,
	})
	
	// 如果是服务器错误，终止后续处理
	if code == CodeError {
		c.Abort()
	}
}

// ParameterError 返回参数错误响应
func ParameterError(c *gin.Context, msg string) {
	if msg == "" {
		msg = "请求参数错误"
	}
	Fail(c, CodeInvalidParams, msg, nil)
}

// AuthFailed 返回认证失败响应
func AuthFailed(c *gin.Context, msg string) {
	if msg == "" {
		msg = "认证失败"
	}
	Fail(c, CodeAuthFailed, msg, nil)
}

// NotFound 返回资源不存在响应
func NotFound(c *gin.Context, msg string) {
	if msg == "" {
		msg = "请求的资源不存在"
	}
	Fail(c, CodeNotFound, msg, nil)
}

// Forbidden 返回无权限响应
func Forbidden(c *gin.Context, msg string) {
	if msg == "" {
		msg = "没有操作权限"
	}
	Fail(c, CodeForbidden, msg, nil)
}

// ServerError 返回服务器错误响应
func ServerError(c *gin.Context, err error) {
	Fail(c, CodeError, "系统繁忙，请稍后再试", err)
}
