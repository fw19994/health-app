import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/budget_category.dart';
import '../../themes/budget_theme.dart';
import '../common/progress_bar.dart';

class BudgetCategories extends StatelessWidget {
  const BudgetCategories({Key? key}) : super(key: key);

  // 模拟数据，实际应用中应该从数据源获取
  List<BudgetCategory> get _categories => [
    BudgetCategory(
      id: '1',
      name: '住房',
      description: '包含房租、物业费等',
      icon: FontAwesomeIcons.house,
      budget: 3000,
      spent: 2800,
      lastMonthSpent: 2667,
      color: Colors.red,
      iconId: 1,
    ),
    BudgetCategory(
      id: '2',
      name: '餐饮',
      description: '包含日常饮食、外卖',
      icon: FontAwesomeIcons.utensils,
      budget: 1000,
      spent: 650,
      lastMonthSpent: 706,
      color: Colors.purple,
      iconId: 2,
    ),
    BudgetCategory(
      id: '3',
      name: '购物',
      description: '包含日用品、服装等',
      icon: FontAwesomeIcons.shoppingCart,
      budget: 800,
      spent: 450,
      lastMonthSpent: 450,
      color: Colors.blue,
      iconId: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BudgetTheme.cardDecoration,
      padding: const EdgeInsets.all(BudgetTheme.spacingMedium),
      child: Column(
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('预算', style: BudgetTheme.subheadingStyle),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // TODO: 实现复制上月功能
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('复制上月'),
                    style: TextButton.styleFrom(
                      foregroundColor: BudgetTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: BudgetTheme.spacingSmall),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: 显示添加类别弹窗
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('添加类别'),
                    style: TextButton.styleFrom(
                      foregroundColor: BudgetTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: BudgetTheme.spacingMedium),
          
          // 分类列表
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => 
                const SizedBox(height: BudgetTheme.spacingMedium),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _CategoryCard(category: category);
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final BudgetCategory category;

  const _CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  Color _getIconColor() {
    // 直接使用颜色
    return category.color.withOpacity(0.1);
  }

  Color _getIconTextColor() {
    // 直接使用颜色
    return category.color;
  }

  IconData _getCategoryIcon() {
    // 直接使用图标
    return category.icon;
  }

  String _formatMoney(double amount) {
    return '¥${amount.toStringAsFixed(0)}';
  }

  String _formatProgress(double progress) {
    return '${(progress * 100).toInt()}%';
  }

  Widget _buildMonthOverMonthIndicator() {
    final change = category.monthOverMonthChange;
    String status;
    
    // 基于monthOverMonthChange计算状态
    if (change > 0) {
      status = 'increase';
    } else if (change < 0) {
      status = 'decrease';
    } else {
      status = 'same';
    }
    
    Color textColor;
    IconData icon;
    
    switch (status) {
      case 'increase':
        textColor = Colors.red;
        icon = Icons.arrow_upward;
        break;
      case 'decrease':
        textColor = Colors.green;
        icon = Icons.arrow_downward;
        break;
      default:
        textColor = BudgetTheme.textSecondaryColor;
        icon = Icons.remove;
    }

    return Row(
      children: [
        Icon(Icons.show_chart, size: 12, color: BudgetTheme.textSecondaryColor),
        const SizedBox(width: 4),
        Text(
          '较上月 ',
          style: BudgetTheme.captionStyle,
        ),
        if (status != 'same')
          Text(
            '${change.abs().toStringAsFixed(0)}%',
            style: BudgetTheme.captionStyle.copyWith(color: textColor),
          ),
        if (status == 'same')
          Text(
            '持平',
            style: BudgetTheme.captionStyle,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BudgetTheme.spacingMedium),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 类别信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getIconColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: _getIconTextColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: BudgetTheme.spacingMedium),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: BudgetTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        category.description,
                        style: BudgetTheme.captionStyle,
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF9CA3AF),
                ),
                onPressed: () {
                  // TODO: 显示类别操作菜单
                },
              ),
            ],
          ),

          const SizedBox(height: BudgetTheme.spacingMedium),

          // 进度信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已用 ${_formatMoney(category.spent)} / ${_formatMoney(category.budget)}',
                style: BudgetTheme.bodyStyle,
              ),
              Text(
                _formatProgress(category.progress),
                style: BudgetTheme.bodyStyle.copyWith(
                  color: category.progress > 0.9 ? Colors.red : BudgetTheme.textPrimaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: BudgetTheme.spacingSmall),

          // 进度条
          ProgressBar(
            progress: category.progress,
            fillColor: _getIconTextColor(),
          ),

          const SizedBox(height: BudgetTheme.spacingSmall),

          // 月度比较
          _buildMonthOverMonthIndicator(),
        ],
      ),
    );
  }
} 