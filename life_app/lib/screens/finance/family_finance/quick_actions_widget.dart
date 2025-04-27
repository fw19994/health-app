import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuickActionsWidget extends StatelessWidget {
  final Function() onAddExpense;
  final Function() onViewReport;
  final Function() onMemberAnalysis;

  const QuickActionsWidget({
    Key? key,
    required this.onAddExpense,
    required this.onViewReport,
    required this.onMemberAnalysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: FontAwesomeIcons.plus,
            label: '添加支出',
            color: const Color(0xFF16A34A),
            onTap: onAddExpense,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: FontAwesomeIcons.chartColumn,
            label: '分析报告',
            color: const Color(0xFF8B5CF6),
            onTap: onViewReport,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: FontAwesomeIcons.userGroup,
            label: '成员分析',
            color: const Color(0xFF10B981),
            onTap: onMemberAnalysis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 