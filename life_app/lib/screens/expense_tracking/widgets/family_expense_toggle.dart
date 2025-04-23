import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FamilyExpenseToggle extends StatelessWidget {
  final bool isFamilyExpense;
  final Function(bool) onChanged;

  const FamilyExpenseToggle({
    super.key,
    required this.isFamilyExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.users,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 12),
              const Text(
                '记为家庭支出',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          Switch(
            value: isFamilyExpense,
            activeColor: const Color(0xFFF97316),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
