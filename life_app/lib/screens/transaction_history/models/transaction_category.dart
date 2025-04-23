import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'transaction.dart';

// 交易分类模型
class TransactionCategory {
  // 分类ID
  final String id;
  
  // 分类名称
  final String name;
  
  // 分类图标
  final IconData icon;
  
  // 分类颜色
  final Color color;
  
  // 分类类型
  final TransactionType type;
  
  // 是否是系统默认分类
  final bool isDefault;
  
  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = true,
  });
  
  // 预定义的收入分类
  static List<TransactionCategory> defaultIncomeCategories = [
    const TransactionCategory(
    id: 'salary',
    name: '工资收入',
    icon: FontAwesomeIcons.briefcase,
      color: Color(0xFF10B981),
      type: TransactionType.income,
    ),
    const TransactionCategory(
    id: 'investment',
    name: '投资收益',
    icon: FontAwesomeIcons.coins,
      color: Color(0xFF6366F1),
      type: TransactionType.income,
    ),
    const TransactionCategory(
    id: 'bonus',
    name: '奖金',
    icon: FontAwesomeIcons.award,
      color: Color(0xFFF59E0B),
      type: TransactionType.income,
    ),
    const TransactionCategory(
      id: 'gift',
      name: '礼金',
    icon: FontAwesomeIcons.gift,
      color: Color(0xFFEC4899),
      type: TransactionType.income,
    ),
    const TransactionCategory(
      id: 'other_income',
      name: '其他收入',
      icon: FontAwesomeIcons.plus,
      color: Color(0xFF9CA3AF),
      type: TransactionType.income,
    ),
  ];
  
  // 预定义的支出分类
  static List<TransactionCategory> defaultExpenseCategories = [
    const TransactionCategory(
      id: 'food',
      name: '餐饮',
      icon: FontAwesomeIcons.utensils,
      color: Color(0xFFF59E0B),
      type: TransactionType.expense,
    ),
    const TransactionCategory(
      id: 'shopping',
      name: '购物',
      icon: FontAwesomeIcons.shoppingBag,
      color: Color(0xFF8B5CF6),
      type: TransactionType.expense,
    ),
    const TransactionCategory(
      id: 'housing',
      name: '住房',
      icon: FontAwesomeIcons.house,
      color: Color(0xFFEF4444),
      type: TransactionType.expense,
    ),
    const TransactionCategory(
      id: 'transportation',
      name: '交通',
      icon: FontAwesomeIcons.car,
      color: Color(0xFF3B82F6),
      type: TransactionType.expense,
    ),
    const TransactionCategory(
      id: 'entertainment',
      name: '娱乐',
      icon: FontAwesomeIcons.gamepad,
      color: Color(0xFFEC4899),
      type: TransactionType.expense,
    ),
    const TransactionCategory(
      id: 'medical',
      name: '医疗',
      icon: FontAwesomeIcons.hospitalUser,
      color: Color(0xFF06B6D4),
      type: TransactionType.expense,
    ),
    const TransactionCategory(
      id: 'education',
      name: '教育',
      icon: FontAwesomeIcons.graduationCap,
      color: Color(0xFFF97316),
      type: TransactionType.expense,
    ),
    const TransactionCategory(
      id: 'other_expense',
      name: '其他支出',
      icon: FontAwesomeIcons.ellipsis,
      color: Color(0xFF9CA3AF),
      type: TransactionType.expense,
    ),
    ];
  
  // 根据ID获取分类
  static TransactionCategory? getById(String id) {
    // 在收入分类中查找
    for (var category in defaultIncomeCategories) {
      if (category.id == id) {
        return category;
      }
    }
    
    // 在支出分类中查找
    for (var category in defaultExpenseCategories) {
      if (category.id == id) {
        return category;
      }
    }
    
    return null;
  }
}
