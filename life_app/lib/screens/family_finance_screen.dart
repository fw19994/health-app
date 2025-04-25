import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../themes/app_theme.dart';
import 'family_members_screen.dart';
import 'finance_report_screen.dart';
import 'member_finances/member_finances_screen.dart';
import 'transaction_history/transaction_history_screen.dart';
import 'expense_tracking_screen.dart';
import '../services/family_member_service.dart';
import '../models/family_member_model.dart';
import '../services/budget_service.dart';
import '../models/monthly_budget.dart';

class FamilyFinanceScreen extends StatefulWidget {
  const FamilyFinanceScreen({super.key});

  @override
  State<FamilyFinanceScreen> createState() => _FamilyFinanceScreenState();
}

class _FamilyFinanceScreenState extends State<FamilyFinanceScreen> {
  // 当前选择的月份 (默认为当前月份)
  DateTime _selectedMonth = DateTime.now();
  
  // 家庭成员数据
  List<FamilyMember> _familyMembers = [];
  bool _isLoadingMembers = true;
  
  // 月度预算数据
  MonthlyBudget? _monthlyBudget;
  bool _isLoadingBudget = true;
  
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
  
  // 支出类别数据
  final List<ExpenseCategory> _expenseCategories = [
    ExpenseCategory(
      name: '住房',
      icon: FontAwesomeIcons.home,
      amount: 3800.0,
      percentage: 44.5,
      color: const Color(0xFFEF4444), // 红色
    ),
    ExpenseCategory(
      name: '日常购物',
      icon: FontAwesomeIcons.cartShopping,
      amount: 1720.0,
      percentage: 20.2,
      color: const Color(0xFF3B82F6), // 蓝色
    ),
    ExpenseCategory(
      name: '餐饮',
      icon: FontAwesomeIcons.utensils,
      amount: 1250.0,
      percentage: 14.7,
      color: const Color(0xFFF59E0B), // 琥珀色
    ),
    ExpenseCategory(
      name: '交通',
      icon: FontAwesomeIcons.car,
      amount: 850.0,
      percentage: 10.0,
      color: const Color(0xFF10B981), // 绿色
    ),
    ExpenseCategory(
      name: '医疗',
      icon: FontAwesomeIcons.heartPulse,
      amount: 520.0,
      percentage: 6.1,
      color: const Color(0xFFEC4899), // 粉色
    ),
    ExpenseCategory(
      name: '其他',
      icon: FontAwesomeIcons.ellipsis,
      amount: 390.0,
      percentage: 4.5,
      color: const Color(0xFF6B7280), // 灰色
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
  
  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
    _loadMonthlyBudget();
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
  
  // 选择月份
  void _selectMonth(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
    _loadMonthlyBudget();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildCategorySpending(),
                    const SizedBox(height: 16),
                    _buildMemberContribution(),
                    const SizedBox(height: 16),
                    _buildRecentExpenses(),
                    const SizedBox(height: 16),
                    _buildBudgetPlanning(),
                    const SizedBox(height: 16),
                    _buildSavingsGoals(),
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
  
  // 头部绿色区域
  Widget _buildHeader() {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // 格式化月份显示
    final monthFormat = DateFormat('MM月', 'zh_CN');
    final currentMonth = monthFormat.format(_selectedMonth);
    
    // 使用月度预算数据
    double totalExpense = _monthlyBudget?.totalSpent ?? 0.0;
    double budget = _monthlyBudget?.totalBudget ?? 0.0;
    double remaining = _monthlyBudget?.remainingAmount ?? 0.0;
    double usagePercent = _monthlyBudget?.usagePercent ?? 0.0;  // 使用double而不是int
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 5, 16, 16), // 使用状态栏高度加上最小距离
      decoration: const BoxDecoration(
        color: Color(0xFF059669), // 更改为UI设计中的bg-green-600颜色
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题、返回按钮和成员列表放在同一行
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                '家庭财务',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 使成员列表靠右对齐
                  children: [
                    if (_isLoadingMembers)
                      // 加载中显示圆形进度条
                      Container(
                        width: 36,
                        height: 36,
                        padding: const EdgeInsets.all(4),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      // 显示家庭成员头像
                      for (var member in _familyMembers)
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: CircleAvatar(
                            radius: 18, // 增大外圈半径
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 16, // 增大内圈半径
                              backgroundImage: member.avatarUrl.isNotEmpty 
                                ? NetworkImage(member.avatarUrl) 
                                : null,
                              child: member.avatarUrl.isEmpty
                                ? Text(
                                    member.name.isNotEmpty ? member.name[0] : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                              backgroundColor: member.avatarUrl.isEmpty 
                                ? Colors.blueGrey 
                                : null,
                            ),
                          ),
                        ),
                    // 添加成员按钮
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FamilyMembersScreen()),
                        ).then((_) {
                          // 返回时重新加载成员数据
                          _loadFamilyMembers();
                        });
                      },
                      child: Container(
                        width: 36, // 增大按钮尺寸
                        height: 36, // 增大按钮尺寸
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // 更改为与顶部颜色协调的绿色
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20, // 增大图标尺寸
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // 减少垂直间距
          const Text(
            '共同管理家庭收支',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10), // 减少垂直间距
          
          // 月度摘要
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '月家庭总开销',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showMonthPicker(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currentMonth,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _isLoadingBudget
                  ? const SizedBox(
                      height: 24, 
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      )
                    )
                  : Row(
                      children: [
                        const SizedBox(width: 30), // 左侧间距，让内容向中间靠
                        
                        // 左侧：总开销
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center, // 居中对齐
                            children: [
                              const Text(
                                '总开销',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${_monthlyBudget?.totalSpent ?? 0}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 中间分隔线
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          height: 40,
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        
                        // 右侧：总预算
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center, // 居中对齐
                            children: [
                              const Text(
                                '总预算',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${_monthlyBudget?.totalBudget ?? 0}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 30), // 右侧间距，让内容向中间靠
                      ],
                    ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已用预算: ${_monthlyBudget?.usagePercent ?? 0}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '剩余: ¥${_monthlyBudget?.remainingAmount ?? 0}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 进度条
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: usagePercent / 100,  // 使用原始百分比值
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 显示月份选择器
  void _showMonthPicker(BuildContext context) async {
    // 这里可以实现月份选择器的弹窗
    // 简单实现，实际项目中可以使用更好的月份选择器库
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (picked != null && picked != _selectedMonth) {
      _selectMonth(picked);
    }
  }

  // 快捷操作区域
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: FontAwesomeIcons.plus,
            label: '添加支出',
            color: const Color(0xFF16A34A),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExpenseTrackingScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: FontAwesomeIcons.chartColumn,
            label: '分析报告',
            color: const Color(0xFF8B5CF6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FinanceReportScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: FontAwesomeIcons.userGroup,
            label: '成员分析',
            color: const Color(0xFF10B981),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MemberFinancesScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 家庭支出分类
  Widget _buildCategorySpending() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '家庭支出分类',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 导航到完整的支出分类页面
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF16A34A),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _expenseCategories.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildCategoryProgressBar(_expenseCategories[index]),
            ),
          ),
        ],
      ),
    );
  }

  // 类别进度条
  Widget _buildCategoryProgressBar(ExpenseCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FaIcon(
                  category.icon,
                  color: category.color,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            Text(
              '¥${category.amount.toStringAsFixed(0)} (${category.percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: category.percentage / 100,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 家庭成员贡献
  Widget _buildMemberContribution() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '家庭成员贡献',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MemberFinancesScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF16A34A),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '查看详细分析',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 成员列表
          if (_isLoadingMembers)
            // 加载中显示骨架屏
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_familyMembers.isEmpty)
            // 没有成员时显示提示
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '暂无家庭成员数据',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              _familyMembers.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildMemberContributionItem(_familyMembers[index], index),
              ),
            ),
          
