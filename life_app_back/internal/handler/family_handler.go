package handler

import (
	"life_app_back/internal/repository"
	"life_app_back/internal/utils"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"life_app_back/internal/model"
	"life_app_back/internal/service"
)

// GetFamilyMembers 获取家庭成员列表
func GetFamilyMembers(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}
	familyId := c.DefaultQuery("family_id", "0")
	if familyId == "" {
		utils.Fail(c, utils.CodeInvalidParams, "family_id参数错误", nil)
	}
	// 调用服务层获取用户所属家庭的所有成员
	memberService := &service.FamilyMemberService{}
	familyIdInt, _ := strconv.Atoi(familyId)
	members, err := memberService.GetUserFamilyMembers(uint(familyIdInt), userID)

	if err != nil {
		statusCode := http.StatusInternalServerError
		if err.Error() == "用户不属于任何家庭" {
			statusCode = http.StatusNotFound
		}

		c.JSON(statusCode, gin.H{
			"code":    -1,
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "获取成功",
		"data":    members,
	})
}

// AddFamilyMember 添加家庭成员
func AddFamilyMember(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request struct {
		UserID      uint   `json:"user_id"`
		Name        string `json:"name" binding:"required"`
		Nickname    string `json:"nickname"`
		Description string `json:"description"`
		Phone       string `json:"phone"`
		Role        string `json:"role" binding:"required"`
		Gender      string `json:"gender"`
		AvatarURL   string `json:"avatar_url"`
		Permission  string `json:"permission" binding:"required"`
		FamilyId    string `json:"family_id"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    -1,
			"message": "参数错误: " + err.Error(),
		})
		return
	}
	familyId, _ := strconv.Atoi(request.FamilyId)
	// 构建成员模型
	member := &model.FamilyMember{
		OwnerID:     uint(familyId),
		UserID:      userID,
		Name:        request.Name,
		Nickname:    request.Nickname,
		Description: request.Description,
		Phone:       request.Phone,
		Role:        request.Role,
		Gender:      request.Gender,
		AvatarURL:   request.AvatarURL,
		Permission:  request.Permission,
	}

	// 如果是虚拟成员，userId为0
	if request.UserID == 0 {
		// 虚拟成员，啥也不做
		member.UserID = 0
	}

	// 调用服务
	memberService := &service.FamilyMemberService{}
	if err := memberService.AddFamilyMember(member); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    -1,
			"message": "添加家庭成员失败: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "添加成功",
		"data": gin.H{
			"id": member.ID,
		},
	})
}

// UpdateFamilyMember 更新家庭成员
func UpdateFamilyMember(c *gin.Context) {
	// 从请求中获取当前用户ID
	_, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取成员ID
	memberIDStr := c.Param("id")
	memberID, err := strconv.ParseUint(memberIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    -1,
			"message": "无效的成员ID",
		})
		return
	}

	// 绑定请求参数
	var request struct {
		Name        string `json:"name"`
		Nickname    string `json:"nickname"`
		Description string `json:"description"`
		Role        string `json:"role"`
		Gender      string `json:"gender"`
		Permission  string `json:"permission"`
		AvatarURL   string `json:"avatar_url"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    -1,
			"message": "参数错误: " + err.Error(),
		})
		return
	}

	// 构建成员模型
	member := &model.FamilyMember{
		ID:          uint(memberID),
		Name:        request.Name,
		Nickname:    request.Nickname,
		Description: request.Description,
		Role:        request.Role,
		Gender:      request.Gender,
		Permission:  request.Permission,
		AvatarURL:   request.AvatarURL,
	}

	// 调用服务
	memberService := &service.FamilyMemberService{}
	if err := memberService.UpdateFamilyMember(member); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    -1,
			"message": "更新家庭成员失败: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "更新成功",
	})
}

// RemoveFamilyMember 移除家庭成员
func RemoveFamilyMember(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取成员ID
	memberIDStr := c.Param("id")
	memberID, err := strconv.ParseUint(memberIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    -1,
			"message": "无效的成员ID",
		})
		return
	}

	// 调用服务
	memberService := &service.FamilyMemberService{}
	if err := memberService.RemoveFamilyMember(uint(memberID), userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    -1,
			"message": "移除家庭成员失败: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "移除成功",
	})
}

