import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../utils/app_icons.dart';

final List<SavingsGoal> dummySavingsGoals = [
  SavingsGoal(
    id: '1',
    name: '旅行基金',
    icon: AppIcons.travel,
    color: Colors.blue,
    targetAmount: 15000,
    currentAmount: 8500,
    monthlyTarget: 1000,
    targetDate: DateTime(2025, 7),
    note: '计划去日本旅行',
    iconId: 33,
    colorCode: '#2196F3',
  ),
  SavingsGoal(
    id: '2',
    name: '教育基金',
    icon: AppIcons.education,
    color: Colors.green,
    targetAmount: 50000,
    currentAmount: 12000,
    monthlyTarget: 2000,
    targetDate: DateTime(2026, 9),
    note: '为进修课程做准备',
    iconId: 32,
    colorCode: '#4CAF50',
  ),
];
