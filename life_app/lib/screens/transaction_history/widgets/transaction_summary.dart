import 'package:flutter/material.dart';

class TransactionSummary extends StatelessWidget {
  final int transactionCount;
  final double totalIncome;
  final double totalExpense;

  const TransactionSummary({
    super.key,
    required this.transactionCount,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            label: '总交易',
            value: '${transactionCount}笔',
            valueColor: const Color(0xFF1F2937),
          ),
          _buildSummaryItem(
            label: '总收入',
            value: '¥${totalIncome.toStringAsFixed(0)}',
            valueColor: const Color(0xFF10B981),
          ),
          _buildSummaryItem(
            label: '总支出',
            value: '¥${totalExpense.toStringAsFixed(0)}',
            valueColor: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
