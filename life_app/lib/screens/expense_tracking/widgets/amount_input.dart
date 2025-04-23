import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(double) onAmountChanged;

  const AmountInput({
    super.key,
    required this.controller,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '金额',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '¥',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFF97316),
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final amount = double.tryParse(value) ?? 0.0;
                      onAmountChanged(amount);
                    } else {
                      onAmountChanged(0);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
