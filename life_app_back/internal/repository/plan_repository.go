package repository

import (
	"errors"
	"fmt"
	"gorm.io/gorm"
	"life_app_back/internal/model"
	"sort"
	"time"
)

// PlanRepository 计划仓库
type PlanRepository struct{}

// GetPlanByID 根据ID获取计划
func (r *PlanRepository) GetPlanByID(id uint) (*model.Plan, error) {
	var plan model.Plan
	if err := model.DB.First(&plan, id).Error; err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, err
	}
	return &plan, nil
}

// CreatePlan 创建计划
func (r *PlanRepository) CreatePlan(plan *model.Plan) error {
	return model.DB.Create(plan).Error
}

// UpdatePlan 更新计划
func (r *PlanRepository) UpdatePlan(plan *model.Plan) error {
	return model.DB.Save(plan).Error
}

// DeletePlan 删除计划
func (r *PlanRepository) DeletePlan(id uint) error {
	return model.DB.Delete(&model.Plan{}, id).Error
}

// GetDailyPlans 获取指定日期的计划列表
func (r *PlanRepository) GetDailyPlans(userID uint, date time.Time) ([]model.Plan, error) {
	var plans []model.Plan
	startDate := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
	endDate := time.Date(date.Year(), date.Month(), date.Day(), 23, 59, 59, 0, date.Location())

	// 打印日期范围信息
	fmt.Printf("查询日计划 - 用户ID: %d, 日期: %s, 开始时间: %s, 结束时间: %s\n",
		userID, date.Format("2006-01-02"), startDate.Format("2006-01-02 15:04:05"),
		endDate.Format("2006-01-02 15:04:05"))

	// 查询条件：
	// 1. 用户ID匹配
	// 2. 日期是指定日期的计划
	// 3. 或者是重复类型的计划（根据重复类型判断是否应该在当天显示）
	query := model.DB.Debug().Where("user_id = ? and date<? ", userID, endDate).
		Where("(date BETWEEN ? AND ? OR "+
			"(recurrence_type = 'daily') OR "+
			"(recurrence_type = 'weekly' AND WEEKDAY(?) = WEEKDAY(date)) OR "+
			"(recurrence_type = 'monthly' AND DAY(?) = DAY(date)) OR "+
			"(recurrence_type = 'weekdays' AND WEEKDAY(?) BETWEEN 0 AND 4) OR "+
			"(recurrence_type = 'weekends' AND WEEKDAY(?) IN (5, 6)))",
			startDate, endDate, date, date, date, date)

	if err := query.Order("start_time").Find(&plans).Error; err != nil {
		return nil, err
	}

	fmt.Printf("查询结果 - 找到计划数量: %d\n", len(plans))
	return plans, nil
}

// GetFamilyDailyPlans 获取指定家庭指定日期的计划列表
func (r *PlanRepository) GetFamilyDailyPlans(familyID uint, date time.Time) ([]model.Plan, error) {
	var plans []model.Plan
	startDate := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
	endDate := time.Date(date.Year(), date.Month(), date.Day(), 23, 59, 59, 999999999, date.Location())

	// 打印日期范围信息
	fmt.Printf("查询家庭日计划 - 家庭ID: %d, 日期: %s, 开始时间: %s, 结束时间: %s\n",
		familyID, date.Format("2006-01-02"), startDate.Format("2006-01-02 15:04:05.999999999"),
		endDate.Format("2006-01-02 15:04:05.999999999"))

	// 查询条件：
	// 1. 家庭ID匹配
	// 2. 日期是指定日期的计划
	// 3. 或者是重复类型的计划（根据重复类型判断是否应该在当天显示）
	query := model.DB.Debug().Where("family_id = ?", familyID).
		Where("(date BETWEEN ? AND ? OR "+
			"(recurrence_type = 'daily') OR "+
			"(recurrence_type = 'weekly' AND WEEKDAY(?) = WEEKDAY(date)) OR "+
			"(recurrence_type = 'monthly' AND DAY(?) = DAY(date)) OR "+
			"(recurrence_type = 'weekdays' AND WEEKDAY(?) BETWEEN 0 AND 4) OR "+
			"(recurrence_type = 'weekends' AND WEEKDAY(?) IN (5, 6)))",
			startDate, endDate, date, date, date, date)

	if err := query.Order("start_time").Find(&plans).Error; err != nil {
		return nil, err
	}

	fmt.Printf("查询结果 - 找到家庭计划数量: %d\n", len(plans))
	return plans, nil
}

