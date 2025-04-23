import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/savings_goal.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_icons.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onEdit;
  final VoidCallback? onMarkAsCompleted;
  final VoidCallback? onMarkAsDeleted;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    required this.onEdit,
    this.onMarkAsCompleted,
    this.onMarkAsDeleted,
  });

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月';
  }

  @override
  Widget build(BuildContext context) {
    final progress = goal.currentAmount / goal.targetAmount;
    final percentage = (progress * 100).round();
    
    // 调试信息
    print('渲染储蓄目标卡片: ${goal.name}, iconId=${goal.iconId}, 颜色=${goal.color.toString()}');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      goal.icon,
                      color: goal.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '目标日期：${_formatDate(goal.targetDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${goal.currentAmount.toStringAsFixed(0)} / ¥${goal.targetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '每月储蓄 ¥${goal.monthlyTarget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已完成',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  color: goal.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
                    color: goal.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '当前进度',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${goal.currentAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '每月存入',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${goal.monthlyTarget.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onMarkAsDeleted != null) 
                TextButton.icon(
                  onPressed: onMarkAsDeleted,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.red,
                  ),
                  label: const Text(
                    '作废',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                label: const Text(
                  '编辑',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              const SizedBox(width: 8),
              if (onMarkAsCompleted != null)
                TextButton.icon(
                  onPressed: onMarkAsCompleted,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.green,
                  ),
                  label: const Text(
                    '完成',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
