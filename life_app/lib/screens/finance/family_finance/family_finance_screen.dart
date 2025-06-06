import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../themes/app_theme.dart';
import '../../../services/family_member_service.dart';
import '../../../models/family_member_model.dart';
import '../../../services/budget_service.dart';
import '../../../models/monthly_budget.dart';
import '../../../services/finance_service.dart';
import '../../../services/icon_service.dart';
import '../../../services/api_service.dart';

import '../../expense_tracking_screen.dart';
import '../../finance_report_screen.dart';
import '../../member_finances/member_finances_screen.dart';
import '../../transaction_history/transaction_history_screen.dart';
import '../../budget_settings_screen.dart';
import '../../savings_goals_screen.dart';
import '../../member_detail/member_detail_screen.dart';
import '../../member_finances/models/family_member.dart' as detail_model;

import 'header_widget.dart';
import 'quick_actions_widget.dart';
import 'expense_categories_widget.dart';
import 'member_contributions_widget.dart';
import 'recent_expenses_widget.dart';
import 'budget_planning_widget.dart';
import 'savings_goals_widget.dart';
import 'models.dart';
import '../../../models/savings_goal.dart';

class FamilyFinanceScreen extends StatefulWidget {
  final int familyId;
  
  const FamilyFinanceScreen({
    super.key, 
    required this.familyId,
  });

  @override
  State<FamilyFinanceScreen> createState() => _FamilyFinanceScreenState();
}

class _FamilyFinanceScreenState extends State<FamilyFinanceScreen> with WidgetsBindingObserver {
  // 调试开关
  final bool _enableDebug = true;
  
  // 当前家庭ID
  late int _familyId;
  
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
  List<FamilyExpense> _recentExpenses = [];
  bool _isLoadingRecentExpenses = true;
  
  // 预算规划数据
  List<BudgetItem> _budgetItems = [];
  
  // 储蓄目标数据
  List<SavingsGoal> _savingsGoals = []; // 初始为空列表，从后端加载
  bool _isLoadingSavingsGoals = true;
  
  // 创建服务实例
  final FinanceService _financeService = FinanceService();
  final IconService _iconService = IconService();
  final BudgetService _budgetService = BudgetService(); // 添加BudgetService实例
  final ApiService _api = ApiService(); // 添加ApiService实例
  
  // 类变量定义部分添加总收入和总支出字段
  double _totalFamilyIncome = 0.0;
  double _totalFamilyExpense = 0.0;
  
  @override
  void initState() {
    super.initState();
    // 初始化家庭ID
    _familyId = widget.familyId;
    // 注册生命周期监听器
    WidgetsBinding.instance.addObserver(this);
    // 加载数据
    _loadFamilyMembers();
    _loadMonthlyBudget();
    _loadExpenseCategories();
    _loadRecentExpenses();
    _loadBudgetPlanningData();
    _loadFamilySavingsGoals(); // 添加加载家庭储蓄目标
  }
  