// CreateInvitation 创建邀请
func CreateInvitation(c *gin.Context) {
	// 从请求中获取当前用户ID
	_, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request struct {
		OwnerID uint `json:"owner_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    -1,
			"message": "参数错误: " + err.Error(),
		})
		return
	}

	// 调用服务
	memberService := &service.FamilyMemberService{}
	invitation, err := memberService.CreateInvitation(request.OwnerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    -1,
			"message": "创建邀请失败: " + err.Error(),
		})
		return
	}

	// 计算过期时间（秒）
	expireSeconds := int64(invitation.ExpireTime.Sub(time.Now()).Seconds())

	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "创建成功",
		"data": gin.H{
			"inviteCode": invitation.InviteCode,
			"expireTime": expireSeconds,
		},
	})
}

// GetFamilyRoles 获取家庭角色
func GetFamilyRoles(c *gin.Context) {
	// 调用服务获取角色信息
	memberService := &service.FamilyMemberService{}
	roles := memberService.GetFamilyRoles()

	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "获取成功",
		"data":    roles,
	})
}

// JoinFamily 通过邀请码加入家庭
func JoinFamily(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request struct {
		InviteCode string `json:"invite_code" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    -1,
			"message": "参数错误: " + err.Error(),
		})
		return
	}

	// 获取用户信息
	user, err := repository.FindUserByID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    -1,
			"message": "获取用户信息失败: " + err.Error(),
		})
		return
	}

	// 查找邀请码
	repo := &repository.FamilyMemberRepository{}
	invitation, err := repo.GetInvitationByCode(request.InviteCode)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    -1,
			"message": "无效的邀请码: " + err.Error(),
		})
		return
	}

	// 创建家庭成员
	member := &model.FamilyMember{
		OwnerID:    invitation.OwnerID,
		UserID:     userID,
		Name:       user.Nickname,
		Phone:      user.Phone,
		AvatarURL:  user.Avatar,
		Role:       "其他",  // 默认角色
		Permission: "查看者", // 默认权限
	}

	memberService := &service.FamilyMemberService{}
	if err := memberService.AddFamilyMember(member); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    -1,
			"message": "加入家庭失败: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "加入家庭成功",
		"data": gin.H{
			"owner_id":  invitation.OwnerID,
			"member_id": member.ID,
		},
	})
}

// GetFamilies 获取用户关联的所有家庭
func GetFamilies(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 调用服务层获取家庭列表
	familyService := &service.FamilyService{}
	families, err := familyService.GetFamilies(userID)

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回结果
	utils.Success(c, families, "获取家庭列表成功")
}

// CreateFamily 创建新家庭
func CreateFamily(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request struct {
		Name        string `json:"name" binding:"required"`
		Description string `json:"description"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "请求参数错误: "+err.Error())
		return
	}

	// 调用服务层创建家庭
	familyService := &service.FamilyService{}
	family, err := familyService.CreateFamily(userID, request.Name, request.Description)

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回结果
	utils.Success(c, family, "创建家庭成功")
}

// GetFamilyDetail 获取家庭详情
func GetFamilyDetail(c *gin.Context) {
	// 从请求中获取当前用户ID
	_, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取家庭ID
	familyIDStr := c.Param("id")
	familyID, err := strconv.ParseUint(familyIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的家庭ID")
		return
	}

	// 调用服务层获取家庭详情
	familyService := &service.FamilyService{}
	family, err := familyService.GetFamilyByID(uint(familyID))

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回结果
	utils.Success(c, family, "获取家庭详情成功")
}

// UpdateFamily 更新家庭信息
func UpdateFamily(c *gin.Context) {
	// 从请求中获取当前用户ID
	_, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取家庭ID
	familyIDStr := c.Param("id")
	familyID, err := strconv.ParseUint(familyIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的家庭ID")
		return
	}

	// 绑定请求参数
	var request struct {
		Name        string `json:"name" binding:"required"`
		Description string `json:"description"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "请求参数错误: "+err.Error())
		return
	}

	// 调用服务层更新家庭
	familyService := &service.FamilyService{}
	family, err := familyService.UpdateFamily(uint(familyID), request.Name, request.Description)

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回结果
	utils.Success(c, family, "更新家庭信息成功")
}

// SetFamilyStatus 设置家庭状态
func SetFamilyStatus(c *gin.Context) {
	// 从请求中获取当前用户ID
	_, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取家庭ID
	familyIDStr := c.Param("id")
	familyID, err := strconv.ParseUint(familyIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的家庭ID")
		return
	}

	// 绑定请求参数
	var request struct {
		IsActive bool `json:"is_active"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "请求参数错误: "+err.Error())
		return
	}

	// 调用服务层设置家庭状态
	familyService := &service.FamilyService{}
	if err := familyService.SetFamilyStatus(uint(familyID), request.IsActive); err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回结果
	utils.Success(c, nil, "设置家庭状态成功")
}

// DeleteFamily 删除家庭
func DeleteFamily(c *gin.Context) {
	// 从请求中获取当前用户ID
	_, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 获取家庭ID
	familyIDStr := c.Param("id")
	familyID, err := strconv.ParseUint(familyIDStr, 10, 32)
	if err != nil {
		utils.ParameterError(c, "无效的家庭ID")
		return
	}

	// 调用服务层删除家庭
	familyService := &service.FamilyService{}
	if err := familyService.DeleteFamily(uint(familyID)); err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回结果
	utils.Success(c, nil, "删除家庭成功")
}

// JoinFamilyByCode 通过邀请码加入家庭
func JoinFamilyByCode(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 绑定请求参数
	var request struct {
		Code string `json:"code" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		utils.ParameterError(c, "请求参数错误: "+err.Error())
		return
	}

	// 调用服务层加入家庭
	familyService := &service.FamilyService{}
	family, err := familyService.JoinFamily(userID, request.Code)

	if err != nil {
		utils.ServerError(c, err)
		return
	}

	// 返回结果
	utils.Success(c, family, "加入家庭成功")
}
