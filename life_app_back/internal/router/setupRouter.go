package router

import (
	"os"

	"github.com/gin-gonic/gin"
	"life_app_back/internal/handler"
	"life_app_back/internal/middleware"
)

// SetupRouter 设置所有API路由
func SetupRouter(router *gin.Engine) *gin.Engine {

	// 跨域中间件
	router.Use(middleware.Cors())

	// 健康检查
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "ok",
			"env":    os.Getenv("APP_ENV"),
		})
	})

	// API路由组
	v1 := router.Group("/api/v1")
	{
		// 认证路由 - 无需认证
		auth := v1.Group("/auth")
		{
			auth.POST("/sms/send", handler.SendSMSCode)   // 发送短信验证码
			auth.POST("/login/sms", handler.LoginWithSMS) // 短信登录
			auth.POST("/register", handler.Register)      // 注册
			auth.POST("/refresh", handler.RefreshToken)   // 刷新令牌
		}

		// 需要认证的路由组
		authenticated := v1.Group("/")
		authenticated.Use(middleware.JWTAuth())
		{
			// 用户路由
			user := authenticated.Group("/user")
			{
				user.GET("/profile", handler.GetUserProfile)    // 获取用户资料
				user.PUT("/profile", handler.UpdateUserProfile) // 更新用户资料
				user.PUT("/nickname", handler.UpdateNickname)   // 修改昵称
				user.POST("/avatar", handler.UploadAvatar)      // 上传头像
				user.PUT("/password", handler.ChangePassword)   // 修改密码
				user.DELETE("/logout", handler.Logout)          // 登出
				user.GET("/phone", handler.GetUserByPhone)      // 根据手机号查询用户信息
			}

			// 上传文件路由
			upload := authenticated.Group("/upload")
			{
				upload.POST("/image", handler.UploadImage) // 上传图片
			}

			// 健康模块路由
			health := authenticated.Group("/health")
			{
				health.GET("/summary", handler.GetHealthSummary) // 健康摘要
				health.POST("/steps", handler.RecordSteps)       // 记录步数
				health.POST("/water", handler.RecordWaterIntake) // 记录饮水量
				health.POST("/sleep", handler.RecordSleep)       // 记录睡眠
				health.GET("/records", handler.GetHealthRecords) // 获取健康记录
			}

			// 财务模块路由
			finance := authenticated.Group("/finance")
			{
				finance.GET("/summary", handler.GetFinanceSummary)                 // 财务摘要
				finance.POST("/transaction", handler.AddTransaction)               // 添加交易记录 (支出或收入)
				finance.GET("/expenses", handler.GetExpenses)                      // 获取支出列表
				finance.GET("/categories", handler.GetExpenseCategories)           // 获取支出类别
				finance.GET("/report", handler.GenerateFinancialReport)            // 生成财务报告
				finance.GET("/recent-transactions", handler.GetRecentTransactions) // 获取近期交易记录
				
				// 新增API路由
				finance.GET("/transactions", handler.GetTransactions)              // 获取交易记录，支持筛选和分页
				finance.GET("/transaction-groups", handler.GetTransactionGroups)   // 获取按日期分组的交易记录
				finance.GET("/trend", handler.GetTransactionTrend)                 // 获取交易趋势数据
				finance.GET("/member-stats", handler.GetMemberExpenseStats)        // 获取成员支出统计
				finance.GET("/expense-analysis", handler.GetExpenseAnalysis)       // 获取支出分析数据，按类别统计
			}

			// 预算模块路由
			budget := authenticated.Group("/budget")
			{
				budget.GET("/categories", handler.GetBudgetCategories)             // 获取预算列表
				budget.GET("/all-categories", handler.GetAllBudgetCategories)      // 获取所有预算
				budget.POST("/category", handler.CreateBudgetCategory)             // 创建预算
				budget.PUT("/category/:id", handler.UpdateBudgetCategory)          // 更新预算
				budget.DELETE("/category/:id", handler.DeleteBudgetCategory)       // 删除预算
				budget.POST("/copy-previous", handler.CopyBudgetFromPreviousMonth) // 从上月复制预算
				budget.GET("/monthly", handler.GetMonthlyBudget)                   // 获取月度预算和消费数据
			}

			// 储蓄目标路由
			savings := authenticated.Group("/savings")
			{
				savings.GET("/goals", handler.GetSavingsGoals)                             // 获取储蓄目标列表
				savings.POST("/goal", handler.CreateSavingsGoal)                           // 创建储蓄目标
				savings.PUT("/goal/:id", handler.UpdateSavingsGoal)                        // 更新储蓄目标
				savings.DELETE("/goal/:id", handler.DeleteSavingsGoal)                     // 删除储蓄目标
				savings.PUT("/goal/:id/progress", handler.UpdateSavingsGoalProgress)       // 更新储蓄目标进度
				savings.PUT("/goal/:id/status", handler.UpdateSavingsGoalStatus)           // 更新储蓄目标状态
				savings.GET("/goal/:id/monthly", handler.GetSavingsGoalMonthlyRequirement) // 获取每月所需金额
			}

			// 家庭成员路由
			family := authenticated.Group("/family")
			{
				family.GET("/members", handler.GetFamilyMembers)         // 获取家庭成员
				family.POST("/member", handler.AddFamilyMember)          // 添加家庭成员
				family.PUT("/member/:id", handler.UpdateFamilyMember)    // 更新家庭成员
				family.DELETE("/member/:id", handler.RemoveFamilyMember) // 移除家庭成员
				family.POST("/invite", handler.CreateInvitation)         // 创建邀请
				family.GET("/roles", handler.GetFamilyRoles)             // 获取家庭角色
			}

			// 图标路由
			icons := authenticated.Group("/icons")
			{
				icons.GET("get", handler.NewIconHandler().GetUserAvailableIcons) // 获取用户可用的图标
				icons.POST("add", handler.NewIconHandler().CreateUserIcon)       // 创建用户自定义图标
			}
		}
	}

	return router
}