// GetMonthlyPlans 获取指定月份的计划列表
func (r *PlanRepository) GetMonthlyPlans(userID uint, year int, month int) ([]model.Plan, error) {
	var plans []model.Plan
	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := startDate.AddDate(0, 1, 0).Add(-time.Nanosecond)

	if err := model.DB.Where("user_id = ? AND date BETWEEN ? AND ?", userID, startDate, endDate).Order("date, start_time").Find(&plans).Error; err != nil {
		return nil, err
	}
	return plans, nil
}

// GetFamilyMonthlyPlans 获取指定家庭指定月份的计划列表
func (r *PlanRepository) GetFamilyMonthlyPlans(familyID uint, year int, month int) ([]model.Plan, error) {
	var plans []model.Plan
	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := startDate.AddDate(0, 1, 0).Add(-time.Nanosecond)

	if err := model.DB.Where("family_id = ? AND date BETWEEN ? AND ?", familyID, startDate, endDate).Order("date, start_time").Find(&plans).Error; err != nil {
		return nil, err
	}
	return plans, nil
}

// GetMonthlyPlansGroupedByDate 获取指定月份的计划，按日期分组
func (r *PlanRepository) GetMonthlyPlansGroupedByDate(userID uint, year int, month int) (model.MonthlyPlansGrouped, error) {
	var plans []model.Plan
	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := startDate.AddDate(0, 1, 0).Add(-time.Nanosecond)

	// 获取月份内所有计划（包括一次性计划和重复计划）
	query := model.DB.Where("user_id = ?", userID).
		Where("date BETWEEN ? AND ? OR "+
			"(recurrence_type IN ('daily', 'weekly', 'monthly', 'weekdays', 'weekends'))",
			startDate, endDate)

	if err := query.Order("date, start_time").Find(&plans).Error; err != nil {
		return model.MonthlyPlansGrouped{}, err
	}

	// 创建返回结构
	result := model.MonthlyPlansGrouped{
		Year:  year,
		Month: month,
	}

	// 创建日期映射，用于按天分组
	dailyPlansMap := make(map[string][]model.PlanResponse)

	// 正确计算当月的天数
	daysInMonth := time.Date(year, time.Month(month+1), 0, 0, 0, 0, 0, time.Local).Day()

	// 将所有计划按日期分组
	for _, plan := range plans {
		planResp := plan.ToResponse()

		// 检查原始日期的计划在当天是否已完成
		if !plan.CompletedAt.IsZero() {
			isCompletedToday, err := r.CheckPlanCompletionToday(plan.ID, plan.Date)
			if err == nil {
				planResp.IsCompletedToday = isCompletedToday
			}
		}

		// 根据重复类型处理计划
		switch plan.RecurrenceType {
		case "once":
			// 一次性计划，只在其原始日期显示
			if plan.Date.Year() == year && plan.Date.Month() == time.Month(month) {
				dateStr := plan.Date.Format("2006-01-02")
				dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], planResp)
			}
		case "daily":
			// 每日重复计划，在当月每一天都显示
			for day := 1; day <= daysInMonth; day++ {
				date := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.Local)
				dateStr := date.Format("2006-01-02")

				// 为每一天创建一个计划副本
				dailyPlanResp := planResp
				dailyPlanResp.Date = date

				dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], dailyPlanResp)
			}
		case "weekly":
			// 每周重复计划，在当月所有相同星期几的日期显示
			originalWeekday := plan.Date.Weekday()
			for day := 1; day <= daysInMonth; day++ {
				date := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.Local)

				// 只在相同星期几的日期显示
				if date.Weekday() == originalWeekday {
					dateStr := date.Format("2006-01-02")

					// 为每个符合条件的日期创建一个计划副本
					weeklyPlanResp := planResp
					weeklyPlanResp.Date = date

					dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], weeklyPlanResp)
				}
			}
		case "weekdays":
			// 工作日重复计划，在当月所有工作日显示
			for day := 1; day <= daysInMonth; day++ {
				date := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.Local)
				weekday := date.Weekday()

				// 工作日为周一至周五（1-5）
				if weekday >= time.Monday && weekday <= time.Friday {
					dateStr := date.Format("2006-01-02")

					// 为每个工作日创建一个计划副本
					weekdayPlanResp := planResp
					weekdayPlanResp.Date = date
					dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], weekdayPlanResp)
				}
			}
		case "weekends":
			// 周末重复计划，在当月所有周末显示
			for day := 1; day <= daysInMonth; day++ {
				date := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.Local)
				weekday := date.Weekday()
				// 周末为周六、周日（0和6）
				if weekday == time.Saturday || weekday == time.Sunday {
					dateStr := date.Format("2006-01-02")
					// 为每个周末创建一个计划副本
					weekendPlanResp := planResp
					weekendPlanResp.Date = date
					dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], weekendPlanResp)
				}
			}
		case "monthly":
			// 每月重复计划，在当月中与原始计划日期相同的天数显示
			originalDay := plan.Date.Day()

			// 确保日期不超过当月最大天数
			if originalDay <= daysInMonth {
				date := time.Date(year, time.Month(month), originalDay, 0, 0, 0, 0, time.Local)
				dateStr := date.Format("2006-01-02")

				monthlyPlanResp := planResp
				monthlyPlanResp.Date = date
				dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], monthlyPlanResp)
			}
		}
	}

	// 将映射转换为DailyPlansGroup数组
	for dateStr, plans := range dailyPlansMap {
		date, _ := time.Parse("2006-01-02", dateStr)
		dailyGroup := model.DailyPlansGroup{
			Date:  dateStr,
			Day:   date.Day(),
			Plans: plans,
		}
		result.DailyPlans = append(result.DailyPlans, dailyGroup)
	}

	// 按日期排序
	sort.Slice(result.DailyPlans, func(i, j int) bool {
		return result.DailyPlans[i].Date < result.DailyPlans[j].Date
	})

	return result, nil
}

