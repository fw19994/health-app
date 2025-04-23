import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/budget_theme.dart';

class EditBudgetDialog extends StatefulWidget {
  final double currentBudget;

  const EditBudgetDialog({
    Key? key,
    required this.currentBudget,
  }) : super(key: key);

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentBudget.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    if (value.isEmpty) {
      setState(() => _errorText = '请输入预算金额');
      return;
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      setState(() => _errorText = '请输入有效的数字');
      return;
    }

    if (amount <= 0) {
      setState(() => _errorText = '预算金额必须大于0');
      return;
    }

    setState(() => _errorText = null);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(BudgetTheme.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '编辑预算',
              style: BudgetTheme.headingStyle,
            ),

            const SizedBox(height: BudgetTheme.spacingLarge),

            // 输入框
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: '预算金额',
                hintText: '请输入预算金额',
                prefixText: '¥ ',
                errorText: _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _validateInput,
            ),

            const SizedBox(height: BudgetTheme.spacingLarge),

            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: BudgetTheme.spacingMedium),
                ElevatedButton(
                  onPressed: _errorText != null
                      ? null
                      : () {
                          final amount = double.parse(_controller.text);
                          Navigator.of(context).pop(amount);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BudgetTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 