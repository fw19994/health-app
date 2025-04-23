import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/budget/budget_category.dart';
import '../../themes/budget_theme.dart';
import 'dialogs/edit_category_dialog.dart';

class BudgetCategoryList extends StatelessWidget {
  final List<BudgetCategory> categories;
  final Function(BudgetCategory) onCategoryAdded;
  final Function(BudgetCategory) onCategoryUpdated;
  final Function(String) onCategoryDeleted;

  const BudgetCategoryList({
    Key? key,
    required this.categories,
    required this.onCategoryAdded,
    required this.onCategoryUpdated,
    required this.onCategoryDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和添加按钮
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BudgetTheme.spacingLarge,
            vertical: BudgetTheme.spacingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '预算类别',
                style: BudgetTheme.headingStyle,
              ),
              IconButton(
                onPressed: () => _showAddCategoryDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                color: BudgetTheme.primaryColor,
              ),
            ],
          ),
        ),

        // 类别列表
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryCard(
              category: category,
              onEdit: () => _showEditCategoryDialog(context, category),
              onDelete: () => _showDeleteConfirmation(context, category),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final result = await showDialog<BudgetCategory>(
      context: context,
      builder: (context) => const EditCategoryDialog(),
    );

    if (result != null) {
      onCategoryAdded(result);
    }
  }

  Future<void> _showEditCategoryDialog(
    BuildContext context,
    BudgetCategory category,
  ) async {
    final result = await showDialog<BudgetCategory>(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );

    if (result != null) {
      onCategoryUpdated(result);
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    BudgetCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除类别'),
        content: Text('确定要删除"${category.name}"类别吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: BudgetTheme.errorColor,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onCategoryDeleted(category.id);
    }
  }
}

class _CategoryCard extends StatelessWidget {
  final BudgetCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    Key? key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: BudgetTheme.spacingLarge,
        vertical: BudgetTheme.spacingSmall,
      ),
      decoration: BudgetTheme.cardDecoration,
      child: Column(
        children: [
          // 类别信息
          Padding(
            padding: const EdgeInsets.all(BudgetTheme.spacingMedium),
            child: Row(
              children: [
                // 图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getColorFromString(category.color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    color: _getColorFromString(category.color),
                  ),
                ),
                const SizedBox(width: BudgetTheme.spacingMedium),

                // 类别名称和描述
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: BudgetTheme.subheadingStyle,
                      ),
                      if (category.description.isNotEmpty) ...[
                        const SizedBox(height: BudgetTheme.spacingSmall),
                        Text(
                          category.description,
                          style: BudgetTheme.captionStyle,
                        ),
                      ],
                    ],
                  ),
                ),

                // 编辑和删除按钮
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: BudgetTheme.textSecondaryColor,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: BudgetTheme.errorColor,
                ),
              ],
            ),
          ),

          // 预算进度
          Padding(
            padding: const EdgeInsets.fromLTRB(
              BudgetTheme.spacingMedium,
              0,
              BudgetTheme.spacingMedium,
              BudgetTheme.spacingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: category.usagePercentage / 100,
                    backgroundColor: BudgetTheme.progressBackgroundColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      category.isOverBudget
                          ? BudgetTheme.errorColor
                          : BudgetTheme.progressFillColor,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: BudgetTheme.spacingSmall),

                // 预算信息
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已使用: ¥${category.spent.toStringAsFixed(2)}',
                      style: BudgetTheme.captionStyle,
                    ),
                    Text(
                      '预算: ¥${category.budget.toStringAsFixed(2)}',
                      style: BudgetTheme.captionStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'red':
        return const Color(0xFFDC2626);
      case 'purple':
        return const Color(0xFF9333EA);
      case 'blue':
        return const Color(0xFF2563EB);
      case 'green':
        return const Color(0xFF16A34A);
      case 'yellow':
        return const Color(0xFFD97706);
      default:
        return BudgetTheme.primaryColor;
    }
  }
} 