// GetFamilyMonthlyPlansGroupedByDate 获取指定家庭指定月份的计划，按日期分组
func (r *PlanRepository) GetFamilyMonthlyPlansGroupedByDate(familyID uint, year int, month int) (model.MonthlyPlansGrouped, error) {
	var plans []model.Plan
	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := startDate.AddDate(0, 1, 0).Add(-time.Nanosecond)

	// 获取月份内所有计划（包括一次性计划和重复计划）
	query := model.DB.Where("family_id = ?", familyID).
		Where("date BETWEEN ? AND ? OR "+
			"(recurrence_type IN ('daily', 'weekly', 'monthly', 'weekdays', 'weekends'))",
			startDate, endDate)

	if err := query.Order("date, start_time").Find(&plans).Error; err != nil {
		return model.MonthlyPlansGrouped{}, err
	}

	// 创建返回结构
	result := model.MonthlyPlansGrouped{
		Year:  year,
		Month: month,
	}

	// 创建日期映射，用于按天分组
	dailyPlansMap := make(map[string][]model.PlanResponse)

	// 正确计算当月的天数
	daysInMonth := time.Date(year, time.Month(month+1), 0, 0, 0, 0, 0, time.Local).Day()

	// 将所有计划按日期分组
	for _, plan := range plans {
		planResp := plan.ToResponse()

		// 检查原始日期的计划在当天是否已完成
		if !plan.CompletedAt.IsZero() {
			isCompletedToday, err := r.CheckPlanCompletionToday(plan.ID, plan.Date)
			if err == nil {
				planResp.IsCompletedToday = isCompletedToday
			}
		}

		// 根据重复类型处理计划
		switch plan.RecurrenceType {
		case "once":
			// 一次性计划，只在其原始日期显示
			if plan.Date.Year() == year && plan.Date.Month() == time.Month(month) {
				dateStr := plan.Date.Format("2006-01-02")
				dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], planResp)
			}
		case "daily":
			// 每日重复计划，在当月每一天都显示
			for day := 1; day <= daysInMonth; day++ {
				date := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.Local)
				dateStr := date.Format("2006-01-02")

				// 为每一天创建一个计划副本
				dailyPlanResp := planResp
				dailyPlanResp.Date = date

				// 检查该计划在当天是否已完成
				isCompletedToday, err := r.CheckPlanCompletionToday(plan.ID, date)
				if err == nil {
					dailyPlanResp.IsCompletedToday = isCompletedToday
				}

				dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], dailyPlanResp)
			}
		case "weekly":
			// 每周重复计划，在当月所有相同星期几的日期显示
			originalWeekday := plan.Date.Weekday()
			for day := 1; day <= daysInMonth; day++ {
				date := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.Local)

				// 只在相同星期几的日期显示
				if date.Weekday() == originalWeekday {
					dateStr := date.Format("2006-01-02")

					// 为每个符合条件的日期创建一个计划副本
					weeklyPlanResp := planResp
					weeklyPlanResp.Date = date

					// 检查该计划在当天是否已完成
					isCompletedToday, err := r.CheckPlanCompletionToday(plan.ID, date)
					if err == nil {
						weeklyPlanResp.IsCompletedToday = isCompletedToday
					}

					dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], weeklyPlanResp)
				}
			}
		case "weekdays":
			// 工作日重复计划，在当月所有工作日显示
			for day := 1; day <= daysInMonth; day++ {
				date := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.Local)
				weekday := date.Weekday()

				// 工作日为周一至周五（1-5）
				if weekday >= time.Monday && weekday <= time.Friday {
					dateStr := date.Format("2006-01-02")

					// 为每个工作日创建一个计划副本
					weekdayPlanResp := planResp
					weekdayPlanResp.Date = date

					// 检查该计划在当天是否已完成
					isCompletedToday, err := r.CheckPlanCompletionToday(plan.ID, date)
					if err == nil {
						weekdayPlanResp.IsCompletedToday = isCompletedToday
					}

					dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], weekdayPlanResp)
				}
			}
		case "weekends":
			// 周末重复计划，在当月所有周末显示
			for day := 1; day <= daysInMonth; day++ {
				date := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.Local)
				weekday := date.Weekday()

				// 周末为周六、周日（0和6）
				if weekday == time.Saturday || weekday == time.Sunday {
					dateStr := date.Format("2006-01-02")

					// 为每个周末创建一个计划副本
					weekendPlanResp := planResp
					weekendPlanResp.Date = date

					// 检查该计划在当天是否已完成
					isCompletedToday, err := r.CheckPlanCompletionToday(plan.ID, date)
					if err == nil {
						weekendPlanResp.IsCompletedToday = isCompletedToday
					}

					dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], weekendPlanResp)
				}
			}
		case "monthly":
			// 每月重复计划，在当月中与原始计划日期相同的天数显示
			originalDay := plan.Date.Day()

			// 确保日期不超过当月最大天数
			if originalDay <= daysInMonth {
				date := time.Date(year, time.Month(month), originalDay, 0, 0, 0, 0, time.Local)
				dateStr := date.Format("2006-01-02")

				monthlyPlanResp := planResp
				monthlyPlanResp.Date = date

				// 检查该计划在当天是否已完成
				isCompletedToday, err := r.CheckPlanCompletionToday(plan.ID, date)
				if err == nil {
					monthlyPlanResp.IsCompletedToday = isCompletedToday
				}

				dailyPlansMap[dateStr] = append(dailyPlansMap[dateStr], monthlyPlanResp)
			}
		}
	}

	// 将映射转换为DailyPlansGroup数组
	for dateStr, plans := range dailyPlansMap {
		date, _ := time.Parse("2006-01-02", dateStr)
		dailyGroup := model.DailyPlansGroup{
			Date:  dateStr,
			Day:   date.Day(),
			Plans: plans,
		}
		result.DailyPlans = append(result.DailyPlans, dailyGroup)
	}

	// 按日期排序
	sort.Slice(result.DailyPlans, func(i, j int) bool {
		return result.DailyPlans[i].Date < result.DailyPlans[j].Date
	})

	return result, nil
}

