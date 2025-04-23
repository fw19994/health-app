import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditBudgetModal extends StatefulWidget {
  final String title;
  final double initialAmount;
  final Function(double) onSave;

  const EditBudgetModal({
    Key? key,
    required this.title,
    required this.initialAmount,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditBudgetModalState createState() => _EditBudgetModalState();
}

class _EditBudgetModalState extends State<EditBudgetModal> {
  late TextEditingController _controller;
  bool _enableNotification = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementAmount() {
    final currentValue = double.tryParse(_controller.text) ?? 0;
    _controller.text = (currentValue + 100).toStringAsFixed(2);
  }

  void _decrementAmount() {
    final currentValue = double.tryParse(_controller.text) ?? 0;
    if (currentValue >= 100) {
      _controller.text = (currentValue - 100).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                color: Colors.grey,
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: _decrementAmount,
                      color: Colors.grey.shade600,
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _incrementAmount,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '预算超支提醒',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _enableNotification,
                onChanged: (value) {
                  setState(() {
                    _enableNotification = value;
                  });
                },
                activeColor: Color(0xFFF97316),
              ),
            ],
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_controller.text);
              if (amount != null) {
                widget.onSave(amount);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF97316),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '保存',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
