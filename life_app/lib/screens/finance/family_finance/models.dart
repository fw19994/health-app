import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// 支出类别数据模型
class ExpenseCategoryData {
  final String name;
  final IconData? icon;  // 允许为空，因为可能获取失败
  final double amount;
  final double percentage;
  final Color? color;  // 允许为空，因为可能获取失败
  final int iconId;  // 添加iconId字段以便可以重新获取
  
  ExpenseCategoryData({
    required this.name,
    this.icon,
    required this.amount,
    required this.percentage,
    this.color,
    required this.iconId,
  });
  
  // 创建一个安全的工厂方法，确保即使数据不完整也能创建有效对象
  static ExpenseCategoryData safe({
    String? name,
    IconData? icon,
    double? amount,
    double? percentage,
    Color? color,
    int? iconId,
  }) {
    return ExpenseCategoryData(
      name: name ?? '未分类',
      icon: icon,
      amount: amount ?? 0.0,
      percentage: percentage ?? 0.0,
      color: color,
      iconId: iconId ?? 0,
    );
  }
  
  @override
  String toString() {
    return 'ExpenseCategoryData{name: $name, amount: $amount, percentage: $percentage, iconId: $iconId}';
  }
}

// 家庭支出数据模型
class FamilyExpense {
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String payerName;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  
  FamilyExpense({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.payerName,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

// 预算项目数据模型
class BudgetItem {
  final String category;
  final IconData icon;
  final double currentAmount;
  final double budgetAmount;
  final bool isOverBudget;
  
  BudgetItem({
    required this.category,
    required this.icon,
    required this.currentAmount,
    required this.budgetAmount,
    required this.isOverBudget,
  });
}

// 储蓄目标数据模型
class SavingsGoal {
  final String title;
  final IconData icon;
  final double currentAmount;
  final double targetAmount;
  final DateTime deadline;
  final Color color;
  
  SavingsGoal({
    required this.title,
    required this.icon,
    required this.currentAmount,
    required this.targetAmount,
    required this.deadline,
    required this.color,
  });
} 