// GetPlansByPhaseID 获取指定阶段的计划列表
func (r *PlanRepository) GetPlansByPhaseID(phaseID uint) ([]model.Plan, error) {
	var plans []model.Plan
	if err := model.DB.Where("project_phase_id = ?", phaseID).Order("date, start_time").Find(&plans).Error; err != nil {
		return nil, err
	}
	return plans, nil
}

// CompletePlan 完成计划
func (r *PlanRepository) CompletePlan(id uint, userID uint, date time.Time) error {
	// 获取计划信息
	var plan model.Plan
	if err := model.DB.First(&plan, id).Error; err != nil {
		return err
	}

	// 开启事务
	tx := model.DB.Begin()

	// 创建完成记录
	completionRecord := model.PlanCompletionRecord{
		PlanID:    id,
		UserID:    userID,
		Date:      date,
		CreatedAt: time.Now(),
	}
	if err := tx.Create(&completionRecord).Error; err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit().Error
}

// CancelPlan 取消计划
func (r *PlanRepository) CancelPlan(id uint) error {
	return model.DB.Model(&model.Plan{}).Where("id = ?", id).Update("status", "canceled").Error
}

// CheckPlanCompletionToday 检查计划在指定日期是否已完成
func (r *PlanRepository) CheckPlanCompletionToday(planID uint, date time.Time) (bool, error) {
	var count int64
	startOfDay := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, time.Local)
	endOfDay := time.Date(date.Year(), date.Month(), date.Day(), 23, 59, 59, 0, time.Local)

	err := model.DB.Debug().Model(&model.PlanCompletionRecord{}).
		Where("plan_id = ? AND date BETWEEN ? AND ?", planID, startOfDay, endOfDay).
		Count(&count).Error

	return count > 0, err
}

