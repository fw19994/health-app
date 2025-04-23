import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/savings_goal.dart';
import '../../../utils/app_icons.dart';
import '../../../themes/app_theme.dart';

class EditSavingsGoalModal extends StatefulWidget {
  final SavingsGoal? goal;
  final Function(SavingsGoal) onSave;

  const EditSavingsGoalModal({
    Key? key,
    this.goal,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditSavingsGoalModalState createState() => _EditSavingsGoalModalState();
}

class _EditSavingsGoalModalState extends State<EditSavingsGoalModal> {
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _monthlyContributionController;
  late TextEditingController _noteController;
  late DateTime _targetDate;
  IconData _selectedIcon = AppIcons.housing;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetAmountController = TextEditingController(
      text: widget.goal?.targetAmount.toStringAsFixed(2) ?? '0.00',
    );
    _monthlyContributionController = TextEditingController(
      text: widget.goal?.monthlyContribution.toStringAsFixed(2) ?? '0.00',
    );
    _noteController = TextEditingController(text: widget.goal?.note ?? '');
    _targetDate = widget.goal?.targetDate ?? DateTime.now().add(Duration(days: 365));
    
    // 处理图标数据转换
    if (widget.goal != null) {
      try {
        // 如果是字符串ID格式，先转换成对应的AppIcons图标
        final iconData = IconData(
          int.parse(widget.goal!.icon),
          fontFamily: 'MaterialIcons',
        );
        _selectedIcon = iconData;
      } catch (e) {
        // 如果发生错误，使用默认图标
        _selectedIcon = AppIcons.housing;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _monthlyContributionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 3650)),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
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
      child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.goal == null ? '添加储蓄目标' : '编辑储蓄目标',
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
            SizedBox(height: 16),
            // 当前选中图标显示区域
            if (widget.goal != null) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _selectedIcon,
                        color: _selectedColor,
                        size: 30,
                      ),
                    ),
                  ],
                ),
          ),
          SizedBox(height: 24),
          Text(
              '选择类别',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
            Text(
              '目标名称',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '目标金额',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
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
                    controller: _targetAmountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      hintText: '目标金额',
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
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
                    controller: _monthlyContributionController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      hintText: '每月存入金额',
                    ),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '目标日期',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${_targetDate.year}年${_targetDate.month}月${_targetDate.day}日',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: '备注',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
              final monthlyContribution = double.tryParse(_monthlyContributionController.text) ?? 0;
              final note = _noteController.text.trim();
              
              if (name.isEmpty || targetAmount <= 0 || monthlyContribution <= 0) {
                // Show error
                return;
              }

              final goal = SavingsGoal(
                id: widget.goal?.id ?? DateTime.now().toString(),
                name: name,
                  icon: _selectedIcon.codePoint.toString(),
                targetAmount: targetAmount,
                currentAmount: widget.goal?.currentAmount ?? 0,
                monthlyContribution: monthlyContribution,
                targetDate: _targetDate,
                note: note,
              );

              widget.onSave(goal);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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
      ),
    );
  }
}
