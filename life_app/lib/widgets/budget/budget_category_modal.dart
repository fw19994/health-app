import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/budget_category.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../services/budget_service.dart';
import '../common/number_input.dart';
import '../common/category_selector.dart';
import '../common/month_picker_modal.dart';
import '../../services/icon_service.dart';

class BudgetCategoryModal extends StatefulWidget {
  final BudgetCategory? category;

  const BudgetCategoryModal({
    super.key,
    this.category,
  });

  @override
  State<BudgetCategoryModal> createState() => _BudgetCategoryModalState();
}

class _BudgetCategoryModalState extends State<BudgetCategoryModal> {
  late double _budget;
  late String _reminderThreshold;
  int _selectedCategoryIndex = 0;
  late DateTime _budgetDate;
  String _note = '';
  bool _isLoading = true;
  String _errorMessage = '';
  
  // 更新提醒阈值选项
  final List<String> _reminderThresholds = ['70', '80', '90', '100', 'none'];
  
  // 预定义类别 - 将从后端获取
  List<CategoryItem> _categories = [];
  
  // 图标服务实例
  late IconService _iconService;

  @override
  void initState() {
    super.initState();
    _budget = widget.category?.budget ?? 500.00; // 默认预算值更新为500
    _budgetDate = DateTime.now(); // 默认为当前月份
    _reminderThreshold = '80';
    _iconService = IconService();
    
    // 从后端加载图标
    _loadCategoryIcons();
    
    // 如果是编辑现有类别，设置选中的类别索引
    if (widget.category != null) {
      Future.delayed(Duration.zero, () {
        final index = _categories.indexWhere((c) => 
          c.label == widget.category!.name || 
          c.id.toString() == widget.category!.id);
        if (index != -1) {
          setState(() {
            _selectedCategoryIndex = index;
          });
        }
      });
    }
  }
  
  // 从后端加载图标
  void _loadCategoryIcons() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      // 从IconService获取支出类别图标
      final icons = await _iconService.getUserAvailableIcons(context: context);
      
      // 筛选出支出类别的图标 (categoryId = 1)
      final expenseIcons = icons.where((icon) => icon.categoryId == 1).toList();
      
      // 转换为CategoryItem格式
      final categories = expenseIcons.map((icon) => icon.toCategoryItem()).toList();
      
      // 如果没有图标，添加默认图标
      if (categories.isEmpty) {
        categories.addAll([
          CategoryItem(icon: FontAwesomeIcons.house, label: '住房', color: Colors.red, id: 1),
          CategoryItem(icon: FontAwesomeIcons.utensils, label: '餐饮', color: Colors.orange, id: 2),
          CategoryItem(icon: FontAwesomeIcons.car, label: '交通', color: Colors.blue, id: 3),
        ]);
      }
      
      setState(() {
        _categories = categories;
        _isLoading = false;
        
        // 如果是编辑模式，设置选中的类别索引
        if (widget.category != null) {
          final index = _categories.indexWhere((c) => 
            c.label == widget.category!.name || 
            c.id.toString() == widget.category!.id);
          if (index != -1) {
            _selectedCategoryIndex = index;
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载预算类别失败: $e';
        _isLoading = false;
        
        // 加载失败时使用默认图标
        _categories = [
          CategoryItem(icon: FontAwesomeIcons.house, label: '住房', color: Colors.red, id: 1),
          CategoryItem(icon: FontAwesomeIcons.utensils, label: '餐饮', color: Colors.orange, id: 2),
          CategoryItem(icon: FontAwesomeIcons.car, label: '交通', color: Colors.blue, id: 3),
          CategoryItem(icon: FontAwesomeIcons.shirt, label: '服装', color: Colors.purple, id: 4),
          CategoryItem(icon: FontAwesomeIcons.basketShopping, label: '购物', color: Colors.pink, id: 5),
          CategoryItem(icon: FontAwesomeIcons.heartPulse, label: '医疗', color: Colors.teal, id: 6),
          CategoryItem(icon: FontAwesomeIcons.graduationCap, label: '教育', color: Colors.green, id: 7),
          CategoryItem(icon: FontAwesomeIcons.film, label: '娱乐', color: Colors.indigo, id: 8),
        ];
      });
    }
  }
  
