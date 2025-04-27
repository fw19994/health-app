import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../themes/app_theme.dart';
import '../../../services/family_member_service.dart';
import '../../../models/family_member_model.dart';
import '../../../services/budget_service.dart';
import '../../../models/monthly_budget.dart';
import '../../../services/finance_service.dart';
import '../../../services/icon_service.dart';

import '../../expense_tracking_screen.dart';
import '../../finance_report_screen.dart';
import '../../member_finances/member_finances_screen.dart';
import '../../transaction_history/transaction_history_screen.dart';
import '../../budget_settings_screen.dart';
import '../../savings_goals_screen.dart';

import 'header_widget.dart';
import 'quick_actions_widget.dart';
import 'expense_categories_widget.dart';
import 'member_contributions_widget.dart';
import 'recent_expenses_widget.dart';
import 'budget_planning_widget.dart';
import 'savings_goals_widget.dart';
import 'models.dart';

class FamilyFinanceScreen extends StatefulWidget {
  const FamilyFinanceScreen({super.key});

  @override
  State<FamilyFinanceScreen> createState() => _FamilyFinanceScreenState();
}

class _FamilyFinanceScreenState extends State<FamilyFinanceScreen> {
  // 调试开关
  final bool _enableDebug = true;
  
  // 当前选择的月份 (默认为当前月份)
  DateTime _selectedMonth = DateTime.now();
  
  // 家庭成员数据
  List<FamilyMember> _familyMembers = [];
  bool _isLoadingMembers = true;
  
  // 月度预算数据
  MonthlyBudget? _monthlyBudget;
  bool _isLoadingBudget = true;
  
  // 支出分类数据
  List<ExpenseCategoryData> _expenseCategories = [];
  bool _isLoadingCategories = true;
  
