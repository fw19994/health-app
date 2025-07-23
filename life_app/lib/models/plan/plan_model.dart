import 'package:flutter/material.dart';

/// 计划模型类，表示单个计划项
class Plan {
  final String id;
  final String title;
  final String description;
  final DateTime? date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String category; // work, personal, health, family
  final String reminderType; // none, time
  final int? reminderMinutes;
  final String recurrenceType; // once, daily, weekly, monthly, weekdays, weekends
  final bool isPinned;
  final bool isCompleted;
  final bool isCompletedToday; // 今天是否完成（用于重复计划）
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;
  final List<int>? recurrenceDays; // 用于自定义重复（例如：[1,3,5]表示周一、周三、周五）
  final bool isEnabled;
  
  Plan({
    required this.id,
    required this.title,
    this.description = '',
    this.date,
    this.startTime,
    this.endTime,
    required this.category,
    required this.reminderType,
    this.reminderMinutes,
    required this.recurrenceType,
    required this.isPinned,
    required this.isCompleted,
    this.isCompletedToday = false,
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
    this.recurrenceDays,
    this.isEnabled = true,
  });
  
  /// 从JSON对象创建Plan实例
  factory Plan.fromJson(Map<String, dynamic> json) {
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
    
    // 解析日期字符串
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      
      // 如果是字符串格式
      if (dateValue is String) {
        try {
          // 尝试解析完整的ISO 8601格式
          return DateTime.parse(dateValue);
        } catch (e) {
          try {
            // 尝试解析YYYY-MM-DD格式
            final parts = dateValue.split('-');
            if (parts.length == 3) {
              return DateTime(
                int.parse(parts[0]), // 年
                int.parse(parts[1]), // 月
                int.parse(parts[2]), // 日
              );
            }
          } catch (e) {
            print('解析日期失败: $e');
          }
        }
      }
      return null;
    }
    
    // 确保ID是字符串类型
    String ensureStringId(dynamic id) {
      if (id == null) return '';
      if (id is String) return id;
      return id.toString(); // 将其他类型（如int）转换为字符串
    }
    
    // 判断计划是否完成（优先使用is_completed_today字段）
    bool determineCompletionStatus(Map<String, dynamic> json) {
      // 只使用is_completed_today字段判断完成状态
      return json['is_completed_today'] == true;
    }

    return Plan(
      id: ensureStringId(json['id']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: parseDate(json['date']),
      startTime: _parseTimeOfDay(json['startTime'] ?? json['start_time']),
      endTime: _parseTimeOfDay(json['endTime'] ?? json['end_time']),
      category: json['category'] ?? 'work',
      reminderType: json['reminderType'] ?? json['reminder_type'] ?? 'none',
      reminderMinutes: json['reminderMinutes'] ?? json['reminder_minutes'],
      recurrenceType: json['recurrenceType'] ?? json['recurrence_type'] ?? 'once',
      isPinned: json['isPinned'] ?? json['is_pinned'] ?? false,
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
      isCompletedToday: determineCompletionStatus(json),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      recurrenceDays: json['recurrenceDays'] != null ? List<int>.from(json['recurrenceDays']) : null,
      isEnabled: json['isEnabled'] ?? json['is_enabled'] ?? true,
    );
  }
  
