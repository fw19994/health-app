import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/transaction_category.dart';

class RecentTransactionSuggestions extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onTransactionSelected;

  const RecentTransactionSuggestions({
    super.key,
    required this.transactions,
    required this.onTransactionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '近期类似支出',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: transactions.map((transaction) {
              return _buildSuggestionItem(transaction);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Transaction transaction) {
    return GestureDetector(
      onTap: () => onTransactionSelected(transaction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  transaction.category.icon,
                  color: transaction.category.color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  transaction.merchant ?? transaction.category.name,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            Text(
              transaction.formattedAmount,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