// GetPlanCompletionRecords 获取计划的完成记录
func (r *PlanRepository) GetPlanCompletionRecords(planID uint) ([]model.PlanCompletionRecord, error) {
	var records []model.PlanCompletionRecord
	if err := model.DB.Where("plan_id = ?", planID).Order("date DESC").Find(&records).Error; err != nil {
		return nil, err
	}
	return records, nil
}

// DeletePlanCompletionRecords 删除计划的完成记录
func (r *PlanRepository) DeletePlanCompletionRecords(planID uint) error {
	return model.DB.Where("plan_id = ?", planID).Delete(&model.PlanCompletionRecord{}).Error
}

// SpecialProjectRepository 专项计划仓库
type SpecialProjectRepository struct{}

// GetSpecialProjectByID 根据ID获取专项计划
func (r *SpecialProjectRepository) GetSpecialProjectByID(id uint) (*model.SpecialProject, error) {
	var project model.SpecialProject
	if err := model.DB.First(&project, id).Error; err != nil {
		return nil, err
	}
	return &project, nil
}

// CreateSpecialProject 创建专项计划
func (r *SpecialProjectRepository) CreateSpecialProject(project *model.SpecialProject) error {
	return model.DB.Create(project).Error
}

// UpdateSpecialProject 更新专项计划
func (r *SpecialProjectRepository) UpdateSpecialProject(project *model.SpecialProject) error {
	return model.DB.Save(project).Error
}