  // 格式化日期为"2024年4月"的形式
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月';
  }
  
  // 显示月份选择器
  void _showMonthPicker() async {
    HapticFeedback.mediumImpact(); // 添加触感反馈
    final DateTime? selectedDate = await MonthPickerModal.show(
      context: context,
      initialDate: _budgetDate,
    );
    
    if (selectedDate != null) {
      setState(() {
        _budgetDate = selectedDate;
      });
    }
  }

  // 获取提醒阈值显示文本
  String _getReminderThresholdText(String value) {
    switch (value) {
      case '70':
        return '使用70%时提醒';
      case '80':
        return '使用80%时提醒';
      case '90':
        return '使用90%时提醒';
      case '100':
        return '预算用完时提醒';
      case 'none':
        return '不提醒';
      default:
        return '使用80%时提醒';
    }
  }
  
  // 处理添加新类别
  void _handleAddCategory(String name, IconData icon, Color color) {
    // 这里可以添加创建新类别的逻辑
    setState(() {
      _categories.add(CategoryItem(
        icon: icon,
        label: name,
        color: color,
        id: _categories.length + 1,
      ));
      _selectedCategoryIndex = _categories.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[LOG] BudgetCategoryModal from budget_category_modal.dart is used');
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.category == null ? '添加预算' : '编辑预算',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 加载状态
                if (_isLoading)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          '正在加载预算类别...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                // 错误状态
                else if (_errorMessage.isNotEmpty && _categories.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red[300]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCategoryIcons,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  )
                // 正常状态
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 根据是否编辑模式显示不同的类别选择器
                      widget.category == null
                        ? CategorySelector(
                            categories: _categories,
                            selectedIndex: _selectedCategoryIndex,
                            onCategorySelected: (index) {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                            onAddCategory: _handleAddCategory,
                            title: '选择预算类别',
                            isExpenseType: true,
                            showAddButton: false,
                          )
                        : _buildReadOnlyCategoryDisplay(),
                      
                      const SizedBox(height: 24),
                      const Text(
                        '预算金额',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildNumberInput(
                        value: _budget,
                        step: 100,
                        accentColor: AppTheme.primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _budget = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '预算周期',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 使用与储蓄目标相同的日期选择器
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showMonthPicker,
                            borderRadius: BorderRadius.circular(8),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(_budgetDate),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppTheme.primaryColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '超支提醒',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _reminderThreshold,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: _reminderThresholds.map((threshold) => DropdownMenuItem(
                          value: threshold,
                          child: Text(_getReminderThresholdText(threshold)),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _reminderThreshold = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),
                      // 备注输入框
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '备注',
                          hintText: '填写本类别的预算备注（选填）',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        initialValue: _note,
                        maxLines: 2,
                        onChanged: (val) {
                          setState(() {
                            _note = val;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: const Text(
                                  '取消',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _categories.isEmpty || _selectedCategoryIndex >= _categories.length 
                                  ? null // 禁用按钮
                                  : () async {
                                    // 创建预算类别并保存
                                    final selectedCategory = _categories[_selectedCategoryIndex];
                                    final budgetCategory = BudgetCategory(
                                      id: widget.category?.id ?? DateTime.now().toString(),
                                      name: selectedCategory.label,
                                      icon: selectedCategory.icon,
                                      budget: _budget,
                                      spent: widget.category?.spent ?? 0,
                                      color: selectedCategory.color,
                                      reminderEnabled: _reminderThreshold != 'none',
                                      description: _note,
                                      iconId: selectedCategory.id,
                                    );
                                    
                                    try {
                                      final budgetService = BudgetService();
                                      await budgetService.addBudgetCategory(
                                        budgetCategory,
                                        context: context, // 传递context以获取认证令牌
                                      );
                                      
                                      // 显示成功消息
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('预算添加成功'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } catch (e) {
                                      // 显示错误消息
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('预算添加失败: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  '保存',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建数字输入组件，参考储蓄目标模态框的实现
  Widget _buildNumberInput({
    required double value,
    required double step,
    required Color accentColor,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              '¥',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: value.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (text) {
                final newValue = double.tryParse(text);
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // 创建一个只读的类别显示组件，用于编辑模式
  Widget _buildReadOnlyCategoryDisplay() {
    // 确保有有效的选中索引
    if (_selectedCategoryIndex < 0 || _selectedCategoryIndex >= _categories.length) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "无法显示类别信息",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    // 获取当前选中的类别
    final selectedCategory = _categories[_selectedCategoryIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '预算类别（编辑模式下不可更改）',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              // 类别图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selectedCategory.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  selectedCategory.icon,
                  color: selectedCategory.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // 类别名称和提示文本
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCategory.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "编辑模式下不可更改类别",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