  /// 将Plan实例转换为JSON对象
  Map<String, dynamic> toJson() {
    String? _timeOfDayToString(TimeOfDay? time) {
      if (time == null) return null;
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    
    // 将日期格式化为 YYYY-MM-DD 格式
    String? _formatDate(DateTime? date) {
      if (date == null) return null;
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    return {
      'id': id,
      'title': title,
      'description': description,
      'date': _formatDate(date),
      'startTime': _timeOfDayToString(startTime),
      'endTime': _timeOfDayToString(endTime),
      'category': category,
      'reminderType': reminderType,
      'reminderMinutes': reminderMinutes,
      'recurrenceType': recurrenceType,
      'isPinned': isPinned,
      'isCompleted': isCompleted,
      'isCompletedToday': isCompletedToday,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'recurrenceDays': recurrenceDays,
      'isEnabled': isEnabled,
    };
  }
  
  /// 复制并创建新的Plan实例，允许更新特定字段
  Plan copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? category,
    String? reminderType,
    int? reminderMinutes,
    String? recurrenceType,
    bool? isPinned,
    bool? isCompleted,
    bool? isCompletedToday,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    List<int>? recurrenceDays,
    bool? isEnabled,
  }) {
    return Plan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      reminderType: reminderType ?? this.reminderType,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      isPinned: isPinned ?? this.isPinned,
      isCompleted: isCompleted ?? this.isCompleted,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recurrenceDays: recurrenceDays ?? this.recurrenceDays,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
  
  /// 获取格式化的时间范围字符串
  String get timeRangeString {
    if (startTime == null) return '全天';
    
    final start = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
    
    if (endTime == null) return start;
    
    final end = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
  
  /// 获取提醒描述文本
  String get reminderText {
    if (reminderType == 'none' || reminderMinutes == null || reminderMinutes == 0) return '不提醒';
    
    if (reminderMinutes! < 60) {
      return '提前${reminderMinutes}分钟';
    } else if (reminderMinutes! < 1440) {
      return '提前${reminderMinutes! ~/ 60}小时';
    } else {
      return '提前${reminderMinutes! ~/ 1440}天';
    }
  }
  
  /// 检查计划是否在指定日期
  bool isOnDate(DateTime date) {
    if (this.date == null) return false;
    
    return this.date!.year == date.year && 
           this.date!.month == date.month && 
           this.date!.day == date.day;
  }
  
  /// 检查计划是否可以接收提醒
  bool get canReceiveReminder {
    return reminderType != 'none' && 
           reminderMinutes != null && 
           reminderMinutes! > 0 &&
           date != null &&
           !isCompleted &&
           isEnabled;
  }
  
  /// 将TimeOfDay转换为DateTime
  DateTime? toDateTime() {
    if (date == null) return null;
    if (startTime == null) return date;
    
    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      startTime!.hour,
      startTime!.minute,
    );
  }
  
  /// 检查计划是否为重复计划
  bool get isRecurring {
    return recurrenceType != 'once';
  }
  
  /// 获取下一次重复的日期
  DateTime? getNextOccurrence(DateTime after) {
    if (date == null || recurrenceType == 'once') return null;
    
    switch (recurrenceType) {
      case 'daily':
        return _getNextDailyOccurrence(after);
      case 'weekly':
        return _getNextWeeklyOccurrence(after);
      case 'monthly':
        return _getNextMonthlyOccurrence(after);
      case 'custom':
        return _getNextCustomOccurrence(after);
      default:
        return null;
    }
  }
  
  // 获取下一个每日重复的日期
  DateTime? _getNextDailyOccurrence(DateTime after) {
    if (date == null) return null;
    
    final DateTime baseDate = DateTime(
      after.year,
      after.month,
      after.day,
    );
    
    // 如果基准日期是今天，但时间已过，返回明天
    if (baseDate.isAtSameMomentAs(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day)) && 
        startTime != null &&
        TimeOfDay.now().hour > startTime!.hour || 
        (TimeOfDay.now().hour == startTime!.hour && TimeOfDay.now().minute > startTime!.minute)) {
      return baseDate.add(const Duration(days: 1));
    }
    
    return baseDate;
  }
  
  // 获取下一个每周重复的日期
  DateTime? _getNextWeeklyOccurrence(DateTime after) {
    if (date == null) return null;
    
    final int targetWeekday = date!.weekday;
    final int daysUntilNextOccurrence = (targetWeekday - after.weekday + 7) % 7;
    
    // 如果是同一天但时间已过，则等待下一周
    if (daysUntilNextOccurrence == 0 && 
        startTime != null && 
        TimeOfDay.now().hour > startTime!.hour || 
        (TimeOfDay.now().hour == startTime!.hour && TimeOfDay.now().minute > startTime!.minute)) {
      return after.add(Duration(days: 7));
    }
    
    return after.add(Duration(days: daysUntilNextOccurrence));
  }
  
  // 获取下一个每月重复的日期
  DateTime? _getNextMonthlyOccurrence(DateTime after) {
    if (date == null) return null;
    
    final int targetDay = date!.day;
    
    // 如果当月的目标日期还没到
    if (targetDay > after.day) {
      return DateTime(after.year, after.month, targetDay);
    }
    
    // 如果是当天但时间已过，或者当月的目标日期已过，计算下个月的日期
    int nextMonth = after.month + 1;
    int nextYear = after.year;
    
    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }
    
    // 处理月份天数不同的情况
    int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    int actualDay = targetDay > daysInNextMonth ? daysInNextMonth : targetDay;
    
    return DateTime(nextYear, nextMonth, actualDay);
  }
  
  // 获取下一个自定义重复的日期
  DateTime? _getNextCustomOccurrence(DateTime after) {
    if (date == null || recurrenceDays == null || recurrenceDays!.isEmpty) {
      return null;
    }
    
    // 获取当前星期几（1-7，周一到周日）
    final int currentWeekday = after.weekday;
    
    // 找出下一个要重复的星期几
    int? nextWeekday;
    int minDaysToAdd = 7; // 默认等待一周
    
    for (int day in recurrenceDays!) {
      int daysToAdd = (day - currentWeekday + 7) % 7;
      if (daysToAdd == 0) {
        // 如果是今天，检查时间是否已过
        if (startTime == null || 
            TimeOfDay.now().hour < startTime!.hour || 
            (TimeOfDay.now().hour == startTime!.hour && TimeOfDay.now().minute < startTime!.minute)) {
          nextWeekday = day;
          minDaysToAdd = 0;
          break;
        } else {
          daysToAdd = 7; // 如果今天的时间已过，等待下周的同一天
        }
      }
      
      if (daysToAdd < minDaysToAdd && daysToAdd > 0) {
        minDaysToAdd = daysToAdd;
        nextWeekday = day;
      }
    }
    
    if (nextWeekday != null) {
      return after.add(Duration(days: minDaysToAdd));
    }
    
    return null;
  }

  // 将计划标记为已完成
  Plan markAsCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  // 将计划标记为未完成
  Plan markAsIncomplete() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }
} 