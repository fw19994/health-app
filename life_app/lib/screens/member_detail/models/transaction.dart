import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String title;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  
  const Transaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
  
  // 格式化金额显示，收入前加+，支出前加-
  String get formattedAmount {
    return type == TransactionType.income
        ? "+¥${amount.toStringAsFixed(0)}"
        : "-¥${amount.toStringAsFixed(0)}";
  }
  
  // 获取金额颜色
  Color get amountColor {
    return type == TransactionType.income
        ? const Color(0xFF10B981) // 绿色（收入）
        : const Color(0xFFEF4444); // 红色（支出）
  }
}
