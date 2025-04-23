import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../member_finances/models/family_member.dart';
import '../transaction_history/transaction_history_screen.dart';
import 'models/income_source.dart';
import 'models/expense_category.dart';
import 'models/transaction.dart';
import 'models/budget_item.dart';
import 'widgets/member_detail_header.dart';
import 'widgets/time_period_selector.dart';
import 'widgets/income_expense_comparison.dart';
import 'widgets/income_sources.dart';
import 'widgets/expense_categories.dart';
import 'widgets/monthly_trends.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/financial_health.dart';
import 'widgets/personal_budget.dart';
import 'widgets/financial_advice.dart';

class MemberDetailScreen extends StatefulWidget {
  final FamilyMember member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  int _selectedTimeIndex = 2; // 默认选择"本月"
  
  // 获取收入来源数据
  List<IncomeSource> get _incomeSources => [
    const IncomeSource(
      name: "工资收入",
      amount: 11500,
      percentage: 88.6,
      color: Color(0xFF4F46E5),
    ),
    const IncomeSource(
      name: "奖金",
      amount: 980,
      percentage: 7.5,
      color: Color(0xFF818CF8),
    ),
    const IncomeSource(
      name: "投资收益",
      amount: 500,
      percentage: 3.9,
      color: Color(0xFFA5B4FC),
    ),
  ];
  
  // 获取支出分类数据
  List<ExpenseCategory> get _expenseCategories => [
    const ExpenseCategory(
      name: "住房",
      amount: 2100,
      percentage: 45.9,
      color: Color(0xFFEF4444),
      icon: FontAwesomeIcons.house,
    ),
    const ExpenseCategory(
      name: "交通",
      amount: 885,
      percentage: 19.4,
      color: Color(0xFF3B82F6),
      icon: FontAwesomeIcons.car,
    ),
    const ExpenseCategory(
      name: "餐饮",
      amount: 640,
      percentage: 14.0,
      color: Color(0xFFF59E0B),
      icon: FontAwesomeIcons.utensils,
    ),
    const ExpenseCategory(
      name: "休闲娱乐",
      amount: 480,
      percentage: 10.5,
      color: Color(0xFF10B981),
      icon: FontAwesomeIcons.film,
    ),
    const ExpenseCategory(
      name: "其他",
      amount: 467,
      percentage: 10.2,
      color: Color(0xFF8B5CF6),
      icon: FontAwesomeIcons.ellipsis,
    ),
  ];
  
  // 获取月度趋势数据
  List<MonthData> get _monthlyData => [
    const MonthData(label: "10月", expense: 4500),
    const MonthData(label: "11月", expense: 5500),
    const MonthData(label: "12月", expense: 6980),
    const MonthData(label: "1月", expense: 4000),
    const MonthData(label: "2月", expense: 3500),
    const MonthData(label: "3月", expense: 3000),
    const MonthData(label: "4月", expense: 3500),
  ];
  
  // 获取近期交易数据
  List<Transaction> get _recentTransactions => [
    Transaction(
      title: "房贷还款",
      date: DateTime(2025, 4, 1),
      amount: 1850,
      type: TransactionType.expense,
      icon: FontAwesomeIcons.house,
      iconBgColor: const Color(0xFFFEE2E2),
      iconColor: const Color(0xFFEF4444),
    ),
    Transaction(
      title: "加油站",
      date: DateTime(2025, 3, 30),
      amount: 350,
      type: TransactionType.expense,
      icon: FontAwesomeIcons.car,
      iconBgColor: const Color(0xFFDBEAFE),
      iconColor: const Color(0xFF3B82F6),
    ),
    Transaction(
      title: "家庭聚餐",
      date: DateTime(2025, 3, 28),
      amount: 420,
      type: TransactionType.expense,
      icon: FontAwesomeIcons.utensils,
      iconBgColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFF59E0B),
    ),
    Transaction(
      title: "工资收入",
      date: DateTime(2025, 3, 25),
      amount: 11500,
      type: TransactionType.income,
      icon: FontAwesomeIcons.briefcase,
      iconBgColor: const Color(0xFFD1FAE5),
      iconColor: const Color(0xFF10B981),
    ),
  ];
  
  // 获取财务健康指标数据
  List<HealthMetric> get _healthMetrics => [
    const HealthMetric(name: "收支比例", score: 28, maxScore: 30),
    const HealthMetric(name: "消费规律性", score: 25, maxScore: 30),
    const HealthMetric(name: "债务管理", score: 18, maxScore: 20),
    const HealthMetric(name: "储蓄投资", score: 14, maxScore: 20),
  ];
  
  // 获取预算项数据
  List<BudgetItem> get _budgetItems => [
    BudgetItem(
      name: "住房类",
      amount: 2500,
      used: 2100,
      color: const Color(0xFFEF4444),
      icon: FontAwesomeIcons.house,
    ),
    BudgetItem(
      name: "交通类",
      amount: 1200,
      used: 885,
      color: const Color(0xFF3B82F6),
      icon: FontAwesomeIcons.car,
    ),
    BudgetItem(
      name: "餐饮类",
      amount: 800,
      used: 640,
      color: const Color(0xFFF59E0B),
      icon: FontAwesomeIcons.utensils,
    ),
    BudgetItem(
      name: "休闲娱乐",
      amount: 600,
      used: 480,
      color: const Color(0xFF10B981),
      icon: FontAwesomeIcons.film,
    ),
    BudgetItem(
      name: "日常用品",
      amount: 600,
      used: 387,
      color: const Color(0xFF8B5CF6),
      icon: FontAwesomeIcons.basketShopping,
    ),
    BudgetItem(
      name: "其他",
      amount: 800,
      used: 80,
      color: const Color(0xFF6B7280),
      icon: FontAwesomeIcons.ellipsis,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 头部
            MemberDetailHeader(member: widget.member),
            
            // 内容部分
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 时间段选择器
                  SizedBox(
                    height: 40,
                    child: TimePeriodSelector(
                      selectedIndex: _selectedTimeIndex,
                      onPeriodSelected: (index) {
                        setState(() {
                          _selectedTimeIndex = index;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 收入与支出对比
                  IncomeExpenseComparison(member: widget.member),
                  const SizedBox(height: 16),
                  
                  // 收入来源
                  IncomeSources(
                    sources: _incomeSources,
                    onViewDetails: () {},
                  ),
                  const SizedBox(height: 16),
                  
                  // 支出分类
                  ExpenseCategories(
                    categories: _expenseCategories,
                    onViewDetails: () {},
                  ),
                  const SizedBox(height: 16),
                  
                  // 月度消费趋势
                  MonthlyTrends(
                    monthlyData: _monthlyData,
                    onViewMore: () {},
                  ),
                  const SizedBox(height: 16),
                  
                  // 近期交易
                  RecentTransactions(
                    transactions: _recentTransactions,
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionHistoryScreen(
                            initialMemberId: widget.member.role == '爸爸' ? 'dad' : 
                                           widget.member.role == '妈妈' ? 'mom' : 
                                           widget.member.role == '女儿' ? 'daughter' : 
                                           widget.member.role == '儿子' ? 'son' : null,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 财务健康评估
                  FinancialHealth(
                    score: 85,
                    metrics: _healthMetrics,
                    lastMonthScore: 82,
                  ),
                  const SizedBox(height: 16),
                  
                  // 个人月度预算
                  PersonalBudget(
                    totalBudget: 6500,
                    usedAmount: 4572,
                    budgetItems: _budgetItems,
                    onEditBudget: (item) {
                      // 打开编辑预算对话框
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 个性化财务建议
                  const FinancialAdvice(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
