import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final IconData icon;
  
  const ExpenseCategory({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}
