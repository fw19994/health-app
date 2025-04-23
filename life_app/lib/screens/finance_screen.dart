import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../themes/app_theme.dart';
import '../services/budget_service.dart';
import '../models/monthly_budget.dart';
import '../services/finance_service.dart';
import '../models/api_response.dart';
import '../services/icon_service.dart';
import '../models/icon.dart';
import '../models/savings_goal.dart';
import 'expense_tracking_screen.dart';
import 'family_finance_screen.dart' hide SavingsGoal;
import 'finance_report_screen.dart';
import 'budget_settings_screen.dart';
import 'savings_goals_screen.dart';
import '../widgets/finance/simplified_savings_goal_card.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  // 预算服务实例
  final BudgetService _budgetService = BudgetService();
  // 添加财务服务和图标服务实例
  final FinanceService _financeService = FinanceService();
  final IconService _iconService = IconService();
  
  // 当前年月
  late int _currentYear;
  late int _currentMonth;
  late String _currentMonthText;
  
  // 添加图标数据列表和近期交易列表
  List<IconModel> _systemIcons = [];
  List<IconModel> _customIcons = [];
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoadingTransactions = false;
  
  // 添加当前预算数据
  MonthlyBudget? _currentBudget;
  bool _isLoadingBudget = true;
  
  // 添加交易摘要数据
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  bool _isLoadingTransactionSummary = true;
  
  // 添加支出分析数据
  List<Map<String, dynamic>> _expenseAnalysisData = [];
  bool _isLoadingExpenseAnalysis = true;
  
  // 添加储蓄目标列表
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoadingSavingsGoals = false;
  String _savingsGoalsError = '';
  
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
    
    // 格式化月份显示
    final monthFormat = DateFormat('M月', 'zh_CN');
    _currentMonthText = monthFormat.format(now);
    
    // 加载图标和近期交易数据
    _loadIcons();
    _loadRecentTransactions();
    _loadCurrentBudget(); // 添加加载预算数据
    _loadTransactionSummary(); // 添加加载交易摘要数据
    _loadExpenseAnalysis(); // 添加加载支出分析数据
    _loadSavingsGoals(); // 添加加载储蓄目标数据
  }
  
  // 加载图标数据
  Future<void> _loadIcons() async {
    try {
      final icons = await _iconService.getUserAvailableIcons(context: context);
      setState(() {
        _systemIcons = icons.where((icon) => !icon.isCustom).toList();
        _customIcons = icons.where((icon) => icon.isCustom).toList();
      });
    } catch (e) {
      debugPrint('加载图标失败: $e');
    }
  }
  
  // 加载近期交易数据
  Future<void> _loadRecentTransactions() async {
    if (!mounted) return;

    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      // 调用API获取近期交易数据，获取支出类型交易
      final response = await _financeService.getRecentTransactions(
        context: context,
        type: 'expense',
      );
      
      if (mounted && response.success && response.data != null) {
        setState(() {
          _recentTransactions = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      debugPrint('加载近期交易失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTransactions = false;
        });
      }
    }
  }
  
  // 加载当前预算数据
  Future<void> _loadCurrentBudget() async {
    setState(() {
      _isLoadingBudget = true;
    });
    
    try {
      final budget = await _budgetService.getMonthlyBudget(
        year: _currentYear,
        month: _currentMonth,
        context: context,
      );
      
      if (mounted) {
        setState(() {
          _currentBudget = budget;
          _isLoadingBudget = false;
        });
      }
    } catch (e) {
      debugPrint('加载预算数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingBudget = false;
        });
      }
    }
  }
  
  // 加载交易摘要数据
  Future<void> _loadTransactionSummary() async {
    setState(() {
      _isLoadingTransactionSummary = true;
    });
    
    try {
      // 创建当前月份的起始日期和结束日期
      final now = DateTime.now();
      final startDate = DateTime(_currentYear, _currentMonth, 1); // 当月第一天
      final lastDay = DateTime(_currentYear, _currentMonth + 1, 0).day; // 当月最后一天
      final endDate = DateTime(_currentYear, _currentMonth, lastDay, 23, 59, 59); // 当月最后一天的23:59:59
      
      // 调用获取交易摘要的方法
      final response = await _financeService.getTransactionSummary(
        context: context,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (mounted && response.success && response.data != null) {
        setState(() {
          // 解析总收入和总支出
          _totalIncome = response.data['summary']['total_income']?.toDouble() ?? 0.0;
          _totalExpense = response.data['summary']['total_expense']?.toDouble() ?? 0.0;
          _isLoadingTransactionSummary = false;
        });
      } else {
        debugPrint('加载交易摘要失败: ${response.message}');
        setState(() {
          _isLoadingTransactionSummary = false;
        });
      }
    } catch (e) {
      debugPrint('加载交易摘要出错: $e');
      setState(() {
        _isLoadingTransactionSummary = false;
      });
    }
  }
  
  // 加载支出分析数据
  Future<void> _loadExpenseAnalysis() async {
    setState(() {
      _isLoadingExpenseAnalysis = true;
    });
    
    try {
      // 创建当前月份的起始日期和结束日期
      final now = DateTime.now();
      final startDate = DateTime(_currentYear, _currentMonth, 1); // 当月第一天
      final lastDay = DateTime(_currentYear, _currentMonth + 1, 0).day; // 当月最后一天
      final endDate = DateTime(_currentYear, _currentMonth, lastDay, 23, 59, 59); // 当月最后一天的23:59:59
      
      // 调用获取支出分析数据的方法
      final response = await _financeService.getExpenseAnalysis(
        context: context,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (mounted && response.success && response.data != null) {
        setState(() {
          // 解析支出分析数据
          if (response.data['data'] != null) {
            _expenseAnalysisData = List<Map<String, dynamic>>.from(response.data['data']);
          } else {
            _expenseAnalysisData = [];
          }
          _isLoadingExpenseAnalysis = false;
        });
      } else {
        debugPrint('加载支出分析数据失败: ${response.message}');
        setState(() {
          _isLoadingExpenseAnalysis = false;
        });
      }
    } catch (e) {
      debugPrint('加载支出分析数据出错: $e');
      setState(() {
        _isLoadingExpenseAnalysis = false;
      });
    }
  }
  
  // 加载储蓄目标数据
  Future<void> _loadSavingsGoals() async {
    setState(() {
      _isLoadingSavingsGoals = true;
      _savingsGoalsError = '';
    });
    
    try {
      // 获取储蓄目标数据，只加载进行中的目标
      final goals = await _budgetService.getSavingsGoals(status: 'in_progress', context: context);
      
      // 为每个目标加载真实图标
      for (var goal in goals) {
        await goal.loadRealIcon(context: context);
      }
      
      if (mounted) {
        setState(() {
          _savingsGoals = goals;
          _isLoadingSavingsGoals = false;
        });
      }
      print('成功加载储蓄目标: ${goals.length}个');
    } catch (e) {
      print('加载储蓄目标失败: $e');
      if (mounted) {
        setState(() {
          _savingsGoalsError = '加载储蓄目标失败: $e';
          _isLoadingSavingsGoals = false;
        });
      }
    }
  }
  
  // 根据图标ID获取图标数据
  IconData _getIconDataById(int iconId) {
    // 尝试从系统图标中查找
    for (var icon in _systemIcons) {
      if (icon.id == iconId) {
        return icon.icon;
      }
    }
    
    // 尝试从自定义图标中查找
    for (var icon in _customIcons) {
      if (icon.id == iconId) {
        return icon.icon;
      }
    }
    
    // 返回默认图标
    return Icons.category;
  }

  // 根据图标ID获取图标名称
  String _getIconNameById(int iconId) {
    // 尝试从系统图标中查找
    for (var icon in _systemIcons) {
      if (icon.id == iconId) {
        return icon.name;
      }
    }
    
    // 尝试从自定义图标中查找
    for (var icon in _customIcons) {
      if (icon.id == iconId) {
        return icon.name;
      }
    }
    
    // 返回默认名称
    return "未知类别";
  }

  // 根据图标ID获取图标颜色
  Color _getIconColorById(int iconId) {
    // 尝试从系统图标中查找
    for (var icon in _systemIcons) {
      if (icon.id == iconId) {
        return icon.color;
      }
    }
    
    // 尝试从自定义图标中查找
    for (var icon in _customIcons) {
      if (icon.id == iconId) {
        return icon.color;
      }
    }
    
    // 返回默认颜色
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: 16),
                  _buildBudgetOverviewSection(context),
                  const SizedBox(height: 16),
                  _buildRecentTransactions(context),
                  const SizedBox(height: 16),
                  _buildMonthlySpendingAnalysis(context),
                  const SizedBox(height: 16),
                  _buildSavingsGoal(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 财务仪表盘头部 - 橙黄色渐变背景
  Widget _buildHeader(BuildContext context) {
    // 格式化数字
    final formatter = NumberFormat('#,##0.00', 'zh_CN');
    
    // 获取剩余预算金额，如果预算数据未加载则显示占位符
    final String remainingAmount = _isLoadingBudget || _currentBudget == null
        ? '加载中...'
        : '¥${formatter.format(_currentBudget!.remainingAmount)}';
    
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 余额卡片
          Container(
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      '财务仪表盘',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '本月余额',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  remainingAmount, // 使用与预算剩余相同的值
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBF7D0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isLoadingBudget || _currentBudget == null || _currentBudget!.changePercent >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: _isLoadingBudget || _currentBudget == null || _currentBudget!.changePercent >= 0
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFEF4444),
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _isLoadingBudget || _currentBudget == null
                                ? '计算中...'
                                : '${_currentBudget!.changePercent.abs().toStringAsFixed(1)}% 较上月',
                            style: TextStyle(
                              color: _isLoadingBudget || _currentBudget == null || _currentBudget!.changePercent >= 0
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFEF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '总收入',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoadingTransactionSummary
                              ? '加载中...'
                              : '¥${formatter.format(_totalIncome)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '总支出',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoadingTransactionSummary
                              ? '加载中...'
                              : '¥${formatter.format(_totalExpense)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 快捷操作区域 - 改为水平滚动
  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: 80, // 减小固定高度
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildQuickActionCard(
              context,
              icon: Icons.add,
              label: '记一笔',
              bgColor: const Color(0xFFF8FAFC),
              iconColor: AppTheme.primaryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpenseTrackingScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildQuickActionCard(
              context,
              icon: Icons.tune,
              label: '预算和储蓄设置',
              bgColor: AppTheme.budgetButtonBg,
              iconColor: AppTheme.budgetButtonIcon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BudgetSettingsScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildQuickActionCard(
              context,
              icon: Icons.savings_outlined,
              label: '储蓄目标设置',
              bgColor: const Color(0xFFDEECFF),
              iconColor: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildQuickActionCard(
              context,
              icon: Icons.people_outline,
              label: '家庭账本',
              bgColor: AppTheme.familyButtonBg,
              iconColor: AppTheme.familyButtonIcon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FamilyFinanceScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildQuickActionCard(
              context,
              icon: FontAwesomeIcons.chartLine,
              label: '分析报告',
              bgColor: Colors.purple.shade50,
              iconColor: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FinanceReportScreen()),
                );
              },
            ),
            const SizedBox(width: 4), // 添加尾部间距使最后一个项目不会紧贴边缘
          ],
        ),
      ),
    );
  }

  // 单个快捷操作卡片 - 更小尺寸
  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    // 进一步减小尺寸
    final cardWidth = 65.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: cardWidth,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 预算概览区域
  Widget _buildBudgetOverviewSection(BuildContext context) {
    if (_isLoadingBudget) {
      return _buildBudgetOverviewSkeleton();
    } else if (_currentBudget == null) {
      return _buildBudgetOverviewError("无法获取预算数据");
    } else {
      return _buildBudgetOverview(_currentBudget!);
    }
  }

  // 预算概览加载中骨架屏
  Widget _buildBudgetOverviewSkeleton() {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white, // 设置为白色背景
      elevation: 0, // 移除阴影效果
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100), // 添加细边框
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '预算概览',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _currentMonthText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 30,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 预算概览错误显示
  Widget _buildBudgetOverviewError(String errorMsg) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white, // 设置为白色背景
      elevation: 0, // 移除阴影效果
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100), // 添加细边框
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '预算概览',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _currentMonthText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.orange[300],
            ),
            const SizedBox(height: 10),
            const Text(
              '加载预算数据失败',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              errorMsg,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  // 重新加载页面
                });
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  // 预算概览卡片 - 使用API数据
  Widget _buildBudgetOverview(MonthlyBudget budget) {
    // 格式化数字
    final formatter = NumberFormat('#,##0.00', 'zh_CN');
    
    // 直接使用API返回的原始百分比值，不乘以100
    final displayPercent = budget.usagePercent.toStringAsFixed(2);
    
    // 安全地计算进度条宽度 - 使用小数形式百分比与100的比率
    final progressWidth = (MediaQuery.of(context).size.width - 64) * (budget.usagePercent / 100); 

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white, // 设置为白色背景
      elevation: 0, // 移除阴影效果
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100), // 添加细边框
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '预算概览',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _currentMonthText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '已用',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥${formatter.format(budget.totalSpent)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8), // 仅添加水平间距
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '剩余',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥${formatter.format(budget.remainingAmount)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8), // 仅添加水平间距
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '总预算',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥${formatter.format(budget.totalBudget)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '预算使用进度',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '$displayPercent%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                // 背景进度条
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // 实际进度
                Container(
                  height: 8,
                  width: progressWidth.clamp(0, MediaQuery.of(context).size.width - 64),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 月度支出分析
  Widget _buildMonthlySpendingAnalysis(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white, // 设置为白色背景
      elevation: 0, // 移除阴影效果
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100), // 添加细边框
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '月度支出分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                // 月份选择器
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentMonthText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 支出柱状图 - 根据加载状态显示不同内容
            if (_isLoadingExpenseAnalysis)
              // 加载中状态
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_expenseAnalysisData.isEmpty)
              // 空数据状态
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Column(
                    children: [
                      Icon(
                        FontAwesomeIcons.chartSimple,
                        size: 38,
                        color: Colors.grey[350],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '暂无支出分析数据',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // 有数据状态 - 显示柱状图
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildSpendingColumns(),
                ),
              ),
            
            if (!_isLoadingExpenseAnalysis && _expenseAnalysisData.isNotEmpty) ...[
            const SizedBox(height: 16),
            
            // 主要支出类别
            const Text(
              '主要支出类别',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 12),
            
              // 主要支出类别列表
              ..._buildCategoryProgressBars(),
            ],
          ],
        ),
      ),
    );
  }
  
  // 构建支出柱状图列
  List<Widget> _buildSpendingColumns() {
    // 排序支出数据并限制最多显示7条
    final sortedData = List<Map<String, dynamic>>.from(_expenseAnalysisData)
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    final displayData = sortedData.take(7).toList();
    
    // 找出金额最高的类别
    double maxAmount = 0;
    if (displayData.isNotEmpty) {
      maxAmount = displayData.first['amount'];
    }
    
    // 构建柱状图列
    return displayData.map((item) {
      final double amount = item['amount'];
      // 计算高度比例
      final double heightRatio = maxAmount > 0 ? amount / maxAmount : 0;
      // 是否是最高的柱子
      final bool isHighlighted = amount == maxAmount;
      
      return _buildSpendingColumn(
        item['category_name'], 
        heightRatio, 
        isHighlighted
      );
    }).toList();
  }
  
  // 构建类别进度条列表
  List<Widget> _buildCategoryProgressBars() {
    // 排序支出数据并限制最多显示4条
    final sortedData = List<Map<String, dynamic>>.from(_expenseAnalysisData)
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    final displayData = sortedData.take(4).toList();
    
    // 构建类别进度条列表
    List<Widget> progressBars = [];
    
    for (int i = 0; i < displayData.length; i++) {
      final item = displayData[i];
      final iconId = item['icon_id'];
      final category = item['category_name'];
      final amount = item['amount'];
      final percentage = item['percentage'];
      
      // 根据类别名称选择对应的图标
      IconData iconData;
      Color iconColor;
      
      switch (category) {
        case '餐饮':
          iconData = FontAwesomeIcons.utensils;
          iconColor = const Color(0xFFA855F7); // 紫色
          break;
        case '购物':
          iconData = FontAwesomeIcons.shoppingCart;
          iconColor = const Color(0xFF3B82F6); // 蓝色
          break;
        case '住房':
          iconData = FontAwesomeIcons.home;
          iconColor = const Color(0xFFEF4444); // 红色
          break;
        case '交通':
          iconData = FontAwesomeIcons.car;
          iconColor = const Color(0xFF10B981); // 绿色
          break;
        case '医疗':
          iconData = FontAwesomeIcons.hospitalUser;
          iconColor = const Color(0xFFF59E0B); // 黄色
          break;
        case '教育':
          iconData = FontAwesomeIcons.graduationCap;
          iconColor = const Color(0xFF6366F1); // 靛蓝色
          break;
        default:
          iconData = FontAwesomeIcons.tags;
          iconColor = Colors.grey;
      }
      
      // 添加进度条，每个进度条下方添加间距
      progressBars.add(
            _buildCategoryProgressBar(
              context,
          icon: iconData,
          color: iconColor,
          category: category,
          amount: '¥${amount.toStringAsFixed(0)}',
          percentage: percentage.round(),
      ),
    );
      
      // 除了最后一个，其他都添加间距
      if (i < displayData.length - 1) {
        progressBars.add(const SizedBox(height: 12));
      }
    }
    
    return progressBars;
  }
  
  // 支出柱状图的单个柱子
  Widget _buildSpendingColumn(String category, double height, bool isHighlighted) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 120 * height,
            decoration: BoxDecoration(
              color: isHighlighted 
                ? AppTheme.primaryColor 
                : AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              color: isHighlighted ? AppTheme.textPrimary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  // 类别进度条
  Widget _buildCategoryProgressBar(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String category,
    required String amount,
    required int percentage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FaIcon(
                  icon,
                  color: color,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '$amount ($percentage%)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              height: 6,
              width: MediaQuery.of(context).size.width * percentage / 100 - 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 财务健康和储蓄目标
  Widget _buildSavingsGoal(BuildContext context) {
    return Column(
      children: [
        // 财务健康部分
        Card(
          margin: EdgeInsets.zero,
          color: Colors.white, // 设置为白色背景
          elevation: 0, // 移除阴影效果
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100), // 添加细边框
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '财务健康',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 存款充足提示
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle,
                          color: const Color(0xFF10B981),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '您的存款充足',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '您当前的储蓄金额可以覆盖约4个月的生活开支，这是个不错的应急准备。',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // 住房开销偏高提示
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.warning_amber,
                          color: const Color(0xFFF59E0B),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '住房开销偏高',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '您的住房支出占月收入的35%，略高于建议的30%。考虑寻找更经济的选择。',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 储蓄目标部分
        Card(
          margin: EdgeInsets.zero,
          color: Colors.white, // 设置为白色背景
          elevation: 0, // 移除阴影效果
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100), // 添加细边框
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '储蓄目标',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
                        ).then((_) => _loadSavingsGoals()); // 返回时刷新数据
                      },
                      child: const Text(
                        '查看全部',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 加载状态
                if (_isLoadingSavingsGoals)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                // 错误状态
                else if (_savingsGoalsError.isNotEmpty && _savingsGoals.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                          Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Colors.red[300],
                              ),
                          const SizedBox(height: 8),
                                  Text(
                            '加载失败',
                                    style: TextStyle(
                              color: Colors.red[300],
                                  fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                                ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _loadSavingsGoals,
                            child: const Text('重试'),
                              ),
                            ],
                          ),
                    ),
                  )
                // 数据为空
                else if (_savingsGoals.isEmpty) 
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                          Icon(
                            Icons.savings_outlined,
                            size: 32,
                            color: Colors.grey,
                              ),
                          const SizedBox(height: 8),
                                  const Text(
                            '暂无储蓄目标',
                                    style: TextStyle(
                              color: Colors.grey,
                                      fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
                              ).then((_) => _loadSavingsGoals());
                            },
                            child: const Text('添加目标'),
                                  ),
                                ],
                              ),
                    ),
                  )
                // 储蓄目标列表
                else
                  ...List.generate(
                    _savingsGoals.length > 2 ? 2 : _savingsGoals.length, // 最多显示2个
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index < (_savingsGoals.length > 2 ? 1 : _savingsGoals.length - 1) ? 12 : 0),
                      child: SimplifiedSavingsGoalCard(
                        goal: _savingsGoals[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
                          ).then((_) => _loadSavingsGoals());
                        },
                      ),
                                ),
                              ),
                            ],
                          ),
          ),
        ),
      ],
    );
  }

  // 近期交易列表 - 重新实现，参考记一笔页面
  Widget _buildRecentTransactions(BuildContext context) {
    // 获取并限制最多显示3条记录
    final displayTransactions = _recentTransactions.take(3).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '近期交易',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // 添加"查看全部"按钮到右上角
                if (!_isLoadingTransactions && displayTransactions.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/transaction_history');
                    },
                    child: Row(
                      children: [
                        Text(
                          '查看全部',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 交易列表内容
          if (_isLoadingTransactions)
            // 加载中状态
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (displayTransactions.isEmpty)
            // 空数据状态
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.fileCircleExclamation,
                      size: 38,
                      color: Colors.grey[350],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '暂无近期交易记录',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // 有数据状态 - 展示交易列表，每个交易使用Container包装
            Column(
              children: displayTransactions.map((transaction) {
                // 解析交易数据
                final int iconId = transaction['icon_id'] ?? 0;
                final IconData iconData = _getIconDataById(iconId);
                final Color iconColor = _getIconColorById(iconId);
                final String iconName = _getIconNameById(iconId);
                
                // 获取交易类型
                final String type = transaction['type'] ?? 'expense';
                final bool isExpense = type == 'expense';
                
                // 获取金额
                final num amount = transaction['amount'] ?? 0;
                final String amountStr = isExpense ? 
                    '-¥${amount.toStringAsFixed(2)}' : 
                    '+¥${amount.toStringAsFixed(2)}';
                
                // 获取商家和备注
                final String merchant = transaction['merchant'] ?? '';
                final String notes = transaction['notes'] ?? '';
                
                // 获取并格式化日期时间
                DateTime? transactionDate;
                try {
                  if (transaction['date'] != null) {
                    transactionDate = DateTime.parse(transaction['date']);
                  }
                } catch (e) {
                  debugPrint('解析日期失败: $e');
                }
                
                // 格式化日期时间
                String formattedDateTime = '';
                if (transactionDate != null) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final yesterday = today.subtract(const Duration(days: 1));
                  final transactionDay = DateTime(
                    transactionDate.year,
                    transactionDate.month,
                    transactionDate.day,
                  );
                  
                  // 时间部分 HH:mm
                  final timeStr = DateFormat('HH:mm').format(transactionDate);
                  
                  if (transactionDay == today) {
                    formattedDateTime = '今天 $timeStr';
                  } else if (transactionDay == yesterday) {
                    formattedDateTime = '昨天 $timeStr';
                  } else {
                    formattedDateTime = DateFormat('MM-dd $timeStr').format(transactionDate);
                  }
                }
                
                // 构建单个交易项 - 类似记一笔页面的样式
                return GestureDetector(
                  onTap: () {
                    // 点击单个交易项时也导航到交易记录页面
                    Navigator.pushNamed(context, '/transaction_history');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 图标
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              iconData,
                              size: 20,
                              color: iconColor,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 10),
                        
                        // 中间内容：商家、备注、日期
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 商家名称
                              Text(
                                merchant.isNotEmpty ? merchant : iconName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              // 标签、日期和备注信息
                              Row(
                                children: [
                                  // 交易类型标签
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isExpense 
                                          ? Colors.red.shade50 
                                          : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isExpense ? '支出' : '收入',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isExpense 
                                            ? Colors.red.shade700 
                                            : Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 6),
                                  
                                  // 日期时间
                                  if (formattedDateTime.isNotEmpty)
                                    Text(
                                      formattedDateTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  
                                  // 如果有备注和日期，添加分隔点
                                  if (formattedDateTime.isNotEmpty && notes.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        '•',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  
                                  // 备注 (如果有)
                                  if (notes.isNotEmpty)
                                    Flexible(
                                      child: Text(
                                        notes,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // 金额
                        Text(
                          amountStr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isExpense 
                                ? Colors.red.shade600 
                                : Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// 饼图绘制类
class DonutChartPainter extends CustomPainter {
  final List<ChartSegment> segments;
  
  DonutChartPainter({required this.segments});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    double startAngle = -90 * (3.14159 / 180); // 从12点钟方向开始
    
    // 计算总值，用于计算每个段的角度
    final totalValue = segments.fold(0.0, (sum, segment) => sum + segment.value);
    
    for (final segment in segments) {
      final sweepAngle = (segment.value / totalValue) * 2 * 3.14159;
      final segmentPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(rect, startAngle, sweepAngle, true, segmentPaint);
      startAngle += sweepAngle;
    }
    
    // 画中间的空心
    final innerRadius = radius * 0.6;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 图表段数据类
class ChartSegment {
  final double value;
  final Color color;
  
  ChartSegment({required this.value, required this.color});
}
