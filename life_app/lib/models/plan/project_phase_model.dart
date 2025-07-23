import 'package:flutter/material.dart';
import 'project_task_model.dart';

/// 专项计划阶段模型
class ProjectPhase {
  final String id;
  final String specialProjectId;
  final String name;
  final String description;
  final int orderIndex;
  final int totalTasks;
  final int completedTasks;
  final double progress;
  final List<ProjectTask> tasks;
  final DateTime createdAt;

  ProjectPhase({
    required this.id,
    required this.specialProjectId,
    required this.name,
    required this.description,
    required this.orderIndex,
    this.totalTasks = 0,
    this.completedTasks = 0,
    double? progress,
    this.tasks = const [],
    DateTime? createdAt,
  }) : 
    this.progress = progress ?? (totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0),
    this.createdAt = createdAt ?? DateTime.now();

  /// 从JSON创建阶段实例
  factory ProjectPhase.fromJson(Map<String, dynamic> json) {
    // 解析任务列表
    List<ProjectTask> taskList = [];
    if (json['plans'] != null) {
      taskList = (json['plans'] as List)
          .map((taskJson) => ProjectTask.fromJson(taskJson))
          .toList();
    }
    
    return ProjectPhase(
      id: json['id']?.toString() ?? '',  // 确保 ID 始终是字符串类型
      specialProjectId: json['special_project_id']?.toString() ?? '',  // 确保 specialProjectId 始终是字符串类型
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      orderIndex: json['order_index'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      progress: (json['progress'] ?? 0.0).toDouble(),
      tasks: taskList,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  /// 将阶段转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'special_project_id': specialProjectId,
      'name': name,
      'description': description,
      'order_index': orderIndex,
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'progress': progress,
    };
  }

  /// 创建阶段的副本，可选择性地更新某些属性
  ProjectPhase copyWith({
    String? id,
    String? specialProjectId,
    String? name,
    String? description,
    int? orderIndex,
    int? totalTasks,
    int? completedTasks,
    double? progress,
    List<ProjectTask>? tasks,
    DateTime? createdAt,
  }) {
    return ProjectPhase(
      id: id ?? this.id,
      specialProjectId: specialProjectId ?? this.specialProjectId,
      name: name ?? this.name,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      progress: progress ?? this.progress,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// 获取阶段进度百分比
  double getProgressPercentage() {
    return progress / 100;
  }

  /// 判断阶段是否已完成
  bool isCompleted() {
    return totalTasks > 0 && completedTasks >= totalTasks;
  }
} 