import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateRangePicker extends StatefulWidget {
  /// 初始开始日期
  final DateTime? initialStartDate;
  
  /// 初始结束日期
  final DateTime? initialEndDate;
  
  /// 选择日期范围后的回调
  final Function(DateTimeRange)? onDateRangeSelected;
  
  /// 最早可选日期
  final DateTime? firstDate;
  
  /// 最晚可选日期
  final DateTime? lastDate;
  
  /// 日期格式
  final String? dateFormat;
  
  /// 标题
  final String? title;

  const CustomDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.onDateRangeSelected,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
    this.title,
  });

  /// 显示自定义日期选择器
  static Future<DateTimeRange?> show({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? dateFormat,
    String? title,
  }) async {
    // 当前选择的日期范围
    final now = DateTime.now();
    final startDate = initialStartDate ?? now.subtract(const Duration(days: 30));
    final endDate = initialEndDate ?? now;
    
    // 确保日期在有效范围内
    final validFirstDate = firstDate ?? DateTime(now.year - 5);
    final validLastDate = lastDate ?? now;
    
    // 确保开始日期和结束日期在有效范围内
    final validStartDate = startDate.isBefore(validFirstDate) ? validFirstDate : 
                          (startDate.isAfter(validLastDate) ? validLastDate : startDate);
    final validEndDate = endDate.isBefore(validFirstDate) ? validFirstDate : 
                        (endDate.isAfter(validLastDate) ? validLastDate : endDate);
    
    final result = await showModalBottomSheet<DateTimeRange?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CustomDateRangePicker(
        initialStartDate: validStartDate,
        initialEndDate: validEndDate,
        firstDate: validFirstDate,
        lastDate: validLastDate,
        dateFormat: dateFormat,
        title: title,
      ),
    );
    
    return result;
  }

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late DateTime startDate;
  late DateTime endDate;
  
  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate ?? DateTime.now().subtract(const Duration(days: 30));
    endDate = widget.initialEndDate ?? DateTime.now();
  }
  
  void _updateStartDate(DateTime date) {
    setState(() {
      startDate = date;
    });
  }
  
  void _updateEndDate(DateTime date) {
    setState(() {
      endDate = date;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 1,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // 顶部小横条
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      widget.title ?? '自定义日期范围',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (endDate.isBefore(startDate)) {
                          // 如果结束日期在开始日期之前，交换它们
                          final temp = startDate;
                          startDate = endDate;
                          endDate = temp;
                        }
                        
                        final dateRange = DateTimeRange(
                          start: startDate,
                          end: endDate,
                        );
                        
                        if (widget.onDateRangeSelected != null) {
                          widget.onDateRangeSelected!(dateRange);
                        }
                        
                        Navigator.pop(context, dateRange);
                      },
                      child: const Text(
                        '确定',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 日期区间显示
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            color: const Color(0xFFF9FAFB),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '开始日期',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(widget.dateFormat ?? 'yyyy年MM月dd日').format(startDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 2,
                  color: const Color(0xFFD1D5DB),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '结束日期',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(widget.dateFormat ?? 'yyyy年MM月dd日').format(endDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 选项卡 - 开始日期/结束日期
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: DefaultTabController(
              length: 2,
              child: TabBar(
                labelColor: const Color(0xFF059669),
                unselectedLabelColor: const Color(0xFF6B7280),
                indicatorColor: const Color(0xFF059669),
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: '开始日期'),
                  Tab(text: '结束日期'),
                ],
              ),
            ),
          ),
          
          // 日历区域
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // 开始日期选择
                  _buildCalendarPicker(
                    selectedDate: startDate,
                    onDateSelected: _updateStartDate,
                    maxDate: widget.lastDate ?? DateTime.now(),
                    minDate: widget.firstDate ?? DateTime(DateTime.now().year - 5),
                  ),
                  
                  // 结束日期选择
                  _buildCalendarPicker(
                    selectedDate: endDate,
                    onDateSelected: _updateEndDate,
                    maxDate: widget.lastDate ?? DateTime.now(),
                    minDate: widget.firstDate ?? DateTime(DateTime.now().year - 5),
                  ),
                ],
              ),
            ),
          ),
          
          // 常用快捷选项
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickDateOption(
                    '今天', 
                    () {
                      setState(() {
                        _updateStartDate(DateTime.now());
                        _updateEndDate(DateTime.now());
                      });
                    },
                  ),
                  _buildQuickDateOption(
                    '昨天', 
                    () {
                      final yesterday = DateTime.now().subtract(const Duration(days: 1));
                      setState(() {
                        _updateStartDate(yesterday);
                        _updateEndDate(yesterday);
                      });
                    },
                  ),
                  _buildQuickDateOption(
                    '近7天', 
                    () {
                      setState(() {
                        _updateStartDate(DateTime.now().subtract(const Duration(days: 7)));
                        _updateEndDate(DateTime.now());
                      });
                    },
                  ),
                  _buildQuickDateOption(
                    '本月', 
                    () {
                      setState(() {
                        _updateStartDate(DateTime(DateTime.now().year, DateTime.now().month, 1));
                        _updateEndDate(DateTime.now());
                      });
                    },
                  ),
                  _buildQuickDateOption(
                    '上月', 
                    () {
                      final now = DateTime.now();
                      setState(() {
                        _updateStartDate(DateTime(now.year, now.month - 1, 1));
                        _updateEndDate(DateTime(now.year, now.month, 0));
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建日历选择器
  Widget _buildCalendarPicker({
    required DateTime selectedDate,
    required Function(DateTime) onDateSelected,
    required DateTime maxDate,
    required DateTime minDate,
  }) {
    return CalendarDatePicker(
      initialDate: selectedDate,
      firstDate: minDate,
      lastDate: maxDate,
      onDateChanged: onDateSelected,
    );
  }
  
  // 构建快捷日期选项
  Widget _buildQuickDateOption(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(color: Color(0xFFD1D5DB)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
} 