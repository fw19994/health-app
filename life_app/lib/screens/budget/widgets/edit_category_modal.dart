import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/budget_category.dart';

class EditCategoryModal extends StatefulWidget {
  final BudgetCategory? category;
  final Function(BudgetCategory) onSave;

  const EditCategoryModal({
    Key? key,
    this.category,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditCategoryModalState createState() => _EditCategoryModalState();
}

class _EditCategoryModalState extends State<EditCategoryModal> {
  late TextEditingController _amountController;
  late String _selectedIcon;
  late String _selectedColor;
  bool _enableNotification = true;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.category?.amount.toStringAsFixed(2) ?? '0.00',
    );
    _selectedIcon = widget.category?.icon ?? '0xe25a'; // restaurant 默认图标
    _selectedColor = widget.category?.color ?? '0xFFF97316'; // orange 默认颜色
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[LOG] EditCategoryModal from edit_category_modal.dart is used');
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
                widget.category == null ? '添加预算' : '编辑预算',
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
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      hintText: '输入预算金额',
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
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
              final amount = double.tryParse(_amountController.text) ?? 0;
              
              if (amount <= 0) {
                // Show error
                return;
              }

              final category = BudgetCategory(
                id: widget.category?.id ?? DateTime.now().toString(),
                name: widget.category?.name ?? '预算',
                icon: _selectedIcon,
                amount: amount,
                spent: widget.category?.spent ?? 0,
                color: _selectedColor,
              );

              widget.onSave(category);
              Navigator.pop(context);
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
