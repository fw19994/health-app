import 'dart:math' as math;
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
          decoration: const BoxDecoration(
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

class _DatePickerModalState extends State<DatePickerModal> with SingleTickerProviderStateMixin {
  late int _currentYear;
  late int _currentMonth;
  late int _selectedDay;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // 主题颜色
  final Color _primaryColor = BudgetTheme.primaryColor;
  final Color _accentColor = const Color(0xFF10B981);
  
  @override
  void initState() {
    super.initState();
    _currentYear = widget.initialDate.year;
    _currentMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
    
    // 添加动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// 构建年份导航部分
  Widget _buildYearNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 上一年按钮
          _buildNavButton(
            icon: Icons.keyboard_arrow_left,
            onTap: () {
              setState(() {
                _currentYear--;
                _animationController.reset();
                _animationController.forward();
              });
            },
          ),
          
          // 当前年份显示
          InkWell(
            onTap: _showYearPicker,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
            children: [
              Text(
                '$_currentYear年',
                    style: const TextStyle(
                      fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: _primaryColor,
              ),
            ],
              ),
            ),
          ),
          
          // 下一年按钮
          _buildNavButton(
            icon: Icons.keyboard_arrow_right,
            onTap: () {
              setState(() {
                _currentYear++;
                _animationController.reset();
                _animationController.forward();
              });
            },
          ),
        ],
      ),
    );
  }
  
  // 构建导航按钮
  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: Colors.grey[700],
          size: 24,
        ),
      ),
    );
  }
  
  /// 显示年份选择器
  void _showYearPicker() {
    // 获取当前年份和构建范围更广的年份列表（前10年到后10年）
    final currentYear = DateTime.now().year;
    final years = List.generate(
      21, // 21年范围：当前年份±10年
      (index) => currentYear - 10 + index
    );
    
    // 控制器用于初始滚动到当前年份位置
    final ScrollController scrollController = ScrollController();
    
    // 使用底部弹出菜单，效果更现代
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许占用更多空间
      backgroundColor: Colors.transparent,
      builder: (context) {
        // 确保在构建后滚动到当前年份
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 计算需要滚动的位置
          final selectedIndex = years.indexOf(_currentYear);
          if (selectedIndex != -1) {
            // 计算滚动位置，使选中项居中
            final itemHeight = 60.0; // 每个年份项的高度
            final screenHeight = MediaQuery.of(context).size.height;
            final offset = (selectedIndex * itemHeight) - (screenHeight / 4);
            
            // 滚动到选中的年份
            scrollController.animateTo(
              math.max(0, offset),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // 顶部拖动条
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      '选择年份',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // 今年按钮
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentYear = DateTime.now().year;
                        });
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('今年'),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // 年份列表
              Expanded(
            child: ListView.builder(
                  controller: scrollController,
              itemCount: years.length,
              itemBuilder: (context, index) {
                    final year = years[index];
                    final bool isSelected = year == _currentYear;
                    final bool isCurrentYear = year == DateTime.now().year;
                    
                    return InkWell(
                  onTap: () {
                    setState(() {
                          _currentYear = year;
                          _animationController.reset();
                          _animationController.forward();
                    });
                    Navigator.pop(context);
                  },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? _primaryColor : isCurrentYear ? _primaryColor.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ] : null,
                          border: isCurrentYear && !isSelected 
                              ? Border.all(color: _primaryColor, width: 1.5)
                              : !isSelected 
                                  ? Border.all(color: Colors.grey.shade200)
                                  : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$year年',
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.w500,
                                    color: isSelected 
                                        ? Colors.white 
                                        : isCurrentYear 
                                            ? _primaryColor 
                                            : Colors.black87,
                                  ),
                                ),
                                if (isCurrentYear && !isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: _primaryColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      '今年',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                );
              },
            ),
              ),
              
              // 底部按钮
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('取消', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 构建月份选择器
  Widget _buildMonthSelector() {
    // 月份列表
    final List<String> monthNames = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
      child: Row(
        children: [
            const SizedBox(width: 16),
            ...List.generate(12, (index) {
              final month = index + 1;
              final isSelected = month == _currentMonth;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
              setState(() {
                      _currentMonth = month;
                      _animationController.reset();
                      _animationController.forward();
              });
            },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? _primaryColor : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      monthNames[index],
            style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
        ],
        ),
      ),
    );
  }
  
  /// 构建日期网格
  Widget _buildDateGrid() {
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final lastDayOfMonth = DateTime(_currentYear, _currentMonth + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final totalDays = lastDayOfMonth.day;
    
    // 当前日期，用于标记今天
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GridView.builder(
      shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
      ),
      itemCount: 42, // 6行7列
      itemBuilder: (context, index) {
        // 计算当前日期
          final day = index - (firstWeekday == 7 ? 0 : firstWeekday) + 1;
        final isCurrentMonth = day > 0 && day <= totalDays;
          
          // 检查是否是今天
          final currentDate = DateTime(_currentYear, _currentMonth, day);
          final isToday = currentDate.year == today.year && 
                         currentDate.month == today.month && 
                         currentDate.day == today.day;
                         
        final isSelected = isCurrentMonth && day == _selectedDay;
        
        return isCurrentMonth
            ? InkWell(
              onTap: () {
                setState(() {
                  _selectedDay = day;
                });
              },
                borderRadius: BorderRadius.circular(100),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : isToday ? _primaryColor.withOpacity(0.1) : null,
                  shape: BoxShape.circle,
                    border: isToday && !isSelected ? Border.all(
                      color: _primaryColor,
                      width: 1.5,
                  ) : null,
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : isToday 
                                ? _primaryColor
                                : Colors.black87,
                        fontSize: 16,
                        fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            )
          : Container();
      },
      ),
    );
  }
  
  /// 构建快速选择按钮
  Widget _buildQuickSelectButtons() {
    final quickButtons = [
      {'text': '今天', 'days': 0},
      {'text': '昨天', 'days': -1},
      {'text': '明天', 'days': 1},
      {'text': '下周', 'days': 7},
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: quickButtons.map<Widget>((button) {
          final targetDate = DateTime.now().add(Duration(days: button['days'] as int));
          return _buildQuickSelectButton(
            button['text'] as String, 
            () {
            setState(() {
                _currentYear = targetDate.year;
                _currentMonth = targetDate.month;
                _selectedDay = targetDate.day;
            });
            },
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建单个快速选择按钮
  Widget _buildQuickSelectButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _accentColor,
          ),
        ),
      ),
    );
  }
  
  /// 构建最近选择记录
  Widget _buildRecentDates() {
    if (widget.recentDates == null || widget.recentDates!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
          Text(
            '最近选择',
            style: TextStyle(
              fontSize: 14,
                  fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.recentDates!.map<Widget>((date) {
              return _buildQuickSelectButton(
                DateFormat('MM/dd').format(date),
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final selectedDate = DateTime(_currentYear, _currentMonth, _selectedDay);
                widget.onDateSelected(selectedDate);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('确定'),
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '选择日期',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 年份导航
          _buildYearNavigation(),
          
          // 月份选择器
          _buildMonthSelector(),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 星期标题
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Row(
                      children: ['日', '一', '二', '三', '四', '五', '六'].map((day) {
                        final bool isWeekend = day == '日' || day == '六';
                        return Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                color: isWeekend ? Colors.red[300] : Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
                  
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                  
                  // 快速选择按钮
                  _buildQuickSelectButtons(),
                  
                  // 最近选择记录
                  _buildRecentDates(),
                  
                  const SizedBox(height: 16),
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