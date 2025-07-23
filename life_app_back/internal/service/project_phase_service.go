package service

import (
	"errors"
	"life_app_back/internal/model"
	"life_app_back/internal/repository"
)

// ProjectPhaseService 专项计划阶段服务
type ProjectPhaseService struct {
	repo repository.ProjectPhaseRepository
}

// GetPhaseByID 根据ID获取阶段
func (s *ProjectPhaseService) GetPhaseByID(id uint) (model.ProjectPhaseResponse, error) {
	// 查询阶段
	phase, err := s.repo.GetPhaseByID(id)
	if err != nil {
		return model.ProjectPhaseResponse{}, err
	}

	// 转换为响应模型
	response := phase.ToResponse()

	// 获取阶段下的计划
	planRepo := repository.PlanRepository{}
	plans, err := planRepo.GetPlansByPhaseID(id)
	if err == nil {
		planResponses := make([]model.PlanResponse, len(plans))
		var completedCount int
		for i, plan := range plans {
			planResponses[i] = plan.ToResponse()
			if plan.Status == "completed" {
				completedCount++
			}
		}
		response.Plans = planResponses
		response.TotalTasks = len(plans)
		response.CompletedTasks = completedCount
		
		// 计算进度
		if len(plans) > 0 {
			response.Progress = float64(completedCount) / float64(len(plans)) * 100
		}
	}

	return response, nil
}

// CreatePhase 创建阶段
func (s *ProjectPhaseService) CreatePhase(phase *model.ProjectPhase, referencePhaseID uint, position string) (uint, error) {
	// 验证必填字段
	if phase.Name == "" {
		return 0, errors.New("阶段名称不能为空")
	}

	if phase.SpecialProjectID == 0 {
		return 0, errors.New("必须指定所属专项计划")
	}

	// 调用仓库层创建阶段
	if err := s.repo.CreatePhase(phase, referencePhaseID, position); err != nil {
		return 0, err
	}

	return phase.ID, nil
}

// UpdatePhase 更新阶段
func (s *ProjectPhaseService) UpdatePhase(phase *model.ProjectPhase) error {
	// 查询原有阶段
	existingPhase, err := s.repo.GetPhaseByID(phase.ID)
	if err != nil {
		return err
	}

	// 更新字段
	if phase.Name != "" {
		existingPhase.Name = phase.Name
	}
	existingPhase.Description = phase.Description

	// 调用仓库层更新阶段
	return s.repo.UpdatePhase(existingPhase)
}

// DeletePhase 删除阶段
func (s *ProjectPhaseService) DeletePhase(id uint) error {
	return s.repo.DeletePhase(id)
}

// GetPhasesByProjectID 获取专项计划的所有阶段
func (s *ProjectPhaseService) GetPhasesByProjectID(projectID uint) ([]model.ProjectPhaseResponse, error) {
	// 查询专项计划的所有阶段
	phases, err := s.repo.GetPhasesByProjectID(projectID)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型
	responses := make([]model.ProjectPhaseResponse, len(phases))
	
	// 获取计划仓库
	planRepo := repository.PlanRepository{}
	
	for i, phase := range phases {
		responses[i] = phase.ToResponse()
		
		// 获取阶段下的计划
		plans, err := planRepo.GetPlansByPhaseID(phase.ID)
		if err == nil {
			var completedCount int
			for _, plan := range plans {
				if plan.Status == "completed" {
					completedCount++
				}
			}
			responses[i].TotalTasks = len(plans)
			responses[i].CompletedTasks = completedCount
			
			// 计算进度
			if len(plans) > 0 {
				responses[i].Progress = float64(completedCount) / float64(len(plans)) * 100
			}
		}
	}

	return responses, nil
}

// ReorderPhases 重新排序阶段
func (s *ProjectPhaseService) ReorderPhases(projectID uint, phaseIDs []uint) error {
	return s.repo.ReorderPhases(projectID, phaseIDs)
} 