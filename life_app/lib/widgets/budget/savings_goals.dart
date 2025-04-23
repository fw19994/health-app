import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/budget/savings_goal.dart';
import '../../themes/budget_theme.dart';
import '../common/progress_bar.dart';

class SavingsGoals extends StatelessWidget {
  const SavingsGoals({Key? key}) : super(key: key);

  // 模拟数据，实际应用中应该从数据源获取
  List<SavingsGoal> get _goals => [
    SavingsGoal(
      id: '1',
      name: '旅行基金',
      icon: 'plane',
      targetAmount: 15000,
      currentAmount: 8500,
      monthlySaving: 1000,
      targetDate: DateTime(2025, 7),
      priority: 'medium',
      reminderFrequency: 'monthly',
      notes: '计划明年7月去日本旅行，预计费用15000元。',
      remindersEnabled: true,
    ),
    SavingsGoal(
      id: '2',
      name: '教育基金',
      icon: 'graduation-cap',
      targetAmount: 50000,
      currentAmount: 12000,
      monthlySaving: 2000,
      targetDate: DateTime(2026, 9),
      priority: 'high',
      reminderFrequency: 'monthly',
      notes: '为未来的进修学习做准备。',
      remindersEnabled: true,
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
              Text('储蓄目标', style: BudgetTheme.subheadingStyle),
              TextButton.icon(
                onPressed: () {
                  // TODO: 显示添加目标弹窗
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('添加目标'),
                style: TextButton.styleFrom(
                  foregroundColor: BudgetTheme.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: BudgetTheme.spacingMedium),
          
          // 目标列表
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _goals.length,
            separatorBuilder: (context, index) => 
                const SizedBox(height: BudgetTheme.spacingMedium),
            itemBuilder: (context, index) {
              final goal = _goals[index];
              return _SavingsGoalCard(goal: goal);
            },
          ),
        ],
      ),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;

  const _SavingsGoalCard({
    Key? key,
    required this.goal,
  }) : super(key: key);

  IconData _getGoalIcon() {
    switch (goal.icon) {
      case 'plane':
        return FontAwesomeIcons.plane;
      case 'graduation-cap':
        return FontAwesomeIcons.graduationCap;
      default:
        return FontAwesomeIcons.piggyBank;
    }
  }

  Color _getIconColor() {
    switch (goal.icon) {
      case 'plane':
        return const Color(0xFFDBEAFE);
      case 'graduation-cap':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getIconTextColor() {
    switch (goal.icon) {
      case 'plane':
        return const Color(0xFF2563EB);
      case 'graduation-cap':
        return const Color(0xFF16A34A);
      default:
        return BudgetTheme.textSecondaryColor;
    }
  }

  String _formatMoney(double amount) {
    return '¥${amount.toStringAsFixed(0)}';
  }

  String _formatProgress(double progress) {
    return '${(progress * 100).toInt()}%';
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: 显示编辑目标弹窗
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(BudgetTheme.spacingMedium),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 目标信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        _getGoalIcon(),
                        color: _getIconTextColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: BudgetTheme.spacingMedium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: BudgetTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '目标日期：${_formatDate(goal.targetDate)}',
                          style: BudgetTheme.captionStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatMoney(goal.currentAmount)} / ${_formatMoney(goal.targetAmount)}',
                      style: BudgetTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '每月储蓄 ${_formatMoney(goal.monthlySaving)}',
                      style: BudgetTheme.captionStyle,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: BudgetTheme.spacingMedium),

            // 进度信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已完成',
                  style: BudgetTheme.bodyStyle,
                ),
                Text(
                  _formatProgress(goal.progress),
                  style: BudgetTheme.bodyStyle.copyWith(
                    color: _getIconTextColor(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: BudgetTheme.spacingSmall),

            // 进度条
            ProgressBar(
              progress: goal.progress,
              fillColor: _getIconTextColor(),
            ),
          ],
        ),
      ),
    );
  }
} 