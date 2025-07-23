import 'package:flutter/material.dart';
import 'project_task_model.dart';
import 'project_phase_model.dart';

/// 项目状态枚举
enum ProjectStatus {
  planned,   // 未开始
  active,    // 进行中
  completed, // 已完成
}

/// 专项计划模型类
class SpecialProject {
  final String id;
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectStatus status;
  final int completedTasks;
  final int totalTasks;
  final double budget;
  final double spent;
  final List<ProjectTask> tasks;
  final List<ProjectPhase> phases;
  final IconData icon;
  final List<Color> iconBackgroundGradient;
  final double progress;
  final int daysRemaining;
  final bool isOverdue;
  
  // 为了兼容旧代码，添加name getter
  String get name => title;

  SpecialProject({
    required this.id,
    required this.title,
    required this.description,
    this.startDate,
    this.endDate,
    required this.status,
    required this.completedTasks,
    required this.totalTasks,
    required this.budget,
    required this.spent,
    required this.tasks,
    this.phases = const [],
    this.icon = Icons.folder,
    this.iconBackgroundGradient = const [Color(0xFF4F46E5), Color(0xFF818CF8)],
    double? progress,
    this.daysRemaining = 0,
    this.isOverdue = false,
  }) : this.progress = progress ?? (totalTasks > 0 ? completedTasks / totalTasks : 0.0);

  /// 从JSON创建项目实例
  factory SpecialProject.fromJson(Map<String, dynamic> json) {
    List<ProjectTask> taskList = [];
    if (json['tasks'] != null) {
      taskList = (json['tasks'] as List)
          .map((taskJson) => ProjectTask.fromJson(taskJson))
          .toList();
    }
    
    // 处理阶段数据
    List<ProjectPhase> phasesList = [];
    if (json['phases'] != null) {
      phasesList = (json['phases'] as List)
          .map((phaseJson) => ProjectPhase.fromJson(phaseJson))
          .toList();
    }
    
    // 处理后端返回的日期格式
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      
      try {
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        }
        return null;
      } catch (e) {
        print('解析日期失败: $e, 值: $dateValue');
        return null;
      }
    }
    
    // 处理字段名称差异
    final startDate = json['startDate'] != null ? parseDate(json['startDate']) : 
                     (json['start_date'] != null ? parseDate(json['start_date']) : null);
                     
    final endDate = json['endDate'] != null ? parseDate(json['endDate']) : 
                   (json['end_date'] != null ? parseDate(json['end_date']) : null);
    
    final completedTasks = json['completedTasks'] ?? json['completed_tasks'] ?? 0;
    final totalTasks = json['totalTasks'] ?? json['total_tasks'] ?? 0;
    // 计算真实进度，不使用传入的progress值
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final budget = (json['budget'] ?? 0.0).toDouble();
    final spent = (json['actualCost'] ?? json['actual_cost'] ?? 0.0).toDouble();
    final daysRemaining = json['days_remaining'] ?? 0;
    final isOverdue = json['is_overdue'] ?? false;
    
    return SpecialProject(
      id: json['id']?.toString() ?? '',  // 确保 ID 始终是字符串类型
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: startDate,
      endDate: endDate,
      status: _parseStatus(json['status']),
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      budget: budget,
      spent: spent,
      tasks: taskList,
      phases: phasesList,
      icon: _parseIcon(json['icon']),
      iconBackgroundGradient: _parseGradient(json['iconBackgroundGradient']),
      progress: progress,
      daysRemaining: daysRemaining,
      isOverdue: isOverdue,
    );
  }

  /// 将项目实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate != null ? _formatDate(startDate!) : null,
      'endDate': endDate != null ? _formatDate(endDate!) : null,
      'status': _statusToString(status),
      'completedTasks': completedTasks,
      'totalTasks': totalTasks,
      'budget': budget,
      'spent': spent,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'icon': _iconToString(icon),
      'iconBackgroundGradient': _gradientToList(iconBackgroundGradient),
      'progress': progress,
    };
  }

  /// 格式化日期为 yyyy-MM-dd 格式
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 创建项目的副本，可选择性地更新某些属性
  SpecialProject copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? completedTasks,
    int? totalTasks,
    double? budget,
    double? spent,
    List<ProjectTask>? tasks,
    IconData? icon,
    List<Color>? iconBackgroundGradient,
    double? progress,
  }) {
    return SpecialProject(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      completedTasks: completedTasks ?? this.completedTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      tasks: tasks ?? this.tasks,
      icon: icon ?? this.icon,
      iconBackgroundGradient: iconBackgroundGradient ?? this.iconBackgroundGradient,
      progress: progress ?? this.progress,
    );
  }

  /// 解析状态字符串为枚举
  static ProjectStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return ProjectStatus.active;
      case 'completed':
        return ProjectStatus.completed;
      case 'planned':
      default:
        return ProjectStatus.planned;
    }
  }

  /// 将状态枚举转换为字符串
  static String _statusToString(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'active';
      case ProjectStatus.completed:
        return 'completed';
      case ProjectStatus.planned:
        return 'planned';
    }
  }
  
  /// 解析图标字符串为IconData
  static IconData _parseIcon(dynamic iconData) {
    // 这里应该根据实际情况解析图标数据
    // 暂时返回默认图标
    return Icons.folder;
  }
  
  /// 将图标转换为字符串
  static String _iconToString(IconData icon) {
    // 这里应该根据实际情况将图标转换为字符串
    // 暂时返回默认值
    return 'folder';
  }
  
  /// 解析渐变色列表
  static List<Color> _parseGradient(dynamic gradientData) {
    if (gradientData is List) {
      try {
        return gradientData
            .map((colorData) => Color(int.parse(colorData.toString())))
            .toList();
      } catch (e) {
        // 解析失败，返回默认渐变色
      }
    }
    // 默认渐变色
    return [
      const Color(0xFF4F46E5),
      const Color(0xFF818CF8),
    ];
  }
  
  /// 将渐变色列表转换为可序列化的格式
  static List<int> _gradientToList(List<Color> gradient) {
    return gradient.map((color) => color.value).toList();
  }

  /// 获取项目进度百分比
  double getProgressPercentage() {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// 获取项目状态的颜色
  Color getStatusColor() {
    switch (status) {
      case ProjectStatus.planned:
        return const Color(0xFF9CA3AF); // 灰色
      case ProjectStatus.active:
        return const Color(0xFF4F46E5); // 紫色
      case ProjectStatus.completed:
        return const Color(0xFF10B981); // 绿色
    }
  }

  /// 获取项目状态的文本
  String getStatusText() {
    switch (status) {
      case ProjectStatus.planned:
        return '未开始';
      case ProjectStatus.active:
        return '进行中';
      case ProjectStatus.completed:
        return '已完成';
    }
  }

  /// 获取特定阶段的任务
  List<ProjectTask> getTasksByCategory(String category) {
    return tasks.where((task) => task.category == category).toList();
  }
} 