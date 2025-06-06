import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// 交易类型
enum TransactionType {
  income,   // 收入
  expense,  // 支出
}

// 交易记录数据模型
class Transaction {
  // 交易ID
  final String id;
  
  // 交易标题
  final String title;
  
  // 交易描述
  final String? description;
  
  // 商户信息
  final String? merchant;
  
  // 交易日期
  final DateTime date;
  
  // 交易时间
  final TimeOfDay time;
  
  // 交易金额
  final double amount;
  
  // 交易类型 (收入/支出)
  final TransactionType type;
  
  // 交易分类ID
  final String category;
  
  // 分类图标
  final IconData categoryIcon;
  
  // 分类颜色
  final Color categoryColor;
  
  // 原始图标ID（用于异步加载）
  final int? iconId;
  
  // 成员ID
  final String memberId;
  
  // 成员名称
  final String memberName;
  
  // 成员角色
  final String memberRole;
  
  // 成员颜色
  final Color memberColor;
  
  // 成员头像URL
  final String memberAvatarUrl;
  
  const Transaction({
    required this.id,
    required this.title,
    this.description,
    this.merchant,
    required this.date,
    required this.time,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
    this.iconId,
    required this.memberId,
    required this.memberName,
    required this.memberRole,
    required this.memberColor,
    this.memberAvatarUrl = '',
  });
  
  // 获取收支前缀
  String get amountPrefix => type == TransactionType.income ? "+" : "-";
  
  // 获取格式化金额
  String get formattedAmount => "$amountPrefix¥${amount.toStringAsFixed(0)}";
  
  // 获取金额颜色
  Color get amountColor => type == TransactionType.income
      ? const Color(0xFF10B981)  // 绿色 (收入)
      : const Color(0xFFEF4444); // 红色 (支出)
}

// 按日期分组的交易记录
class TransactionDateGroup {
  // 日期
  final DateTime date;
  
  // 该日期下的交易记录
  final List<Transaction> transactions;
  
  // 该日期总收入
  final double totalIncome;
  
  // 该日期总支出
  final double totalExpense;
  
  const TransactionDateGroup({
    required this.date,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });
  
  // 计算日净收支
  double get netAmount => totalIncome - totalExpense;
  
  // 计算日收支余额
  double get balance => totalIncome - totalExpense;
  
  // 格式化日收支余额
  String get formattedBalance {
    final prefix = balance >= 0 ? "+" : "";
    return "$prefix¥${balance.toStringAsFixed(0)}";
  }
  
  // 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  // 是否为昨天
  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
}
