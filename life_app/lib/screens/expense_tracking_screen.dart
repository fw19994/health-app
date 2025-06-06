import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 为振动反馈添加的导入
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../themes/app_theme.dart';
import '../utils/app_icons.dart';
import '../widgets/common/icon_selector_modal.dart';
import '../widgets/common/date_picker_modal.dart';
import '../services/icon_service.dart';
import '../models/icon.dart';
import 'dart:io';
import '../models/family_member_model.dart';
import '../services/family_member_service.dart';
import '../services/finance_service.dart'; // 导入 FinanceService
import '../models/api_response.dart'; // 导入 ApiResponse
import '../widgets/common/category_selector.dart';
import '../services/budget_service.dart';
import '../models/savings_goal.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  // 添加家庭ID参数
  final int? familyId;
  final bool isFamilyExpense;
  
  const ExpenseTrackingScreen({
    super.key, 
    this.familyId,
    this.isFamilyExpense = false,
  });

  @override
  State<ExpenseTrackingScreen> createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  // 输入框焦点状态
  bool _merchantFocused = false;
  bool _noteFocused = false;
  bool _sourceFocused = false;
  // 交易类型 (支出, 收入)
  final List<String> _transactionTypes = ['支出', '收入'];
  int _selectedTypeIndex = 0;

  // 最近选择的日期记录
  List<DateTime> _recentDates = [];

  // 图标服务
  final IconService _iconService = IconService();

  // 系统图标列表
  List<IconModel> _systemIcons = [];
  List<IconModel> _customIcons = [];

  // 当前选中的类别
  int _selectedCategoryIndex = 0; 

  // 记为家庭支出（从widget继承初始值，但可变）
  late bool _isFamilyExpense;

  // 控制器
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  
  // 日期
  DateTime _selectedDate = DateTime.now();
  late DateFormat _dateFormat;
  
  // 新类别的控制器
  final TextEditingController _newCategoryNameController = TextEditingController();
  Color _newCategoryColor = Colors.blue;
  IconData _newCategoryIcon = FontAwesomeIcons.tag;

  // 添加图片识别相关变量
  String? _uploadedImagePath;
  String _recognizedText = '';
  bool _isRecognizing = false;

  // 家庭成员相关
  List<FamilyMember> _familyMembers = [];
  FamilyMember? _selectedRecorder;
  bool _isLoadingMembers = false;
  
  // FinanceService 实例
  late FinanceService _financeService;

  // 添加一个状态来跟踪保存操作
  bool _isSaving = false;
  
  // 添加一个变量来存储近期交易
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoadingTransactions = false;

  // 添加储蓄目标相关变量
  // 添加储蓄目标列表
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoadingSavingsGoals = false;
  SavingsGoal? _selectedSavingsGoal;
  
  // 预加载储蓄目标服务
  final BudgetService _budgetService = BudgetService();

  @override
  void initState() {
    super.initState();
    // 初始化 FinanceService (不再需要 context)
    _financeService = FinanceService();
    // 初始化中文日期格式
    initializeDateFormatting('zh_CN', null);
    _dateFormat = DateFormat('yyyy年MM月dd日', 'zh_CN');
    // 加载图标数据
    _loadIcons();
    // 加载自定义类别
    _loadCustomCategories();
    // 初始化选择第一个类别
    _selectedCategoryIndex = 0;
    // 加载家庭成员
    _loadFamilyMembers();
    // 加载近期交易 (不传入类型参数)
    _loadRecentTransactions();
    // 加载储蓄目标
    _loadSavingsGoals();
      // 初始化 _isFamilyExpense - 始终设置为true（因为UI中已移除此选项）
      _isFamilyExpense = true;
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

  // 获取所有类别（系统图标+自定义图标+添加按钮）
  List<CategoryItem> get _allCategories {
    List<CategoryItem> all = [];
    
    // 添加系统图标
    final systemIcons = _selectedTypeIndex == 0 
        ? _systemIcons.where((icon) => icon.categoryId == 1).toList()  // 支出类别 ID=1
        : _systemIcons.where((icon) => icon.categoryId == 2).toList(); // 收入类别 ID=2
    
    all.addAll(systemIcons.map((icon) => CategoryItem.fromIconModel(icon)));
    
    // 添加自定义图标
    final customIcons = _selectedTypeIndex == 0 
        ? _customIcons.where((icon) => icon.categoryId == 1).toList()  // 支出类别 ID=1
        : _customIcons.where((icon) => icon.categoryId == 2).toList(); // 收入类别 ID=2
    
    all.addAll(customIcons.map((icon) => CategoryItem.fromIconModel(icon)));
    
    // 添加新类别的按钮
    all.add(CategoryItem(icon: FontAwesomeIcons.plus, label: '添加', color: Colors.grey));
    return all;
  }

  // 类别选择
  Widget _buildCategories() {
    // 获取当前交易类型的图标
    final categoryType = _selectedTypeIndex == 0 ? '支出' : '收入';
    final List<CategoryItem> typeCategories = _allCategories;

    return CategorySelector(
      categories: typeCategories.sublist(0, typeCategories.length - 1), // 排除最后一个"添加"按钮，由组件内部处理
      selectedIndex: _selectedCategoryIndex,
      onCategorySelected: (index) {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      onAddCategory: (name, icon, color) {
        // 直接调用保存方法
        _saveCustomCategory(name, icon, color);
      },
      title: '$categoryType类别',
      isExpenseType: _selectedTypeIndex == 0,
      onLongPress: (index) {
        if (index >= _systemIcons.length) {
          _showEditCategoryDialog(index - _systemIcons.length);
        }
      },
    );
  }

  // 显示添加类别对话框
  void _showAddCategoryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '添加新类别',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newCategoryNameController,
                    decoration: const InputDecoration(
                      labelText: '类别名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      IconSelectorModal.show(
                        context,
                        selectedIcon: _newCategoryIcon,
                        selectedColor: _newCategoryColor,
                        onIconSelected: (icon, color, name) {
                          setState(() {
                            _newCategoryIcon = icon;
                            _newCategoryColor = color;
                            if (_newCategoryNameController.text.isEmpty) {
                              _newCategoryNameController.text = name;
                            }
                          });
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(_newCategoryIcon, color: _newCategoryColor),
                          const SizedBox(width: 8),
                          const Text('选择图标'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_newCategoryNameController.text.isNotEmpty) {
                            try {
                              // 显示加载提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('正在创建图标...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              
                              // 创建自定义图标
                              await _saveCustomCategory(
                                _newCategoryNameController.text,
                                _newCategoryIcon,
                                _newCategoryColor
                              );
                              
                              // 清除输入并关闭对话框
                              setState(() {
                                _newCategoryNameController.clear();
                              });
                              Navigator.pop(context);
                              
                              // 显示成功提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('图标创建成功'),
                                  backgroundColor: Colors.green,
                                ),
                              );
    } catch (e) {
                              debugPrint('创建图标失败: $e');
                              // 显示错误提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('创建图标失败: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            // 显示输入验证错误
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('请输入类别名称'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示日期选择器
  Future<void> _showDatePicker() async {
    final selectedDate = await DatePickerModal.show(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      recentDates: _recentDates,
    );
    
    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
        // 更新最近选择记录
        if (!_recentDates.contains(selectedDate)) {
          _recentDates.insert(0, selectedDate);
          if (_recentDates.length > 5) {
            _recentDates.removeLast();
          }
        }
      });
    }
  }
  
  /// 构建日期选择按钮 - 优化版
  Widget _buildDateSelector() {
    // 获取今天、明天、昨天的日期
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    // 确定选择的日期是否为特殊日期(今天/昨天/明天)，以便显示特殊标签
    String dateLabel;
    if (_selectedDate.year == today.year && _selectedDate.month == today.month && _selectedDate.day == today.day) {
      dateLabel = '今天';
    } else if (_selectedDate.year == yesterday.year && _selectedDate.month == yesterday.month && _selectedDate.day == yesterday.day) {
      dateLabel = '昨天';
    } else if (_selectedDate.year == tomorrow.year && _selectedDate.month == tomorrow.month && _selectedDate.day == tomorrow.day) {
      dateLabel = '明天';
    } else {
      dateLabel = '';
    }
    
    // 日期格式化
    final dateStr = DateFormat('MM月dd日').format(_selectedDate);
    final weekdayStr = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][_selectedDate.weekday % 7];
    
    return InkWell(
      onTap: _showDatePicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
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
            // 左侧图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedTypeIndex == 0
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.event,
                  size: 20,
                  color: _selectedTypeIndex == 0
                      ? Colors.red.shade400
                      : Colors.green.shade400,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 中间日期信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateLabel.isEmpty ? dateStr : '$dateLabel ($dateStr)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$weekdayStr · ${DateFormat('yyyy年').format(_selectedDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // 右侧修改图标
            Icon(
              Icons.arrow_drop_down,
              size: 24,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    _sourceController.dispose();
    _newCategoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 头部区域
          Container(
            height: 120,
            decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
                colors: _selectedTypeIndex == 0
                    ? [const Color(0xFFF97316), const Color(0xFFEF4444)]
                    : [const Color(0xFF10B981), const Color(0xFF059669)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
                  mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                '记一笔',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                            fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
                    Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前余额',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                            const SizedBox(height: 4),
                    Text(
                              '¥5,000.00',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                              _selectedTypeIndex == 0 ? '本月预算' : '本月收入',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                            const SizedBox(height: 4),
                    Text(
                              '¥3,000.00',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecentTransactionsCard(), // 重新添加近期交易卡片
                    const SizedBox(height: 16),
                    _buildTransactionTypeToggle(),
                    const SizedBox(height: 16),
                    _selectedTypeIndex == 0 ? _buildExpenseForm() : _buildIncomeForm(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
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

  // 交易类型切换
  Widget _buildTransactionTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: List.generate(
            _transactionTypes.length,
            (index) => Expanded(
              child: GestureDetector(
                onTap: () {
                  _onTransactionTypeChanged(index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTypeIndex == index
                        ? index == 0
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFDCFCE7)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _transactionTypes[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _selectedTypeIndex == index
                          ? index == 0
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 当交易类型切换时，重置选中的类别索引
  void _onTransactionTypeChanged(int index) {
    setState(() {
      _selectedTypeIndex = index;
      _selectedCategoryIndex = 0; // 重置到第一个类别
    });
    // 不再在这里重新加载近期交易
  }

  // 加载近期交易数据（不区分支出和收入类型）
  Future<void> _loadRecentTransactions() async {
    if (!mounted) return;

    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      // 确保家庭成员数据已加载
      if (_familyMembers.isEmpty) {
        await _loadFamilyMembers();
      }

      // 修复：添加必需的type参数，默认获取支出类型交易
      final response = await _financeService.getRecentTransactions(
        context: context,
        type: 'expense', // 添加必需的type参数
        familyId: widget.familyId, // 添加家庭ID
        isFamilyBudget: widget.familyId != null, // 如果有家庭ID，则使用家庭预算
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

  // 根据recorder_id查找对应的家庭成员
  FamilyMember? _findFamilyMemberById(dynamic recorderId) {
    if (_familyMembers.isEmpty) {
      return null;
    }
    
    try {
      int id;
      if (recorderId is int) {
        id = recorderId;
      } else if (recorderId is String) {
        id = int.tryParse(recorderId) ?? 0;
      } else {
        id = 0;
      }
      
      return _familyMembers.firstWhere((member) => member.id == id, 
          orElse: () => _familyMembers.first);
    } catch (e) {
      debugPrint('查找家庭成员失败: $e');
      return null;
    }
  }

  // 构建近期交易卡片
  Widget _buildRecentTransactionsCard() {
    // 获取并限制最多显示3条记录
    final displayTransactions = _recentTransactions.take(3).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和筛选
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 标题
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.clockRotateLeft,
                    size: 16,
                    color: Colors.blue.shade500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '近期交易记录',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              // 右上角显示查看更多按钮（如果有记录）
              if (!_isLoadingTransactions && _recentTransactions.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // TODO: 跳转到交易历史记录页面
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('暂未实现查看更多功能'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '查看更多',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 12, color: Colors.blue.shade700),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 交易列表
          if (_isLoadingTransactions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (displayTransactions.isEmpty)
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
            Column(
              children: displayTransactions.map((transaction) {
                // 获取记账人信息
                final int recorderId = transaction['recorder_id'] ?? 0;
                final FamilyMember? recorder = _findFamilyMemberById(recorderId);
                
                // 获取图标信息
                final int iconId = transaction['icon_id'] ?? 0;
                final String iconName = _getIconNameById(iconId);
                final IconData iconData = _getIconDataById(iconId);
                final Color iconColor = _getIconColorById(iconId);
                
                // 获取交易类型
                final String type = transaction['type'] ?? 'expense';
                final bool isExpense = type == 'expense';
                
                // 获取备注和商家信息
                final String notes = transaction['notes'] ?? '';
                final String merchant = transaction['merchant'] ?? '';
                
                // 获取金额
                final amount = transaction['amount'] ?? 0;
                final String amountStr = '¥${amount.toString()}';
                
                // 获取并格式化日期时间
                DateTime? transactionDate;
                try {
                  if (transaction['date'] != null) {
                    transactionDate = DateTime.parse(transaction['date']);
                  }
                } catch (e) {
                  debugPrint('解析日期失败: $e');
                }
                
                // 格式化日期时间，例如 "04-16 15:30" 或 "今天 15:30"
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
                  
                  // 日期部分
                  if (transactionDay == today) {
                    formattedDateTime = '今天 $timeStr';
                  } else if (transactionDay == yesterday) {
                    formattedDateTime = '昨天 $timeStr';
                  } else {
                    formattedDateTime = DateFormat('MM-dd $timeStr').format(transactionDate);
                  }
                }
                
                return Container(
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
                            
                            // 备注和日期
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
                      
                      const SizedBox(width: 6),
                      
                      // 右侧信息：金额和记账人
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          
                          // 记账人 (如果有)
                          if (recorder != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: recorder.avatarUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(recorder.avatarUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: recorder.avatarUrl.isEmpty 
                                        ? Colors.grey.shade200
                                        : null,
                                  ),
                                  child: recorder.avatarUrl.isEmpty
                                      ? Center(
                                          child: Text(
                                            (recorder.nickname.isNotEmpty ? recorder.nickname : recorder.name).isNotEmpty
                                                ? (recorder.nickname.isNotEmpty ? recorder.nickname : recorder.name)[0]
                                                : '?',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  recorder.nickname.isNotEmpty ? recorder.nickname : recorder.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
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

  // 支出表单
  Widget _buildExpenseForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 金额输入和记账人
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '金额',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                  ),
                  _buildRecorderSelector(),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '¥',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
          ),
          
          // 类别选择 - 不再需要额外的容器
          _buildCategories(),
          
          // 日期选择
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '日期',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildDateSelector(),
              const Divider(height: 32),
            ],
          ),
          
          // 商家输入
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '商家',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _merchantFocused ? const Color(0xFF3B82F6) : Colors.grey.shade200,
                    width: _merchantFocused ? 1.5 : 1,
                  ),
                  boxShadow: _merchantFocused 
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        )
                      ] 
                    : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
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
                      child: const Icon(FontAwesomeIcons.store, color: Color(0xFF3B82F6), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            // 状态更新会触发重建，让我们能够响应焦点变化
                            _merchantFocused = hasFocus;
                          });
                        },
                        child: TextField(
                          controller: _merchantController,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: '输入商家名称',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: const TextStyle(color: Color(0xFFA3A3A3)),
                            // 移除默认的下划线效果
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            // 移除内部填充，使其更加贴合我们的自定义容器
                            isDense: true,
                          ),
                          cursorColor: const Color(0xFF3B82F6),
                          // 点击时添加触觉反馈
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          
          // 备注输入
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '备注',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _noteFocused ? const Color(0xFFEC4899) : Colors.grey.shade200,
                    width: _noteFocused ? 1.5 : 1,
                  ),
                  boxShadow: _noteFocused 
                    ? [
                        BoxShadow(
                          color: const Color(0xFFEC4899).withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        )
                      ] 
                    : null,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _noteFocused ? const Color(0xFFFDF2F8) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            FontAwesomeIcons.stickyNote, 
                            color: _noteFocused ? const Color(0xFFEC4899) : const Color(0xFFEC4899).withOpacity(0.7), 
                            size: 18
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {
                                _noteFocused = hasFocus;
                              });
                            },
                            child: SizedBox(
                              height: 40, // 固定高度
                              child: Center(
                                child: TextField(
                                  controller: _noteController,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '添加备注',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    hintStyle: TextStyle(color: Color(0xFFA3A3A3)),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                  ),
                                  maxLines: 1, // 先限制为单行，解决对齐问题
                                  cursorColor: Color(0xFFEC4899),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          
          // 上传图片区域
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '图片',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildImageUploadArea(),
              const Divider(height: 32),
            ],
          ),
          
          // 家庭支出开关已移除
          
          // 对于支出类型，不显示储蓄目标选择器
        ],
      ),
    );
  }

  // 收入表单
  Widget _buildIncomeForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 金额输入和记账人
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '金额',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  _buildRecorderSelector(),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '¥',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
          ),
          
          // 收入类别选择 - 不再需要额外的容器
          _buildCategories(),
          
          // 日期选择
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '日期',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildDateSelector(),
              const Divider(height: 32),
            ],
          ),
          
          // 来源输入
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '来源',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _sourceFocused ? const Color(0xFF6366F1) : Colors.grey.shade200,
                    width: _sourceFocused ? 1.5 : 1,
                  ),
                  boxShadow: _sourceFocused 
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        )
                      ] 
                    : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _sourceFocused ? const Color(0xFFF0F1FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        FontAwesomeIcons.building,
                        color: _sourceFocused ? const Color(0xFF6366F1) : const Color(0xFF6366F1).withOpacity(0.7), 
                        size: 18
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            _sourceFocused = hasFocus;
                          });
                        },
                        child: TextField(
                          controller: _sourceController,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: '输入收入来源',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintStyle: TextStyle(color: Color(0xFFA3A3A3)),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                          ),
                          cursorColor: Color(0xFF6366F1),
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          
          // 储蓄目标选择器
          _buildSavingsGoalSelector(),
          
          // 备注输入
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '备注',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
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
                          child: const Icon(FontAwesomeIcons.stickyNote, color: Color(0xFFEC4899), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: '添加备注',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: TextStyle(color: Color(0xFFA3A3A3)),
                            ),
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          
          // 上传图片区域 (新增)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '图片',
                    style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildImageUploadArea(),
              const Divider(height: 32),
            ],
          ),
        ],
      ),
    );
  }

  // 显示编辑类别对话框
  void _showEditCategoryDialog(int customCategoryIndex) {
    final iconModel = _customIcons[customCategoryIndex];
    
    // 设置初始值
    _newCategoryNameController.text = iconModel.name;
    _newCategoryColor = iconModel.color;
    _newCategoryIcon = iconModel.icon;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('编辑类别'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _newCategoryNameController,
                      decoration: const InputDecoration(
                        labelText: '类别名称',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('选择图标'),
                    const SizedBox(height: 8),
                    _buildIconSelector(setState),
                    const SizedBox(height: 16),
                    const Text('选择颜色'),
                    const SizedBox(height: 8),
                    _buildColorSelector(setState),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    // 删除类别
                    _deleteCategory(customCategoryIndex);
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('删除'),
                ),
                TextButton(
                  onPressed: () {
                    if (_newCategoryNameController.text.isNotEmpty) {
                      _updateCategory(
                        customCategoryIndex,
                        _newCategoryNameController.text, 
                        _newCategoryIcon, 
                        _newCategoryColor
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  // 构建图标选择器
  Widget _buildIconSelector(StateSetter setModalState) {
    // 创建一组可选的图标
    List<IconData> availableIcons = [
      FontAwesomeIcons.tag,
      FontAwesomeIcons.coffee,
      FontAwesomeIcons.plane,
      FontAwesomeIcons.gift,
      FontAwesomeIcons.gamepad,
      FontAwesomeIcons.tshirt,
      FontAwesomeIcons.baby,
      FontAwesomeIcons.dog,
      FontAwesomeIcons.cat,
      FontAwesomeIcons.book,
      FontAwesomeIcons.music,
      FontAwesomeIcons.suitcase,
      FontAwesomeIcons.dumbbell,
      FontAwesomeIcons.laptop,
      FontAwesomeIcons.mobile,
      FontAwesomeIcons.wifi,
    ];
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableIcons.map((icon) {
        bool isSelected = _newCategoryIcon == icon;
        return GestureDetector(
          onTap: () {
            setModalState(() {
              _newCategoryIcon = icon;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? _newCategoryColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: _newCategoryColor, width: 2) : null,
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: isSelected ? _newCategoryColor : Colors.grey,
                size: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  // 构建颜色选择器
  Widget _buildColorSelector(StateSetter setModalState) {
    // 创建一组可选的颜色
    List<Color> availableColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableColors.map((color) {
        bool isSelected = _newCategoryColor.value == color.value;
        return GestureDetector(
          onTap: () {
            setModalState(() {
              _newCategoryColor = color;
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ] : null,
            ),
          ),
        );
      }).toList(),
    );
  }
  
  // 添加新类别
  void _addNewCategory(String name, IconData icon, Color color) {
    int categoryId = _selectedTypeIndex == 0 ? 1 : 2; // 1=支出, 2=收入
    
    setState(() {
      _customIcons.add(IconModel(
        id: 0, // 临时ID
        name: name,
        code: name.toLowerCase().replaceAll(' ', '_'),
        iconType: 'fontawesome',
        iconCode: 'fa-tag', // 默认图标
        colorCode: '#${color.value.toRadixString(16).substring(2)}',
        categoryId: categoryId, // 确保使用正确的categoryId
        category: _selectedTypeIndex == 0 ? '支出' : '收入',
        isCustom: true,
      ));
      // 自动选中新添加的类别
      _selectedCategoryIndex = _allCategories.length - 2; // 减2是因为减去了最后的"添加"按钮
    });
    // 保存自定义类别
    _saveCustomCategory(name, icon, color);
  }
  
  // 更新类别
  void _updateCategory(int index, String name, IconData icon, Color color) {
    int categoryId = _selectedTypeIndex == 0 ? 1 : 2; // 1=支出, 2=收入
    
    setState(() {
      _customIcons[index] = IconModel(
        id: _customIcons[index].id,
        name: name,
        code: name.toLowerCase().replaceAll(' ', '_'),
        iconType: 'fontawesome',
        iconCode: 'fa-tag', // 默认图标
        colorCode: '#${color.value.toRadixString(16).substring(2)}',
        categoryId: categoryId, // 确保使用正确的categoryId
        category: _selectedTypeIndex == 0 ? '支出' : '收入',
        isCustom: true,
      );
    });
    // 保存自定义类别
    _saveCustomCategory(name, icon, color);
  }
  
  // 删除类别
  void _deleteCategory(int index) {
    setState(() {
      _customIcons.removeAt(index);
      // 如果删除的是当前选中的类别，则重置选中索引
      if (_selectedCategoryIndex >= _systemIcons.length) {
        _selectedCategoryIndex = 0;
      }
    });
  }

  // 加载自定义类别
  Future<void> _loadCustomCategories() async {
    try {
      final icons = await _iconService.getUserAvailableIcons(context: context);
      setState(() {
        _customIcons = icons.where((icon) => icon.isCustom).toList();
      });
    } catch (e) {
      print('加载自定义分类失败: $e');
    }
  }

  // 保存自定义类别
  Future<void> _saveCustomCategory(String name, IconData icon, Color color) async {
    try {
      // 将iconData转换为图标ID (使用codePoint的值)
      int iconId = _getFontAwesomeIconId(icon);
      
      // 根据当前交易类型确定类别ID (1=支出, 2=收入)
      int categoryId = _selectedTypeIndex == 0 ? 1 : 2;
      
      await _iconService.createUserIcon(
        iconId: iconId,
        customName: name,
        customColor: '#${color.value.toRadixString(16).substring(2)}',
        categoryId: categoryId,  // 添加categoryId参数
        context: context,
      );
      
      // 重新加载类别数据
      await _loadCustomCategories();
      
      // 重要：添加setState刷新UI，并自动选择新添加的类别
      setState(() {
        // 计算新添加类别的索引位置
        final int systemIconsCount = _systemIcons
            .where((icon) => icon.categoryId == (_selectedTypeIndex == 0 ? 1 : 2))
            .length;
            
        final int customIconsCount = _customIcons
            .where((icon) => icon.categoryId == (_selectedTypeIndex == 0 ? 1 : 2))
            .length;
            
        // 选中新添加的类别 (最后一个自定义类别)
        _selectedCategoryIndex = systemIconsCount + customIconsCount - 1;
      });
      
    } catch (e) {
      print('保存自定义分类失败: $e');
    }
  }
  
  // 获取FontAwesome图标的ID
  int _getFontAwesomeIconId(IconData icon) {
    // 将常用的FontAwesome图标映射到后端数据库中对应的ID
    // 这是根据后端返回的数据来构建的映射表
    if (icon == FontAwesomeIcons.house) return 1; // 住房
    if (icon == FontAwesomeIcons.utensils) return 2; // 餐饮
    if (icon == FontAwesomeIcons.cartShopping) return 3; // 购物
    if (icon == FontAwesomeIcons.car) return 4; // 交通
    if (icon == FontAwesomeIcons.gamepad) return 5; // 娱乐
    if (icon == FontAwesomeIcons.graduationCap) return 6; // 教育
    if (icon == FontAwesomeIcons.plane) return 7; // 旅行
    if (icon == FontAwesomeIcons.kitMedical) return 8; // 医疗
    if (icon == FontAwesomeIcons.spa) return 9; // 美容
    if (icon == FontAwesomeIcons.gift) return 10; // 礼品
    if (icon == FontAwesomeIcons.bolt) return 11; // 水电
    if (icon == FontAwesomeIcons.paw) return 12; // 宠物
    if (icon == FontAwesomeIcons.shieldHalved) return 13; // 保险
    if (icon == FontAwesomeIcons.baby) return 14; // 育儿
    if (icon == FontAwesomeIcons.shirt) return 15; // 服装
    if (icon == FontAwesomeIcons.handHoldingHeart) return 16; // 捐赠
    if (icon == FontAwesomeIcons.screwdriverWrench) return 17; // 维修
    if (icon == FontAwesomeIcons.newspaper) return 18; // 订阅
    if (icon == FontAwesomeIcons.fileInvoiceDollar) return 19; // 税收
    if (icon == FontAwesomeIcons.chartLine) return 20; // 投资
    
    // 收入类别
    if (icon == FontAwesomeIcons.moneyBillWave) return 21; // 工资
    if (icon == FontAwesomeIcons.handHoldingDollar) return 22; // 奖金
    if (icon == FontAwesomeIcons.piggyBank) return 23; // 投资收益
    if (icon == FontAwesomeIcons.building) return 24; // 租金
    if (icon == FontAwesomeIcons.arrowRotateLeft) return 25; // 退款
    if (icon == FontAwesomeIcons.gift) return 26; // 礼金
    if (icon == FontAwesomeIcons.laptopCode) return 27; // 兼职
    if (icon == FontAwesomeIcons.coins) return 28; // 其他收入
    
    // 通用图标
    if (icon == FontAwesomeIcons.tag) return 1; // 默认使用住房图标
    
    // 如果没有匹配的图标，则使用默认图标ID
    return 1;
  }

  // 修改保存按钮的逻辑
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveTransaction, // 绑定新的保存方法，防止重复点击
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSaving 
              ? Colors.grey // 保存时按钮变灰
              : AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ) // 显示加载指示器
            : const Text(
                '保存',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // 新的保存交易方法
  Future<void> _saveTransaction() async {
    // 1. 数据校验
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入金额'), backgroundColor: Colors.orange),
      );
      return;
    }
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的金额'), backgroundColor: Colors.orange),
      );
      return;
    }
    // 移除记账人必选校验
    // 确保类别已选择 (不是 "添加" 按钮)
    if (_selectedCategoryIndex >= _allCategories.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择一个有效的类别'), backgroundColor: Colors.orange),
      );
      return;
    }

    // 2. 设置保存状态
    setState(() {
      _isSaving = true;
    });

    // 3. 准备数据
    final transactionType = _selectedTypeIndex == 0 ? "expense" : "income";
    final selectedCategory = _allCategories[_selectedCategoryIndex];
    // 需要从 CategoryItem 获取 IconModel 的 ID，或者直接使用 IconModel
    // 假设 IconModel 列表与 CategoryItem 列表对应，需要找到正确的 IconModel
    IconModel? selectedIconModel;
    // 注意：这里的查找逻辑依赖于 _allCategories 的构建方式
    if (_selectedCategoryIndex < _systemIcons.length) {
      // 查找系统图标
      final systemCategoryIcons = _selectedTypeIndex == 0
          ? _systemIcons.where((icon) => icon.categoryId == 1).toList()
          : _systemIcons.where((icon) => icon.categoryId == 2).toList();
      if (_selectedCategoryIndex < systemCategoryIcons.length) {
         selectedIconModel = systemCategoryIcons[_selectedCategoryIndex];
      }
    } else {
       // 查找自定义图标
       final customCategoryIcons = _selectedTypeIndex == 0
          ? _customIcons.where((icon) => icon.categoryId == 1).toList()
          : _customIcons.where((icon) => icon.categoryId == 2).toList();
        final customIndex = _selectedCategoryIndex - (_selectedTypeIndex == 0
            ? _systemIcons.where((icon) => icon.categoryId == 1).length
            : _systemIcons.where((icon) => icon.categoryId == 2).length);
         if (customIndex >= 0 && customIndex < customCategoryIcons.length) {
             selectedIconModel = customCategoryIcons[customIndex];
         }
    }

    if (selectedIconModel == null) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('无法找到对应的图标信息'), backgroundColor: Colors.red),
         );
          setState(() {
             _isSaving = false;
          });
         return;
    }


    final int iconId = selectedIconModel.id;

    final String merchant = _merchantController.text;
    final String notes = _noteController.text;
    // 修改记账人ID的获取方式，允许为空
    final int? recorderId = _selectedRecorder?.id;
    
    // 获取储蓄目标ID (仅当交易类型为收入且已选择储蓄目标时)
    int? goalId;
    if (transactionType == 'income' && _selectedSavingsGoal != null) {
      // 将String类型的id转换为int
      goalId = int.tryParse(_selectedSavingsGoal!.id);
    }

    // 4. 调用 Service
    try {
      final response = await _financeService.addTransaction(
        context: context,
        type: transactionType,
        amount: amount,
        iconId: iconId,
        date: _selectedDate,
        merchant: merchant,
        notes: notes,
        recorderId: recorderId ?? 0, // 如果为null则使用0作为默认值
        isFamilyExpense: _isFamilyExpense,
        imageUrl: _uploadedImagePath, // 传递图片路径，如果需要的话
        goalId: goalId, // 传递储蓄目标ID
        familyId: widget.familyId, // 添加家庭ID参数
      );

      // 5. 处理结果
      if (mounted) { // 检查 widget 是否还在树中
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('记账成功!'), backgroundColor: Colors.green),
          );
          // 成功后返回上一页
          Navigator.pop(context, true); // 返回 true 表示成功
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('记账失败: ${response.message}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      // Service 层已处理 DioError 和其他异常，这里捕获以防万一
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发生错误: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 结束保存状态
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 图片上传区域
  Widget _buildImageUploadArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 上传按钮
        InkWell(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.camera,
                  color: _selectedTypeIndex == 0 ? Colors.red.shade400 : Colors.green.shade400,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _uploadedImagePath != null ? '重新上传图片' : '上传图片（支持自动识别）',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedTypeIndex == 0 ? Colors.red.shade400 : Colors.green.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 图片预览和识别结果
        if (_uploadedImagePath != null) ...[
          const SizedBox(height: 12),
          // 图片预览
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_uploadedImagePath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 识别状态或结果
          if (_isRecognizing)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(height: 8),
                    Text('正在识别图片内容...', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            )
          else if (_recognizedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text('识别结果:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(_recognizedText, style: TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击上面的文本可编辑',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  // 选择图片方法
  Future<void> _pickImage() async {
    // TODO: 实现图片选择功能
    // 这里是模拟实现，实际需要使用image_picker等插件
    setState(() {
      _isRecognizing = true;
      // 假设已上传图片
      _uploadedImagePath = '/path/to/image.jpg';
    });
    
    // 模拟图片识别过程
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isRecognizing = false;
      _recognizedText = "商家：XX超市\n金额：¥56.80\n日期：2023-08-15\n品类：食品/日用品";
      
      // 自动填充表单
      _merchantController.text = "XX超市";
      _amountController.text = "56.80";
    });
  }

  // 加载家庭成员
  Future<void> _loadFamilyMembers() async {
    if (!mounted) return;

      setState(() {
        _isLoadingMembers = true;
      });

    try {
      final familyMemberService = FamilyMemberService(context: context);
      final response = await familyMemberService.getFamilyMembers(
        familyId: widget.familyId, // 传递家庭ID
      );
      
      if (mounted && response.success && response.data != null) {
        setState(() {
          _familyMembers = response.data!;
          
          // 寻找当前用户，找不到则使用第一个家庭成员作为默认记账人
          if (_familyMembers.isNotEmpty) {
            // 尝试找到当前用户
            final currentUserMember = _familyMembers.where((member) => member.isCurrentUser).firstOrNull;
            _selectedRecorder = currentUserMember ?? _familyMembers.first;
          } else {
            // 如果没有家庭成员，则设置为null
            _selectedRecorder = null;
          }
          
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      debugPrint('加载家庭成员失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
        });
      }
    }
  }

  // 显示记账人选择器
  void _showRecorderPicker() {
    if (_familyMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无家庭成员数据')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
            mainAxisSize: MainAxisSize.min,
        children: [
              // 顶部指示条
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '选择记账人',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              // 家庭成员列表
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _familyMembers.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                    indent: 46,
                    endIndent: 0,
                  ),
                  itemBuilder: (context, index) {
                    final member = _familyMembers[index];
                    final isSelected = _selectedRecorder?.id == member.id;
                    final displayName = member.nickname.isNotEmpty 
                        ? member.nickname 
                        : member.name;
                    final roleName = member.getRoleName();

                    return InkWell(
                  onTap: () {
                        setState(() {
                          _selectedRecorder = member;
                        });
                        Navigator.pop(context);
                  },
                  child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                          color: isSelected ? (_selectedTypeIndex == 0 
                              ? Colors.red.shade50 
                              : Colors.green.shade50) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                            _buildMemberAvatar(member, size: 36),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                            Text(
                                    roleName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                            ),
                            if (isSelected) 
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: _selectedTypeIndex == 0 
                                      ? Colors.red.shade500 
                                      : Colors.green.shade500,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                          ],
                  ),
                ),
              );
                  },
                ),
          ),
        ],
      ),
        );
      },
    );
  }

  // 构建记账人头像
  Widget _buildMemberAvatar(FamilyMember member, {double size = 30}) {
    final bool isCurrentUser = member.isCurrentUser;
    final double radius = size / 2;
    final double indicatorSize = size * 0.4;
    
    if (member.avatarUrl.isNotEmpty) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(member.avatarUrl),
            backgroundColor: Colors.grey[200],
          ),
          if (isCurrentUser)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  size: indicatorSize,
                  color: _selectedTypeIndex == 0 
                      ? const Color(0xFFEF4444) 
                      : const Color(0xFF10B981),
                ),
              ),
            ),
        ],
      );
    } else {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: _selectedTypeIndex == 0 
                ? Colors.red.shade50 
                : Colors.green.shade50,
            child: Text(
              member.nickname.isNotEmpty 
                  ? member.nickname[0] 
                  : member.name.isNotEmpty 
                      ? member.name[0] 
                      : '?',
          style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.w500,
                color: _selectedTypeIndex == 0 
                    ? Colors.red.shade700 
                    : Colors.green.shade700,
              ),
            ),
          ),
          if (isCurrentUser)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
            color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  size: indicatorSize,
                  color: _selectedTypeIndex == 0 
                      ? const Color(0xFFEF4444) 
                      : const Color(0xFF10B981),
                ),
              ),
            ),
        ],
      );
    }
  }

  // 在金额输入区域中显示的记账人选择器
  Widget _buildRecorderSelector() {
    return GestureDetector(
      onTap: _showRecorderPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedTypeIndex == 0 
                ? Colors.red.shade200 
                : Colors.green.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedRecorder != null)
              _buildMemberAvatar(_selectedRecorder!, size: 24)
            else if (_isLoadingMembers)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _selectedTypeIndex == 0 
                      ? Colors.red.shade300 
                      : Colors.green.shade300,
                ),
              )
            else
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(
                  Icons.person,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              _selectedRecorder != null
                  ? (_selectedRecorder!.nickname.isNotEmpty
                      ? _selectedRecorder!.nickname
                      : _selectedRecorder!.name)
                  : '选择记账人',
              style: TextStyle(
                fontSize: 13,
                color: _selectedTypeIndex == 0 
                    ? Colors.red.shade700 
                    : Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: _selectedTypeIndex == 0 
                  ? Colors.red.shade400 
                  : Colors.green.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // 加载储蓄目标数据
  Future<void> _loadSavingsGoals() async {
    setState(() {
      _isLoadingSavingsGoals = true;
    });
    
    try {
      // 获取进行中的储蓄目标
      final goals = await _budgetService.getSavingsGoals(
        status: 'in_progress',
        context: context,
        familyId: widget.familyId, // 添加家庭ID
        isFamilySavings: widget.familyId != null, // 如果有家庭ID，则使用家庭储蓄
      );
      
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
    } catch (e) {
      print('加载储蓄目标失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingSavingsGoals = false;
        });
      }
    }
  }

  // 构建储蓄目标选择器
  Widget _buildSavingsGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '储蓄目标',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            if (_selectedSavingsGoal != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSavingsGoal = null;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    '清除选择',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showSavingsGoalPicker,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _selectedSavingsGoal != null 
                  ? Colors.white 
                  : Colors.grey.shade50,
              border: Border.all(
                color: _selectedSavingsGoal != null 
                    ? const Color(0xFF6366F1).withOpacity(0.5)
                    : Colors.grey.shade200,
                width: _selectedSavingsGoal != null ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _selectedSavingsGoal != null
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // 图标部分
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedSavingsGoal != null
                        ? _selectedSavingsGoal!.color.withOpacity(0.15)
                        : Colors.blue.shade50,
                    shape: BoxShape.circle,
                    border: _selectedSavingsGoal != null
                        ? Border.all(
                            color: _selectedSavingsGoal!.color.withOpacity(0.4),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Center(
                    child: _selectedSavingsGoal != null
                        ? Icon(
                            _selectedSavingsGoal!.icon,
                            size: 18,
                            color: _selectedSavingsGoal!.color,
                          )
                        : Icon(
                            Icons.savings_outlined,
                            size: 20,
                            color: Colors.blue.shade400,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 文本内容部分
                                  Expanded(
                  child: _selectedSavingsGoal != null
                      ? Text(
                          _selectedSavingsGoal!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          _isLoadingSavingsGoals 
                              ? '加载中...' 
                              : '选择储蓄目标（可选）',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
                
                // 箭头按钮
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _selectedSavingsGoal != null
                        ? _selectedSavingsGoal!.color.withOpacity(0.1)
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: _selectedSavingsGoal != null
                          ? _selectedSavingsGoal!.color
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 显示储蓄目标选择器
  void _showSavingsGoalPicker() {
    if (_savingsGoals.isEmpty && !_isLoadingSavingsGoals) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('没有可用的储蓄目标'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,  // 减小高度
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 顶部拖动条和标题
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 拖动指示器
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 标题
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.savings,
                          color: Colors.indigo.shade400,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '选择储蓄目标',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // 添加关闭按钮
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 内容区域
            Expanded(
              child: _isLoadingSavingsGoals
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _savingsGoals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '没有可用的储蓄目标',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        // "不选择"选项
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _selectedSavingsGoal == null 
                                  ? Colors.green.shade300
                                  : Colors.grey.shade200,
                              width: _selectedSavingsGoal == null ? 2 : 1,
                            ),
                          ),
                          tileColor: _selectedSavingsGoal == null 
                              ? Colors.green.shade50 
                              : Colors.white,
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(Icons.not_interested, color: Colors.grey),
                          ),
                          title: const Text('不选择储蓄目标'),
                          trailing: _selectedSavingsGoal == null
                              ? Icon(Icons.check_circle, color: Colors.green.shade600)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedSavingsGoal = null;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        
                        // 分隔线和标题
                        if (_savingsGoals.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade400,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '你的储蓄目标',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_savingsGoals.length}个',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // 简化后的储蓄目标列表
                        ..._savingsGoals.map((goal) {
                          final bool isSelected = _selectedSavingsGoal?.id == goal.id;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected 
                                    ? goal.color.withOpacity(0.7) 
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            tileColor: isSelected 
                                ? goal.color.withOpacity(0.05) 
                                : Colors.white,
                            leading: CircleAvatar(
                              backgroundColor: goal.color.withOpacity(0.2),
                              child: Icon(goal.icon, color: goal.color, size: 20),
                            ),
                            title: Text(
                              goal.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: goal.color)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedSavingsGoal = goal;
                              });
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
