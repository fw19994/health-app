import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan/special_project_model.dart';
import '../models/plan/project_task_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'project_phase_service.dart'; // Added import for ProjectPhaseService

/// 专项计划服务类，负责管理专项计划数据
class SpecialProjectService extends ChangeNotifier {
  // 专项计划列表
  final List<SpecialProject> _projects = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();
  late ProjectPhaseService _phaseService; // Added ProjectPhaseService
  BuildContext? _context;
  
  // 获取所有专项计划
  List<SpecialProject> get projects => _projects;
  
  // 加载状态
  bool get isLoading => _isLoading;
  
  // 错误信息
  String? get error => _error;

  // 构造函数
  SpecialProjectService({BuildContext? context}) {
    _context = context;
    _phaseService = ProjectPhaseService(context: context); // Initialize ProjectPhaseService
    if (context != null) {
      loadProjects();
    }
  }

  // 设置上下文并加载数据
  Future<void> setContext(BuildContext context) async {
    _context = context;
    _phaseService.setContext(context); // Set context for ProjectPhaseService
    // 设置了上下文后加载数据
    await loadProjects();
  }
  
  // 根据ID获取专项计划
  SpecialProject? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // 根据状态过滤专项计划
  List<SpecialProject> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((project) => project.status == status).toList();
  }
  
  // 从API加载专项计划
  Future<void> loadProjects() async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      await _loadFromCache();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiService.get(
        path: ApiConstants.getSpecialProjects,
        context: _context,
      );
      
      if (response['code'] == 0 && response['data'] != null) {
        final List<dynamic> projectsData = response['data'] is List 
            ? response['data'] 
            : (response['data']['projects'] ?? []);
        
        _projects.clear();
        
        for (var item in projectsData) {
          try {
            final project = SpecialProject.fromJson(item);
            _projects.add(project);
          } catch (e) {
            print('解析专项计划数据失败: $e');
          }
        }
        
        await _saveToCache();
        _error = null;
      } else {
        _error = response['message'] ?? '加载专项计划失败';
      }
    } catch (e) {
      print('加载专项计划失败: $e');
      _error = '加载专项计划失败，请检查网络连接';
      await _loadFromCache();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 从本地缓存加载专项计划
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? projectsJson = prefs.getString('special_projects');
      
      if (projectsJson != null) {
        final List<dynamic> decoded = jsonDecode(projectsJson);
        
        _projects.clear();
        for (var item in decoded) {
          try {
            final project = SpecialProject.fromJson(item);
    _projects.add(project);
          } catch (e) {
            print('解析缓存专项计划数据失败: $e');
          }
        }
      }
    } catch (e) {
      print('从缓存加载专项计划失败: $e');
    }
  }
  
  // 保存专项计划到本地缓存
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = jsonEncode(_projects.map((p) => p.toJson()).toList());
      await prefs.setString('special_projects', projectsJson);
    } catch (e) {
      print('保存专项计划到缓存失败: $e');
    }
  }
  
  // 添加专项计划
  Future<SpecialProject?> addProject(SpecialProject project) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return null;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 准备请求数据
      final data = {
        'title': project.title,
        'description': project.description,
        'start_date': project.startDate != null ? _formatDate(project.startDate!) : null,
        'end_date': project.endDate != null ? _formatDate(project.endDate!) : null,
        'status': _statusToString(project.status),
        'budget': project.budget,
        // 如果有阶段，也可以添加
        'phases': project.tasks.map((task) => {
          'name': task.category,
          'description': '',
        }).toSet().toList(),
      };
      
      final response = await _apiService.post(
        path: ApiConstants.createSpecialProject,
        data: data,
        context: _context,
      );
      
      if (response['code'] == 0 && response['data'] != null) {
        // 获取创建的专项计划ID
        final createdId = response['data']['id']?.toString() ?? '';
        
        if (createdId.isNotEmpty) {
          // 创建一个新的专项计划对象，使用后端返回的ID
          final createdProject = SpecialProject(
            id: createdId,
            title: project.title,
            description: project.description,
            startDate: project.startDate,
            endDate: project.endDate,
            status: project.status,
            completedTasks: 0,
            totalTasks: 0,
            budget: project.budget,
            spent: 0,
            tasks: [],
            icon: project.icon,
            iconBackgroundGradient: project.iconBackgroundGradient,
          );
          
          _projects.add(createdProject);
          await _saveToCache();
          _error = null;
          notifyListeners();
          
          return createdProject;
        }
      } else {
        _error = response['message'] ?? '创建专项计划失败';
      }
    } catch (e) {
      print('创建专项计划失败: $e');
      _error = '创建专项计划失败，请检查网络连接';
    } finally {
      _isLoading = false;
    notifyListeners();
  }
  
    return null;
  }
  
  // 更新专项计划
  Future<bool> updateProject(SpecialProject project) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 准备请求数据
      final data = {
        'title': project.title,
        'description': project.description,
        'start_date': project.startDate != null ? _formatDate(project.startDate!) : null,
        'end_date': project.endDate != null ? _formatDate(project.endDate!) : null,
        'status': _statusToString(project.status),
        'budget': project.budget,
      };
      
      final response = await _apiService.put(
        path: '${ApiConstants.updateSpecialProject}/${project.id}',
        data: data,
        context: _context,
      );
      
      if (response['code'] == 0) {
        // 更新本地数据
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
          await _saveToCache();
        }
        _error = null;
      notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '更新专项计划失败';
      }
    } catch (e) {
      print('更新专项计划失败: $e');
      _error = '更新专项计划失败，请检查网络连接';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    return false;
  }
  
  // 删除专项计划
  Future<bool> deleteProject(String id) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiService.delete(
        path: '${ApiConstants.deleteSpecialProject}/${id}',
        context: _context,
      );
      
      if (response['code'] == 0) {
        // 从本地数据中删除
    _projects.removeWhere((project) => project.id == id);
        await _saveToCache();
        _error = null;
    notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '删除专项计划失败';
      }
    } catch (e) {
      print('删除专项计划失败: $e');
      _error = '删除专项计划失败，请检查网络连接';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    return false;
  }
  
  // 更新专项计划状态
  Future<bool> updateProjectStatus(String id, ProjectStatus status) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final data = {
        'status': _statusToString(status),
      };
      
      final response = await _apiService.put(
        path: '${ApiConstants.updateSpecialProject}/${id}/status',
        data: data,
        context: _context,
      );
      
      if (response['code'] == 0) {
        // 更新本地数据
        final index = _projects.indexWhere((p) => p.id == id);
        if (index >= 0) {
          _projects[index] = _projects[index].copyWith(status: status);
          await _saveToCache();
        }
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '更新专项计划状态失败';
      }
    } catch (e) {
      print('更新专项计划状态失败: $e');
      _error = '更新专项计划状态失败，请检查网络连接';
    } finally {
      _isLoading = false;
    notifyListeners();
    }
    
    return false;
  }
  
  // 添加任务到项目
  void addTaskToProject(String projectId, ProjectTask task) {
    final project = getProjectById(projectId);
    if (project != null) {
      final tasks = List<ProjectTask>.from(project.tasks);
      tasks.add(task);
      
      final updatedProject = project.copyWith(
        tasks: tasks,
        totalTasks: project.totalTasks + 1,
      );
      
      updateProject(updatedProject);
    }
  }
  
  // 更新任务
  void updateTask(String projectId, ProjectTask updatedTask) {
    final project = getProjectById(projectId);
    if (project != null) {
      final tasks = List<ProjectTask>.from(project.tasks);
      final taskIndex = tasks.indexWhere((t) => t.id == updatedTask.id);
      
      if (taskIndex >= 0) {
        // 保存原始任务状态
        final oldStatus = tasks[taskIndex].status;
        
        // 更新任务
        tasks[taskIndex] = updatedTask;
        
        // 如果任务状态发生变化，更新完成任务数量
        int completedTasks = project.completedTasks;
        if (oldStatus != updatedTask.status) {
          if (oldStatus != TaskStatus.completed && updatedTask.status == TaskStatus.completed) {
            completedTasks++;
          } else if (oldStatus == TaskStatus.completed && updatedTask.status != TaskStatus.completed) {
            completedTasks--;
          }
        }
        
        final updatedProject = project.copyWith(
          tasks: tasks,
          completedTasks: completedTasks,
        );
        
        updateProject(updatedProject);
      }
    }
  }
  
  // 删除任务
  void deleteTask(String projectId, String taskId) {
    final project = getProjectById(projectId);
    if (project != null) {
      final tasks = List<ProjectTask>.from(project.tasks);
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);
      
      if (taskIndex >= 0) {
        // 检查是否是已完成的任务
        final isCompleted = tasks[taskIndex].status == TaskStatus.completed;
        
        // 删除任务
        tasks.removeAt(taskIndex);
        
        // 更新项目
        final updatedProject = project.copyWith(
          tasks: tasks,
          totalTasks: project.totalTasks - 1,
          completedTasks: isCompleted ? project.completedTasks - 1 : project.completedTasks,
        );
        
        updateProject(updatedProject);
      }
    }
  }
  
  // 更新任务状态
  void updateTaskStatus(String projectId, String taskId, TaskStatus status) {
    final project = getProjectById(projectId);
    if (project != null) {
      final tasks = List<ProjectTask>.from(project.tasks);
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);
      
      if (taskIndex >= 0) {
        final oldStatus = tasks[taskIndex].status;
        final task = tasks[taskIndex].copyWith(status: status);
        tasks[taskIndex] = task;
        
        // 更新完成任务数量
        int completedTasks = project.completedTasks;
        if (oldStatus != TaskStatus.completed && status == TaskStatus.completed) {
          completedTasks++;
        } else if (oldStatus == TaskStatus.completed && status != TaskStatus.completed) {
          completedTasks--;
        }
        
        final updatedProject = project.copyWith(
          tasks: tasks,
          completedTasks: completedTasks,
        );
        
        updateProject(updatedProject);
      }
    }
  }
  
  // 更新阶段名称
  Future<bool> updatePhase(String projectId, String oldName, String newName) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
    
      // 首先获取该阶段的ID
      final phases = await _phaseService.getProjectPhases(projectId);
      final phaseData = phases.firstWhere(
        (phase) => phase['name'] == oldName,
        orElse: () => <String, dynamic>{},
      );
      
      if (phaseData.isEmpty || phaseData['id'] == null) {
        _error = '未找到指定阶段';
        _isLoading = false;
        notifyListeners();
        return false;
    }
    
      // 使用阶段服务更新阶段名称
      final result = await _phaseService.updatePhase(
        phaseId: phaseData['id'].toString(),
        name: newName,
        description: phaseData['description'] ?? '',
      );
      
      if (result) {
        // 更新本地项目数据中的任务分类
    final project = getProjectById(projectId);
        if (project != null) {
    final tasks = List<ProjectTask>.from(project.tasks);
    for (int i = 0; i < tasks.length; i++) {
            if (tasks[i].category == oldName) {
              tasks[i] = tasks[i].copyWith(category: newName);
      }
    }
    
      final updatedProject = project.copyWith(tasks: tasks);
          
          // 更新本地缓存（不调用updateProject避免额外的API调用）
          final index = _projects.indexWhere((p) => p.id == projectId);
          if (index >= 0) {
            _projects[index] = updatedProject;
            await _saveToCache();
          }
        }
        
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
    } else {
        _error = _phaseService.error ?? '更新阶段名称失败';
    }
    } catch (e) {
      print('更新阶段名称失败: $e');
      _error = '更新阶段名称失败，请检查网络连接';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    return false;
  }
  
  // 添加阶段
  Future<bool> addPhase(String projectId, String phaseName, String beforePhaseName) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 使用阶段服务创建新阶段
      final phaseData = await _phaseService.createPhase(
        projectId: projectId,
        name: phaseName,
        description: '',
      );
      
      if (phaseData != null) {
        // 重新获取项目的所有阶段
        final phases = await _phaseService.getProjectPhases(projectId);
    
        // 如果指定了beforePhaseName，需要对阶段进行重新排序
        if (beforePhaseName.isNotEmpty) {
          // 提取当前所有阶段ID
          final phaseIds = phases.map((p) => p['id'].toString()).toList();
          
          // 找到新阶段和目标阶段的ID
          final newPhaseId = phaseData['id'].toString();
          String? beforePhaseId;
          
          for (var phase in phases) {
            if (phase['name'] == beforePhaseName) {
              beforePhaseId = phase['id'].toString();
              break;
            }
          }
          
          if (beforePhaseId != null) {
            // 从列表中移除新阶段ID
            phaseIds.remove(newPhaseId);
            
            // 找到目标阶段ID的位置
            final beforeIndex = phaseIds.indexOf(beforePhaseId);
            
            // 在目标阶段ID之前插入新阶段ID
            phaseIds.insert(beforeIndex, newPhaseId);
            
            // 使用阶段服务重新排序阶段
            await _phaseService.reorderPhases(projectId: projectId, phaseIds: phaseIds);
          }
        }
        
        // 重新加载项目数据以反映更改
        await loadProjects();
        _error = null;
        return true;
      } else {
        _error = _phaseService.error ?? '添加阶段失败';
      }
    } catch (e) {
      print('添加阶段失败: $e');
      _error = '添加阶段失败，请检查网络连接';
    } finally {
      _isLoading = false;
    notifyListeners();
  }
  
    return false;
  }
  
  // 在指定任务前插入任务
  Future<bool> insertTaskBefore(String projectId, String referenceTaskId, ProjectTask task) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      // 获取当前项目数据
    final project = getProjectById(projectId);
      if (project == null) {
        _error = '未找到指定项目';
        return false;
      }
      
      final tasks = List<ProjectTask>.from(project.tasks);
      final refTaskIndex = tasks.indexWhere((t) => t.id == referenceTaskId);
      
      if (refTaskIndex < 0) {
        _error = '未找到参考任务';
        return false;
      }
      
      // 生成任务ID
      final String newTaskId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 创建包含ID的任务对象
      final newTask = task.copyWith(id: newTaskId);
      
      // 在参考任务之前插入新任务
      tasks.insert(refTaskIndex, newTask);
    
    // 更新项目
    final updatedProject = project.copyWith(
      tasks: tasks,
        totalTasks: project.totalTasks + 1,
      );
      
      // 更新项目数据
      final success = await updateProject(updatedProject);
      
      return success;
    } catch (e) {
      print('在指定任务前插入任务失败: $e');
      _error = '插入任务失败，请检查网络连接';
      return false;
    }
  }
  
  // 删除阶段
  Future<bool> deletePhase(String projectId, String phaseName) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 首先获取该阶段的ID
      final phases = await _phaseService.getProjectPhases(projectId);
      final phaseData = phases.firstWhere(
        (phase) => phase['name'] == phaseName,
        orElse: () => <String, dynamic>{},
      );
      
      if (phaseData.isEmpty || phaseData['id'] == null) {
        _error = '未找到指定阶段';
        _isLoading = false;
        notifyListeners();
        return false;
  }
  
      // 使用阶段服务删除阶段
      final result = await _phaseService.deletePhase(phaseData['id'].toString());
      
      if (result) {
        // 更新本地项目数据，移除该阶段的所有任务
    final project = getProjectById(projectId);
    if (project != null) {
    final tasks = List<ProjectTask>.from(project.tasks);
          final oldTasksCount = tasks.length;
    
    // 计算该阶段已完成的任务数量
          int completedTasksInPhase = 0;
          for (final task in tasks) {
            if (task.category == phaseName && task.status == TaskStatus.completed) {
              completedTasksInPhase++;
            }
          }
    
    // 移除该阶段的所有任务
          tasks.removeWhere((task) => task.category == phaseName);
    
    final updatedProject = project.copyWith(
      tasks: tasks,
            totalTasks: project.totalTasks - (oldTasksCount - tasks.length),
      completedTasks: project.completedTasks - completedTasksInPhase,
    );
    
          // 更新本地缓存（不调用updateProject避免额外的API调用）
          final index = _projects.indexWhere((p) => p.id == projectId);
          if (index >= 0) {
            _projects[index] = updatedProject;
            await _saveToCache();
          }
        }
        
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = _phaseService.error ?? '删除阶段失败';
      }
    } catch (e) {
      print('删除阶段失败: $e');
      _error = '删除阶段失败，请检查网络连接';
    } finally {
      _isLoading = false;
    notifyListeners();
  }
  
    return false;
  }
  
  // 辅助方法：状态枚举转字符串
  String _statusToString(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'active';
      case ProjectStatus.completed:
        return 'completed';
      case ProjectStatus.planned:
        return 'planned';
    }
  }

  // 辅助方法：格式化日期为 yyyy-MM-dd 格式
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 从API获取专项计划详情
  Future<SpecialProject?> getSpecialProjectDetail(String projectId) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return null;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final response = await _apiService.get(
        path: '${ApiConstants.getSpecialProjectDetail}/$projectId',
        context: _context,
      );
      
      if (response['code'] == 0 && response['data'] != null) {
        final projectData = response['data'];
        
        // 确保ID是字符串类型
        if (projectData['id'] != null && projectData['id'] is int) {
          projectData['id'] = projectData['id'].toString();
        }
        
        // 确保phases中的id和special_project_id是字符串类型
        if (projectData['phases'] != null && projectData['phases'] is List) {
          for (var phase in projectData['phases']) {
            if (phase['id'] != null && phase['id'] is int) {
              phase['id'] = phase['id'].toString();
            }
            if (phase['special_project_id'] != null && phase['special_project_id'] is int) {
              phase['special_project_id'] = phase['special_project_id'].toString();
            }
            
            // 确保plans中的id和project_phase_id是字符串类型
            if (phase['plans'] != null && phase['plans'] is List) {
              for (var plan in phase['plans']) {
                if (plan['id'] != null && plan['id'] is int) {
                  plan['id'] = plan['id'].toString();
                }
                if (plan['project_phase_id'] != null && plan['project_phase_id'] is int) {
                  plan['project_phase_id'] = plan['project_phase_id'].toString();
                }
              }
            }
          }
        }
        
        final project = SpecialProject.fromJson(projectData);
        
        // 更新缓存
        final index = _projects.indexWhere((p) => p.id == project.id);
        if (index >= 0) {
          _projects[index] = project;
        } else {
          _projects.add(project);
        }
        
        setState(() {
          _isLoading = false;
        });
        
        return project;
      } else {
        setState(() {
          _error = response['message'] ?? '获取专项计划详情失败';
          _isLoading = false;
        });
        return null;
      }
    } catch (e) {
      print('获取专项计划详情失败: $e');
      setState(() {
        _error = '获取专项计划详情失败，请检查网络连接';
        _isLoading = false;
      });
      return null;
    }
  }
  
  // 设置状态并通知监听器
  void setState(Function() updateState) {
    updateState();
    notifyListeners();
  }

  // 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // 向指定阶段添加任务
  Future<bool> addTaskToPhase({
    required String projectId,
    required String phaseId,
    required ProjectTask task,
  }) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 准备任务数据
      final data = {
        'project_phase_id': int.parse(phaseId),
        'title': task.title,
        'description': task.description,
        'date': _formatDate(task.date),
        'start_time': task.startTime != null ? 
          '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}' : null,
        'end_time': task.endTime != null ? 
          '${task.endTime!.hour.toString().padLeft(2, '0')}:${task.endTime!.minute.toString().padLeft(2, '0')}' : null,
        'is_all_day': task.isAllDay,
        'cost': task.cost,
        'status': _taskStatusToString(task.status),
        'category': task.category, // 添加必需的Category参数
        'recurrence_type': 'once', // 添加必需的RecurrenceType参数
      };
      
      // 调用API创建任务
      final response = await _apiService.post(
        path: ApiConstants.createPlan,
        data: data,
        context: _context,
      );
      
      if (response['code'] == 0) {
        // 更新本地数据
    final project = getProjectById(projectId);
    if (project != null) {
          // 获取创建的任务ID
          final createdTaskId = response['data']?['id']?.toString() ?? '';
          
          if (createdTaskId.isNotEmpty) {
            // 创建一个新的任务对象，使用后端返回的ID
            final createdTask = task.copyWith(id: createdTaskId);
            
            // 更新项目中的任务列表
      final tasks = List<ProjectTask>.from(project.tasks);
            tasks.add(createdTask);
        
        final updatedProject = project.copyWith(
          tasks: tasks,
          totalTasks: project.totalTasks + 1,
        );
        
            // 更新本地缓存
            final index = _projects.indexWhere((p) => p.id == projectId);
            if (index >= 0) {
              _projects[index] = updatedProject;
              await _saveToCache();
            }
          }
        }
        
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '添加任务失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('添加任务失败: $e');
      _error = '添加任务失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 向指定阶段添加任务，并指定位置
  Future<bool> addTaskToPhaseWithPosition({
    required String projectId,
    required String phaseId,
    required ProjectTask task,
    required String referenceTaskId,
    required String position, // 'before' 或 'after'
  }) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 准备任务数据
      final data = {
        'project_phase_id': int.parse(phaseId),
        'title': task.title,
        'description': task.description,
        'date': _formatDate(task.date),
        'start_time': task.startTime != null ? 
          '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}' : null,
        'end_time': task.endTime != null ? 
          '${task.endTime!.hour.toString().padLeft(2, '0')}:${task.endTime!.minute.toString().padLeft(2, '0')}' : null,
        'is_all_day': task.isAllDay,
        'cost': task.cost,
        'status': _taskStatusToString(task.status),
        'reference_task_id': int.parse(referenceTaskId),
        'position': position,
        'category': task.category, // 添加必需的Category参数
        'recurrence_type': 'once', // 添加必需的RecurrenceType参数
      };
      
      // 调用API创建任务
      final response = await _apiService.post(
        path: ApiConstants.createPlan,
        data: data,
        context: _context,
      );
      
      if (response['code'] == 0) {
        // 更新本地数据 - 由于位置关系复杂，直接重新加载项目数据
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '添加任务失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('添加任务失败: $e');
      _error = '添加任务失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 辅助方法：任务状态枚举转字符串
  String _taskStatusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return 'not_started';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
    }
  }

  // 更新指定阶段中的任务
  Future<bool> updateTaskInPhase({
    required String projectId,
    required String phaseId,
    required ProjectTask task,
  }) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 准备任务数据
      final data = {
        'title': task.title,
        'description': task.description,
        'date': _formatDate(task.date),
        'start_time': task.startTime != null ? 
          '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}' : null,
        'end_time': task.endTime != null ? 
          '${task.endTime!.hour.toString().padLeft(2, '0')}:${task.endTime!.minute.toString().padLeft(2, '0')}' : null,
        'is_all_day': task.isAllDay,
        'cost': task.cost,
        'status': _taskStatusToString(task.status),
        'project_phase_id': int.parse(phaseId),
        'category': "", // 专项计划更新时category必须为空字符串
        'recurrence_type': 'once', // 添加必需的RecurrenceType参数
      };
      
      // 调用API更新任务
      final response = await _apiService.put(
        path: '${ApiConstants.updatePlan}/${task.id}',
        data: data,
        context: _context,
      );
      
      if (response['code'] == 0) {
        // 更新本地数据
    final project = getProjectById(projectId);
    if (project != null) {
      final tasks = List<ProjectTask>.from(project.tasks);
          final taskIndex = tasks.indexWhere((t) => t.id == task.id);
          
          if (taskIndex >= 0) {
            // 保存原始任务状态
            final oldStatus = tasks[taskIndex].status;
            
            // 更新任务
            tasks[taskIndex] = task;
            
            // 如果任务状态发生变化，更新完成任务数量
            int completedTasks = project.completedTasks;
            if (oldStatus != task.status) {
              if (oldStatus != TaskStatus.completed && task.status == TaskStatus.completed) {
                completedTasks++;
              } else if (oldStatus == TaskStatus.completed && task.status != TaskStatus.completed) {
                completedTasks--;
              }
            }
        
        final updatedProject = project.copyWith(
          tasks: tasks,
              completedTasks: completedTasks,
            );
            
            // 更新本地缓存
            final index = _projects.indexWhere((p) => p.id == projectId);
            if (index >= 0) {
              _projects[index] = updatedProject;
              await _saveToCache();
            }
          }
        }
        
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '更新任务失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('更新任务失败: $e');
      _error = '更新任务失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 从指定阶段删除任务
  Future<bool> deleteTaskFromPhase({
    required String projectId,
    required String phaseId,
    required String taskId,
  }) async {
    if (_context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 调用API删除任务
      final response = await _apiService.delete(
        path: '${ApiConstants.deletePlan}/$taskId',
        context: _context,
      );
      
      if (response['code'] == 0) {
        // 更新本地数据
    final project = getProjectById(projectId);
        if (project != null) {
          final tasks = List<ProjectTask>.from(project.tasks);
          final taskIndex = tasks.indexWhere((t) => t.id == taskId);
          
          if (taskIndex >= 0) {
            // 检查是否是已完成的任务
            final isCompleted = tasks[taskIndex].status == TaskStatus.completed;
            
            // 删除任务
            tasks.removeAt(taskIndex);
            
            // 更新项目
            final updatedProject = project.copyWith(
              tasks: tasks,
              totalTasks: project.totalTasks - 1,
              completedTasks: isCompleted ? project.completedTasks - 1 : project.completedTasks,
            );
            
            // 更新本地缓存
            final index = _projects.indexWhere((p) => p.id == projectId);
            if (index >= 0) {
              _projects[index] = updatedProject;
              await _saveToCache();
            }
          }
        }
        
        _error = null;
        _isLoading = false;
    notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '删除任务失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('删除任务失败: $e');
      _error = '删除任务失败，请检查网络连接';
      _isLoading = false;
   notifyListeners();
      return false;
    }
  }

  // 标记任务为已完成
  Future<bool> markTaskAsCompleted(String taskId, {BuildContext? context, DateTime? date}) async {
    if (_context == null && context == null) {
      print('警告：SpecialProjectService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 找到对应的任务
      ProjectTask? targetTask;
      for (final project in _projects) {
        final taskIndex = project.tasks.indexWhere((task) => task.id == taskId);
        if (taskIndex >= 0) {
          targetTask = project.tasks[taskIndex];
          break;
        }
      }
      
      // 使用任务的日期或当前日期
      final taskDate = date ?? targetTask?.date ?? DateTime.now();
      String dateStr = "${taskDate.year}-${taskDate.month.toString().padLeft(2, '0')}-${taskDate.day.toString().padLeft(2, '0')}";
      
      // 发送API请求
      final response = await _apiService.put(
        path: '${ApiConstants.completePlan}/$taskId/complete',
        data: {
          'completed': true,
          'date': dateStr,
        },
        context: context ?? _context,
      );
      
      if (response['code'] == 0) {
        // 找到任务所在的项目
        for (int i = 0; i < _projects.length; i++) {
          final project = _projects[i];
          final taskIndex = project.tasks.indexWhere((task) => task.id == taskId);
          
          if (taskIndex >= 0) {
            // 获取当前任务
            final task = project.tasks[taskIndex];
            
            // 创建完成状态的任务
            final completedTask = task.copyWith(
              status: TaskStatus.completed,
            );
            
            // 更新任务列表
            final updatedTasks = List<ProjectTask>.from(project.tasks);
            updatedTasks[taskIndex] = completedTask;
            
            // 更新项目
            final updatedProject = project.copyWith(
              tasks: updatedTasks,
              completedTasks: project.completedTasks + 1,
            );
            
            // 更新缓存
            _projects[i] = updatedProject;
            await _saveToCache();
            break;
          }
        }
        
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? '标记任务完成失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('标记任务完成失败: $e');
      _error = '标记任务完成失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 