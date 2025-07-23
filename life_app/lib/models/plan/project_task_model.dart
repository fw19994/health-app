import 'package:flutter/material.dart';

/// 任务状态枚举
enum TaskStatus {
  notStarted,  // 未开始
  inProgress,  // 进行中
  completed,   // 已完成
}

/// 项目任务模型类
class ProjectTask {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isAllDay;
  final double cost;
  final TaskStatus status;
  final String category;
  final bool isCompletedToday; // 添加是否今日已完成标记

  ProjectTask({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    required this.cost,
    required this.status,
    required this.category,
    this.isCompletedToday = false, // 默认为false
  });

  /// 从JSON创建任务实例
  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    TimeOfDay? _parseTimeOfDay(String? timeString) {
      if (timeString == null) return null;
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      
      try {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        return null;
      }
    }
    
    // 处理字段名称差异，优先使用后端返回的字段名
    final startTimeStr = json['start_time'] ?? json['startTime'];
    final endTimeStr = json['end_time'] ?? json['endTime'];
    
    return ProjectTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      startTime: _parseTimeOfDay(startTimeStr),
      endTime: _parseTimeOfDay(endTimeStr),
      isAllDay: json['isAllDay'] ?? json['is_all_day'] ?? false,
      cost: (json['cost'] ?? 0).toDouble(),
      status: _parseStatus(json['status']),
      category: json['category'] ?? '',
      isCompletedToday: json['is_completed_today'] ?? false, // 解析新字段
    );
  }

  /// 将任务实例转换为JSON
  Map<String, dynamic> toJson() {
    String? _timeOfDayToString(TimeOfDay? time) {
      if (time == null) return null;
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'start_time': _timeOfDayToString(startTime),
      'end_time': _timeOfDayToString(endTime),
      'is_all_day': isAllDay,
      'cost': cost,
      'status': _statusToString(status),
      'category': category,
      'is_completed_today': isCompletedToday, // 转换新字段
    };
  }

  /// 创建任务的副本，可选择性地更新某些属性
  ProjectTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isAllDay,
    double? cost,
    TaskStatus? status,
    String? category,
    bool? isCompletedToday, // 添加新字段
  }) {
    return ProjectTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      category: category ?? this.category,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday, // 复制新字段
    );
  }

  /// 解析状态字符串为枚举
  static TaskStatus _parseStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'notStarted':
      default:
        return TaskStatus.notStarted;
    }
  }

  /// 将状态枚举转换为字符串
  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'inProgress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.notStarted:
        return 'notStarted';
    }
  }

  /// 获取任务状态的颜色
  Color getStatusColor() {
    switch (status) {
      case TaskStatus.notStarted:
        return const Color(0xFF9CA3AF); // 灰色
      case TaskStatus.inProgress:
        return const Color(0xFFF59E0B); // 黄色
      case TaskStatus.completed:
        return const Color(0xFF10B981); // 绿色
    }
  }

  /// 获取任务状态的文本
  String getStatusText() {
    switch (status) {
      case TaskStatus.notStarted:
        return '未开始';
      case TaskStatus.inProgress:
        return '进行中';
      case TaskStatus.completed:
        return '已完成';
    }
  }

  /// 获取任务类别的颜色
  Color getCategoryColor() {
    switch (category) {
      case 'design':
        return const Color(0xFF0369A1); // 蓝色
      case 'purchase':
        return const Color(0xFF92400E); // 棕色
      case 'construction':
        return const Color(0xFF6B21A8); // 紫色
      case 'inspection':
        return const Color(0xFF166534); // 绿色
      default:
        return const Color(0xFF4B5563); // 灰色
    }
  }

  /// 获取任务类别的背景颜色
  Color getCategoryBackgroundColor() {
    switch (category) {
      case 'design':
        return const Color(0xFFE0F2FE); // 淡蓝色
      case 'purchase':
        return const Color(0xFFFEF3C7); // 淡黄色
      case 'construction':
        return const Color(0xFFF3E8FF); // 淡紫色
      case 'inspection':
        return const Color(0xFFDCFCE7); // 淡绿色
      default:
        return const Color(0xFFF3F4F6); // 淡灰色
    }
  }

  /// 获取任务类别的文本
  String getCategoryText() {
    switch (category) {
      case 'design':
        return '设计';
      case 'purchase':
        return '采购';
      case 'construction':
        return '施工';
      case 'inspection':
        return '验收';
      default:
        return '其他';
    }
  }

  /// 获取格式化的时间范围字符串
  String get timeRangeString {
    if (isAllDay) return '全天';
    if (startTime == null) return '无时间';
    
    final start = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
    
    if (endTime == null) return start;
    
    final end = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
} 