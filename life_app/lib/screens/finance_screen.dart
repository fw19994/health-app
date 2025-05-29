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
import 'finance/family_finance/family_finance_screen.dart' hide SavingsGoal;
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
      // 调用API获取近期交易数据，获取所有类型交易（不指定type）
      final response = await _financeService.getRecentTransactions(
        context: context,
        type: '', // 不指定交易类型，获取所有类型交易
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
          _currentBudget = null;
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
      final startDate = DateTime(_currentYear, _currentMonth, 1); // 当月第一天
      final lastDay = DateTime(_currentYear, _currentMonth + 1, 0).day; // 当月最后一天
      final endDate = DateTime(_currentYear, _currentMonth, lastDay, 23, 59, 59); // 当月最后一天的23:59:59
      
      // 调用获取支出分析数据的方法
      final response = await _financeService.getExpenseAnalysis(
        context: context,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            // 解析支出分析数据，增加错误处理
            try {
              if (response.data['data'] != null) {
                final rawData = List.from(response.data['data']);
                
                // 验证并过滤数据
                _expenseAnalysisData = rawData.where((item) {
                  return item is Map && 
                         item['amount'] != null && 
                         item['category_name'] != null &&
                         item['percentage'] != null;
                }).map((item) => Map<String, dynamic>.from(item)).toList();
                
                // 处理百分比数据
                for (var item in _expenseAnalysisData) {
                  // 确保percentage是整数
                  if (item['percentage'] is num) {
                    item['percentage'] = (item['percentage'] as num).toInt();
                  } else {
                    item['percentage'] = 0;
                  }
                }
              } else {
                _expenseAnalysisData = [];
              }
            } catch (e) {
              print('解析支出分析数据出错: $e');
              _expenseAnalysisData = [];
            }
          } else {
            _expenseAnalysisData = [];
          }
          _isLoadingExpenseAnalysis = false;
        });
      }
    } catch (e) {
      print('加载支出分析数据出错: $e');
      if (mounted) {
        setState(() {
          _expenseAnalysisData = [];
          _isLoadingExpenseAnalysis = false;
        });
      }
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
      body: Column(
          children: [
          // 移除SafeArea，让头部延伸到状态栏
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
    );
  }

  // 财务仪表盘头部 - 橙黄色渐变背景
  Widget _buildHeader(BuildContext context) {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // 格式化数字
    final formatter = NumberFormat('#,##0.00', 'zh_CN');
    
    // 获取剩余预算金额，如果预算数据未加载则显示占位符
    final String remainingAmount = _isLoadingBudget || _currentBudget == null
        ? '加载中...'
        : '¥${formatter.format(_currentBudget!.remainingAmount)}';
    
    return Container(
      padding: EdgeInsets.fromLTRB(12, statusBarHeight + 8, 12, 8),
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
          // 标题与余额并排
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                      '财务仪表盘',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const Text(
                      '本月余额',
                      style: TextStyle(
                        color: Colors.white,
                  fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
          
          // 金额和上月比较
          Row(
            children: [
              // 金额
                Text(
                remainingAmount,
                  style: const TextStyle(
                    color: Colors.white,
                  fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(width: 8),
              // 变化指示器
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
                      size: 10,
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
                        fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          
          const SizedBox(height: 8),
          
          // 收入和支出
                Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
                ),
            child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                // 收入
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.greenAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '总收入',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          _isLoadingTransactionSummary
                              ? '加载中...'
                              : '¥${formatter.format(_totalIncome)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // 支出
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.redAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '总支出',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          _isLoadingTransactionSummary
                              ? '加载中...'
                              : '¥${formatter.format(_totalExpense)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
              onTap: () async {
                // 等待记一笔页面返回结果
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpenseTrackingScreen()),
                );
                
                // 如果返回结果为true（表示记账成功），则刷新所有财务数据
                if (result == true) {
                  _loadCurrentBudget();
                  _loadTransactionSummary();
                  _loadExpenseAnalysis();
                  _loadRecentTransactions();
                }
              },
            ),
            const SizedBox(width: 10),
            _buildQuickActionCard(
              context,
              icon: Icons.tune,
              label: '预算设置',
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
    try {
    // 格式化数字
    final formatter = NumberFormat('#,##0.00', 'zh_CN');
    
      // 确保百分比在0-100之间
      final safePercent = budget.usagePercent.clamp(0.0, 100.0);
      final displayPercent = safePercent.toStringAsFixed(2);
    
    // 安全地计算进度条宽度 - 使用小数形式百分比与100的比率
      final availableWidth = MediaQuery.of(context).size.width - 64;
      final progressWidth = availableWidth * (safePercent / 100.0);

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
                          overflow: TextOverflow.ellipsis,
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
                          overflow: TextOverflow.ellipsis,
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
                          overflow: TextOverflow.ellipsis,
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
                    width: progressWidth.clamp(0, availableWidth),
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
    } catch (e) {
      print('预算展示错误: $e');
      return _buildBudgetOverviewError("数据异常: 请刷新重试");
    }
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
              // 有数据状态 - 显示增强版柱状图
            SizedBox(
                height: 220, // 增加高度以容纳更多信息
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildEnhancedSpendingColumns(),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // 构建增强版支出柱状图列
  List<Widget> _buildEnhancedSpendingColumns() {
    // 防御性检查：确保有数据
    if (_expenseAnalysisData.isEmpty) {
      return [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("暂无数据", style: TextStyle(color: Colors.grey))
            ],
          )
        )
      ];
    }
    
    try {
      // 排序支出数据并限制最多显示7条
      final sortedData = List<Map<String, dynamic>>.from(_expenseAnalysisData)
        ..sort((a, b) {
          num amountA = a['amount'];
          num amountB = b['amount'];
          return amountB.compareTo(amountA);
        });
      final displayData = sortedData.take(7).toList();
      
      // 找出金额最高的类别
      double maxAmount = 0;
      double totalAmount = 0;
      if (displayData.isNotEmpty) {
        maxAmount = (displayData.first['amount'] as num).toDouble();
        // 计算总支出
        for (var item in displayData) {
          totalAmount += (item['amount'] as num).toDouble();
        }
      }
      
      // 构建柱状图列
      return displayData.map((item) {
        final double amount = (item['amount'] as num).toDouble();
        // 计算高度比例，防止除零错误
        final double heightRatio = maxAmount > 0 ? (amount / maxAmount).clamp(0.0, 1.0) : 0;
        // 是否是最高的柱子
        final bool isHighlighted = amount == maxAmount;
        // 计算占总支出百分比
        final int percentage = totalAmount > 0 ? ((amount / totalAmount) * 100).round() : 0;
        // 获取图标ID
        final int iconId = item['icon_id'] ?? 0;
        final String category = item['category_name'] ?? "未知";
        
        // 使用与近期交易相同的方式获取图标
        final IconData iconData = _getIconDataById(iconId);
        final Color iconColor = _getIconColorById(iconId);
        
        return _buildEnhancedSpendingColumn(
          category: category,
          amount: amount,
          percentage: percentage,
          heightRatio: heightRatio,
          isHighlighted: isHighlighted,
          icon: iconData,
          iconColor: iconColor
        );
      }).toList();
    } catch (e) {
      // 捕获任何解析错误，提供优雅的降级
      print('构建柱状图时出错: $e');
      return [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 24),
              const SizedBox(height: 8),
              const Text("数据解析错误", style: TextStyle(color: Colors.grey))
            ],
          )
        )
      ];
    }
  }
  
  // 增强版支出柱状图的单个柱子
  Widget _buildEnhancedSpendingColumn({
    required String category,
    required double amount,
    required int percentage,
    required double heightRatio,
    required bool isHighlighted,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 添加金额标签
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '¥${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                color: isHighlighted ? AppTheme.primaryColor : Colors.grey[600],
              ),
            ),
          ),
          // 添加百分比标签
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$percentage%',
            style: TextStyle(
                fontSize: 10,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
                color: isHighlighted ? AppTheme.primaryColor : Colors.grey[600],
            ),
          ),
          ),
          // 柱状图条
          Container(
            height: 100 * heightRatio,
            decoration: BoxDecoration(
              color: isHighlighted 
                ? iconColor
                : iconColor.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
            ),
        ),
          ),
          // 添加图标
            Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 12,
              color: iconColor,
              ),
            ),
          const SizedBox(height: 2),
          // 类别名称
          Text(
            category,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              color: isHighlighted ? AppTheme.textPrimary : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
    );
  }

  // 财务健康和储蓄目标
  Widget _buildSavingsGoal(BuildContext context) {
    try {
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
        
          // 储蓄目标部分 - 根据加载状态显示不同内容
          _buildSavingsGoalsCard(),
        ],
      );
    } catch (e) {
      print('构建财务健康和储蓄目标时发生错误: $e');
      // 提供降级的UI，确保用户界面不会完全崩溃
      return Card(
          margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 24),
              const SizedBox(height: 8),
              const Text('加载财务指标时出现错误'),
              const SizedBox(height: 8),
              ElevatedButton(
                child: const Text('刷新'),
                onPressed: () {
                  // 重新加载数据
                  _loadSavingsGoals();
                  _loadTransactionSummary();
                },
              ),
            ],
          ),
        ),
      );
    }
  }
  
  // 储蓄目标卡片 - 抽取为单独方法以增强可维护性
  Widget _buildSavingsGoalsCard() {
    // 加载中状态
    if (_isLoadingSavingsGoals) {
      return Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100),
          ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    
    // 错误状态
    if (_savingsGoalsError.isNotEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
            child: Column(
                  children: [
                    const Text(
                      '储蓄目标',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
              const SizedBox(height: 16),
              Icon(Icons.error_outline, color: Colors.orange, size: 24),
              const SizedBox(height: 8),
              Text(
                '加载储蓄目标失败',
                style: TextStyle(color: Colors.grey[700]),
                        ),
              const SizedBox(height: 4),
              Text(
                '请稍后再试',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadSavingsGoals,
                child: const Text('重试'),
                    ),
                  ],
                ),
        ),
      );
    }
    
    // 空数据状态
    if (_savingsGoals.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100),
                  ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
                      );
                    },
                    child: const Text('去设置'),
                                  ),
                                ],
                              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                            children: [
                    Icon(
                      Icons.savings_outlined,
                      color: Colors.grey[400],
                      size: 48,
                                ),
                    const SizedBox(height: 8),
                              Text(
                      '您还没有设置储蓄目标',
                                style: TextStyle(
                                  color: Colors.grey[600],
                        fontSize: 14,
                              ),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
                        );
                      },
                      child: const Text('设置目标'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                            ),
                          ),
                        ],
                      ),
                  ),
      );
    }
    
    // 有数据状态 - 显示储蓄目标
    try {
      return Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100),
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
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
                      );
                    },
                    child: const Text('查看更多'),
                                  ),
                                ],
                              ),
              const SizedBox(height: 8),
              
              // 只显示前两个进行中的目标
              ..._savingsGoals.take(2).map((goal) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SimplifiedSavingsGoalCard(goal: goal),
                )
              ).toList(),
            ],
          ),
        ),
      );
    } catch (e) {
      print('构建储蓄目标卡片时发生错误: $e');
      // 发生错误时的降级UI
      return Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
                            children: [
                              const Text(
                '储蓄目标',
                                style: TextStyle(
                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
              const SizedBox(height: 16),
              const Text('加载目标数据时出错'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadSavingsGoals,
                child: const Text('重试'),
                              ),
                            ],
                          ),
        ),
      );
    }
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