          // 结余状态
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '目前结余状态',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Text(
                  '平衡',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 成员贡献项
  Widget _buildMemberContributionItem(FamilyMember member, int index) {
    // 为不同成员使用不同颜色
    final List<Color> memberColors = [
      const Color(0xFF6366F1), // 靛蓝色
      const Color(0xFFEC4899), // 粉色
      const Color(0xFFF59E0B), // 琥珀色
      const Color(0xFF10B981), // 绿色
    ];
    
    final color = memberColors[index % memberColors.length];
    
    // 计算财务贡献数据（这里使用模拟数据，实际应从API获取）
    final double contribution = index == 0 ? 4730.25 : 3800.20;
    final double contributionPercentage = index == 0 ? 55.4 : 44.6;
    
    return Row(
      children: [
        // 成员头像
        CircleAvatar(
          radius: 24,
          backgroundImage: member.avatarUrl.isNotEmpty 
            ? NetworkImage(member.avatarUrl) 
            : null,
          child: member.avatarUrl.isEmpty
            ? Text(
                member.name.isNotEmpty ? member.name[0] : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            : null,
          backgroundColor: member.avatarUrl.isEmpty 
            ? Colors.blueGrey 
            : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 成员名称和关系
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                      children: [
                        TextSpan(text: member.name),
                        TextSpan(
                          text: ' (${member.role})',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 贡献金额和百分比
                  Text(
                    '¥${contribution.toStringAsFixed(2)} (${contributionPercentage.toStringAsFixed(1)}%)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 贡献进度条
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: contributionPercentage / 100,  // 直接使用原始百分比
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 近期家庭支出
  Widget _buildRecentExpenses() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '近期家庭支出',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF16A34A),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 近期支出列表
          ...List.generate(
            _recentExpenses.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildExpenseItem(_recentExpenses[index]),
            ),
          ),
        ],
      ),
    );
  }
  
  // 支出项目
  Widget _buildExpenseItem(FamilyExpense expense) {
    // 格式化日期
    String formattedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
    
    if (expenseDate == today) {
      formattedDate = '今天';
    } else if (expenseDate == today.subtract(const Duration(days: 1))) {
      formattedDate = '昨天';
    } else {
      formattedDate = DateFormat('MM月dd日', 'zh_CN').format(expense.date);
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 类别图标
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: expense.iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FaIcon(
              expense.icon,
              color: expense.iconColor,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // 支出信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    expense.payerName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '•',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 金额和类别
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '-¥${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              expense.category,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 家庭预算规划
  Widget _buildBudgetPlanning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '家庭预算规划',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: 打开编辑预算的界面
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: Color(0xFF16A34A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '编辑',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 预算列表
          ...List.generate(
            _budgetItems.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildBudgetItem(_budgetItems[index]),
            ),
          ),
        ],
      ),
    );
  }
  
  // 预算项目
  Widget _buildBudgetItem(BudgetItem item) {
    // 计算预算使用百分比
    double percentage = (item.currentAmount / item.budgetAmount) * 100;
    if (percentage > 100) {
      percentage = 100; // 限制为最大100%显示
    }
    
    // 确定进度条颜色
    Color progressColor;
    if (item.isOverBudget) {
      progressColor = const Color(0xFFEF4444); // 超出预算红色
    } else if (percentage > 80) {
      progressColor = const Color(0xFFF59E0B); // 接近预算琥珀色
    } else {
      progressColor = const Color(0xFF10B981); // 未超出预算绿色
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FaIcon(
                  item.icon,
                  color: const Color(0xFF6B7280),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            Text(
              '¥${item.currentAmount.toStringAsFixed(0)} / ¥${item.budgetAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 13,
                color: item.isOverBudget ? const Color(0xFFEF4444) : const Color(0xFF4B5563),
                fontWeight: item.isOverBudget ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,  // 直接使用原始百分比
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 共同储蓄目标
  Widget _buildSavingsGoals() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '共同储蓄目标',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              // 添加按钮
              GestureDetector(
                onTap: () {
                  // TODO: 打开添加新储蓄目标界面
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 14,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '添加',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 储蓄目标列表
          ...List.generate(
            _savingsGoals.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildSavingsGoalItem(_savingsGoals[index]),
            ),
          ),
        ],
      ),
    );
  }

  // 储蓄目标项目
  Widget _buildSavingsGoalItem(SavingsGoal goal) {
    // 计算进度百分比
    double percentage = (goal.currentAmount / goal.targetAmount) * 100;
    String percentageStr = percentage.toStringAsFixed(0);
    
    // 计算距离截止日期的天数
    final now = DateTime.now();
    final daysLeft = goal.deadline.difference(now).inDays;
    
    // 格式化截止日期
    final dateFormat = DateFormat('yyyy年MM月dd日', 'zh_CN');
    final deadlineStr = dateFormat.format(goal.deadline);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // 标题行
          Row(
            children: [
              // 图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: FaIcon(
                    goal.icon,
                    color: goal.color,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // 标题和进度
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '已存 ¥${goal.currentAmount.toStringAsFixed(0)} / ¥${goal.targetAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 进度百分比
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentageStr%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: goal.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 进度条
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,  // 直接使用原始百分比
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: goal.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 截止日期
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '目标日期: $deadlineStr',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                '剩余 $daysLeft 天',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 支出类别数据模型
class ExpenseCategory {
  final String name;
  final IconData icon;
  final double amount;
  final double percentage;
  final Color color;
  
  ExpenseCategory({
    required this.name,
    required this.icon,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

// 家庭支出数据模型
class FamilyExpense {
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String payerName;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  
  FamilyExpense({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.payerName,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

// 预算项目数据模型
class BudgetItem {
  final String category;
  final IconData icon;
  final double currentAmount;
  final double budgetAmount;
  final bool isOverBudget;
  
  BudgetItem({
    required this.category,
    required this.icon,
    required this.currentAmount,
    required this.budgetAmount,
    required this.isOverBudget,
  });
}

// 储蓄目标数据模型
class SavingsGoal {
  final String title;
  final IconData icon;
  final double currentAmount;
  final double targetAmount;
  final DateTime deadline;
  final Color color;
  
  SavingsGoal({
    required this.title,
    required this.icon,
    required this.currentAmount,
    required this.targetAmount,
    required this.deadline,
    required this.color,
  });
}
