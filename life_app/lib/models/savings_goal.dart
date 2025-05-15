import 'package:flutter/material.dart';
import '../services/icon_service.dart';

class SavingsGoal {
  final String id;
  final String name;
  IconData icon; // 改为可变的
  Color color; // 改为可变的
  final double targetAmount;
  final double currentAmount;
  final double monthlyTarget;
  final DateTime targetDate;
  final String? note;
  final int iconId;
  final String colorCode;
  final DateTime? completedAt; // 完成时间，仅对已完成目标有效
  final bool isFamilySavings; // 是否为家庭储蓄目标
  bool _iconLoaded = false; // 跟踪图标是否已加载

  SavingsGoal({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyTarget,
    required this.targetDate,
    this.note,
    required this.iconId,
    required this.colorCode,
    this.completedAt,
    this.isFamilySavings = false, // 默认为个人储蓄目标
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount) : 0;
  
  // 从后端API加载真实图标
  Future<void> loadRealIcon({BuildContext? context}) async {
    if (_iconLoaded) return; // 如果已加载，直接返回
    
    try {
      final iconService = IconService();
      final iconModel = await iconService.getIconById(iconId, context: context);
      
      if (iconModel != null) {
        // 无条件使用图标服务返回的图标
        icon = iconModel.icon;
        
        // 无条件使用图标服务返回的颜色
        color = iconModel.color;
        
        print('成功加载图标: ID=$iconId, 名称=${iconModel.name}, 颜色=${iconModel.colorCode}');
        _iconLoaded = true;
      } else {
        print('图标加载失败: 未找到ID=$iconId的图标');
      }
    } catch (e) {
      print('加载图标失败 (ID: $iconId): $e');
    }
  }
  
  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    // 处理icon_id，确保是整数
    int iconId = json['icon_id'] is int ? json['icon_id'] : int.tryParse(json['icon_id']?.toString() ?? '0') ?? 0;
    
    // 处理颜色，确保格式正确
    String colorStr = json['color']?.toString() ?? '';
    if (colorStr.isEmpty) {
      // 使用默认颜色 #FF9800 (橙色)
      colorStr = '#FF9800';
    }
    if (!colorStr.startsWith('#')) {
      colorStr = '#$colorStr';
    }
    
    // 处理日期，确保格式正确
    DateTime targetDate;
    try {
      targetDate = DateTime.parse(json['target_date'].toString());
    } catch (e) {
      // 默认为一年后
      targetDate = DateTime.now().add(const Duration(days: 365));
    }
    
    // 处理完成时间
    DateTime? completedAt;
    if (json['completed_at'] != null && json['completed_at'].toString().isNotEmpty) {
      try {
        completedAt = DateTime.parse(json['completed_at'].toString());
      } catch (e) {
        print('解析完成时间失败: ${json['completed_at']}');
        // 错误时不设置完成时间
      }
    }
    
    // 处理数值，确保为double类型
    double targetAmount = 0;
    if (json['target_amount'] != null) {
      targetAmount = (json['target_amount'] is double) 
          ? json['target_amount'] 
          : double.tryParse(json['target_amount'].toString()) ?? 0;
    }
    
    double currentAmount = 0;
    if (json['current_amount'] != null) {
      currentAmount = (json['current_amount'] is double) 
          ? json['current_amount'] 
          : double.tryParse(json['current_amount'].toString()) ?? 0;
    }
    
    double monthlyTarget = 0;
    if (json['monthly_target'] != null) {
      monthlyTarget = (json['monthly_target'] is double) 
          ? json['monthly_target'] 
          : double.tryParse(json['monthly_target'].toString()) ?? 0;
    }
    
    // 处理isFamilySavings，确保为布尔值
    bool isFamilySavings = false;
    if (json['is_family_savings'] != null) {
      isFamilySavings = (json['is_family_savings'] is bool)
          ? json['is_family_savings']
          : (json['is_family_savings'].toString().toLowerCase() == 'true');
    }
    
    // 设置默认图标（临时），将在异步加载时替换
    Color color;
    try {
      color = Color(int.parse(colorStr.replaceAll('#', '0xFF'), radix: 16));
    } catch (e) {
      // 如果颜色解析失败，使用默认颜色
      color = Colors.orange;
    }
    
    // 默认图标
    IconData iconData = Icons.savings;
    
    return SavingsGoal(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '储蓄目标',
      icon: iconData,
      color: color,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      monthlyTarget: monthlyTarget,
      targetDate: targetDate,
      note: json['note']?.toString(),
      iconId: iconId,
      colorCode: colorStr,
      completedAt: completedAt,
      isFamilySavings: isFamilySavings,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_id': iconId,
      'color': colorCode,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'monthly_target': monthlyTarget,
      'target_date': targetDate.toIso8601String(),
      'note': note,
      'completed_at': completedAt?.toIso8601String(),
      'is_family_savings': isFamilySavings,
    };
  }
}
