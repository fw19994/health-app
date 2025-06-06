package handler

import (
	"github.com/gin-gonic/gin"
	"life_app_back/internal/service"
	"life_app_back/internal/utils"
	"net/http"
	"time"
)

// GetFamilyContributions 获取家庭成员财务贡献数据
// @Summary 获取家庭成员财务贡献数据
// @Description 获取家庭成员的收入和支出数据，包括占比和金额
// @Tags 财务管理
// @Accept json
// @Produce json
// @Param year query int false "年份，默认当前年"
// @Param month query int false "月份，默认当前月"
// @Success 200 {object} util.Response "成功"
// @Failure 400 {object} util.Response "请求错误"
// @Failure 500 {object} util.Response "服务器内部错误"
// @Router /api/v1/finance/family-contributions [get]
func GetFamilyContributions(c *gin.Context) {
	// 从请求中获取当前用户ID
	userID, ok := utils.MustGetUserID(c)
	if !ok {
		return // MustGetUserID函数已经处理了错误响应
	}

	// 解析查询参数
	var query struct {
		Year     int `form:"year"`
		Month    int `form:"month"`
		FamilyId int `form:"family_id"`
	}

	if err := c.ShouldBindQuery(&query); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code":    -1,
			"message": "参数解析错误: " + err.Error(),
		})
		return
	}

	// 设置默认时间范围（当前月）
	now := time.Now()
	if query.Year == 0 {
		query.Year = now.Year()
	}
	if query.Month == 0 {
		query.Month = int(now.Month())
	}

	// 创建时间范围
	startTime := time.Date(query.Year, time.Month(query.Month), 1, 0, 0, 0, 0, time.Local)
	endTime := startTime.AddDate(0, 1, 0).Add(-time.Second)

	// 查询家庭成员
	familyService := &service.FamilyMemberService{}
	members, err := familyService.GetUserFamilyMembers(uint(query.FamilyId), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    -1,
			"message": "获取家庭成员失败: " + err.Error(),
		})
		return
	}

	// 收集所有成员的UserID，用于批量查询
	userIDs := make([]int64, 0, len(members))
	for _, member := range members {
		userIDs = append(userIDs, int64(member.ID))
	}

	// 查询每个成员的财务数据
	financeService := service.NewFinanceService()

	// 批量获取所有成员的财务数据
	financeData, err := financeService.GetMembersFinanceData(userIDs, startTime, endTime)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code":    -1,
			"message": "获取成员财务数据失败: " + err.Error(),
		})
		return
	}

	// 处理数据
	membersData := make([]gin.H, 0, len(members))

	// 计算总收入和总支出
	var totalIncome float64
	var totalExpense float64

	// 处理每个成员的数据
	for _, member := range members {
		// 从批量查询结果中获取当前成员的财务数据
		memberFinance, exists := financeData[int64(member.ID)]

		// 默认值
		income := 0.0
		expense := 0.0

		// 如果存在该成员的数据，则使用查询结果
		if exists {
			income = memberFinance["income"]
			expense = memberFinance["expense"]
		}

		totalIncome += income
		totalExpense += expense

		// 保存成员数据
		memberData := gin.H{
			"user_id":    member.UserID,
			"name":       member.Name,
			"nickname":   member.Nickname,
			"role":       member.Role,
			"avatar_url": member.AvatarURL,
			"income":     income,
			"expense":    expense,
			"balance":    income - expense,
		}

		membersData = append(membersData, memberData)
	}

	// 添加占比数据
	for i := range membersData {
		if totalIncome > 0 {
			income := membersData[i]["income"].(float64)
			incomePercentage := (income / totalIncome) * 100
			membersData[i]["income_percentage"] = incomePercentage
		} else {
			membersData[i]["income_percentage"] = 0.0
		}

		if totalExpense > 0 {
			expense := membersData[i]["expense"].(float64)
			expensePercentage := (expense / totalExpense) * 100
			membersData[i]["expense_percentage"] = expensePercentage
		} else {
			membersData[i]["expense_percentage"] = 0.0
		}
	}

	// 构建响应数据
	response := gin.H{
		"year":          query.Year,
		"month":         query.Month,
		"total_income":  totalIncome,
		"total_expense": totalExpense,
		"total_balance": totalIncome - totalExpense,
		"members":       membersData,
	}

	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "获取成功",
		"data":    response,
	})
}
