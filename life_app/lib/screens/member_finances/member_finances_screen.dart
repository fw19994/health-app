import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'widgets/header.dart';
import 'widgets/family_overview.dart';
import 'widgets/income_contribution.dart';
import 'widgets/expense_distribution.dart';
import 'widgets/member_card.dart';
import 'models/family_member.dart';

class MemberFinancesScreen extends StatefulWidget {
  const MemberFinancesScreen({super.key});

  @override
  State<MemberFinancesScreen> createState() => _MemberFinancesScreenState();
}

class _MemberFinancesScreenState extends State<MemberFinancesScreen> {
  // 当前选中的成员索引，0表示"全家"
  int _selectedMemberIndex = 0;
  
  // 是否处于比较模式
  bool _isCompareMode = false;
  
  // 家庭成员数据
  final List<FamilyMember> _familyMembers = [
    FamilyMember(
      name: '全家',
      role: '家庭主账户',
      income: 23600,
      expenses: 15240,
      budget: 21400,
      savingsRate: 35.4,
      budgetUsage: 71.3,
      incomeChange: 5.2,
      expensesChange: 7.8,
      color: const Color(0xFF7C3AED),
      icon: FontAwesomeIcons.users,
      avatarBgColor: const Color(0xFFF3F4F6),
      incomeContribution: 100,
      expenseContribution: 100,
      mainConsumption: '住房 / 日常',
    ),
    FamilyMember(
      name: '李明',
      role: '爸爸',
      income: 12980,
      expenses: 4572, 
      budget: 8000,
      savingsRate: 64.8,
      budgetUsage: 57.2,
      incomeChange: 3.2,
      expensesChange: 4.6,
      color: const Color(0xFF4F46E5),
      icon: FontAwesomeIcons.user,
      avatarBgColor: const Color(0xFFEEF2FF),
      incomeContribution: 55,
      expenseContribution: 30,
      mainConsumption: '住房 / 交通',
    ),
    FamilyMember(
      name: '王芳',
      role: '妈妈',
      income: 9440,
      expenses: 5334,
      budget: 9000,
      savingsRate: 43.5,
      budgetUsage: 59.3,
      incomeChange: 7.5,
      expensesChange: 9.8,
      color: const Color(0xFF9333EA),
      icon: FontAwesomeIcons.user,
      avatarBgColor: const Color(0xFFF3E8FF),
      incomeContribution: 40,
      expenseContribution: 35,
      mainConsumption: '餐饮 / 购物',
    ),
    FamilyMember(
      name: '李小美',
      role: '女儿',
      income: 910,
      expenses: 3810,
      budget: 3500,
      savingsRate: -318.7,
      budgetUsage: 108.9,
      incomeChange: 15.0,
      expensesChange: 12.3,
      color: const Color(0xFFEC4899),
      icon: FontAwesomeIcons.user,
      avatarBgColor: const Color(0xFFFCE7F3),
      incomeContribution: 4,
      expenseContribution: 25,
      mainConsumption: '教育 / 购物',
    ),
    FamilyMember(
      name: '李小强',
      role: '儿子',
      income: 270,
      expenses: 1524,
      budget: 1500,
      savingsRate: -464.4,
      budgetUsage: 101.6,
      incomeChange: 25.0,
      expensesChange: -5.2,
      color: const Color(0xFF3B82F6),
      icon: FontAwesomeIcons.user,
      avatarBgColor: const Color(0xFFDBEAFE),
      incomeContribution: 1,
      expenseContribution: 10,
      mainConsumption: '娱乐 / 食品',
    ),
  ];

  void _onSelectMember(int index) {
    setState(() {
      _selectedMemberIndex = index;
    });
  }

  void _toggleCompareMode() {
    setState(() {
      _isCompareMode = !_isCompareMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MemberFinancesHeader(
            membersCount: _familyMembers.length,
            selectedIndex: _selectedMemberIndex,
            isCompareMode: _isCompareMode,
            onSelectMember: _onSelectMember,
            onToggleCompareMode: _toggleCompareMode,
            memberNames: _familyMembers.map((member) => member.name).toList(),
            memberRoles: _familyMembers.map((member) => member.role).toList(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FamilyOverview(member: _familyMembers[_selectedMemberIndex]),
                    const SizedBox(height: 16),
                    IncomeContribution(members: _familyMembers),
                    const SizedBox(height: 16),
                    ExpenseDistribution(members: _familyMembers),
                    const SizedBox(height: 16),
                    if (_isCompareMode || _selectedMemberIndex == 0)
                      // 显示除"全家"外的所有成员卡片
                      ...List.generate(
                        _familyMembers.length,
                        (index) => index == 0 
                            ? const SizedBox.shrink() 
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: MemberCard(member: _familyMembers[index]),
                              ),
                      )
                    else
                      // 只显示当前选中成员的卡片
                      MemberCard(member: _familyMembers[_selectedMemberIndex]),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
