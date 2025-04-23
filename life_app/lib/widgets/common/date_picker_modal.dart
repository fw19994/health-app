import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../themes/budget_theme.dart';
import '../../utils/app_icons.dart';

/// 日期选择器模态框组件
/// 
/// 弹出一个模态框让用户选择具体日期，包含年份导航、月份选择、日期网格、快速选择项
class DatePickerModal extends StatefulWidget {
  /// 初始选中的日期
  final DateTime initialDate;
  
  /// 当用户选择了日期后的回调函数
  final Function(DateTime) onDateSelected;
  
  /// 最近选择的日期记录
  final List<DateTime>? recentDates;

  const DatePickerModal({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
    this.recentDates,
  }) : super(key: key);

  /// 显示日期选择器模态框
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    List<DateTime>? recentDates,
  }) async {
    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DatePickerModal(
            initialDate: initialDate,
            recentDates: recentDates,
            onDateSelected: (date) {
              Navigator.of(context).pop(date);
            },
          ),
        );
      },
    );
  }

  @override
  _DatePickerModalState createState() => _DatePickerModalState();
}

class _DatePickerModalState extends State<DatePickerModal> {
  late int _currentYear;
  late int _currentMonth;
  late int _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _currentYear = widget.initialDate.year;
    _currentMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }
  
  /// 构建年份导航部分
  Widget _buildYearNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 上一年按钮
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.grey[600]),
            onPressed: () {
              setState(() {
                _currentYear--;
              });
            },
          ),
          
          // 当前年份显示
          Row(
            children: [
              Text(
                '$_currentYear年',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey[600]),
                onPressed: () {
                  _showYearPicker();
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                splashRadius: 20,
              ),
            ],
          ),
          
          // 下一年按钮
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onPressed: () {
              setState(() {
                _currentYear++;
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// 显示年份选择器
  void _showYearPicker() {
    // 构建近10年的年份列表供选择
    final currentYear = DateTime.now().year;
    final years = List.generate(
      10, 
      (index) => currentYear - 5 + index
    );
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择年份'),
          content: Container(
            width: double.minPositive,
            height: 300,
            child: ListView.builder(
              itemCount: years.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${years[index]}年'),
                  selected: years[index] == _currentYear,
                  selectedTileColor: BudgetTheme.primaryColor.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _currentYear = years[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  /// 构建月份选择器
  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 上个月按钮
          IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.grey[600]),
            onPressed: () {
              setState(() {
                if (_currentMonth == 1) {
                  _currentMonth = 12;
                  _currentYear--;
                } else {
                  _currentMonth--;
                }
              });
            },
          ),
          
          // 当前月份显示
          Text(
            '$_currentMonth月',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // 下个月按钮
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.grey[600]),
            onPressed: () {
              setState(() {
                if (_currentMonth == 12) {
                  _currentMonth = 1;
                  _currentYear++;
                } else {
                  _currentMonth++;
                }
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// 构建日期网格
  Widget _buildDateGrid() {
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final lastDayOfMonth = DateTime(_currentYear, _currentMonth + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final totalDays = lastDayOfMonth.day;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 42, // 6行7列
      itemBuilder: (context, index) {
        // 计算当前日期
        final day = index - firstWeekday + 1;
        final isCurrentMonth = day > 0 && day <= totalDays;
        final isToday = isCurrentMonth && 
          day == DateTime.now().day && 
          _currentMonth == DateTime.now().month && 
          _currentYear == DateTime.now().year;
        final isSelected = isCurrentMonth && day == _selectedDay;
        
        return isCurrentMonth
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = day;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? BudgetTheme.primaryColor : null,
                  shape: BoxShape.circle,
                  border: isToday ? Border.all(
                    color: BudgetTheme.primaryColor,
                    width: 1,
                    style: BorderStyle.solid,
                  ) : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            )
          : Container();
      },
    );
  }
  
  /// 构建快速选择按钮
  Widget _buildQuickSelectButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildQuickSelectButton('今天', () {
            final now = DateTime.now();
            setState(() {
              _currentYear = now.year;
              _currentMonth = now.month;
              _selectedDay = now.day;
            });
          }),
          _buildQuickSelectButton('明天', () {
            final tomorrow = DateTime.now().add(Duration(days: 1));
            setState(() {
              _currentYear = tomorrow.year;
              _currentMonth = tomorrow.month;
              _selectedDay = tomorrow.day;
            });
          }),
          _buildQuickSelectButton('下周', () {
            final nextWeek = DateTime.now().add(Duration(days: 7));
            setState(() {
              _currentYear = nextWeek.year;
              _currentMonth = nextWeek.month;
              _selectedDay = nextWeek.day;
            });
          }),
          _buildQuickSelectButton('下个月', () {
            final nextMonth = DateTime(_currentYear, _currentMonth + 1, 1);
            setState(() {
              _currentYear = nextMonth.year;
              _currentMonth = nextMonth.month;
              _selectedDay = 1;
            });
          }),
        ],
      ),
    );
  }
  
  /// 构建单个快速选择按钮
  Widget _buildQuickSelectButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
  
  /// 构建最近选择记录
  Widget _buildRecentDates() {
    if (widget.recentDates == null || widget.recentDates!.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最近选择',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.recentDates!.map((date) {
              return _buildQuickSelectButton(
                DateFormat('M月d日').format(date),
                () {
                  setState(() {
                    _currentYear = date.year;
                    _currentMonth = date.month;
                    _selectedDay = date.day;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey[300]!),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final selectedDate = DateTime(_currentYear, _currentMonth, _selectedDay);
                widget.onDateSelected(selectedDate);
              },
              child: Text('确定'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BudgetTheme.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '选择日期',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[600]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 年份导航
          _buildYearNavigation(),
          
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          
          // 月份选择器
          _buildMonthSelector(),
          
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 星期标题
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: ['日', '一', '二', '三', '四', '五', '六'].map((day) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // 日期网格
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDateGrid(),
                  ),
                  
                  // 快速选择按钮
                  _buildQuickSelectButtons(),
                  
                  SizedBox(height: 16),
                  
                  // 最近选择记录
                  _buildRecentDates(),
                ],
              ),
            ),
          ),
          
          // 底部操作按钮
          _buildActionButtons(),
        ],
      ),
    );
  }
} 