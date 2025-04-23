import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'transaction_type.dart';

class TransactionCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final TransactionType type;
  
  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.type,
  });
}

class TransactionCategories {
  // 支出类别
  static const TransactionCategory food = TransactionCategory(
    id: 'food',
    name: '餐饮',
    icon: FontAwesomeIcons.utensils,
    color: Color(0xFFEF4444),
    backgroundColor: Color(0xFFFEE2E2),
    type: TransactionType.expense,
  );
  
  static const TransactionCategory shopping = TransactionCategory(
    id: 'shopping',
    name: '购物',
    icon: FontAwesomeIcons.shoppingBag,
    color: Color(0xFF3B82F6),
    backgroundColor: Color(0xFFDBEAFE),
    type: TransactionType.expense,
  );
  
  static const TransactionCategory housing = TransactionCategory(
    id: 'housing',
    name: '住房',
    icon: FontAwesomeIcons.home,
    color: Color(0xFFF97316),
    backgroundColor: Color(0xFFFED7AA),
    type: TransactionType.expense,
  );
  
  static const TransactionCategory transportation = TransactionCategory(
    id: 'transportation',
    name: '交通',
    icon: FontAwesomeIcons.car,
    color: Color(0xFF8B5CF6),
    backgroundColor: Color(0xFFEDE9FE),
    type: TransactionType.expense,
  );
  
  static const TransactionCategory entertainment = TransactionCategory(
    id: 'entertainment',
    name: '娱乐',
    icon: FontAwesomeIcons.film,
    color: Color(0xFF10B981),
    backgroundColor: Color(0xFFD1FAE5),
    type: TransactionType.expense,
  );
  
  static const TransactionCategory medical = TransactionCategory(
    id: 'medical',
    name: '医疗',
    icon: FontAwesomeIcons.heartbeat,
    color: Color(0xFFEC4899),
    backgroundColor: Color(0xFFFCE7F3),
    type: TransactionType.expense,
  );
  
  static const TransactionCategory education = TransactionCategory(
    id: 'education',
    name: '教育',
    icon: FontAwesomeIcons.graduationCap,
    color: Color(0xFF6366F1),
    backgroundColor: Color(0xFFE0E7FF),
    type: TransactionType.expense,
  );
  
  static const TransactionCategory utilities = TransactionCategory(
    id: 'utilities',
    name: '水电气',
    icon: FontAwesomeIcons.bolt,
    color: Color(0xFFFCD34D),
    backgroundColor: Color(0xFFFEF3C7),
    type: TransactionType.expense,
  );
  
  static const TransactionCategory clothes = TransactionCategory(
    id: 'clothes',
    name: '服饰',
    icon: FontAwesomeIcons.tshirt,
    color: Color(0xFFDB2777),
    backgroundColor: Color(0xFFFBCFE8),
    type: TransactionType.expense,
  );
  
  static const TransactionCategory communication = TransactionCategory(
    id: 'communication',
    name: '通讯',
    icon: FontAwesomeIcons.mobile,
    color: Color(0xFF059669),
    backgroundColor: Color(0xFFD1FAE5),
    type: TransactionType.expense,
  );
  
  // 收入类别
  static const TransactionCategory salary = TransactionCategory(
    id: 'salary',
    name: '工资',
    icon: FontAwesomeIcons.briefcase,
    color: Color(0xFF10B981),
    backgroundColor: Color(0xFFD1FAE5),
    type: TransactionType.income,
  );
  
  static const TransactionCategory bonus = TransactionCategory(
    id: 'bonus',
    name: '奖金',
    icon: FontAwesomeIcons.award,
    color: Color(0xFF3B82F6),
    backgroundColor: Color(0xFFDBEAFE),
    type: TransactionType.income,
  );
  
  static const TransactionCategory investment = TransactionCategory(
    id: 'investment',
    name: '投资收益',
    icon: FontAwesomeIcons.chartLine,
    color: Color(0xFF6366F1),
    backgroundColor: Color(0xFFE0E7FF),
    type: TransactionType.income,
  );
  
  static const TransactionCategory gift = TransactionCategory(
    id: 'gift',
    name: '礼金',
    icon: FontAwesomeIcons.gift,
    color: Color(0xFFDB2777),
    backgroundColor: Color(0xFFFBCFE8),
    type: TransactionType.income,
  );
  
  static const TransactionCategory refund = TransactionCategory(
    id: 'refund',
    name: '退款',
    icon: FontAwesomeIcons.undo,
    color: Color(0xFFF97316),
    backgroundColor: Color(0xFFFED7AA),
    type: TransactionType.income,
  );
  
  // 转账类别
  static const TransactionCategory transfer = TransactionCategory(
    id: 'transfer',
    name: '转账',
    icon: FontAwesomeIcons.exchangeAlt,
    color: Color(0xFF6B7280),
    backgroundColor: Color(0xFFF3F4F6),
    type: TransactionType.transfer,
  );
  
  // 保存自定义类别的集合
  static final List<TransactionCategory> _customCategories = [];
  
  // 添加自定义类别
  static void addCustomCategory(TransactionCategory category) {
    // 检查是否已存在相同ID的类别
    final existingIndex = _customCategories.indexWhere((c) => c.id == category.id);
    if (existingIndex >= 0) {
      // 如果存在，则替换
      _customCategories[existingIndex] = category;
    } else {
      // 否则添加
      _customCategories.add(category);
    }
  }
  
  // 获取所有类别（包括内置和自定义）
  static List<TransactionCategory> getAllCategories() {
    return [
      ...getExpenseCategories(),
      ...getIncomeCategories(),
      ...getTransferCategories(),
      ..._customCategories,
    ];
  }
  
  // 获取所有支出类别
  static List<TransactionCategory> getExpenseCategories() {
    return [
      food,
      shopping, 
      housing,
      transportation,
      entertainment,
      medical,
      education,
      utilities,
      clothes,
      communication,
    ];
  }
  
  // 获取所有收入类别
  static List<TransactionCategory> getIncomeCategories() {
    return [
      salary,
      bonus,
      investment,
      gift,
      refund,
    ];
  }
  
  // 获取所有转账类别
  static List<TransactionCategory> getTransferCategories() {
    return [
      transfer,
    ];
  }
  
  // 重写获取类别方法，加入自定义类别
  static List<TransactionCategory> getCategoriesByType(TransactionType type) {
    List<TransactionCategory> baseCategories;
    switch (type) {
      case TransactionType.expense:
        baseCategories = getExpenseCategories();
        break;
      case TransactionType.income:
        baseCategories = getIncomeCategories();
        break;
      case TransactionType.transfer:
        baseCategories = getTransferCategories();
        break;
    }
    
    // 添加对应类型的自定义类别
    final customCategoriesOfType = _customCategories.where((c) => c.type == type).toList();
    return [...baseCategories, ...customCategoriesOfType];
  }
  
  // 根据ID获取类别
  static TransactionCategory? getCategoryById(String id) {
    final allCategories = [
      ...getExpenseCategories(),
      ...getIncomeCategories(),
      ...getTransferCategories(),
    ];
    
    try {
      return allCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
