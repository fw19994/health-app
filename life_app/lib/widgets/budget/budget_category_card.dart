import 'package:flutter/material.dart';
import '../../models/budget_category.dart';
import '../../themes/app_theme.dart';

class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategory category;
  final VoidCallback onEdit;

  const BudgetCategoryCard({
    super.key,
    required this.category,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = category.spent / category.budget;
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '已用 ¥${category.spent.toStringAsFixed(2)} / ¥${category.budget.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.more_horiz),
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _getProgressColor(percentage),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getProgressColor(percentage),
                ),
              ),
              Row(
                children: [
                  const Text(
                    '预算提醒',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: category.reminderEnabled,
                    onChanged: (value) {},
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage >= 100) {
      return const Color(0xFFEF4444); // 红色
    } else if (percentage >= 80) {
      return const Color(0xFFF97316); // 橙色
    } else {
      return const Color(0xFF10B981); // 绿色
    }
  }
}