  // 近期支出数据
  final List<FamilyExpense> _recentExpenses = [
    FamilyExpense(
      title: '房租',
      category: '住房',
      amount: 2800.0,
      date: DateTime.now().subtract(const Duration(days: 4)),
      payerName: '李明',
      icon: FontAwesomeIcons.home,
      iconBgColor: const Color(0xFFFEE2E2),
      iconColor: const Color(0xFFEF4444),
    ),
    FamilyExpense(
      title: '超市采购',
      category: '日常购物',
      amount: 486.30,
      date: DateTime.now().subtract(const Duration(days: 3)),
      payerName: '王丽',
      icon: FontAwesomeIcons.basketShopping,
      iconBgColor: const Color(0xFFDCFCE7),
      iconColor: const Color(0xFF3B82F6),
    ),
    FamilyExpense(
      title: '外出聚餐',
      category: '餐饮',
      amount: 358.0,
      date: DateTime.now(),
      payerName: '李明',
      icon: FontAwesomeIcons.utensils,
      iconBgColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFF59E0B),
    ),
    FamilyExpense(
      title: '牙医检查',
      category: '医疗',
      amount: 280.0,
      date: DateTime.now(),
      payerName: '王丽',
      icon: FontAwesomeIcons.heartPulse,
      iconBgColor: const Color(0xFFFCE7F3),
      iconColor: const Color(0xFFEC4899),
    ),
  ];
  
  // 预算规划数据
  final List<BudgetItem> _budgetItems = [
    BudgetItem(
      category: '住房',
      icon: FontAwesomeIcons.home,
      currentAmount: 3800.0,
      budgetAmount: 4000.0,
      isOverBudget: false,
    ),
    BudgetItem(
      category: '日常购物',
      icon: FontAwesomeIcons.cartShopping,
      currentAmount: 1720.0,
      budgetAmount: 1500.0,
      isOverBudget: true,
    ),
    BudgetItem(
      category: '餐饮',
      icon: FontAwesomeIcons.utensils,
      currentAmount: 1250.0,
      budgetAmount: 1500.0,
      isOverBudget: false,
    ),
    BudgetItem(
      category: '交通',
      icon: FontAwesomeIcons.car,
      currentAmount: 850.0,
      budgetAmount: 1000.0,
      isOverBudget: false,
    ),
    BudgetItem(
      category: '医疗',
      icon: FontAwesomeIcons.heartPulse,
      currentAmount: 520.0,
      budgetAmount: 600.0,
      isOverBudget: false,
    ),
  ];
  
  // 共同储蓄目标数据
  final List<SavingsGoal> _savingsGoals = [
    SavingsGoal(
      title: '家庭旅行',
      icon: FontAwesomeIcons.plane,
      currentAmount: 6450.0,
      targetAmount: 15000.0,
      deadline: DateTime(2025, 8, 1),
      color: const Color(0xFF3B82F6), // 蓝色
    ),
    SavingsGoal(
      title: '新电脑',
      icon: FontAwesomeIcons.laptop,
      currentAmount: 2240.0,
      targetAmount: 8000.0,
      deadline: DateTime(2025, 6, 30),
      color: const Color(0xFF8B5CF6), // 紫色
    ),
    SavingsGoal(
      title: '教育基金',
      icon: FontAwesomeIcons.graduationCap,
      currentAmount: 12500.0,
      targetAmount: 50000.0,
      deadline: DateTime(2028, 12, 31),
      color: const Color(0xFF10B981), // 绿色
    ),
  ];
  
  // 创建服务实例
  final FinanceService _financeService = FinanceService();
  final IconService _iconService = IconService();
  
  // 类变量定义部分添加总收入和总支出字段
  double _totalFamilyIncome = 0.0;
  double _totalFamilyExpense = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
    _loadMonthlyBudget();
    _loadExpenseCategories();
  }
  
  // 加载家庭成员数据
  Future<void> _loadFamilyMembers() async {
    setState(() {
      _isLoadingMembers = true;
    });
    
    try {
      final familyMemberService = FamilyMemberService(context: context);
      final response = await familyMemberService.getFamilyMembers();
      
      if (response.success && response.data != null) {
        setState(() {
          _familyMembers = response.data!;
          _isLoadingMembers = false;
        });
        
        // 加载成员后立即加载财务贡献数据
        _loadFamilyContributions();
      } else {
        setState(() {
          // 如果获取失败，使用默认数据
          _familyMembers = [
            FamilyMember(
              id: 1,
              ownerId: 1,
              userId: 1,
              name: '李明',
              nickname: '李明',
              description: '家庭主账户',
              phone: '',
              role: '我',
              gender: '男',
              avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
              joinTime: DateTime.now().toString(),
              permission: 'admin',
              isCurrentUser: true,
            ),
            FamilyMember(
              id: 2,
              ownerId: 1,
              userId: 2,
              name: '王丽',
              nickname: '王丽',
              description: '家庭成员',
              phone: '',
              role: '配偶',
              gender: '女',
              avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80',
              joinTime: DateTime.now().toString(),
              permission: 'member',
              isCurrentUser: false,
            ),
          ];
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      print('加载家庭成员失败: $e');
      setState(() {
        // 错误时使用默认数据
        _familyMembers = [
          FamilyMember(
            id: 1,
            ownerId: 1,
            userId: 1,
            name: '李明',
            nickname: '李明',
            description: '家庭主账户',
            phone: '',
            role: '我',
            gender: '男',
            avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
            joinTime: DateTime.now().toString(),
            permission: 'admin',
            isCurrentUser: true,
          ),
          FamilyMember(
            id: 2,
            ownerId: 1,
            userId: 2,
            name: '王丽',
            nickname: '王丽',
            description: '家庭成员',
            phone: '',
            role: '配偶',
            gender: '女',
            avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80',
            joinTime: DateTime.now().toString(),
            permission: 'member',
            isCurrentUser: false,
          ),
        ];
        _isLoadingMembers = false;
      });
    }
  }
  
  // 加载家庭成员财务贡献数据
  Future<void> _loadFamilyContributions() async {
    try {
      final response = await _financeService.getFamilyContributions(
        context: context,
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      );
      
      if (response.success && response.data != null) {
        print('成功加载家庭成员财务贡献数据: ${response.data}');
        
        // 解析数据并更新UI
        final Map<String, dynamic> data = response.data;
        final double totalIncome = data['total_income'] ?? 0.0;
        final double totalExpense = data['total_expense'] ?? 0.0;
        
        // 更新成员数据
        final List<dynamic> membersData = data['members'] ?? [];
        
        // 创建用户ID到财务数据的映射
        final Map<int, Map<String, dynamic>> memberFinanceMap = {};
        
        for (var memberData in membersData) {
          final int userId = memberData['user_id'];
          memberFinanceMap[userId] = {
            'income': memberData['income'] ?? 0.0,
            'expense': memberData['expense'] ?? 0.0,
            'balance': memberData['balance'] ?? 0.0,
            'income_percentage': memberData['income_percentage'] ?? 0.0,
            'expense_percentage': memberData['expense_percentage'] ?? 0.0,
          };
        }
        
        // 更新成员对象的财务数据
        for (var member in _familyMembers) {
          if (memberFinanceMap.containsKey(member.userId)) {
            member.financeData = memberFinanceMap[member.userId];
          }
        }
        
        // 更新UI
        setState(() {
          _totalFamilyIncome = totalIncome;
          _totalFamilyExpense = totalExpense;
        });
      }
    } catch (e) {
      print('加载家庭成员财务贡献数据失败: $e');
      // 发生错误时不更新UI，保持现有数据
    }
  }
  
  // 加载月度预算数据
  Future<void> _loadMonthlyBudget() async {
    setState(() {
      _isLoadingBudget = true;
    });
    
    try {
      final budgetService = BudgetService();
      final monthlyBudget = await budgetService.getMonthlyBudget(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
        context: context,
      );
      
      setState(() {
        _monthlyBudget = monthlyBudget;
        _isLoadingBudget = false;
      });
      
      print('成功加载月度预算: 总预算 ¥${_monthlyBudget?.totalBudget}, 已用 ¥${_monthlyBudget?.totalSpent}');
    } catch (e) {
      print('加载月度预算失败: $e');
      setState(() {
        _isLoadingBudget = false;
      });
    }
  }
  
  // 加载支出分类数据
  Future<void> _loadExpenseCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    
    try {
      // 获取当前月份的开始和结束时间
      final DateTime startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final DateTime endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
      
      if (_enableDebug) {
        print('正在获取支出分类数据，开始时间：$startDate，结束时间：$endDate');
      }
      
      // 调用API获取支出分析数据
      final response = await _financeService.getExpenseAnalysis(
        context: context,
        startDate: startDate,
        endDate: endDate,
      );
      
      print('获取支出分析数据响应：${response.success ? "成功" : "失败"}');
      
      if (response.success && response.data != null) {
        // 总是打印API返回的原始数据，因为这是关键信息
        print('API返回原始数据: ${response.data}');
        
        // 修正数据解析 - 直接使用data字段作为分类数组
        final List<dynamic> categoriesData = response.data['data'] ?? [];
        
        // 计算总金额
        double totalAmount = 0.0;
        for (var item in categoriesData) {
          totalAmount += (item['amount'] ?? 0.0).toDouble();
        }
        
        print('从API获取的分类数量: ${categoriesData.length}');
        print('计算得到的总金额: $totalAmount');
        
        // 调试输出每个分类项的详细信息
        if (_enableDebug && categoriesData.isNotEmpty) {
          print('--- 分类数据详情 ---');
          for (int i = 0; i < categoriesData.length; i++) {
            print('分类 #${i+1}: ${categoriesData[i]}');
          }
          print('------------------');
        }
        
        if (categoriesData.isEmpty) {
          print('API返回的分类数据为空');
          setState(() {
            _expenseCategories = [];
            _isLoadingCategories = false;
          });
          return;
        }
        
        // 预先加载所有图标数据
        final iconService = IconService();
        if (_enableDebug) {
          print('预先加载所有图标数据');
        }
        final allIcons = await iconService.getUserAvailableIcons(context: context);
        print('预加载了 ${allIcons.length} 个图标');
        
        // 临时存储分类数据
        final List<ExpenseCategoryData> categories = [];
        
        // 处理每个分类项 - 使用同步方式处理以保持顺序
        for (var item in categoriesData) {
          try {
            final String name = item['category_name'] ?? '未分类';
            final double amount = (item['amount'] ?? 0.0).toDouble();
            final double percentage = totalAmount > 0 
                ? (amount / totalAmount * 100) 
                : 0.0;
            
            // 获取图标ID
            final int iconId = item['icon_id'] ?? 0;
            
            if (_enableDebug) {
              print('处理分类[$name]，金额=$amount，百分比=$percentage，图标ID=$iconId');
            }
            
            // 从预加载的图标中查找匹配的图标
            var iconModel = allIcons.where((icon) => icon.id == iconId).toList();
            var foundIcon = iconModel.isNotEmpty ? iconModel.first : null;
            
            // 如果预加载的图标列表中没有找到，则单独加载
            if (foundIcon == null) {
              if (_enableDebug) {
                print('未在预加载的图标中找到ID=$iconId的图标，准备单独加载');
              }
              foundIcon = await iconService.getIconById(iconId, context: context);
            }
            
            if (_enableDebug) {
              if (foundIcon != null) {
                print('最终使用的图标：ID=${foundIcon.id}, 名称=${foundIcon.name}，颜色=${foundIcon.colorCode}');
              } else {
                print('未找到图标，将使用默认图标');
              }
            }
            
            // 创建分类数据模型
            categories.add(ExpenseCategoryData(
              name: name,
              icon: foundIcon?.icon,
              amount: amount,
              percentage: percentage,
              color: foundIcon?.color,
              iconId: iconId,
            ));
          } catch (e) {
            print('处理分类项时出错: $e');
            // 添加一个默认项以避免整个列表为空
            categories.add(ExpenseCategoryData.safe(
              name: '处理错误',
              amount: 0,
              percentage: 0,
              iconId: 0,
            ));
          }
        }
        
        print('成功处理${categories.length}个支出分类');
        
        // 确保在主线程中更新UI
        if (mounted) {
          setState(() {
            _expenseCategories = categories;
            _isLoadingCategories = false;
          });
          
          print('已更新UI，当前分类数据长度: ${_expenseCategories.length}');
        }
      } else {
        print('加载支出分类失败: ${response.message}');
        if (mounted) {
          setState(() {
            _isLoadingCategories = false;
          });
        }
      }
    } catch (e) {
      print('加载支出分类异常: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }
  
  // 选择月份
  void _selectMonth(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
    _loadMonthlyBudget();
    _loadExpenseCategories(); // 同时刷新支出分类数据
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // 头部区域
          FamilyFinanceHeader(
            selectedMonth: _selectedMonth,
            familyMembers: _familyMembers,
            isLoadingMembers: _isLoadingMembers,
            monthlyBudget: _monthlyBudget,
            onMonthSelected: _selectMonth,
            onBack: () => Navigator.pop(context),
          ),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 快捷操作
                    QuickActionsWidget(
                      onAddExpense: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ExpenseTrackingScreen()),
                        );
                      },
                      onViewReport: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FinanceReportScreen()),
                        );
                      },
                      onMemberAnalysis: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MemberFinancesScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 支出分类
                    ExpenseCategoriesWidget(
                      categories: _expenseCategories,
                      isLoading: _isLoadingCategories,
                      onRefresh: _loadExpenseCategories,
                    ),
                    const SizedBox(height: 16),
                    
                    // 家庭成员贡献
                    MemberContributionsWidget(
                      members: _familyMembers,
                      isLoading: _isLoadingMembers,
                      totalIncome: _totalFamilyIncome,
                      totalExpense: _totalFamilyExpense,
                      onViewDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MemberFinancesScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 近期支出
                    RecentExpensesWidget(
                      expenses: _recentExpenses,
                      onViewAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 预算规划
                    BudgetPlanningWidget(
                      budgetItems: _budgetItems,
                      onEdit: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const BudgetSettingsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 储蓄目标
                    SavingsGoalsWidget(
                      goals: _savingsGoals,
                      onAddGoal: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
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