import 'package:flutter/material.dart';
import '../models/filter_options.dart';

class TransactionTabs extends StatelessWidget {
  final TransactionFilter selectedTab;
  final Function(TransactionFilter) onTabSelected;

  const TransactionTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTabItem(
            context: context,
            label: '全部交易',
            isSelected: selectedTab == TransactionFilter.all,
            onTap: () => onTabSelected(TransactionFilter.all),
          ),
          _buildTabItem(
            context: context,
            label: '收入',
            isSelected: selectedTab == TransactionFilter.income,
            onTap: () => onTabSelected(TransactionFilter.income),
          ),
          _buildTabItem(
            context: context,
            label: '支出',
            isSelected: selectedTab == TransactionFilter.expense,
            onTap: () => onTabSelected(TransactionFilter.expense),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF059669)
                  : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }
}