// DeleteSpecialProject 删除专项计划
func (r *SpecialProjectRepository) DeleteSpecialProject(id uint) error {
	// 开启事务
	tx := model.DB.Begin()

	// 删除所有关联的阶段
	if err := tx.Where("special_project_id = ?", id).Delete(&model.ProjectPhase{}).Error; err != nil {
		tx.Rollback()
		return err
	}

	// 查找所有关联阶段的ID
	var phaseIDs []uint
	if err := tx.Model(&model.ProjectPhase{}).Where("special_project_id = ?", id).Pluck("id", &phaseIDs).Error; err != nil {
		tx.Rollback()
		return err
	}

	// 删除所有关联的计划
	if len(phaseIDs) > 0 {
		if err := tx.Where("project_phase_id IN ?", phaseIDs).Delete(&model.Plan{}).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	// 删除专项计划
	if err := tx.Delete(&model.SpecialProject{}, id).Error; err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit().Error
}

// GetUserSpecialProjects 获取用户的专项计划列表
func (r *SpecialProjectRepository) GetUserSpecialProjects(userID uint) ([]model.SpecialProject, error) {
	var projects []model.SpecialProject
	if err := model.DB.Where("user_id = ? AND family_id = 0", userID).Order("created_at DESC").Find(&projects).Error; err != nil {
		return nil, err
	}
	return projects, nil
}

// GetFamilySpecialProjects 获取家庭的专项计划列表
func (r *SpecialProjectRepository) GetFamilySpecialProjects(familyID uint) ([]model.SpecialProject, error) {
	var projects []model.SpecialProject
	if err := model.DB.Where("family_id = ?", familyID).Order("created_at DESC").Find(&projects).Error; err != nil {
		return nil, err
	}
	return projects, nil
}

// UpdateSpecialProjectProgress 更新专项计划进度
func (r *SpecialProjectRepository) UpdateSpecialProjectProgress(id uint, progress float64) error {
	return model.DB.Model(&model.SpecialProject{}).Where("id = ?", id).Update("progress", progress).Error
}

// UpdateSpecialProjectStatus 更新专项计划状态
func (r *SpecialProjectRepository) UpdateSpecialProjectStatus(id uint, status string) error {
	return model.DB.Model(&model.SpecialProject{}).Where("id = ?", id).Update("status", status).Error
}

// ProjectPhaseRepository 专项计划阶段仓库
type ProjectPhaseRepository struct{}

// GetPhaseByID 根据ID获取阶段
func (r *ProjectPhaseRepository) GetPhaseByID(id uint) (*model.ProjectPhase, error) {
	var phase model.ProjectPhase
	if err := model.DB.First(&phase, id).Error; err != nil {
		return nil, err
	}
	return &phase, nil
}

// CreatePhase 创建阶段
func (r *ProjectPhaseRepository) CreatePhase(phase *model.ProjectPhase, referencePhaseID uint, position string) error {
	// 开启事务
	tx := model.DB.Begin()

	// 如果没有指定参考阶段ID，则添加到最后
	if referencePhaseID == 0 || position == "" {
		// 获取当前最大的OrderIndex
		var maxOrderIndex int
		if err := tx.Model(&model.ProjectPhase{}).
			Where("special_project_id = ?", phase.SpecialProjectID).
			Select("COALESCE(MAX(order_index), 0)").
			Scan(&maxOrderIndex).Error; err != nil {
			tx.Rollback()
			return err
		}

		// 设置新阶段的OrderIndex为最大值+1
		phase.OrderIndex = maxOrderIndex + 1
	} else {
		// 获取参考阶段的信息
		var referencePhase model.ProjectPhase
		if err := tx.First(&referencePhase, referencePhaseID).Error; err != nil {
			tx.Rollback()
			return err
		}

		// 确保参考阶段属于同一个专项计划
		if referencePhase.SpecialProjectID != phase.SpecialProjectID {
			tx.Rollback()
			return errors.New("参考阶段不属于同一个专项计划")
		}

		// 根据位置设置新阶段的OrderIndex
		if position == "before" {
			// 在参考阶段之前插入
			// 先将参考阶段及之后的所有阶段的OrderIndex加1
			if err := tx.Model(&model.ProjectPhase{}).
				Where("special_project_id = ? AND order_index >= ?", phase.SpecialProjectID, referencePhase.OrderIndex).
				Update("order_index", gorm.Expr("order_index + 1")).Error; err != nil {
				tx.Rollback()
				return err
			}

			// 设置新阶段的OrderIndex为参考阶段的原OrderIndex
			phase.OrderIndex = referencePhase.OrderIndex
		} else if position == "after" {
			// 在参考阶段之后插入
			// 先将参考阶段之后的所有阶段的OrderIndex加1
			if err := tx.Model(&model.ProjectPhase{}).
				Where("special_project_id = ? AND order_index > ?", phase.SpecialProjectID, referencePhase.OrderIndex).
				Update("order_index", gorm.Expr("order_index + 1")).Error; err != nil {
				tx.Rollback()
				return err
			}

			// 设置新阶段的OrderIndex为参考阶段的OrderIndex+1
			phase.OrderIndex = referencePhase.OrderIndex + 1
		}
	}

	// 创建新阶段
	if err := tx.Create(phase).Error; err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit().Error
}

// UpdatePhase 更新阶段
func (r *ProjectPhaseRepository) UpdatePhase(phase *model.ProjectPhase) error {
	return model.DB.Save(phase).Error
}

// DeletePhase 删除阶段
func (r *ProjectPhaseRepository) DeletePhase(id uint) error {
	// 开启事务
	tx := model.DB.Begin()

	// 获取要删除的阶段信息
	var phase model.ProjectPhase
	if err := tx.First(&phase, id).Error; err != nil {
		tx.Rollback()
		return err
	}

	// 删除阶段下的所有计划
	if err := tx.Where("project_phase_id = ?", id).Delete(&model.Plan{}).Error; err != nil {
		tx.Rollback()
		return err
	}

	// 删除阶段
	if err := tx.Delete(&model.ProjectPhase{}, id).Error; err != nil {
		tx.Rollback()
		return err
	}

	// 更新后续阶段的顺序
	if err := tx.Model(&model.ProjectPhase{}).
		Where("special_project_id = ? AND order_index > ?", phase.SpecialProjectID, phase.OrderIndex).
		Update("order_index", gorm.Expr("order_index - 1")).Error; err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit().Error
}

// GetPhasesByProjectID 获取专项计划的所有阶段
func (r *ProjectPhaseRepository) GetPhasesByProjectID(projectID uint) ([]model.ProjectPhase, error) {
	var phases []model.ProjectPhase
	if err := model.DB.Where("special_project_id = ?", projectID).Order("order_index").Find(&phases).Error; err != nil {
		return nil, err
	}
	return phases, nil
}

// ReorderPhases 重新排序阶段
func (r *ProjectPhaseRepository) ReorderPhases(projectID uint, phaseIDs []uint) error {
	// 开启事务
	tx := model.DB.Begin()

	// 验证所有阶段ID是否属于该专项计划
	var count int64
	if err := tx.Model(&model.ProjectPhase{}).
		Where("special_project_id = ? AND id IN ?", projectID, phaseIDs).
		Count(&count).Error; err != nil {
		tx.Rollback()
		return err
	}

	if int(count) != len(phaseIDs) {
		tx.Rollback()
		return gorm.ErrRecordNotFound
	}

	// 更新每个阶段的顺序
	for i, phaseID := range phaseIDs {
		if err := tx.Model(&model.ProjectPhase{}).
			Where("id = ?", phaseID).
			Update("order_index", i+1).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	return tx.Commit().Error
}

// PlanReminderRepository 计划提醒仓库
type PlanReminderRepository struct{}

// CreateReminder 创建提醒
func (r *PlanReminderRepository) CreateReminder(reminder *model.PlanReminder) error {
	return model.DB.Create(reminder).Error
}

// GetRemindersByUserID 获取用户的所有提醒
func (r *PlanReminderRepository) GetRemindersByUserID(userID uint) ([]model.PlanReminder, error) {
	var reminders []model.PlanReminder
	if err := model.DB.Where("user_id = ?", userID).Order("remind_at DESC").Find(&reminders).Error; err != nil {
		return nil, err
	}
	return reminders, nil
}

// GetUnreadRemindersByUserID 获取用户的未读提醒
func (r *PlanReminderRepository) GetUnreadRemindersByUserID(userID uint) ([]model.PlanReminder, error) {
	var reminders []model.PlanReminder
	if err := model.DB.Where("user_id = ? AND is_read = ?", userID, false).Order("remind_at DESC").Find(&reminders).Error; err != nil {
		return nil, err
	}
	return reminders, nil
}

// MarkReminderAsRead 标记提醒为已读
func (r *PlanReminderRepository) MarkReminderAsRead(id uint) error {
	return model.DB.Model(&model.PlanReminder{}).Where("id = ?", id).Update("is_read", true).Error
}

// DeleteReminder 删除提醒
func (r *PlanReminderRepository) DeleteReminder(id uint) error {
	return model.DB.Delete(&model.PlanReminder{}, id).Error
}

// DeleteRemindersByPlanID 删除计划的所有提醒
func (r *PlanReminderRepository) DeleteRemindersByPlanID(planID uint) error {
	return model.DB.Where("plan_id = ?", planID).Delete(&model.PlanReminder{}).Error
}
