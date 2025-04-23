import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Account {
  final String id;
  final String name;
  final double balance;
  final IconData icon;
  final Color color;
  
  const Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
    required this.color,
  });
  
  // 余额显示格式
  String get formattedBalance => '¥${balance.toStringAsFixed(2)}';
  
  // 列表显示名称
  String get displayName => '$name ($formattedBalance)';
}

class AccountTypes {
  // 预定义账户
  static const Account bankAccount = Account(
    id: 'bank',
    name: '工商银行',
    balance: 3245.75,
    icon: FontAwesomeIcons.university,
    color: Color(0xFF3B82F6),
  );
  
  static const Account alipay = Account(
    id: 'alipay',
    name: '支付宝',
    balance: 1580.00,
    icon: FontAwesomeIcons.alipay,
    color: Color(0xFF00AAEE),
  );
  
  static const Account wechat = Account(
    id: 'wechat',
    name: '微信钱包',
    balance: 420.00,
    icon: FontAwesomeIcons.weixin,
    color: Color(0xFF07C160),
  );
  
  static const Account cash = Account(
    id: 'cash',
    name: '现金',
    balance: 0.00,
    icon: FontAwesomeIcons.moneyBillWave,
    color: Color(0xFF10B981),
  );
  
  // 获取所有账户
  static List<Account> getAllAccounts() {
    return [
      bankAccount,
      alipay,
      wechat,
      cash,
    ];
  }
  
  // 根据ID获取账户
  static Account? getAccountById(String id) {
    try {
      return getAllAccounts().firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // 获取总余额
  static double getTotalBalance() {
    return getAllAccounts().fold(0, (sum, account) => sum + account.balance);
  }
}
