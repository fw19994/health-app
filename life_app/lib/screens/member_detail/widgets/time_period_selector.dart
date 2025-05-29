import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/common/custom_date_range_picker.dart';

class TimePeriodSelector extends StatefulWidget {
  final Function(int) onPeriodSelected;
  final int selectedIndex;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime)? onCustomDateRangeSelected;
  final bool isHeader; // 添加是否在头部显示的标志

  const TimePeriodSelector({
    super.key,
    required this.onPeriodSelected,
    required this.selectedIndex,
    this.startDate,
    this.endDate,
    this.onCustomDateRangeSelected,
    this.isHeader = false, // 默认不在头部
  });

  @override
  State<TimePeriodSelector> createState() => _TimePeriodSelectorState();
}

class _TimePeriodSelectorState extends State<TimePeriodSelector> {
  // 时间段选项
  final List<String> _periods = [
    '过去7天',
    '过去30天',
    '本月',
    '上月',
    '过去3个月',
    '过去6个月',
    '过去12个月',
    '2024年',
    '2023年',
  ];

  // 当前显示的时间范围文本
  String _dateRangeText = '';
  
  @override
  void initState() {
    super.initState();
    _updateDateRangeText();
  }
  
  @override
  void didUpdateWidget(TimePeriodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _updateDateRangeText();
    }
  }
  
  // 更新日期范围文本
  void _updateDateRangeText() {
    if (widget.startDate != null && widget.endDate != null) {
      final startFormatted = DateFormat('MM/dd').format(widget.startDate!);
      final endFormatted = DateFormat('MM/dd').format(widget.endDate!);
      _dateRangeText = '$startFormatted-$endFormatted';
    } else {
      _dateRangeText = _periods[widget.selectedIndex];
    }
  }

  // 显示日期选择器
  void _showDatePicker() async {
    final now = DateTime.now();
    final dateRange = await CustomDateRangePicker.show(
      context: context,
      initialStartDate: widget.startDate ?? now.subtract(const Duration(days: 30)),
      initialEndDate: widget.endDate ?? now,
      firstDate: DateTime(now.year - 5), // 5年前
      lastDate: now, // 当前日期为最后日期
      title: '选择日期范围',
    );
    
    if (dateRange != null && widget.onCustomDateRangeSelected != null) {
      widget.onCustomDateRangeSelected!(dateRange.start, dateRange.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.isHeader ? 32 : 40, // 根据位置调整高度
      margin: widget.isHeader 
        ? EdgeInsets.zero // 在头部不需要外边距
        : const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: _showDatePicker,
            child: Container(
          padding: widget.isHeader 
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
            color: widget.isHeader 
                ? Colors.white.withOpacity(0.15) // 在头部使用半透明白色
                : Colors.white,
            borderRadius: BorderRadius.circular(widget.isHeader ? 16 : 20),
            border: Border.all(
              color: widget.isHeader 
                  ? Colors.white.withOpacity(0.2) // 在头部使用半透明白色边框
                  : const Color(0xFFE5E7EB),
            ),
              ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _dateRangeText,
                style: TextStyle(
                  fontSize: widget.isHeader ? 12 : 14, // 根据位置调整字体大小
                  color: widget.isHeader 
                    ? Colors.white // 在头部使用白色文字
                    : const Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: widget.isHeader ? 14 : 16, // 根据位置调整图标大小
                color: widget.isHeader 
                  ? Colors.white // 在头部使用白色图标
                      : const Color(0xFF6B7280),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
