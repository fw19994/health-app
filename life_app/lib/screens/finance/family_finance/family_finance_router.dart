import 'package:flutter/material.dart';
import 'family_finance_screen.dart';

/// 家庭财务页面路由器
/// 用于处理没有参数的路由情况
class FamilyFinanceRouter extends StatelessWidget {
  const FamilyFinanceRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 从路由默认使用家庭ID=1
    return const FamilyFinanceScreen(familyId: 1);
  }
} 