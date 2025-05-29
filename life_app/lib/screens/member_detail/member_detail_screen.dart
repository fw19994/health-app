import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../member_finances/models/family_member.dart';
import '../../models/family_member_model.dart' as backend_model;
import '../transaction_history/transaction_history_screen.dart';
import 'models/income_source.dart';
import 'models/expense_category.dart';
import 'models/transaction.dart';
import 'models/budget_item.dart';
import 'widgets/member_detail_header.dart';
import 'widgets/time_period_selector.dart';

import 'widgets/income_sources.dart';
import 'widgets/expense_categories.dart';
import 'widgets/monthly_trends.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/financial_health.dart';
import 'widgets/personal_budget.dart';
import 'widgets/financial_advice.dart';
import '../../services/finance_service.dart';
import '../../services/icon_service.dart';
import '../transaction_history/models/filter_options.dart';

class MemberDetailScreen extends StatefulWidget {
  final FamilyMember member;
  final backend_model.FamilyMember? backendMember;

  const MemberDetailScreen({
    super.key, 
    required this.member,
    this.backendMember,
  });

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  int _selectedTimeIndex = 2; // 默认选择"本月"
  
  // 添加自定义日期范围变量
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCustomDateRange = false;
  
  // 创建服务实例
  final FinanceService _financeService = FinanceService();
  final IconService _iconService = IconService();
  
  // 添加收入来源和支出分类的状态变量
  List<IncomeSource> _incomeSources = [];
  List<ExpenseCategory> _expenseCategories = [];
  bool _isLoadingIncomeSources = true;
  bool _isLoadingExpenseCategories = true;
  bool _enableDebug = true; // 调试开关
  
  // 月度消费趋势数据
  List<MonthData> _monthlyData = [];
  bool _isLoadingMonthlyTrends = true;
  
  // 成员变量区域，添加状态变量
  List<Transaction> _recentTransactions = [];
  bool _isLoadingRecentTransactions = true;
  
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
  void initState() {
    super.initState();
    _updateDateRange(); // 初始化日期范围
    _loadIncomeSources();
    _loadExpenseCategories();
    _loadMonthlyTrends();
    _loadRecentTransactions(); // 添加加载近期交易
  }

  // 选择时间段时的回调
  void _onPeriodSelected(int index) {
    setState(() {
      _selectedTimeIndex = index;
      _isCustomDateRange = false;
      _startDate = null;
      _endDate = null;
    });
    _updateDateRange(); // 更新日期范围
    // 重新加载数据
    _loadIncomeSources();
    _loadExpenseCategories();
    _loadMonthlyTrends();
    _loadRecentTransactions(); // 添加重新加载近期交易
  }
  
