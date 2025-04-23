import 'package:flutter/material.dart';
import '../../themes/budget_theme.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onMonthSelected;
  final int monthsToShow;

  const MonthSelector({
    Key? key,
    required this.initialDate,
    required this.onMonthSelected,
    this.monthsToShow = 12,
  }) : super(key: key);

  @override
  _MonthSelectorState createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  late ScrollController _scrollController;
  late DateTime _selectedDate;
  late List<DateTime> _months;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedDate = widget.initialDate;
    _generateMonths();
  }

  void _generateMonths() {
    _months = List.generate(widget.monthsToShow, (index) {
      final now = DateTime.now();
      return DateTime(now.year, now.month + index);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatMonth(DateTime date) {
    final formatter = DateFormat('yyyy年M月', 'zh_CN');
    return formatter.format(date);
  }

  String _formatShortMonth(DateTime date) {
    final formatter = DateFormat('M月', 'zh_CN');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        itemBuilder: (context, index) {
          final month = _months[index];
          final isSelected = month.year == _selectedDate.year && 
                           month.month == _selectedDate.month;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = month;
              });
              widget.onMonthSelected(month);
            },
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 16 : 8,
                right: index == _months.length - 1 ? 16 : 0,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                index == 0 ? _formatMonth(month) : _formatShortMonth(month),
                style: TextStyle(
                  color: isSelected ? BudgetTheme.primaryColor : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 