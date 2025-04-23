import 'package:flutter/material.dart';
import '../../member_finances/models/family_member.dart';

class IncomeExpenseComparison extends StatelessWidget {
  final FamilyMember member;

  const IncomeExpenseComparison({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    // 计算结余
    final double balance = member.income - member.expenses;
    
    // 计算支出比例
    final double expenseRatio = member.expenses / member.income;
    
    // 计算储蓄比例
    final double savingsRatio = 1 - expenseRatio;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "收入与支出",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // 收入、支出、结余数据
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "收入: ¥${member.income.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                "支出: ¥${member.expenses.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                "结余: ¥${balance.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 进度条可视化收支比例
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // 支出部分
                FractionallySizedBox(
                  widthFactor: expenseRatio.clamp(0.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                // 分隔线
                Positioned(
                  left: MediaQuery.of(context).size.width * expenseRatio.clamp(0.0, 1.0) * 0.88 - 0.5, // 考虑padding
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 1,
                    color: Colors.white,
                  ),
                ),
                
                // 储蓄部分
                Positioned(
                  left: MediaQuery.of(context).size.width * expenseRatio.clamp(0.0, 1.0) * 0.88,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // 图例
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "支出比例 (${(expenseRatio * 100).toStringAsFixed(1)}%)",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "储蓄比例 (${(savingsRatio * 100).toStringAsFixed(1)}%)",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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
