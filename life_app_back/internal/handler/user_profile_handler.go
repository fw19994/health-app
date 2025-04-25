package handler

import (
	"github.com/gin-gonic/gin"
	"life_app_back/internal/service"
	"life_app_back/internal/utils"
)

// GetUserProfileRequest 获取用户基本信息请求
type GetUserProfileRequest struct {
	UserID uint `json:"user_id"`
}

// UpdateUserProfileRequest 更新用户基本信息请求
type UpdateUserProfileRequest struct {
	Gender       *string  `json:"gender,omitempty"`
	Birthday     *string  `json:"birthday,omitempty"`
	Height       *float64 `json:"height,omitempty"`
	Weight       *float64 `json:"weight,omitempty"`
	BloodType    *string  `json:"blood_type,omitempty"`
	Occupation   *string  `json:"occupation,omitempty"`
	Address      *string  `json:"address,omitempty"`
	EmergContact *string  `json:"emerg_contact,omitempty"`
	EmergPhone   *string  `json:"emerg_phone,omitempty"`
	Bio          *string  `json:"bio,omitempty"`
	Nickname     *string  `json:"nickname,omitempty"`
}

// GetUserProfile 获取用户基本信息
func GetUserProfile(c *gin.Context) {
	// 使用工具函数从认证中间件获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取用户基本信息
	profileResp, err := service.GetUserProfile(userID)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回用户基本信息
	utils.Success(c, profileResp, "获取成功")
}

// UpdateUserProfile 更新用户基本信息
func UpdateUserProfile(c *gin.Context) {
	// 使用工具函数从认证中间件获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 解析请求数据
	var req UpdateUserProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.ParameterError(c, "请求参数错误")
		return
	}

	// 转换为map用于更新
	updateData := make(map[string]interface{})

	// 只更新非空字段
	if req.Gender != nil {
		// 验证性别值是否有效
		if *req.Gender != "male" && *req.Gender != "female" && *req.Gender != "other" {
			utils.ParameterError(c, "性别值无效，必须是male、female或other")
			return
		}
		updateData["gender"] = *req.Gender
	}

	if req.Birthday != nil {
		updateData["birthday"] = *req.Birthday
	}

	if req.Height != nil {
		// 身高应在合理范围内(50cm-250cm)
		if *req.Height < 50 || *req.Height > 250 {
			utils.ParameterError(c, "身高数值应在50-250cm范围内")
			return
		}
		updateData["height"] = *req.Height
	}

	if req.Weight != nil {
		// 体重应在合理范围内(20kg-300kg)
		if *req.Weight < 20 || *req.Weight > 300 {
			utils.ParameterError(c, "体重数值应在20-300kg范围内")
			return
		}
		updateData["weight"] = *req.Weight
	}

	if req.BloodType != nil {
		// 验证血型是否有效
		validBloodTypes := []string{"A", "B", "AB", "O", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"}
		valid := false
		for _, bt := range validBloodTypes {
			if *req.BloodType == bt {
				valid = true
				break
			}
		}
		if !valid {
			utils.ParameterError(c, "血型值无效")
			return
		}
		updateData["blood_type"] = *req.BloodType
	}

	if req.Occupation != nil {
		updateData["occupation"] = *req.Occupation
	}

	if req.Address != nil {
		updateData["address"] = *req.Address
	}

	if req.EmergContact != nil {
		updateData["emerg_contact"] = *req.EmergContact
	}

	if req.EmergPhone != nil {
		updateData["emerg_phone"] = *req.EmergPhone
	}

	if req.Bio != nil {
		// 限制个人简介长度
		if len(*req.Bio) > 500 {
			utils.ParameterError(c, "个人简介长度不能超过500个字符")
			return
		}
		updateData["bio"] = *req.Bio
	}

	if req.Nickname != nil {
		if len(*req.Nickname) > 100 {
			utils.ParameterError(c, "姓名不能超过100个字符")
			return
		}
		updateData["nickname"] = *req.Nickname
	}
	// 更新用户基本信息
	profileResp, err := service.UpdateUserProfile(uint(userID), updateData)
	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回更新后的用户基本信息
	utils.Success(c, profileResp, "更新成功")
}
