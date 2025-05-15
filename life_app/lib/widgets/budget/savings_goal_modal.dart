import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/savings_goal.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_icons.dart';
import '../common/number_input.dart';
import '../common/category_selector.dart';
import '../common/month_picker_modal.dart';
import '../../services/icon_service.dart';
import '../../models/icon.dart';
import '../../services/budget_service.dart';

class SavingsGoalModal extends StatefulWidget {
  final SavingsGoal? goal;
  final bool isFamilySavings; // 添加家庭储蓄标识

  const SavingsGoalModal({
    super.key,
    this.goal,
    this.isFamilySavings = false, // 默认为个人储蓄目标
  });

  @override
  State<SavingsGoalModal> createState() => _SavingsGoalModalState();
}

class _SavingsGoalModalState extends State<SavingsGoalModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  late double _targetAmount;
  late double _monthlyTarget;
  late DateTime _targetDate;
  IconData _selectedIcon = AppIcons.housing;
  Color _selectedColor = const Color(0xFF8B5CF6);
  bool _showSuggestion = false;
  
  // 类别选择器相关变量
  List<CategoryItem> _categories = [];
  int _selectedCategoryIndex = 0;
  
  // 添加图标服务和加载状态
  late IconService _iconService;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _iconService = IconService();
    
    if (widget.goal != null) {
      _nameController.text = widget.goal!.name;
      _targetAmount = widget.goal!.targetAmount;
      _monthlyTarget = widget.goal!.monthlyTarget;
      _targetDate = widget.goal!.targetDate;
      _selectedIcon = widget.goal!.icon;
      _selectedColor = widget.goal!.color;
      
      if (widget.goal!.note != null) {
        _noteController.text = widget.goal!.note!;
      }
    } else {
      _targetAmount = 10000;
      _monthlyTarget = 1000;
      _targetDate = DateTime.now().add(const Duration(days: 365));
    }
    
    // 初始化类别列表
    _loadCategoryIcons();
  }
  
  // 从后端加载图标
  void _loadCategoryIcons() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      // 从IconService获取储蓄目标类别图标
      final icons = await _iconService.getUserAvailableIcons(context: context);
      
      // 筛选出储蓄目标类别的图标 (categoryId = 3)
      final savingsIcons = icons.where((icon) => icon.categoryId == 3).toList();
      
      // 转换为CategoryItem格式
      final categories = savingsIcons.map((icon) => icon.toCategoryItem()).toList();
      
      // 如果没有图标，不再添加默认图标
      setState(() {
        _categories = categories;
        _isLoading = false;
        
        // 如果是编辑模式，尝试选中匹配的类别
        if (widget.goal != null) {
          final index = _categories.indexWhere((c) => 
            c.label == widget.goal!.name || 
            c.icon == widget.goal!.icon);
          if (index != -1) {
            _selectedCategoryIndex = index;
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载储蓄目标类别失败: $e';
        _isLoading = false;
        
        // 加载失败时不再使用默认图标，而是设置为空列表
        _categories = [];
      });
    }
  }
  
  // 处理类别选择
  void _onCategorySelected(int index) {
    HapticFeedback.lightImpact(); // 添加触感反馈
    setState(() {
      _selectedCategoryIndex = index;
      final category = _categories[index];
      _selectedIcon = category.icon;
      _selectedColor = category.color;
      
      // 始终设置名称为类别名称（因为UI上不再显示名称输入框）
      if (widget.goal == null) {
        _nameController.text = category.label;
      }
      
      // 根据类别设置推荐金额（仅在创建新目标时）
      if (widget.goal == null) {
        if (category.label == '住房') {
          _targetAmount = 500000;
        } else if (category.label == '旅行') {
          _targetAmount = 20000;
        } else if (category.label == '教育') {
          _targetAmount = 100000;
        } else if (category.label == '购车') {
          _targetAmount = 200000;
        } else if (category.label == '装修') {
          _targetAmount = 100000;
        } else if (category.label == '电子产品') {
          _targetAmount = 10000;
        } else if (category.label == '结婚') {
          _targetAmount = 100000;
        } else if (category.label == '医疗') {
          _targetAmount = 50000;
        } else if (category.label == '投资') {
          _targetAmount = 50000;
        }
        
        // 更新每月存入金额
        _updateMonthlyTarget();
      }
    });
  }
  
  // 处理添加类别
  void _onAddCategory(String name, IconData icon, Color color) {
    setState(() {
      final newId = _categories.length + 1;
      final newCategory = CategoryItem(
        id: newId,
        icon: icon,
        label: name,
        color: color,
      );
      
      _categories.add(newCategory);
      _selectedCategoryIndex = _categories.length - 1;
      _selectedIcon = icon;
      _selectedColor = color;
      _nameController.text = name;
    });
  }

  void _updateMonthlyTarget() {
    if (_targetAmount > 0) {
      final months = _calculateMonths();
      _monthlyTarget = _targetAmount / months;
      _updateTargetDate();
    }
  }

  void _updateTargetDate() {
    if (_monthlyTarget > 0) {
      final months = (_targetAmount / _monthlyTarget).ceil();
      _targetDate = DateTime.now().add(Duration(days: months * 30));
    }
  }

  int _calculateMonths() {
    if (_monthlyTarget <= 0) return 0;
    return (_targetAmount / _monthlyTarget).ceil();
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月';
  }
  
  // 显示月份选择器
  void _showMonthPicker() async {
    HapticFeedback.mediumImpact(); // 添加触感反馈
    final DateTime? selectedDate = await MonthPickerModal.show(
      context: context,
      initialDate: _targetDate,
    );
    
    if (selectedDate != null) {
      setState(() {
        _targetDate = selectedDate;
        // 根据目标日期反向计算每月存入金额
        final monthsRemaining = _calculateMonthsUntil(selectedDate);
        if (monthsRemaining > 0) {
          _monthlyTarget = _targetAmount / monthsRemaining;
        }
      });
    }
  }
  
  // 计算从现在到目标日期的月数
  int _calculateMonthsUntil(DateTime targetDate) {
    final now = DateTime.now();
    return ((targetDate.year - now.year) * 12 + targetDate.month - now.month).clamp(1, 1000);
  }

  void _validateAndSave() async {
    HapticFeedback.mediumImpact(); // 添加触感反馈
    
    // 如果是新建目标且名称为空，使用默认名称
    if (widget.goal == null && _nameController.text.isEmpty) {
      if (_categories.isNotEmpty && _selectedCategoryIndex >= 0 && _selectedCategoryIndex < _categories.length) {
        _nameController.text = _categories[_selectedCategoryIndex].label;
      } else {
        _nameController.text = "我的储蓄目标";
      }
    }
    
    // 确保编辑模式下保留原名称
    if (widget.goal != null && _nameController.text.isEmpty) {
      _nameController.text = widget.goal!.name;
    }
    
    // 验证表单
    if (_targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入有效的目标金额'), 
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_monthlyTarget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入有效的每月存入金额'), 
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      
      // 获取选中类别的图标ID
      final selectedCategory = _categories[_selectedCategoryIndex];
      final iconId = selectedCategory.id;
      
      // 转换颜色为十六进制字符串格式
      final colorCode = '#${_selectedColor.value.toRadixString(16).substring(2)}';
      
      // 创建储蓄目标对象
      final goal = SavingsGoal(
        id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // 临时ID，后端会替换
        name: _nameController.text,
        icon: _selectedIcon,
        color: _selectedColor,
        targetAmount: _targetAmount,
        currentAmount: widget.goal?.currentAmount ?? 0,
        monthlyTarget: _monthlyTarget,
        targetDate: _targetDate,
        note: _noteController.text,
        iconId: iconId,
        colorCode: colorCode,
        completedAt: widget.goal?.completedAt, // 保留原始完成时间
        isFamilySavings: widget.isFamilySavings, // 使用构造函数的家庭储蓄标识
      );
      
      // 调用服务保存目标
      final budgetService = BudgetService();
      
      // 判断是新增还是编辑
      if (widget.goal == null) {
        // 新增目标
        await budgetService.addSavingsGoal(
          goal, 
          context: context,
          isFamilySavings: widget.isFamilySavings, // 传递家庭标识
        );
        
        // 显示成功消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('储蓄目标创建成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 编辑现有目标
        await budgetService.updateSavingsGoal(
          goal, 
          context: context,
          isFamilySavings: widget.isFamilySavings, // 传递家庭标识
        );
        
        // 显示成功消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('储蓄目标更新成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      // 关闭模态框
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _selectedColor;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部拖动条
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // 主内容区
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 类别标题和关闭按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.goal == null ? "储蓄目标类别" : "修改图标和颜色",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          icon: const Icon(AppIcons.close, size: 20),
                          color: AppTheme.textSecondary,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            padding: const EdgeInsets.all(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 加载状态
                    if (_isLoading)
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              '正在加载储蓄目标类别...',
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.goal == null 
                          ? CategorySelector(
                              categories: _categories,
                              selectedIndex: _selectedCategoryIndex,
                              onCategorySelected: _onCategorySelected,
                              onAddCategory: _onAddCategory,
                              title: '',  // 移除标题，因为我们已经在上面添加了
                              isExpenseType: false,
                              showAddButton: false, // 去掉添加按钮
                              itemsPerPage: 8,
                              parentContext: context,
                            )
                          : _buildSelectedIconDisplay(), // 编辑模式下仅显示当前图标，不可点击
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // 目标名称已隐藏，不再显示
                    
                    // 分别显示两个标题
                    Row(
                      children: [
                        Expanded(
                          child: _buildSectionTitle('目标金额', icon: Icons.savings_outlined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSectionTitle('每月存入', icon: Icons.calendar_month_outlined),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 输入框在同一行
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            value: _targetAmount,
                            step: 1000,
                            accentColor: accentColor,
                            onChanged: (value) {
                              setState(() {
                                _targetAmount = value;
                                _updateMonthlyTarget();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNumberInput(
                            value: _monthlyTarget,
                            step: 100,
                            accentColor: accentColor,
                            onChanged: (value) {
                              setState(() {
                                _monthlyTarget = value;
                                _updateTargetDate();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 2),
                    _buildInfoText('按此金额预计需要${_calculateMonths()}个月完成目标'),
                    
                    // 目标完成月份选择
                    const SizedBox(height: 12),
                    _buildSectionTitle('目标完成月份', icon: Icons.event_outlined),
                    const SizedBox(height: 4),
                    _buildDateSelector(
                      date: _targetDate,
                      accentColor: accentColor,
                      onTap: _showMonthPicker,
                    ),
                    const SizedBox(height: 2),
                    _buildInfoText('距今${_calculateMonthsUntil(_targetDate)}个月'),
                    
                    const SizedBox(height: 12),
                    _buildSectionTitle('备注', icon: Icons.note_outlined),
                    const SizedBox(height: 4),
                    _buildNoteField(
                      controller: _noteController,
                      accentColor: accentColor,
                    ),
                    
                    const SizedBox(height: 16),
                    _buildActionButtons(accentColor),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 构建标题组件
  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
  
  // 构建文本输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Color accentColor,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
        style: const TextStyle(fontSize: 14),
        cursorColor: accentColor,
      ),
    );
  }
  
  // 构建数字输入组件
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
        borderRadius: BorderRadius.circular(12),
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
  
  // 构建日期选择器
  Widget _buildDateSelector({
    required DateTime date,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
          onTap: onTap,
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
                  _formatDate(date),
                  style: const TextStyle(fontSize: 14),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: accentColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 构建备注文本框
  Widget _buildNoteField({
    required TextEditingController controller,
    required Color accentColor,
  }) {
    return Container(
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
      child: TextField(
        controller: controller,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: '添加备注（可选）',
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
        style: const TextStyle(fontSize: 14),
        cursorColor: accentColor,
      ),
    );
  }
  
  // 构建操作按钮
  Widget _buildActionButtons(Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
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
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _validateAndSave,
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '保存',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // 信息文本
  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // 在编辑模式下显示当前选中的图标（不可点击）
  Widget _buildSelectedIconDisplay() {
    // 如果没有找到匹配的类别索引，使用一个默认值
    final displayCategory = _selectedCategoryIndex < _categories.length && _selectedCategoryIndex >= 0
        ? _categories[_selectedCategoryIndex]
        : CategoryItem(
            id: 0,
            icon: _selectedIcon,
            label: _nameController.text,
            color: _selectedColor,
          );
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "当前图标（编辑模式下不可更改）",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: displayCategory.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  displayCategory.icon,
                  color: displayCategory.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayCategory.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "不可更改图标和颜色",
                    style: TextStyle(
                      fontSize: 12,
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
  }
}
