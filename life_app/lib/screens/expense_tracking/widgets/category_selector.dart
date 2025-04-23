import 'package:flutter/material.dart';
import '../models/transaction_category.dart';
import '../models/transaction_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:life_app/widgets/common/icon_selector_modal.dart';

class CategorySelector extends StatefulWidget {
  final TransactionType transactionType;
  final TransactionCategory? selectedCategory;
  final Function(TransactionCategory) onCategorySelected;
  // 添加新的回调函数，用于创建自定义类别
  final Function(String, IconData, Color)? onAddCategory;

  const CategorySelector({
    super.key,
    required this.transactionType,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.onAddCategory,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  // 添加新类别所需的控制器
  final TextEditingController _newCategoryNameController = TextEditingController();
  Color _newCategoryColor = Colors.blue;
  IconData _newCategoryIcon = FontAwesomeIcons.tag;

  @override
  void dispose() {
    _newCategoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根据交易类型获取相应的类别列表
    final categories = TransactionCategories.getCategoriesByType(widget.transactionType);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '类别',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: categories.length + 1, // 加1为了添加"更多"选项
            itemBuilder: (context, index) {
              if (index < categories.length) {
                return _buildCategoryItem(categories[index]);
              } else {
                // "更多"选项，现在改为"添加"
                return _buildAddCategoryItem();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(TransactionCategory category) {
    final isSelected = widget.selectedCategory?.id == category.id;
    
    return GestureDetector(
      onTap: () => widget.onCategorySelected(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: isSelected
                  ? Border.all(color: category.color, width: 2)
                  : null,
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? category.color : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddCategoryItem() {
    return GestureDetector(
      onTap: () {
        if (widget.onAddCategory != null) {
          _showAddCategoryDialog();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.add,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '添加',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 显示添加类别对话框
  void _showAddCategoryDialog() {
    // 重置控制器和状态
    _newCategoryNameController.clear();
    _newCategoryColor = widget.transactionType == TransactionType.expense ? Colors.red : Colors.green;
    _newCategoryIcon = FontAwesomeIcons.tag;
    
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
                                  content: Text('正在创建类别...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              
                              // 回调父组件的添加方法
                              widget.onAddCategory!(
                                _newCategoryNameController.text,
                                _newCategoryIcon,
                                _newCategoryColor
                              );
                              
                              // 关闭对话框
                              Navigator.pop(context);
                              
                              // 显示成功提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('类别创建成功'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              // 显示错误提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('创建类别失败: ${e.toString()}'),
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
}
