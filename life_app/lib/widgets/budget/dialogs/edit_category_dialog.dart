import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/budget/budget_category.dart';
import '../../../themes/budget_theme.dart';

class EditCategoryDialog extends StatefulWidget {
  final BudgetCategory? category;

  const EditCategoryDialog({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  String _selectedIcon = 'home';
  String _selectedColor = 'red';
  String? _errorText;

  final List<Map<String, String>> _icons = [
    {'name': 'home', 'icon': 'home'},
    {'name': 'utensils', 'icon': 'utensils'},
    {'name': 'shopping-cart', 'icon': 'shopping-cart'},
    {'name': 'car', 'icon': 'car'},
    {'name': 'plane', 'icon': 'plane'},
    {'name': 'heart', 'icon': 'heart'},
    {'name': 'book', 'icon': 'book'},
    {'name': 'gamepad', 'icon': 'gamepad'},
  ];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'red', 'color': Color(0xFFDC2626)},
    {'name': 'purple', 'color': Color(0xFF9333EA)},
    {'name': 'blue', 'color': Color(0xFF2563EB)},
    {'name': 'green', 'color': Color(0xFF16A34A)},
    {'name': 'yellow', 'color': Color(0xFFD97706)},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(text: widget.category?.description ?? '');
    _budgetController = TextEditingController(
      text: widget.category?.budget.toStringAsFixed(0) ?? '',
    );
    if (widget.category != null) {
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _validateInput() {
    if (_nameController.text.isEmpty) {
      setState(() => _errorText = '请输入类别名称');
      return;
    }

    final budget = double.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) {
      setState(() => _errorText = '请输入有效的预算金额');
      return;
    }

    setState(() => _errorText = null);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return FontAwesomeIcons.home;
      case 'utensils':
        return FontAwesomeIcons.utensils;
      case 'shopping-cart':
        return FontAwesomeIcons.shoppingCart;
      case 'car':
        return FontAwesomeIcons.car;
      case 'plane':
        return FontAwesomeIcons.plane;
      case 'heart':
        return FontAwesomeIcons.heart;
      case 'book':
        return FontAwesomeIcons.book;
      case 'gamepad':
        return FontAwesomeIcons.gamepad;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(BudgetTheme.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                widget.category == null ? '添加类别' : '编辑类别',
                style: BudgetTheme.headingStyle,
              ),

              const SizedBox(height: BudgetTheme.spacingLarge),

              // 名称输入框
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '类别名称',
                  hintText: '请输入类别名称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (_) => _validateInput(),
              ),

              const SizedBox(height: BudgetTheme.spacingMedium),

              // 描述输入框
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: '描述',
                  hintText: '请输入类别描述',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: BudgetTheme.spacingMedium),

              // 预算输入框
              TextField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: '预算金额',
                  hintText: '请输入预算金额',
                  prefixText: '¥ ',
                  errorText: _errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (_) => _validateInput(),
              ),

              const SizedBox(height: BudgetTheme.spacingMedium),

              // 图标选择
              Text(
                '选择图标',
                style: BudgetTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: BudgetTheme.spacingSmall),
              Wrap(
                spacing: BudgetTheme.spacingMedium,
                runSpacing: BudgetTheme.spacingMedium,
                children: _icons.map((icon) {
                  final isSelected = icon['name'] == _selectedIcon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon['name']!),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BudgetTheme.primaryColor.withOpacity(0.1)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected
                            ? Border.all(
                                color: BudgetTheme.primaryColor,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        _getIconData(icon['name']!),
                        color: isSelected
                            ? BudgetTheme.primaryColor
                            : BudgetTheme.textSecondaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: BudgetTheme.spacingMedium),

              // 颜色选择
              Text(
                '选择颜色',
                style: BudgetTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: BudgetTheme.spacingSmall),
              Wrap(
                spacing: BudgetTheme.spacingMedium,
                runSpacing: BudgetTheme.spacingMedium,
                children: _colors.map((color) {
                  final isSelected = color['name'] == _selectedColor;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = color['name']!),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected
                            ? Border.all(
                                color: color['color'],
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        Icons.circle,
                        color: color['color'],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: BudgetTheme.spacingLarge),

              // 按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: BudgetTheme.spacingMedium),
                  ElevatedButton(
                    onPressed: _errorText != null
                        ? null
                        : () {
                            final category = BudgetCategory(
                              id: widget.category?.id ?? DateTime.now().toString(),
                              name: _nameController.text,
                              description: _descriptionController.text,
                              icon: _selectedIcon,
                              color: _selectedColor,
                              budget: double.parse(_budgetController.text),
                              spent: widget.category?.spent ?? 0,
                              lastMonthSpent: widget.category?.lastMonthSpent ?? 0,
                            );
                            Navigator.of(context).pop(category);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BudgetTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 