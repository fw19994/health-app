import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/family_member.dart';

class FamilyOverview extends StatelessWidget {
  final FamilyMember member;

  const FamilyOverview({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            "全家财务总览",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: FontAwesomeIcons.wallet,
                iconBgColor: const Color(0xFF4F46E5),
                title: "家庭总收入",
                value: "¥${member.income.toStringAsFixed(0)}",
                trend: member.incomeChange,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                icon: FontAwesomeIcons.shoppingCart,
                iconBgColor: const Color(0xFFEF4444),
                title: "家庭总支出",
                value: "¥${member.expenses.toStringAsFixed(0)}",
                trend: member.expensesChange,
                isPositive: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String value,
    required double trend,
    required bool isPositive,
  }) {
    final trendColor = (trend > 0) == isPositive 
        ? const Color(0xFF10B981)  // 积极趋势 (绿色)
        : const Color(0xFFEF4444); // 消极趋势 (红色)
    
    final trendIcon = trend > 0
        ? FontAwesomeIcons.arrowUp
        : FontAwesomeIcons.arrowDown;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      trendIcon,
                      size: 12,
                      color: trendColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${trend.abs().toStringAsFixed(1)}% vs 上月",
                      style: TextStyle(
                        fontSize: 12,
                        color: trendColor,
                      ),
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
}