  @override
  void dispose() {
    // 注销生命周期监听器
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  // 实现生命周期回调
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('页面恢复，刷新数据');
      _refreshAllData();
    }
  }
  
  // 页面依赖变化时的回调
  bool _firstLoad = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 避免首次加载时重复刷新
    if (!_firstLoad) {
      print('页面依赖变化，刷新数据');
      _refreshAllData();
    }
    _firstLoad = false;
  }
  
  // 封装刷新所有数据的方法
  void _refreshAllData() {
    _loadMonthlyBudget();
    _loadExpenseCategories();
    _loadRecentExpenses();
    _loadFamilyContributions();
    _loadBudgetPlanningData();
    _loadFamilySavingsGoals(); // 添加刷新家庭储蓄目标
  }
  
  // 加载家庭成员数据
  Future<void> _loadFamilyMembers() async {
    setState(() {
      _isLoadingMembers = true;
    });
    
    try {
      final familyMemberService = FamilyMemberService(context: context);
      final response = await familyMemberService.getFamilyMembers(
        familyId: _familyId, // 传递家庭ID
      );
      
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
        familyId: _familyId, // 传递家庭ID
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
        
        print('API返回的成员数据数量: ${membersData.length}');
        
        // 创建ID到财务数据的多种映射
        final Map<int, Map<String, dynamic>> memberIdMap = {}; // 成员ID映射
        final Map<int, Map<String, dynamic>> userIdMap = {}; // 用户ID映射
        final Map<String, Map<String, dynamic>> nameMap = {}; // 名称映射
        
        // 打印每个成员的数据以进行调试
        if (_enableDebug) {
          print('--- API返回的成员财务数据 ---');
          for (int i = 0; i < membersData.length; i++) {
            print('成员 #${i+1}: ${membersData[i]}');
          }
          print('---------------------------');
        }
        
        for (var memberData in membersData) {
          // 获取各种可能的标识符
          final int userId = memberData['user_id'] is int 
              ? memberData['user_id'] 
              : int.tryParse(memberData['user_id']?.toString() ?? '0') ?? 0;
          
          final int memberId = memberData['id'] is int 
              ? memberData['id'] 
              : int.tryParse(memberData['id']?.toString() ?? '0') ?? 0;
          
          final String memberName = memberData['name']?.toString() ?? '';
          
          // 创建财务数据对象
          final financeData = {
            'income': (memberData['income'] ?? 0.0).toDouble(),
            'expense': (memberData['expense'] ?? 0.0).toDouble(),
            'balance': (memberData['balance'] ?? 0.0).toDouble(),
            'income_percentage': (memberData['income_percentage'] ?? 0.0).toDouble(),
            'expense_percentage': (memberData['expense_percentage'] ?? 0.0).toDouble(),
          };
          
          // 将数据添加到所有映射表中
          if (userId > 0) {
            userIdMap[userId] = financeData;
          }
          
          if (memberId > 0) {
            memberIdMap[memberId] = financeData;
          }
          
          if (memberName.isNotEmpty) {
            nameMap[memberName.toLowerCase()] = financeData;
          }
          
          print('处理成员财务数据: 用户ID=$userId, 成员ID=$memberId, 姓名=$memberName');
        }
        
        print('当前家庭成员列表:');
        for (var member in _familyMembers) {
          print('成员: ID=${member.id}, 用户ID=${member.userId}, 姓名=${member.name}, 角色=${member.role}');
        }
        
        // 更新成员对象的财务数据
        bool anyMemberUpdated = false;
        for (var member in _familyMembers) {
          // 尝试多种方式匹配成员
          Map<String, dynamic>? financeData;
          
          // 1. 尝试通过用户ID匹配
          if (member.userId != null && userIdMap.containsKey(member.userId)) {
            financeData = userIdMap[member.userId];
            print('通过用户ID=${member.userId}匹配到财务数据: $financeData');
          }
          // 2. 尝试通过成员ID匹配
          else if (memberIdMap.containsKey(member.id)) {
            financeData = memberIdMap[member.id];
            print('通过成员ID=${member.id}匹配到财务数据: $financeData');
          }
          // 3. 尝试通过姓名匹配
          else if (nameMap.containsKey(member.name.toLowerCase())) {
            financeData = nameMap[member.name.toLowerCase()];
            print('通过姓名=${member.name}匹配到财务数据: $financeData');
          }
          // 4. 尝试通过昵称匹配
          else if (member.nickname.isNotEmpty && nameMap.containsKey(member.nickname.toLowerCase())) {
            financeData = nameMap[member.nickname.toLowerCase()];
            print('通过昵称=${member.nickname}匹配到财务数据: $financeData');
          }
          
          // 更新成员财务数据
          if (financeData != null) {
            member.financeData = financeData;
            anyMemberUpdated = true;
            print('成功更新成员 ${member.name} 的财务数据');
          } else {
            print('警告: 未找到成员 ${member.name} 的财务数据');
            // 设置默认财务数据以防止UI错误
            member.financeData = {
              'income': 0.0,
              'expense': 0.0,
              'balance': 0.0,
              'income_percentage': 0.0,
              'expense_percentage': 0.0,
            };
          }
        }
        
        // 只有当有成员数据更新时才刷新UI
        if (anyMemberUpdated || totalIncome != _totalFamilyIncome || totalExpense != _totalFamilyExpense) {
          setState(() {
            _totalFamilyIncome = totalIncome;
            _totalFamilyExpense = totalExpense;
          });
          print('已更新家庭财务数据, 总收入: $totalIncome, 总支出: $totalExpense');
        }
      }
    } catch (e) {
      print('加载家庭成员财务贡献数据失败: $e');
      // 发生错误时为所有成员设置默认财务数据
      for (var member in _familyMembers) {
        if (member.financeData == null) {
          member.financeData = {
            'income': 0.0,
            'expense': 0.0,
            'balance': 0.0,
            'income_percentage': 0.0,
            'expense_percentage': 0.0,
          };
        }
      }
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
        familyId: _familyId, // 传递家庭ID
        isFamilyBudget: true, // 确保使用家庭预算标识
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
        familyId: _familyId, // 传递家庭ID
        startDate: startDate,
        endDate: endDate,
        isFamilyBudget: true, // 添加家庭预算标识
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
  
  // 加载近期支出数据
  Future<void> _loadRecentExpenses() async {
    setState(() {
      _isLoadingRecentExpenses = true;
    });
    
    try {
      // 调用API获取近期交易
      final response = await _financeService.getRecentTransactions(
        context: context,
        type: 'expense', // 只获取支出类型的交易
        isFamilyBudget: true, // 添加家庭预算标识
        familyId: _familyId, // 添加家庭ID
        limit: 5, // 获取5条记录
      );
      
      if (_enableDebug) {
        print('获取近期支出响应：${response.success ? "成功" : "失败"}');
        if (response.success && response.data != null) {
          print('近期支出数据: ${response.data}');
        }
      }
      
      if (response.success && response.data != null) {
        final List<dynamic> transactionsData = response.data ?? [];
        final List<FamilyExpense> expenses = [];
        
        // 预先加载所有图标数据
        final iconService = IconService();
        final allIcons = await iconService.getUserAvailableIcons(context: context);
        
        // 先确保成员信息已加载
        if (_familyMembers.isEmpty) {
          print('警告: 家庭成员列表为空，需要先加载成员数据');
          await _loadFamilyMembers();
        }
        
        // 调试日志 - 打印已加载的所有家庭成员
        if (_enableDebug) {
          print('当前已加载的家庭成员列表:');
          for (var member in _familyMembers) {
            print('成员ID=${member.id}, 名称=${member.name}, 角色=${member.role}');
          }
        }
        
        for (var item in transactionsData) {
          try {
            final String title = item['merchant'] ?? item['notes'] ?? '未命名支出';
            final String category = item['category_name'] ?? '未分类';
            final double amount = (item['amount'] ?? 0.0).toDouble();
            final DateTime date = item['date'] != null
                ? DateTime.parse(item['date'])
                : DateTime.now();
            
            // 获取支付人信息
            final int recorderId = item['recorder_id'] ?? 0;
            
            if (_enableDebug) {
              print('处理交易项: title=$title, recorderId=$recorderId');
            }
            
            String payerName = '未知';
            String avatarUrl = '';
            
            // 直接使用id字段与recorder_id匹配
            if (recorderId > 0) {
              var memberMatch = _familyMembers.where((m) => m.id == recorderId).toList();
              if (memberMatch.isNotEmpty) {
                payerName = memberMatch.first.nickname.isNotEmpty 
                    ? memberMatch.first.nickname 
                    : memberMatch.first.name;
                avatarUrl = memberMatch.first.avatarUrl;
                if (_enableDebug) {
                  print('找到匹配成员: ${memberMatch.first.name}, ID=${memberMatch.first.id}, 头像=${memberMatch.first.avatarUrl}');
                }
              } else {
                if (_enableDebug) {
                  print('未找到ID为 $recorderId 的成员');
                }
                // 保留API返回的原始名称
                payerName = item['recorder_name'] ?? '未知';
              }
            } else {
              if (_enableDebug) {
                print('recorderId无效，使用API返回的名称');
              }
              payerName = item['recorder_name'] ?? '未知';
            }
            
            final String notes = item['notes'] ?? '';
            
            // 获取图标信息
            final int iconId = item['icon_id'] ?? 0;
            var iconData = FontAwesomeIcons.receipt;
            var iconColor = const Color(0xFF3B82F6);
            var iconBgColor = const Color(0xFFDCFCE7);
            var iconName = '';
            
            if (iconId > 0) {
              var iconModel = allIcons.where((icon) => icon.id == iconId).toList();
              var foundIcon = iconModel.isNotEmpty ? iconModel.first : null;
              
              if (foundIcon != null) {
                iconData = foundIcon.icon;
                iconColor = foundIcon.color;
                iconBgColor = foundIcon.color.withOpacity(0.1);
                iconName = foundIcon.name ?? '';
              }
            }
            
            // 创建支出数据
            expenses.add(FamilyExpense(
              title: title,
              category: category,
              amount: amount,
              date: date,
              payerName: payerName,
              payerId: recorderId,
              avatarUrl: avatarUrl,
              icon: iconData,
              iconColor: iconColor,
              iconBgColor: iconBgColor,
              iconName: iconName,
              notes: notes,
            ));
          } catch (e) {
            print('处理近期支出项时出错: $e');
          }
        }
        
        // 排序：按日期从新到旧
        expenses.sort((a, b) => b.date.compareTo(a.date));
        
        // 限制显示数量为最近的4条
        final recentExpenses = expenses.take(4).toList();
        
        setState(() {
          _recentExpenses = recentExpenses;
          _isLoadingRecentExpenses = false;
        });
      } else {
        print('加载近期支出失败: ${response.message}');
        setState(() {
          _isLoadingRecentExpenses = false;
        });
      }
    } catch (e) {
      print('加载近期支出异常: $e');
      setState(() {
        _isLoadingRecentExpenses = false;
      });
    }
  }
  
  // 加载家庭预算规划数据
  Future<void> _loadBudgetPlanningData() async {
    try {
      if (_enableDebug) {
        print('正在加载家庭预算规划数据...');
      }
      
      // 使用BudgetService获取预算类别
      final budgetService = BudgetService();
      final budgetCategories = await budgetService.getBudgetCategories(
        context: context,
        isFamilyBudget: true, // 重要：指定获取家庭预算
        familyId: _familyId, // 添加家庭ID
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      );
      
      if (_enableDebug) {
        print('成功获取家庭预算数据，共 ${budgetCategories.length} 项');
      }
      
      // 创建预算项列表
      List<BudgetItem> budgetItems = [];
      
      // 使用IconService获取所有图标，用于查找对应的图标
      final iconService = IconService();
      final allIcons = await iconService.getUserAvailableIcons(context: context);
      
      for (var category in budgetCategories) {
        // 查找对应的图标
        IconData icon = FontAwesomeIcons.moneyBill; // 默认图标
        Color iconColor = const Color(0xFF6B7280); // 默认颜色
        
        final iconList = allIcons.where((i) => i.id == category.iconId).toList();
        if (iconList.isNotEmpty) {
          icon = iconList.first.icon;
          iconColor = iconList.first.color;
        }
        
        // 判断是否超出预算
        bool isOverBudget = category.spent > category.budget;
        
        // 创建预算项
        budgetItems.add(BudgetItem(
          category: category.name,
          icon: icon,
          currentAmount: category.spent,
          budgetAmount: category.budget,
          isOverBudget: isOverBudget,
          isFamilyBudget: true,
          iconColor: iconColor,
        ));
      }
      
      // 更新UI
      setState(() {
        _budgetItems = budgetItems;
      });
    } catch (e) {
      print('加载家庭预算规划数据失败: $e');
      
      // 如果加载失败，使用默认数据
      if (_budgetItems.isEmpty) {
        setState(() {
          _budgetItems = [
            BudgetItem(
              category: '住房',
              icon: FontAwesomeIcons.home,
              currentAmount: 3800.0,
              budgetAmount: 4000.0,
              isOverBudget: false,
              isFamilyBudget: true,
              iconColor: const Color(0xFF2563EB), // 蓝色
            ),
            BudgetItem(
              category: '日常购物',
              icon: FontAwesomeIcons.cartShopping,
              currentAmount: 1720.0,
              budgetAmount: 1500.0,
              isOverBudget: true,
              isFamilyBudget: true,
              iconColor: const Color(0xFF16A34A), // 绿色
            ),
            BudgetItem(
              category: '餐饮',
              icon: FontAwesomeIcons.utensils,
              currentAmount: 1250.0,
              budgetAmount: 1500.0,
              isOverBudget: false,
              isFamilyBudget: true,
              iconColor: const Color(0xFFEF4444), // 红色
            ),
          ];
        });
      }
    }
  }
  
  // 加载家庭储蓄目标数据
  Future<void> _loadFamilySavingsGoals() async {
    setState(() {
      _isLoadingSavingsGoals = true;
    });
    
    try {
      if (_enableDebug) {
        print('正在加载家庭储蓄目标数据...');
      }
      
      // 我们需要使用ApiService直接获取家庭储蓄目标数据
      // 构建查询参数字典
      Map<String, String> queryParams = {
        'is_family_savings': 'true', // 添加家庭标识
        'family_id': _familyId.toString(), // 添加家庭ID
      };
      
      // 请求API获取家庭储蓄目标
      final response = await _api.get(
        path: '/api/v1/savings/goals',
        params: queryParams,
        context: context,
      );
      
      if (_enableDebug) {
        print('储蓄目标API响应: ${response['code']}, message=${response['message']}');
      }
      
      if (response['code'] != 0) {
        throw Exception(response['message'] ?? '获取家庭储蓄目标失败');
      }
      
      // 解析返回的数据
      final List<dynamic> data = response['data'] ?? [];
      
      // 处理data为空的情况
      if (data.isEmpty) {
        if (_enableDebug) {
          print('API返回的家庭储蓄目标列表为空');
        }
        setState(() {
          _savingsGoals = [];
          _isLoadingSavingsGoals = false;
        });
        return;
      }
      
      // 解析每个储蓄目标
      final familyGoals = <SavingsGoal>[];
      for (var item in data) {
        try {
          final goal = SavingsGoal.fromJson(item);
          await goal.loadRealIcon(context: context);
          familyGoals.add(goal);
        } catch (e) {
          print('解析家庭储蓄目标失败: $e, 数据: $item');
          // 继续处理下一个，不中断
        }
      }
      
      if (_enableDebug) {
        print('成功加载家庭储蓄目标: ${familyGoals.length}个');
      }
      
      if (mounted) {
        setState(() {
          _savingsGoals = familyGoals;
          _isLoadingSavingsGoals = false;
        });
      }
    } catch (e) {
      print('加载家庭储蓄目标异常: $e');
      
      // 使用默认数据
      if (_savingsGoals.isEmpty) {
        setState(() {
          _savingsGoals = _getDefaultSavingsGoals();
          _isLoadingSavingsGoals = false;
        });
      }
    }
  }
  
  // 获取默认的储蓄目标数据
  List<SavingsGoal> _getDefaultSavingsGoals() {
    return [
      SavingsGoal(
        id: '1',
        name: '家庭旅行',
        icon: FontAwesomeIcons.plane,
        color: const Color(0xFF3B82F6), // 蓝色
        targetAmount: 15000.0,
        currentAmount: 6450.0,
        monthlyTarget: 2000.0,
        targetDate: DateTime(2025, 8, 1),
        iconId: 1,
        colorCode: '#3B82F6',
        isFamilySavings: true, // 设置为家庭储蓄目标
      ),
      SavingsGoal(
        id: '2',
        name: '新电脑',
        icon: FontAwesomeIcons.laptop,
        color: const Color(0xFF8B5CF6), // 紫色
        targetAmount: 8000.0,
        currentAmount: 2240.0,
        monthlyTarget: 1000.0,
        targetDate: DateTime(2025, 6, 30),
        iconId: 2,
        colorCode: '#8B5CF6',
        isFamilySavings: true, // 设置为家庭储蓄目标
      ),
      SavingsGoal(
        id: '3',
        name: '教育基金',
        icon: FontAwesomeIcons.graduationCap,
        color: const Color(0xFF10B981), // 绿色
        targetAmount: 50000.0,
        currentAmount: 12500.0,
        monthlyTarget: 3000.0,
        targetDate: DateTime(2028, 12, 31),
        iconId: 3,
        colorCode: '#10B981',
        isFamilySavings: true, // 设置为家庭储蓄目标
      ),
    ];
  }
  
  // 选择月份
  void _selectMonth(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
    _loadMonthlyBudget();
    _loadExpenseCategories(); // 同时刷新支出分类数据
    _loadBudgetPlanningData(); // 刷新家庭预算规划数据
  }
  
  // 构建快捷操作区域
  Widget _buildQuickActions() {
    return QuickActionsWidget(
      familyId: _familyId, // 传递家庭ID
      onAddExpense: () {
        // 刷新数据
        _refreshAllData();
      },
      onViewReport: () {
        // 跳转到财务报告页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FinanceReportScreen(
              familyId: _familyId,
              isFamilyReport: true,
            ),
          ),
        );
      },
      onMemberAnalysis: () {
        // 跳转到成员财务页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberFinancesScreen(
              familyId: _familyId,
            ),
          ),
        );
      },
    );
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
            onBack: () {
              // 注意：从本页面返回时不需要刷新，因为回到首页了
              Navigator.pop(context);
            },
            familyId: _familyId, // 传递家庭ID
          ),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 快捷操作
                    _buildQuickActions(),
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
                      onMemberDetails: (member) {
                        // 导航到成员财务详情页面
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              // 创建MemberDetailScreen需要的FamilyMember模型
                              final detailMember = detail_model.FamilyMember(
                                name: member.nickname.isNotEmpty ? member.nickname : member.name,
                                role: member.role,
                                income: member.income,
                                expenses: member.expense,
                                budget: member.income > 0 ? member.income * 0.8 : 5000, // 预算为收入的80%或默认值
                                savingsRate: member.income > 0 ? ((member.income - member.expense) / member.income * 100) : 0,
                                budgetUsage: member.income > 0 ? (member.expense / (member.income * 0.8) * 100) : 0,
                                incomeChange: 5.0, // 默认值
                                expensesChange: 3.0, // 默认值
                                color: const Color(0xFF3B82F6), // 默认蓝色
                                icon: FontAwesomeIcons.user,
                                avatarBgColor: const Color(0xFFDBEAFE),
                                incomeContribution: member.incomePercentage,
                                expenseContribution: member.expensePercentage,
                                mainConsumption: '主要消费',
                              );
                              
                              return MemberDetailScreen(
                                member: detailMember,
                                backendMember: member,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 近期支出
                    RecentExpensesWidget(
                      expenses: _recentExpenses,
                      isLoading: _isLoadingRecentExpenses,
                      onViewAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TransactionHistoryScreen(
                            familyId: _familyId, // 传递家庭ID到交易记录页面
                          )),
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
                          MaterialPageRoute(
                            builder: (context) => BudgetSettingsScreen(
                              isFamilyBudget: true,
                              familyId: _familyId, // 传递家庭ID
                            ),
                          ),
                        ).then((_) => _loadBudgetPlanningData()); // 返回时刷新数据
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 储蓄目标
                    SavingsGoalsWidget(
                      goals: _savingsGoals,
                      isLoading: _isLoadingSavingsGoals,
                      onAddGoal: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SavingsGoalsScreen(
                              isFamilySavings: true, // 设置为家庭储蓄目标
                              familyId: _familyId, // 传递家庭ID
                            ),
                          ),
                        ).then((_) => _loadFamilySavingsGoals()); // 返回时刷新数据
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