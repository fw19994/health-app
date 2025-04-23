import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BudgetItem {
  final String name;
  final double amount;
  final double used;
  final Color color;
  final IconData icon;
  
  const BudgetItem({
    required this.name,
    required this.amount,
    required this.used,
    required this.color,
    required this.icon,
  });
  
  // 预算使用百分比
  double get usagePercentage => (used / amount * 100).clamp(0, 100);
}
