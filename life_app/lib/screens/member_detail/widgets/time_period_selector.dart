import 'package:flutter/material.dart';

class TimePeriodSelector extends StatefulWidget {
  final Function(int) onPeriodSelected;
  final int selectedIndex;

  const TimePeriodSelector({
    super.key,
    required this.onPeriodSelected,
    required this.selectedIndex,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          _periods.length,
          (index) => GestureDetector(
            onTap: () => widget.onPeriodSelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.selectedIndex == index
                    ? const Color(0xFF4F46E5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _periods[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.selectedIndex == index ? FontWeight.w600 : FontWeight.normal,
                  color: widget.selectedIndex == index
                      ? Colors.white
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
