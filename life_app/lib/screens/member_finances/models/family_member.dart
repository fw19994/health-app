import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FamilyMember {
  final String name;
  final String role;
  final double income;
  final double expenses;
  final double budget;
  final double savingsRate;
  final double budgetUsage;
  final double incomeChange;
  final double expensesChange;
  final Color color;
  final IconData icon;
  final Color avatarBgColor;
  final double incomeContribution;
  final double expenseContribution;
  final String mainConsumption;

  const FamilyMember({
    required this.name,
    required this.role,
    required this.income,
    required this.expenses,
    required this.budget,
    required this.savingsRate,
    required this.budgetUsage,
    required this.incomeChange,
    required this.expensesChange,
    required this.color,
    required this.icon,
    required this.avatarBgColor,
    required this.incomeContribution,
    required this.expenseContribution,
    required this.mainConsumption,
  });
}