  // 自定义日期范围选择的回调
  void _onCustomDateRangeSelected(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _isCustomDateRange = true;
    });
    // 重新加载数据
    _loadIncomeSources();
    _loadExpenseCategories();
    _loadMonthlyTrends();
    _loadRecentTransactions();
  }
  
  // 根据选择的时间段更新日期范围
  void _updateDateRange() {
    final DateTime now = DateTime.now();
    
    if (!_isCustomDateRange) {
      switch (_selectedTimeIndex) {
        case 0: // 过去7天
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;
        case 1: // 过去30天
          _startDate = now.subtract(const Duration(days: 30));
          _endDate = now;
          break;
        case 2: // 本月（默认）
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 3: // 上月
          // 确保月份不会出现负数
          int year = now.year;
          int month = now.month - 1;
          if (month <= 0) {
            month = 12;
            year--;
          }
          _startDate = DateTime(year, month, 1);
          _endDate = DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
          break;
        case 4: // 过去3个月
          _startDate = DateTime(now.year, now.month - 3, now.day > 28 ? 28 : now.day);
          _endDate = now;
          break;
        case 5: // 过去6个月
          // 处理月份越界
          int startMonth = now.month - 6;
          int startYear = now.year;
          while (startMonth <= 0) {
            startMonth += 12;
            startYear--;
          }
          _startDate = DateTime(startYear, startMonth, now.day > 28 ? 28 : now.day);
          _endDate = now;
          break;
        case 6: // 过去12个月
          _startDate = DateTime(now.year - 1, now.month, now.day > 28 ? 28 : now.day);
          _endDate = now;
          break;
        case 7: // 2024年
          _startDate = DateTime(2024, 1, 1);
          _endDate = DateTime(2024, 12, 31, 23, 59, 59);
          // 如果结束日期超过当前日期，则使用当前日期
          if (_endDate!.isAfter(now)) {
            _endDate = now;
          }
          break;
        case 8: // 2023年
          _startDate = DateTime(2023, 1, 1);
          _endDate = DateTime(2023, 12, 31, 23, 59, 59);
          break;
        default:
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
      }
    }
  }
  
  // 加载收入来源数据
  Future<void> _loadIncomeSources() async {
    setState(() {
      _isLoadingIncomeSources = true;
    });
    
    try {
      // 使用当前设置的日期范围
      final DateTime startDate = _startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final DateTime endDate = _endDate ?? DateTime.now();
      
      if (_enableDebug) {
        print('正在获取收入来源数据，成员ID: ${widget.backendMember?.id}');
        print('开始时间：$startDate，结束时间：$endDate');
      }
      
      // 获取成员ID
      final int? memberId = widget.backendMember?.id;
      
      if (memberId == null) {
        print('警告: 成员ID为空，无法获取收入来源数据');
        setState(() {
          _isLoadingIncomeSources = false;
          // 使用默认测试数据
          _incomeSources = [
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
        });
        return;
      }
      
      // 调用API获取收入分析数据 - 修改为使用正确的接口
      final response = await _financeService.getExpenseAnalysis(
        context: context,
        startDate: startDate,
        endDate: endDate,
        memberId: memberId,
        transaction_type: 'income', // 指定为收入类型
      );
      
      if (_enableDebug) {
        print('获取收入来源数据响应：${response.success ? "成功" : "失败"}');
        if (response.success && response.data != null) {
          print('API返回原始数据: ${response.data}');
        }
      }
      
      if (response.success && response.data != null) {
        // 解析数据
        final List<dynamic> categoriesData = response.data['data'] ?? [];
        
        // 计算总金额
        double totalAmount = 0.0;
        for (var item in categoriesData) {
          totalAmount += (item['amount'] ?? 0.0).toDouble();
        }
        
        // 解析并创建收入来源列表
        List<IncomeSource> sources = [];
        
        // 定义固定的颜色列表
        final List<Color> colorList = [
          const Color(0xFF4F46E5), // 深蓝色
          const Color(0xFF818CF8), // 蓝紫色
          const Color(0xFFA5B4FC), // 淡蓝色
          const Color(0xFF10B981), // 绿色
          const Color(0xFF8B5CF6), // 紫色
          const Color(0xFFF59E0B), // 橙色
          const Color(0xFFEF4444), // 红色
        ];
        
        for (int i = 0; i < categoriesData.length; i++) {
          var item = categoriesData[i];
          final String name = item['category_name'] ?? '其他收入';
          final double amount = (item['amount'] ?? 0.0).toDouble();
          final double percentage = totalAmount > 0 ? (amount / totalAmount * 100) : 0.0;
          final Color color = i < colorList.length ? colorList[i] : colorList[i % colorList.length];
          
          sources.add(IncomeSource(
            name: name,
            amount: amount,
            percentage: percentage,
            color: color,
          ));
        }
        
        if (mounted) {
          setState(() {
            _incomeSources = sources;
            _isLoadingIncomeSources = false;
          });
        }
      } else {
        print('加载收入来源失败: ${response.message}');
        if (mounted) {
          setState(() {
            _isLoadingIncomeSources = false;
            // 使用默认测试数据
            _incomeSources = [
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
          });
        }
      }
    } catch (e) {
      print('加载收入来源异常: $e');
      if (mounted) {
        setState(() {
          _isLoadingIncomeSources = false;
          // 使用默认测试数据
          _incomeSources = [
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
        });
      }
    }
  }
  
  // 加载支出分类数据
  Future<void> _loadExpenseCategories() async {
    setState(() {
      _isLoadingExpenseCategories = true;
    });
    
    try {
      // 使用当前设置的日期范围
      final DateTime startDate = _startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final DateTime endDate = _endDate ?? DateTime.now();
      
      if (_enableDebug) {
        print('正在获取支出分类数据，成员ID: ${widget.backendMember?.id}');
        print('开始时间：$startDate，结束时间：$endDate');
      }
      
      // 获取成员ID
      final int? memberId = widget.backendMember?.id;
      
      if (memberId == null) {
        print('警告: 成员ID为空，无法获取支出分类数据');
        setState(() {
          _isLoadingExpenseCategories = false;
          // 使用默认测试数据
          _expenseCategories = [
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
        });
        return;
      }
      
      // 调用API获取支出分析数据 - 使用正确的接口
      final response = await _financeService.getExpenseAnalysis(
        context: context,
        startDate: startDate,
        endDate: endDate,
        memberId: memberId,
        transaction_type: 'expense', // 指定为支出类型
      );
      
      if (_enableDebug) {
        print('获取支出分析数据响应：${response.success ? "成功" : "失败"}');
        if (response.success && response.data != null) {
          print('API返回原始数据: ${response.data}');
        }
      }
      
      if (response.success && response.data != null) {
        // 解析数据
        final List<dynamic> categoriesData = response.data['data'] ?? [];
        
        // 计算总金额
        double totalAmount = 0.0;
        for (var item in categoriesData) {
          totalAmount += (item['amount'] ?? 0.0).toDouble();
        }
        
        // 预先加载所有图标数据
        final allIcons = await _iconService.getUserAvailableIcons(context: context);
        
        // 解析并创建支出分类列表
        List<ExpenseCategory> categories = [];
        
        for (var item in categoriesData) {
          final String name = item['category_name'] ?? '其他支出';
          final double amount = (item['amount'] ?? 0.0).toDouble();
          final double percentage = totalAmount > 0 ? (amount / totalAmount * 100) : 0.0;
          
          // 获取图标ID
          final int iconId = item['icon_id'] ?? 0;
          
          // 从预加载的图标中查找匹配的图标
          var iconModel = allIcons.where((icon) => icon.id == iconId).toList();
          var foundIcon = iconModel.isNotEmpty ? iconModel.first : null;
          
          // 如果预加载的图标列表中没有找到，则单独加载
          if (foundIcon == null && iconId > 0) {
            foundIcon = await _iconService.getIconById(iconId, context: context);
          }
          
          // 添加分类
          categories.add(ExpenseCategory(
            name: name,
            amount: amount,
            percentage: percentage,
            color: foundIcon?.color ?? const Color(0xFF8B5CF6),
            icon: foundIcon?.icon ?? FontAwesomeIcons.tag,
          ));
        }
        
        if (mounted) {
          setState(() {
            _expenseCategories = categories;
            _isLoadingExpenseCategories = false;
          });
        }
      } else {
        print('加载支出分类失败: ${response.message}');
        if (mounted) {
          setState(() {
            _isLoadingExpenseCategories = false;
            // 使用默认测试数据
            _expenseCategories = [
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
          });
        }
      }
    } catch (e) {
      print('加载支出分类异常: $e');
      if (mounted) {
        setState(() {
          _isLoadingExpenseCategories = false;
          // 使用默认测试数据
          _expenseCategories = [
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
        });
      }
    }
  }

  // 加载月度消费趋势数据
  Future<void> _loadMonthlyTrends() async {
    setState(() {
      _isLoadingMonthlyTrends = true;
    });
    
    try {
      // 使用当前设置的日期范围
      final DateTime startDate = _startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final DateTime endDate = _endDate ?? DateTime.now();
      
      if (_enableDebug) {
        print('正在获取月度消费趋势数据，成员ID: ${widget.backendMember?.id}');
        print('开始时间：$startDate，结束时间：$endDate');
      }
      
      // 获取成员ID
      final int? memberId = widget.backendMember?.id;
      
      if (memberId == null) {
        print('警告: 成员ID为空，无法获取月度消费趋势数据');
        setState(() {
          _isLoadingMonthlyTrends = false;
          // 使用默认测试数据
          _monthlyData = _getDefaultMonthlyData();
        });
        return;
      }
      
      // 调用API获取交易趋势数据
      final response = await _financeService.getTransactionTrend(
        context: context,
        startDate: startDate,
        endDate: endDate,
        interval: 'month', // 按月聚合
        type: 'expense', // 只获取支出数据
        memberId: memberId,
      );
      
      if (_enableDebug) {
        print('获取月度消费趋势数据响应：${response.success ? "成功" : "失败"}');
        if (response.success && response.data != null) {
          print('API返回原始数据: ${response.data}');
        }
      }
      
      if (response.success && response.data != null) {
        try {
          // 解析数据
          final List<dynamic> trendsData = response.data['data'] ?? [];
          
          // 临时存储处理后的数据
          List<MonthData> trends = [];
          
          // 处理每个月份的数据
          for (var item in trendsData) {
            // 提取日期和金额
            final String dateStr = item['date'] ?? '';
            final double amount = (item['amount'] ?? 0.0).toDouble();
            
            // 解析日期并格式化为月份标签
            DateTime date;
            String monthLabel;
            
            try {
              date = DateTime.parse(dateStr);
              // 格式化月份标签，例如"3月"
              monthLabel = "${date.month}月";
            } catch (e) {
              // 日期解析失败，使用原始字符串
              print('日期解析失败: $e');
              monthLabel = dateStr;
            }
            
            // 添加到趋势数据列表
            trends.add(MonthData(
              label: monthLabel,
              expense: amount,
            ));
          }
          
          // 如果没有数据或数据不足，使用默认数据
          if (trends.isEmpty) {
            trends = _getDefaultMonthlyData();
          }
          
          // 限制最多显示7个月的数据，从最近的月份开始
          if (trends.length > 7) {
            trends = trends.sublist(trends.length - 7);
          }
          
          // 确保至少有一条数据
          if (trends.isEmpty) {
            trends = _getDefaultMonthlyData();
          }
          
          if (mounted) {
            setState(() {
              _monthlyData = trends;
              _isLoadingMonthlyTrends = false;
            });
          }
        } catch (e) {
          print('解析月度消费趋势数据出错: $e');
          setState(() {
            _isLoadingMonthlyTrends = false;
            // 使用默认测试数据
            _monthlyData = _getDefaultMonthlyData();
          });
        }
      } else {
        print('加载月度消费趋势失败: ${response.message}');
        setState(() {
          _isLoadingMonthlyTrends = false;
          // 使用默认测试数据
          _monthlyData = _getDefaultMonthlyData();
        });
      }
    } catch (e) {
      print('加载月度消费趋势异常: $e');
      setState(() {
        _isLoadingMonthlyTrends = false;
        // 使用默认测试数据
        _monthlyData = _getDefaultMonthlyData();
      });
    }
  }
  
  // 获取默认的月度趋势数据
  List<MonthData> _getDefaultMonthlyData() {
    // 获取当前月份，生成最近7个月的数据
    final DateTime now = DateTime.now();
    List<MonthData> defaultData = [];
    
    for (int i = 6; i >= 0; i--) {
      final DateTime month = DateTime(now.year, now.month - i, 1);
      defaultData.add(MonthData(
        label: "${month.month}月",
        expense: i == 0 ? 3500 : (2500 + (500 * (i % 3))), // 生成一些假数据
      ));
    }
    
    return defaultData;
  }

  // 加载近期交易数据
  Future<void> _loadRecentTransactions() async {
    setState(() {
      _isLoadingRecentTransactions = true;
    });
    
    try {
      // 使用当前设置的日期范围
      final DateTime startDate = _startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final DateTime endDate = _endDate ?? DateTime.now();
      
      // 获取成员ID
      final int? memberId = widget.backendMember?.id;
      
      if (_enableDebug) {
        print('正在获取近期交易数据，成员ID: $memberId');
      }
      
      if (memberId == null) {
        print('警告: 成员ID为空，无法获取近期交易数据');
        setState(() {
          _isLoadingRecentTransactions = false;
          // 使用默认测试数据
          _recentTransactions = [
            Transaction(
              title: "房贷还款",
              date: DateTime(2025, 4, 1),
              amount: 1850,
              type: TransactionType.expense,
              icon: FontAwesomeIcons.house,
              iconBgColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFEF4444),
            ),
            // ... 保留其他默认交易数据
          ];
        });
        return;
      }
      
      // 调用API获取近期交易
      final response = await _financeService.getRecentTransactions(
        context: context,
        type: '', // 使用空字符串表示获取所有类型的交易（收入和支出）
        memberId: memberId, // 传递成员ID
      );
      
      if (_enableDebug) {
        print('获取近期交易响应：${response.success ? "成功" : "失败"}');
        if (response.success && response.data != null) {
          print('近期交易数据: ${response.data}');
        }
      }
      
      if (response.success && response.data != null) {
        final List<dynamic> transactionsData = response.data ?? [];
        final List<Transaction> transactions = [];
        
        // 预先加载所有图标数据
        final allIcons = await _iconService.getUserAvailableIcons(context: context);
        
        for (var item in transactionsData) {
          try {
            final String title = item['merchant'] ?? item['notes'] ?? '未命名交易';
            final double amount = (item['amount'] ?? 0.0).toDouble();
            final DateTime date = item['date'] != null
                ? DateTime.parse(item['date'])
                : DateTime.now();
            
            // 确定交易类型
            final String typeStr = item['type'] ?? 'expense';
            final TransactionType type = 
                typeStr.toLowerCase() == 'income' ? TransactionType.income : TransactionType.expense;
            
            // 获取图标信息
            final int iconId = item['icon_id'] ?? 0;
            var iconData = type == TransactionType.income 
                ? FontAwesomeIcons.moneyBillWave
                : FontAwesomeIcons.receipt;
            var iconColor = type == TransactionType.income
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444);
            var iconBgColor = type == TransactionType.income
                ? const Color(0xFFD1FAE5)
                : const Color(0xFFFEE2E2);
            String iconName = type == TransactionType.income ? "收入" : "支出";
            
            if (iconId > 0) {
              var iconModel = allIcons.where((icon) => icon.id == iconId).toList();
              var foundIcon = iconModel.isNotEmpty ? iconModel.first : null;
              
              if (foundIcon != null) {
                iconData = foundIcon.icon;
                iconColor = foundIcon.color;
                iconBgColor = foundIcon.color.withOpacity(0.1);
                iconName = foundIcon.name; // 使用后端返回的图标名称
              }
            }
            
            // 创建交易数据
            transactions.add(Transaction(
              title: title,
              date: date,
              amount: amount,
              type: type,
              icon: iconData,
              iconBgColor: iconBgColor,
              iconColor: iconColor,
              iconName: iconName, // 添加图标名称属性
            ));
          } catch (e) {
            print('处理交易项时出错: $e');
          }
        }
        
        // 排序：按日期从新到旧
        transactions.sort((a, b) => b.date.compareTo(a.date));
        
        // 限制显示数量为最近的4条
        final recentTransactions = transactions.take(4).toList();
        
        setState(() {
          _recentTransactions = recentTransactions;
          _isLoadingRecentTransactions = false;
        });
      } else {
        print('加载近期交易失败: ${response.message}');
        setState(() {
          _isLoadingRecentTransactions = false;
          // 使用默认测试数据
          _recentTransactions = get_recentTransactions;
        });
      }
    } catch (e) {
      print('加载近期交易异常: $e');
      setState(() {
        _isLoadingRecentTransactions = false;
        // 使用默认测试数据
        _recentTransactions = get_recentTransactions;
      });
    }
  }
  
  // 获取预设的近期交易数据 - 作为fallback使用
  List<Transaction> get get_recentTransactions => [
    Transaction(
      title: "房贷还款",
      date: DateTime(2025, 4, 1),
      amount: 1850,
      type: TransactionType.expense,
      icon: FontAwesomeIcons.house,
      iconBgColor: const Color(0xFFFEE2E2),
      iconColor: const Color(0xFFEF4444),
      iconName: "住房", // 添加图标名称
    ),
    Transaction(
      title: "加油站",
      date: DateTime(2025, 3, 30),
      amount: 350,
      type: TransactionType.expense,
      icon: FontAwesomeIcons.car,
      iconBgColor: const Color(0xFFDBEAFE),
      iconColor: const Color(0xFF3B82F6),
      iconName: "交通", // 添加图标名称
    ),
    Transaction(
      title: "家庭聚餐",
      date: DateTime(2025, 3, 28),
      amount: 420,
      type: TransactionType.expense,
      icon: FontAwesomeIcons.utensils,
      iconBgColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFF59E0B),
      iconName: "餐饮", // 添加图标名称
    ),
    Transaction(
      title: "工资收入",
      date: DateTime(2025, 3, 25),
      amount: 11500,
      type: TransactionType.income,
      icon: FontAwesomeIcons.briefcase,
      iconBgColor: const Color(0xFFD1FAE5),
      iconColor: const Color(0xFF10B981),
      iconName: "工作", // 添加图标名称
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
            MemberDetailHeader(
              member: widget.member,
              backendMember: widget.backendMember,
              selectedTimeIndex: _selectedTimeIndex,
              onPeriodSelected: _onPeriodSelected,
              startDate: _startDate,
              endDate: _endDate,
              onCustomDateRangeSelected: _onCustomDateRangeSelected,
            ),
            
            // 内容部分
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // 收入来源
                  _isLoadingIncomeSources
                  ? _buildLoadingWidget("正在加载收入来源数据...")
                  : IncomeSources(
                    sources: _incomeSources,
                    onViewDetails: () {},
                  ),
                  const SizedBox(height: 16),
                  
                  // 支出分类
                  _isLoadingExpenseCategories
                  ? _buildLoadingWidget("正在加载支出分类数据...")
                  : ExpenseCategories(
                    categories: _expenseCategories,
                    onViewDetails: () {},
                  ),
                  const SizedBox(height: 16),
                  
                  // 月度消费趋势
                  _isLoadingMonthlyTrends
                  ? _buildLoadingWidget("正在加载月度消费趋势数据...")
                  : MonthlyTrends(
                    monthlyData: _monthlyData,
                    onViewMore: () {},
                  ),
                  const SizedBox(height: 16),
                  
                  // 近期交易
                  _isLoadingRecentTransactions 
                  ? _buildLoadingWidget("正在加载近期交易数据...")
                  : RecentTransactions(
                    transactions: _recentTransactions,
                    onViewAll: () {
                      // 获取当前选择的时间段对应的FilterPeriod
                      FilterPeriod period;
                      DateTimeRange? customDateRange;
                      
                      // 使用已经计算好的日期范围
                      final startDate = _startDate ?? DateTime.now().subtract(const Duration(days: 30));
                      final endDate = _endDate ?? DateTime.now();
                      
                      // 根据是否使用自定义日期范围确定period
                      if (_isCustomDateRange) {
                        period = FilterPeriod.custom;
                        customDateRange = DateTimeRange(start: startDate, end: endDate);
                      } else {
                        // 根据选择的时间段设置相应的FilterPeriod
                        switch (_selectedTimeIndex) {
                          case 0: // 过去7天
                            period = FilterPeriod.last7Days;
                            break;
                          case 1: // 过去30天
                            period = FilterPeriod.last30Days;
                            break;
                          case 2: // 本月
                            period = FilterPeriod.thisMonth;
                            break;
                          case 3: // 上月
                            period = FilterPeriod.lastMonth;
                            break;
                          case 4: // 过去3个月
                            period = FilterPeriod.last3Months;
                            break;
                          case 5: // 过去6个月
                            period = FilterPeriod.last6Months;
                            break;
                          case 6: // 过去12个月
                            period = FilterPeriod.last12Months;
                            break;
                          case 7: // 2024年
                          case 8: // 2023年
                            period = FilterPeriod.custom;
                            customDateRange = DateTimeRange(start: startDate, end: endDate);
                            break;
                          default:
                            period = FilterPeriod.last30Days;
                            break;
                        }
                      }
                      
                      // 获取当前成员ID
                      final String? memberId = widget.backendMember?.id.toString();
                      
                      // 【调试日志】详细记录传递的参数
                      print('【成员详情页】跳转交易记录页面：');
                      print('【成员详情页】backendMember ID: ${widget.backendMember?.id}');
                      print('【成员详情页】backendMember Role: ${widget.backendMember?.role}');
                      print('【成员详情页】传递 initialMemberId: ${widget.backendMember?.role.toLowerCase()}');
                      print('【成员详情页】传递 memberId: $memberId');
                      print('【成员详情页】传递 period: $period');
                      print('【成员详情页】传递 customDateRange: $customDateRange');
                      
                      if (_enableDebug) {
                        print('传递成员ID: $memberId, 期间: $period, 自定义范围: $customDateRange');
                      }
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionHistoryScreen(
                            initialMemberId: memberId, // 修改为直接传递成员ID
                            initialFilters: FilterOptions(
                              memberId: memberId,
                              period: period,
                              customDateRange: customDateRange,
                            ),
                          ),
                        ),
                      );
                      
                      // 【调试日志】确认修改后传递的参数
                      print('【成员详情页】修改后传递的 initialMemberId: $memberId');
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
  
  // 构建加载中的Widget
  Widget _buildLoadingWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
