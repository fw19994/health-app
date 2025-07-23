package service

import (
	"errors"
	"life_app_back/internal/model"
	"life_app_back/internal/repository"
	"sort"
)

// SpecialProjectService 专项计划服务
type SpecialProjectService struct {
	repo repository.SpecialProjectRepository
}

// GetSpecialProjectByID 根据ID获取专项计划
func (s *SpecialProjectService) GetSpecialProjectByID(id uint) (model.SpecialProjectResponse, error) {
	// 查询专项计划
	project, err := s.repo.GetSpecialProjectByID(id)
	if err != nil {
		return model.SpecialProjectResponse{}, err
	}

	// 转换为响应模型
	response := project.ToResponse()

	// 获取阶段信息
	phaseRepo := repository.ProjectPhaseRepository{}
	phases, err := phaseRepo.GetPhasesByProjectID(id)
	if err == nil {
		phaseResponses := make([]model.ProjectPhaseResponse, len(phases))
		for i, phase := range phases {
			phaseResponses[i] = phase.ToResponse()
		}
		response.Phases = phaseResponses
	}

	// 计算任务统计信息
	planRepo := repository.PlanRepository{}
	var totalTasks, completedTasks int

	for i, phase := range response.Phases {
		plans, err := planRepo.GetPlansByPhaseID(phase.ID)
		if err == nil {
			totalTasks += len(plans)
			for _, plan := range plans {
				planResponse := plan.ToResponse()
				// 如果是重复类型的计划，检查指定日期是否已完成
				isCompletedToday, err := planRepo.CheckPlanCompletionToday(plan.ID, plan.Date)
				if err == nil && isCompletedToday {
					planResponse.IsCompletedToday = true
					completedTasks++
				}
				response.Phases[i].Plans = append(response.Phases[i].Plans, planResponse)
			}

			// 对计划按照日期和开始时间排序
			sort.Slice(response.Phases[i].Plans, func(j, k int) bool {
				// 首先按日期排序
				if response.Phases[i].Plans[j].Date.Before(response.Phases[i].Plans[k].Date) {
					return true
				}
				if response.Phases[i].Plans[j].Date.After(response.Phases[i].Plans[k].Date) {
					return false
				}

				// 如果日期相同，则按开始时间排序
				return response.Phases[i].Plans[j].StartTime < response.Phases[i].Plans[k].StartTime
			})
		}
	}

	response.TotalTasks = totalTasks
	response.CompletedTasks = completedTasks

	// 计算进度
	if totalTasks > 0 {
		response.Progress = float64(completedTasks) / float64(totalTasks) * 100
	}

	return response, nil
}

// CreateSpecialProject 创建专项计划
func (s *SpecialProjectService) CreateSpecialProject(project *model.SpecialProject) (uint, error) {
	// 验证必填字段
	if project.Title == "" {
		return 0, errors.New("专项计划标题不能为空")
	}

	// 设置默认状态
	if project.Status == "" {
		project.Status = "planning"
	}

	// 调用仓库层创建专项计划
	if err := s.repo.CreateSpecialProject(project); err != nil {
		return 0, err
	}

	return project.ID, nil
}

// UpdateSpecialProject 更新专项计划
func (s *SpecialProjectService) UpdateSpecialProject(project *model.SpecialProject) error {
	// 查询原有专项计划
	existingProject, err := s.repo.GetSpecialProjectByID(project.ID)
	if err != nil {
		return err
	}

	// 更新字段
	if project.Title != "" {
		existingProject.Title = project.Title
	}
	existingProject.Description = project.Description

	if !project.StartDate.IsZero() {
		existingProject.StartDate = project.StartDate
	}

	if !project.EndDate.IsZero() {
		existingProject.EndDate = project.EndDate
	}

	if project.Status != "" {
		existingProject.Status = project.Status
	}

	if project.Budget > 0 {
		existingProject.Budget = project.Budget
	}

	// 调用仓库层更新专项计划
	return s.repo.UpdateSpecialProject(existingProject)
}

// DeleteSpecialProject 删除专项计划
func (s *SpecialProjectService) DeleteSpecialProject(id uint) error {
	return s.repo.DeleteSpecialProject(id)
}

// GetUserSpecialProjects 获取用户的专项计划列表
func (s *SpecialProjectService) GetUserSpecialProjects(userID uint) ([]model.SpecialProjectResponse, error) {
	// 查询用户的专项计划
	projects, err := s.repo.GetUserSpecialProjects(userID)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型
	responses := make([]model.SpecialProjectResponse, len(projects))
	for i, project := range projects {
		responses[i] = project.ToResponse()
	}

	return responses, nil
}

// GetFamilySpecialProjects 获取家庭的专项计划列表
func (s *SpecialProjectService) GetFamilySpecialProjects(familyID uint) ([]model.SpecialProjectResponse, error) {
	// 查询家庭的专项计划
	projects, err := s.repo.GetFamilySpecialProjects(familyID)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型
	responses := make([]model.SpecialProjectResponse, len(projects))
	for i, project := range projects {
		responses[i] = project.ToResponse()
	}

	return responses, nil
}

// UpdateSpecialProjectStatus 更新专项计划状态
func (s *SpecialProjectService) UpdateSpecialProjectStatus(id uint, status string) error {
	return s.repo.UpdateSpecialProjectStatus(id, status)
}

// UpdateSpecialProjectProgress 更新专项计划进度
func (s *SpecialProjectService) UpdateSpecialProjectProgress(projectID uint) error {
	// 获取专项计划的所有阶段
	phaseRepo := repository.ProjectPhaseRepository{}
	phases, err := phaseRepo.GetPhasesByProjectID(projectID)
	if err != nil {
		return err
	}

	// 计算任务统计信息
	planRepo := repository.PlanRepository{}
	var totalTasks, completedTasks int

	for _, phase := range phases {
		plans, err := planRepo.GetPlansByPhaseID(phase.ID)
		if err == nil {
			totalTasks += len(plans)
			for _, plan := range plans {
				if plan.Status == "completed" {
					completedTasks++
				}
			}
		}
	}

	// 计算进度
	var progress float64
	if totalTasks > 0 {
		progress = float64(completedTasks) / float64(totalTasks) * 100
	}

	// 更新专项计划进度
	return s.repo.UpdateSpecialProjectProgress(projectID, progress)
}
