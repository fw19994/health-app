import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../themes/app_theme.dart';
import '../widgets/budget/budget_category_card.dart';
import '../widgets/budget/budget_category_modal.dart';
import '../widgets/budget/budget_tips.dart';
import '../models/budget_category.dart';
import '../widgets/common/month_picker_modal.dart';
import '../services/budget_service.dart';
import '../services/icon_service.dart';
import '../models/icon.dart';
import 'package:intl/intl.dart';
import '../widgets/budget/budget_header.dart';

class BudgetSettingsScreen extends StatefulWidget {
  final bool isFamilyBudget;
  
  const BudgetSettingsScreen({
    super.key,
    this.isFamilyBudget = false,
  });

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<DateTime> recentMonths = [];
  final BudgetService _budgetService = BudgetService();
  final IconService _iconService = IconService();
  
  // 预算类别列表
  List<BudgetCategory> _budgetCategories = [];
  // 图标缓存 - 保存图标ID到IconModel的映射
  final Map<int, IconModel> _iconCache = {};
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // 添加最近3个月的记录
    final now = DateTime.now();
    for (int i = 1; i <= 3; i++) {
      recentMonths.add(DateTime(now.year, now.month - i));
    }
    
    // 加载当月预算数据
    _loadBudgetData();
  }

  // 显示月份选择器
  void _showMonthPicker() async {
    final result = await MonthPickerModal.show(
      context: context,
      initialDate: _selectedDate,
      recentMonths: recentMonths,
    );
    
    if (result != null) {
      setState(() {
        _selectedDate = result;
        // 将选中的月份添加到最近记录中
        if (!recentMonths.any((date) => 
          date.year == result.year && date.month == result.month
        )) {
          recentMonths.insert(0, result);
          if (recentMonths.length > 5) {
            recentMonths.removeLast();
          }
        }
      });
    }
  }

  // 加载预算数据
  Future<void> _loadBudgetData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // 获取指定月份的预算数据，根据isFamilyBudget设置决定获取个人或家庭预算
      final categories = await _budgetService.getBudgetCategories(
        context: context,
        isFamilyBudget: widget.isFamilyBudget, // 使用widget属性
      );
      
      setState(() {
        _budgetCategories = categories;
        _isLoading = false;
      });
      
      // 预加载所有图标
      _preloadIcons();
    } catch (e) {
      setState(() {
        _errorMessage = '加载预算数据失败: $e';
        _isLoading = false;
        
        // 加载失败时使用示例数据
        if (_budgetCategories.isEmpty) {
          _budgetCategories = dummyCategories;
          
          // 预加载示例数据的图标
          _preloadIcons();
        }
      });
    }
  }

  void _handleMonthChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    // 重新加载选中月份的数据
    _loadBudgetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBudgetCategories(),
                  const SizedBox(height: 16),
                  const BudgetTips(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildHeader() {
    return BudgetHeader(
      selectedDate: _selectedDate,
      onMonthSelected: _handleMonthChanged,
    );
  }

  // 预算分类区域
  Widget _buildBudgetCategories() {
    return Container(
      margin: EdgeInsets.zero,
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
          // 标题和操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '预算',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: 实现复制上月功能
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.copy,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '复制上月',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showCategoryModal(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.plus,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '添加类别',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 加载状态
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          // 错误状态
          else if (_errorMessage.isNotEmpty && _budgetCategories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadBudgetData,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          // 数据为空
          else if (_budgetCategories.isEmpty) 
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '没有预算数据',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '点击"添加类别"创建您的第一个预算',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // 预算分类列表
          else
          ...List.generate(
              _budgetCategories.length,
            (index) => Padding(
                padding: EdgeInsets.only(bottom: index < _budgetCategories.length - 1 ? 12 : 0),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    bool isHovered = false;
                    
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => isHovered = true),
                      onExit: (_) => setState(() => isHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                          color: isHovered ? Colors.grey[50] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isHovered ? Colors.grey[200]! : Colors.grey[100]!),
                          boxShadow: isHovered 
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  spreadRadius: 0,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showCategoryModal(context, _budgetCategories[index]),
                            borderRadius: BorderRadius.circular(12),
                            hoverColor: Colors.grey[50],
                            splashColor: Colors.grey[100],
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      // 类别信息和菜单按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // 类别图标
                              Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                              color: _getCategoryColor(_budgetCategories[index].iconId).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                              _getCategoryIcon(_budgetCategories[index].iconId),
                                              color: _getCategoryColor(_budgetCategories[index].iconId),
                                  size: 20,
                                ),
                              ),
                              // 类别名称和描述
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                                _budgetCategories[index].name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                                _budgetCategories[index].description ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // 同比数据（移到右上角）
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.chartLine,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '较上月',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                            _getComparisonText(_budgetCategories[index].monthOverMonthChange),
                                style: TextStyle(
                                  fontSize: 12,
                                              color: _getComparisonColor(_budgetCategories[index].monthOverMonthChange),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 预算进度
                      Column(
                        children: [
                          // 进度数值
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                            '已用 ¥${_budgetCategories[index].spent.toStringAsFixed(0)} / ¥${_budgetCategories[index].budget.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                            '${((_budgetCategories[index].spent / _budgetCategories[index].budget) * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                              color: _budgetCategories[index].spent > _budgetCategories[index].budget
                                      ? Colors.red
                                      : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // 进度条
                          LayoutBuilder(
                            builder: (context, constraints) {
                                          final progress = (_budgetCategories[index].spent / _budgetCategories[index].budget)
                                  .clamp(0.0, 1.0);
                              return Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: constraints.maxWidth * progress,
                                      decoration: BoxDecoration(
                                                    color: _getCategoryColor(_budgetCategories[index].iconId),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                          ),
                        ),
                      ),
                    );
                  },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取同比文本
  String _getComparisonText(double change) {
    if (change == 0) return '持平';
    final prefix = change > 0 ? '+' : '';
    return '$prefix${change.toStringAsFixed(0)}%';
  }

  // 获取同比颜色
  Color _getComparisonColor(double change) {
    if (change > 0) return Colors.red;
    if (change < 0) return Colors.green;
    return Colors.grey[600]!;
  }

  void _showCategoryModal(BuildContext context, [BudgetCategory? category]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
              builder: (context) => BudgetCategoryModal(
            category: category,
            isFamilyBudget: widget.isFamilyBudget,
          ),
    );
    
    // 模态框关闭后重新加载预算数据
    _loadBudgetData();
  }

  // 获取图标的辅助方法
  IconData _getCategoryIcon(int iconId) {
    // 默认图标
    IconData defaultIcon = FontAwesomeIcons.tag;
    
    // 尝试从缓存中获取
    if (_iconCache.containsKey(iconId)) {
      return _iconCache[iconId]!.icon;
    }
    
    // 异步加载并更新缓存，但立即返回默认图标
    _loadIconById(iconId);
    return defaultIcon;
  }
  
  // 获取图标颜色的辅助方法
  Color _getCategoryColor(int iconId) {
    // 默认颜色
    Color defaultColor = Colors.grey;
    
    // 尝试从缓存中获取
    if (_iconCache.containsKey(iconId)) {
      return _iconCache[iconId]!.color;
    }
    
    // 异步加载并更新缓存，但立即返回默认颜色
    _loadIconById(iconId);
    return defaultColor;
  }
  
  // 异步加载图标并更新缓存
  Future<void> _loadIconById(int iconId) async {
    if (!_iconCache.containsKey(iconId)) {
      try {
        final icon = await _iconService.getIconById(iconId, context: context);
        if (icon != null) {
          setState(() {
            _iconCache[iconId] = icon;
          });
        }
      } catch (e) {
        print('加载图标失败: $e');
      }
    }
  }
  
  // 预加载所有预算类别的图标
  Future<void> _preloadIcons() async {
    for (var category in _budgetCategories) {
      await _loadIconById(category.iconId);
    }
  }
}

// 临时数据
final List<BudgetCategory> dummyCategories = [
  BudgetCategory(
    id: '1',
    name: '住房',
    description: '包含房租、物业费等',
    icon: FontAwesomeIcons.home,
    budget: 3000,
    spent: 2800,
    color: Colors.red,
    monthOverMonthChange: 5,
    iconId: 1,
  ),
  BudgetCategory(
    id: '2',
    name: '餐饮',
    description: '包含日常饮食、外卖',
    icon: FontAwesomeIcons.utensils,
    budget: 1000,
    spent: 650,
    color: Colors.purple,
    monthOverMonthChange: -8,
    iconId: 2,
  ),
  BudgetCategory(
    id: '3',
    name: '购物',
    description: '包含日用品、服装等',
    icon: FontAwesomeIcons.cartShopping,
    budget: 800,
    spent: 450,
    color: Colors.blue,
    monthOverMonthChange: 0,
    iconId: 3,
  ),
];
