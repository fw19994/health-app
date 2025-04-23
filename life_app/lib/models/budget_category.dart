import 'package:flutter/material.dart';

class BudgetCategory {
  final String id;
  final String name;
  final String? description;
  final IconData icon;
  final double budget;
  final double spent;
  final Color color;
  final bool reminderEnabled;
  final double monthOverMonthChange;
  final int iconId;

  const BudgetCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.budget,
    required this.spent,
    required this.color,
    this.reminderEnabled = false,
    this.monthOverMonthChange = 0,
    required this.iconId,
  });

  // 从JSON创建BudgetCategory
  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    // 解析颜色值
    Color parseColor(String colorStr) {
      if (colorStr.startsWith('0x')) {
        return Color(int.parse(colorStr));
      } else if (colorStr.startsWith('#')) {
        return Color(int.parse('0xFF${colorStr.substring(1)}'));
      }
      return Colors.grey; // 默认颜色
    }

    // 解析图标
    IconData parseIcon(dynamic iconValue) {
      if (iconValue is int) {
        return IconData(iconValue, fontFamily: 'FontAwesomeIcons');
      }
      return Icons.category; // 默认图标
    }

    return BudgetCategory(
      id: json['id'].toString(),
      name: json['name'] ?? '未命名',
      description: json['description'],
      icon: parseIcon(json['icon_id']),
      budget: (json['budget'] ?? 0.0).toDouble(),
      spent: (json['spent'] ?? 0.0).toDouble(),
      color: parseColor(json['color'] ?? '0xFF9E9E9E'),
      reminderEnabled: (json['reminder_threshold'] ?? 0) > 0,
      monthOverMonthChange: (json['month_over_month'] ?? 0.0).toDouble(),
      iconId: json['icon_id'] ?? 0,
    );
  }

  double get progress => spent / budget;
}
