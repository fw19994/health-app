package model

import (
	"fmt"
)

// BizError 业务错误，用于代表业务规则检查未通过
type BizError struct {
	Message string
}

// Error 实现error接口
func (e *BizError) Error() string {
	return e.Message
}

// NewBizError 创建业务错误
func NewBizError(message string) *BizError {
	return &BizError{
		Message: message,
	}
}

// IsBizError 判断是否为业务错误
func IsBizError(err error) bool {
	_, ok := err.(*BizError)
	return ok
}

// BusinessError 带代码的业务错误
type BusinessError struct {
	Code    int
	Message string
}

// Error 实现error接口
func (e *BusinessError) Error() string {
	return fmt.Sprintf("业务错误(代码:%d): %s", e.Code, e.Message)
}

// NewBusinessError 创建带代码的业务错误
func NewBusinessError(code int, message string) *BusinessError {
	return &BusinessError{
		Code:    code,
		Message: message,
	}
}

// 预定义错误代码
const (
	ErrCodeBadRequest      = 400 // 请求参数错误
	ErrCodeUnauthorized    = 401 // 未授权
	ErrCodeForbidden       = 403 // 权限不足
	ErrCodeNotFound        = 404 // 资源不存在
	ErrCodeConflict        = 409 // 资源冲突
	ErrCodeInternalServer  = 500 // 服务器内部错误
	ErrCodeServiceUnavailable = 503 // 服务不可用
)

// 常用业务错误
var (
	ErrNotFound        = NewBusinessError(ErrCodeNotFound, "资源不存在")
	ErrUnauthorized    = NewBusinessError(ErrCodeUnauthorized, "未授权，请先登录")
	ErrPermissionDenied = NewBusinessError(ErrCodeForbidden, "权限不足")
	ErrInvalidParams   = NewBusinessError(ErrCodeBadRequest, "无效的参数")
	ErrInternalServer  = NewBusinessError(ErrCodeInternalServer, "服务器内部错误")
) 