import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../themes/budget_theme.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_icons.dart';

/// 月份选择器模态框组件
/// 
/// 弹出一个模态框让用户选择年份和月份，包含年份导航、月份网格、快速选择项
class MonthPickerModal extends StatefulWidget {
  /// 初始选中的日期
  final DateTime initialDate;
  
  /// 当用户选择了月份后的回调函数
  final Function(DateTime) onMonthSelected;
  
  /// 最近选择的月份记录
  final List<DateTime>? recentMonths;

  const MonthPickerModal({
    Key? key,
    required this.initialDate,
    required this.onMonthSelected,
    this.recentMonths,
  }) : super(key: key);

  /// 显示月份选择器模态框
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    List<DateTime>? recentMonths,
  }) async {
    // 添加触感反馈
    HapticFeedback.lightImpact();
    
    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65, // 减小高度
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: MonthPickerModal(
            initialDate: initialDate,
            recentMonths: recentMonths,
            onMonthSelected: (date) {
              // 添加触感反馈
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop(date);
            },
          ),
        );
      },
    );
  }

  @override
  _MonthPickerModalState createState() => _MonthPickerModalState();
}

class _MonthPickerModalState extends State<MonthPickerModal> with SingleTickerProviderStateMixin {
  late int _currentYear;
  late int _currentMonth;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // 定义UI主题色
  final Color _primaryColor = AppTheme.primaryColor;
  final Color _backgroundColor = Colors.white;
  
  @override
  void initState() {
    super.initState();
    _currentYear = widget.initialDate.year;
    _currentMonth = widget.initialDate.month;
    
    // 添加动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut)
    );
    
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
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 上一年按钮
          _buildNavigationButton(
            icon: Icons.chevron_left,
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _currentYear--;
              });
            },
          ),
          
          // 当前年份显示
          InkWell(
            onTap: _showYearPicker,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    '$_currentYear年',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
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
          _buildNavigationButton(
            icon: Icons.chevron_right,
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _currentYear++;
              });
            },
          ),
        ],
      ),
    );
  }
  
  // 构建导航按钮
  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: _primaryColor),
        onPressed: onPressed,
        splashRadius: 24,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
  
  /// 显示年份选择器
  void _showYearPicker() {
    HapticFeedback.lightImpact();
    
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
          backgroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.calendar_today, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                '选择年份',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.minPositive,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              itemCount: years.length,
              itemBuilder: (context, index) {
                final isSelected = years[index] == _currentYear;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: isSelected 
                      ? Icon(Icons.check_circle, color: _primaryColor)
                      : const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                    title: Text(
                      '${years[index]}年',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? _primaryColor : AppTheme.textPrimary,
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _currentYear = years[index];
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// 构建月份网格部分
  Widget _buildMonthGrid() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final isSelected = month == _currentMonth && 
                              _currentYear == widget.initialDate.year && 
                              month == widget.initialDate.month;
            final isCurrentMonth = month == DateTime.now().month && 
                                 _currentYear == DateTime.now().year;
            
            // 获取月份对应的季节颜色
            Color monthColor = _getMonthColor(month);
            
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentMonth = month;
                });
                
                // 直接选择并关闭模态框
                final selectedDate = DateTime(_currentYear, _currentMonth);
                widget.onMonthSelected(selectedDate);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isSelected 
                    ? LinearGradient(
                        colors: [
                          monthColor.withOpacity(0.7), 
                          monthColor.withOpacity(0.4)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                  color: isSelected 
                    ? null
                    : isCurrentMonth 
                      ? Colors.grey.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected 
                    ? [
                        BoxShadow(
                          color: monthColor.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$month月',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected || isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                          ? Colors.white 
                          : isCurrentMonth
                            ? _primaryColor
                            : AppTheme.textPrimary,
                      ),
                    ),
                    if (isCurrentMonth && !isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        height: 3,
                        width: 3,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// 获取月份对应的季节颜色
  Color _getMonthColor(int month) {
    switch (month) {
      case 12:
      case 1:
      case 2:
        return Colors.blue; // 冬季
      case 3:
      case 4:
      case 5:
        return Colors.green; // 春季
      case 6:
      case 7:
      case 8:
        return Colors.orange; // 夏季
      case 9:
      case 10:
      case 11:
        return Colors.brown; // 秋季
      default:
        return _primaryColor;
    }
  }
  
  /// 构建快速选择按钮部分
  Widget _buildQuickSelectButtons() {
    final now = DateTime.now();
    
    // 计算上个月和下个月
    final lastMonth = DateTime(
      now.month == 1 ? now.year - 1 : now.year,
      now.month == 1 ? 12 : now.month - 1,
    );
    
    final nextMonth = DateTime(
      now.month == 12 ? now.year + 1 : now.year,
      now.month == 12 ? 1 : now.month + 1,
    );
    
    final formatter = DateFormat('yyyy年M月', 'zh_CN');
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              '快速选择',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              _buildQuickSelectButton(
                '本月',
                () {
                  HapticFeedback.mediumImpact();
                  // 直接选择本月并关闭模态框
                  widget.onMonthSelected(DateTime(now.year, now.month));
                },
                icon: Icons.today,
                color: _primaryColor,
              ),
              _buildQuickSelectButton(
                '上月',
                () {
                  HapticFeedback.mediumImpact();
                  // 直接选择上月并关闭模态框
                  widget.onMonthSelected(lastMonth);
                },
                icon: Icons.arrow_back,
                color: Colors.amber,
              ),
              _buildQuickSelectButton(
                '下月',
                () {
                  HapticFeedback.mediumImpact();
                  // 直接选择下月并关闭模态框
                  widget.onMonthSelected(nextMonth);
                },
                icon: Icons.arrow_forward,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickSelectButton(String text, VoidCallback onTap, {required IconData icon, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部拖动条
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        // 标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: _primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    '选择月份',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                color: Colors.grey[600],
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildYearNavigation(),
                _buildMonthGrid(),
                _buildQuickSelectButtons(),
                // 添加底部间距，替代按钮区域
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 