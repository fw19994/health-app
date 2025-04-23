import 'package:flutter/material.dart';
import '../models/transaction_type.dart';

class TransactionTypeToggle extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Row(
          children: TransactionType.values.map((type) => _buildToggleButton(type)).toList(),
        ),
      ),
    );
  }

  Widget _buildToggleButton(TransactionType type) {
    final isSelected = type == selectedType;
    
    Color textColor;
    Color backgroundColor;
    
    if (isSelected) {
      // 根据类型设置不同的激活颜色
      switch (type) {
        case TransactionType.expense:
          backgroundColor = const Color(0xFFFEE2E2);
          textColor = const Color(0xFFEF4444);
          break;
        case TransactionType.income:
          backgroundColor = const Color(0xFFD1FAE5);
          textColor = const Color(0xFF10B981);
          break;
        case TransactionType.transfer:
          backgroundColor = const Color(0xFFF3F4F6);
          textColor = const Color(0xFF6B7280);
          break;
      }
    } else {
      backgroundColor = Colors.transparent;
      textColor = const Color(0xFF6B7280);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            type.name,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
