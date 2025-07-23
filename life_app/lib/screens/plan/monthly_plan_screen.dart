import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../models/plan/plan_model.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../constants/plan_constants.dart';
import '../../constants/routes.dart';
import '../../services/plan_service.dart';
import '../../widgets/plan/add_plan_modal.dart';
import '../../widgets/plan/action_buttons.dart';
import 'daily_plan_screen.dart';
import 'widgets/plan_card_widget.dart';
import 'package:flutter/rendering.dart';
// Now we have our own PlanCardWidget component

class MonthlyPlanScreen extends StatefulWidget {
  const MonthlyPlanScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyPlanScreen> createState() => _MonthlyPlanScreenState();
}

class _MonthlyPlanScreenState extends State<MonthlyPlanScreen> {
  // 焦点日期（当前显示的月份）
  DateTime _focusedDay = DateTime.now();
  
  // 选中的日期
  DateTime? _selectedDay;
  
  // 日历格式
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // 星期几的中文名称
  final List<String> _weekdayNames = ['日', '一', '二', '三', '四', '五', '六'];
  

  
  // 类别图例
  final List<Map<String, dynamic>> _categories = [
    {'name': '工作', 'color': 0xFF60a5fa, 'id': 'work'},
    {'name': '个人', 'color': 0xFFf97316, 'id': 'personal'},
    {'name': '健康', 'color': 0xFF22c55e, 'id': 'health'},
    {'name': '家庭', 'color': 0xFFa855f7, 'id': 'family'},
    {'name': '学习', 'color': 0xFF6366F1, 'id': 'study'},
    {'name': '阅读', 'color': 0xFFD946EF, 'id': 'reading'},
    {'name': '锻炼', 'color': 0xFFF43F5E, 'id': 'exercise'},
    {'name': '饮食', 'color': 0xFFF97316, 'id': 'diet'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // 加载月度计划数据
    _loadMonthlyPlans();
    // 初始化时加载当前选中日期的计划
    _loadMonthlyPlansForSelectedDay();
  }
  
  // 加载月度计划数据
  Future<void> _loadMonthlyPlans() async {
    final planService = Provider.of<PlanService>(context, listen: false);
    await planService.loadMonthlyPlans(
      year: _focusedDay.year,
      month: _focusedDay.month,
    );
  }
  
  // 专门用于月度计划页面的加载选中日期的计划方法
  Future<void> _loadMonthlyPlansForSelectedDay() async {
    if (_selectedDay == null) return;
    
    print('MonthlyPlanScreen调用_loadMonthlyPlansForSelectedDay加载月度计划，日期: ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}');
    
    // 调用相同的API，但使用专门为月度计划页面创建的方法
    final planService = Provider.of<PlanService>(context, listen: false);
    await planService.loadPlans(date: _selectedDay);
  }
  
  // 原方法保留，但不再调用
  Future<void> _loadPlansForSelectedDay() async {
    if (_selectedDay == null) return;
    
    print('MonthlyPlanScreen调用_loadPlansForSelectedDay加载计划，日期: ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}');
    
    // 无论选中日期是否在当前显示的月份内，都从daily接口获取数据
    final planService = Provider.of<PlanService>(context, listen: false);
    await planService.loadPlans(date: _selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildCalendarContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddEventButton(),
    );
  }

  // 构建浮动添加按钮
  Widget _buildAddEventButton() {
    return FloatingActionButton(
      onPressed: () async {
        final success = await AddPlanModal.show(
          context, 
          selectedDate: _selectedDay ?? DateTime.now()
        );
        
        // 如果添加成功，刷新数据
        if (success) {
          // 刷新月度计划数据（日历视图）
          await _loadMonthlyPlans();
        }
      },
      backgroundColor: const Color(0xFF10B981),
      elevation: 4,
      child: const Icon(Icons.add, size: 24),
    );
  }

  // 构建头部
  Widget _buildHeader() {
        return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: const BoxDecoration(
            color: Colors.white,
      ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
          // 返回按钮
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
                                color: Color(0xFF374151),
            ),
                              ),
          
          // 月份标题
                Text(
            DateFormat('yyyy年M月', 'zh_CN').format(_focusedDay),
                  style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
          
          // 操作按钮行
          Row(
          children: [
              // 设置按钮
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.planSettings);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 20,
                    color: Color(0xFF374151),
                  ),
                ),
              ),

              const SizedBox(width: 8),
              
              // 上个月
              GestureDetector(
              onTap: () {
                setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                    // 重置选中日期为新月份的第一天
                    _selectedDay = _focusedDay;
                  });
                  // 加载新月份的日历视图数据
                  _loadMonthlyPlans();
                },
      child: Container(
                  padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
        ),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 20,
                    color: Color(0xFF374151),
              ),
            ),
              ),
              
              const SizedBox(width: 8),
              
              // 下个月
              GestureDetector(
                onTap: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                    // 重置选中日期为新月份的第一天
                    _selectedDay = _focusedDay;
                  });
                  // 加载新月份的日历视图数据
                  _loadMonthlyPlans();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                child: const Icon(
                    Icons.chevron_right,
                  size: 20,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建月份导航按钮
  Widget _buildMonthNavButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  // 构建日历内容
  Widget _buildCalendarContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: [
        // 自定义日历网格
        _buildCustomCalendar(),
        const SizedBox(height: 16),
        // 类别图例
        _buildLegend(),
          const SizedBox(height: 20),
        // 选中日期的事件预览（使用新组件）
        _selectedDay != null 
            ? MonthlyPlanDetailsWidget(selectedDay: _selectedDay!)
            : const SizedBox.shrink(),
      ],
    );
  }



  // 构建自定义日历网格
  Widget _buildCustomCalendar() {
    // 获取本月的第一天
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    // 计算本月的天数
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    // 计算本月第一天是星期几（0是周日，1是周一，以此类推）
    final firstWeekday = firstDay.weekday % 7;
    // 计算需要显示的上个月的天数
    final daysFromPrevMonth = firstWeekday;
    // 计算上个月的最后一天
    final lastDayOfPrevMonth = DateTime(_focusedDay.year, _focusedDay.month, 0).day;
    // 计算日历总行数（向上取整）
    final rowCount = ((daysInMonth + daysFromPrevMonth) / 7).ceil();
    
    // 获取计划服务
    final planService = Provider.of<PlanService>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // 星期标题行
          Row(
            children: _weekdayNames.map((day) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            )).toList(),
          ),
          // 日期网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: rowCount * 7,
            itemBuilder: (context, index) {
              // 计算当前索引对应的日期
              int day;
              bool isCurrentMonth = true;
              bool isToday = false;
              
              // 上个月的日期
              if (index < daysFromPrevMonth) {
                day = lastDayOfPrevMonth - daysFromPrevMonth + index + 1;
                isCurrentMonth = false;
              }
              // 下个月的日期
              else if (index >= daysFromPrevMonth + daysInMonth) {
                day = index - daysFromPrevMonth - daysInMonth + 1;
                isCurrentMonth = false;
              }
              // 本月的日期
              else {
                day = index - daysFromPrevMonth + 1;
                // 检查是否是今天
                final now = DateTime.now();
                isToday = now.year == _focusedDay.year && 
                         now.month == _focusedDay.month && 
                         now.day == day;
              }
              
              // 计算完整日期
              DateTime cellDate;
              if (index < daysFromPrevMonth) {
                // 上个月
                cellDate = DateTime(_focusedDay.year, _focusedDay.month - 1, day);
              } else if (index >= daysFromPrevMonth + daysInMonth) {
                // 下个月
                cellDate = DateTime(_focusedDay.year, _focusedDay.month + 1, day);
              } else {
                // 本月
                cellDate = DateTime(_focusedDay.year, _focusedDay.month, day);
              }
              
              // 获取该日期的计划
              final plans = _getEventsForDay(cellDate);
              
              // 根据计划类型获取不同颜色的点
              List<Widget> eventDots = [];
              
              // 收集所有不同类别（最多显示3个点）
              final categories = <String>{};
              for (var plan in plans) {
                if (categories.length < 3) {
                  categories.add(plan.category);
                }
              }
              
              // 为每个类别创建一个点
              for (var category in categories) {
                // 获取类别对应的颜色
                Color dotColor;
                
                switch (category.toLowerCase()) {
                  case 'work': dotColor = const Color(0xFF60a5fa); break; // 工作
                  case 'personal': dotColor = const Color(0xFFf97316); break; // 个人
                  case 'health': dotColor = const Color(0xFF22c55e); break; // 健康
                  case 'family': dotColor = const Color(0xFFa855f7); break; // 家庭
                  case 'study': dotColor = const Color(0xFF6366F1); break; // 学习
                  case 'reading': dotColor = const Color(0xFFD946EF); break; // 阅读
                  case 'exercise': dotColor = const Color(0xFFF43F5E); break; // 锻炼
                  case 'diet': dotColor = const Color(0xFFF97316); break; // 饮食
                  case 'finance': dotColor = const Color(0xFF65A30D); break; // 财务
                  case 'social': dotColor = const Color(0xFF0EA5E9); break; // 社交
                  case 'project': dotColor = const Color(0xFF475569); break; // 项目
                  case 'event': dotColor = const Color(0xFF84CC16); break; // 活动
                  default: dotColor = const Color(0xFF60a5fa); break;
                }
                
                eventDots.add(
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dotColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }
              
              // 是否是选中的日期
              final isSelected = _selectedDay != null && 
                               _selectedDay!.year == cellDate.year &&
                               _selectedDay!.month == cellDate.month &&
                               _selectedDay!.day == cellDate.day;
              
              return GestureDetector(
                onTap: () {
                  // 检查是否是同一天
                  bool isSameDay = _selectedDay != null && 
                                  _selectedDay!.year == cellDate.year &&
                                  _selectedDay!.month == cellDate.month &&
                                  _selectedDay!.day == cellDate.day;
                  
                  // 如果是同一天，不重新加载数据
                  if (isSameDay) {
                    print('选中了相同的日期，不重新加载数据');
                    return;
                  }
                  
                  setState(() {
                    _selectedDay = cellDate;
                  });
                  
                  // 加载选中日期的计划数据（使用月度计划专用方法）
                  print('选中新日期: ${DateFormat('yyyy-MM-dd').format(cellDate)}，加载数据');
                  _loadMonthlyPlansForSelectedDay();
                  
                  // 添加触觉反馈
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFFF0FDF4) : Colors.white,
                    border: isSelected ? Border.all(color: const Color(0xFF10B981), width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 日期数字
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday ? const Color(0xFF10B981) : null,
                        ),
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: !isCurrentMonth ? const Color(0xFF9CA3AF) : 
                                   isToday ? Colors.white : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 事件点
                      if (eventDots.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: eventDots.map((dot) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: dot,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建图例
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "类别图例",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
        children: _categories.map((category) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(category['color']),
                      borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                category['name'],
                style: const TextStyle(
                      fontSize: 14,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          );
        }).toList(),
          ),
        ],
      ),
    );
  }

  // 修改从计划服务获取指定日期的事件，只获取启用的计划
  List<Plan> _getEventsForDay(DateTime date) {
    final PlanService planService = Provider.of<PlanService>(context, listen: false);
    
    // 日历视图使用getMonthlyPlansForDate直接获取特定日期的计划
    if (date.month == _focusedDay.month && date.year == _focusedDay.year) {
      // 使用优化后的方法，直接获取指定日期的计划
      final allPlans = planService.getMonthlyPlansForDate(date);
      
      // 只获取启用的计划
      final result = allPlans.where((plan) => plan.isEnabled).toList();
      
      // 对31日进行特殊调试
      if (date.day == 31) {
        print('【日历视图】日期: ${DateFormat('yyyy-MM-dd').format(date)}, 找到的计划数量: ${result.length}');
        if (result.isEmpty) {
          print('【日历视图】31号没有匹配的计划，检查可能的原因:');
          
          // 使用格式化的日期字符串检查dailyPlansMap
          final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          print('日期字符串: $dateStr');
          print('dailyPlansMap中的所有日期: ${planService.dailyPlansMap.keys}');
          print('dailyPlansMap是否包含31日: ${planService.dailyPlansMap.containsKey(dateStr)}');
          
          if (planService.dailyPlansMap.containsKey(dateStr)) {
            final plans31 = planService.dailyPlansMap[dateStr]!;
            print('31号原始计划数量: ${plans31.length}');
            for (var plan in plans31) {
              print('31号计划: ${plan.title}, 启用状态: ${plan.isEnabled}');
            }
          }
        }
      }
      
      return result;
    } else {
      // 如果日期不在当前显示的月份内，返回空列表
      return [];
    }
  }
} 

/// 月度计划卡片组件，与日计划保持一致的完成状态展示
class MonthlyPlanCard extends StatefulWidget {
  final Plan plan;
  final Color categoryColor;
  
  const MonthlyPlanCard({
    Key? key,
    required this.plan,
    required this.categoryColor,
  }) : super(key: key);
  
  @override
  State<MonthlyPlanCard> createState() => _MonthlyPlanCardState();
}

class _MonthlyPlanCardState extends State<MonthlyPlanCard> {
  bool _showActions = false;

  // 判断计划是否完成
  bool get isTaskCompleted {
    // 统一使用isCompletedToday判断完成状态
    return widget.plan.isCompletedToday;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showActions = !_showActions;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 类别指示条
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: widget.categoryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            
            // 禁用指示器
            if (!widget.plan.isEnabled)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '已停用',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            
            // 时间标签
            Positioned(
              top: 14,
              right: widget.plan.isEnabled ? 14 : 70,
              child: Text(
                widget.plan.timeRangeString,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6b7280),
                ),
              ),
            ),
            
            // 内容
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Padding(
                    padding: const EdgeInsets.only(right: 70), // 为时间标签留出空间
                    child: Text(
                      widget.plan.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                        decoration: isTaskCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  
                  // 描述
                  if (widget.plan.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.plan.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6b7280),
                      ),
                    ),
                  ],
                  
                  // 操作栏
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFF3F4F6),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 完成按钮
                        GestureDetector(
                          onTap: () {
                            if (widget.plan.isEnabled && !isTaskCompleted) {
                              final planService = Provider.of<PlanService>(context, listen: false);
                              
                              // 获取选中的日期
                              final monthlyPlanScreen = context.findAncestorStateOfType<_MonthlyPlanScreenState>();
                              final selectedDate = monthlyPlanScreen?._selectedDay ?? DateTime.now();
                              
                              // 传递选中的日期给markAsCompleted方法
                              planService.markAsCompleted(widget.plan.id, context: context, date: selectedDate)
                                .then((_) {
                                  // 计划标记完成后，刷新月度数据源
                                  if (monthlyPlanScreen != null) {
                                    // 刷新月度日历视图数据
                                    monthlyPlanScreen._loadMonthlyPlans();
                                  }
                                });
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isTaskCompleted ? const Color(0xFF22c55e) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isTaskCompleted ? const Color(0xFF22c55e) : const Color(0xFFD1D5DB),
                                    width: 2,
                                  ),
                                ),
                                child: isTaskCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isTaskCompleted ? '已完成' : '标记完成',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 更多操作按钮或操作按钮组
                        // 如果任务已完成，不显示更多操作按钮
                        isTaskCompleted 
                            ? const SizedBox.shrink()
                            : (_showActions
                                ? SizedBox(
                                    height: 36,
                                    child: PlanActionButtons(
                                      plan: widget.plan,
                                      onActionComplete: () {
                                        setState(() {
                                          _showActions = false;
                                        });
                                      },
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showActions = true;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.more_horiz,
                                      color: Color(0xFF9CA3AF),
                                      size: 20,
                                    ),
                                  )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 

/// 月度计划详情组件，专门用于月度计划页面
class MonthlyPlanDetailsWidget extends StatefulWidget {
  final DateTime selectedDay;
  
  const MonthlyPlanDetailsWidget({
    Key? key,
    required this.selectedDay,
  }) : super(key: key);

  @override
  State<MonthlyPlanDetailsWidget> createState() => _MonthlyPlanDetailsWidgetState();
}

class _MonthlyPlanDetailsWidgetState extends State<MonthlyPlanDetailsWidget> {
  @override
  void initState() {
    super.initState();
    print('MonthlyPlanDetailsWidget初始化，日期: ${DateFormat('yyyy-MM-dd').format(widget.selectedDay)}');
  }
  
  @override
  void didUpdateWidget(MonthlyPlanDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当选中日期变化时，重新构建UI
    if (widget.selectedDay != oldWidget.selectedDay) {
      print('MonthlyPlanDetailsWidget日期变化: ${DateFormat('yyyy-MM-dd').format(oldWidget.selectedDay)} -> ${DateFormat('yyyy-MM-dd').format(widget.selectedDay)}');
      setState(() {});
    }
  }

  // 获取选中日期的详细计划
  List<Plan> _getPlansForSelectedDay(PlanService planService) {
    print('===============================================');
    print('调试信息: 获取选中日期的计划，日期: ${DateFormat('yyyy-MM-dd').format(widget.selectedDay)}');
    // 打印planService中的plans总数量
    print('调试信息: planService.plans总数量: ${planService.plans.length}');
    // 从planService的plans中获取数据（这些数据来自daily API）
    final plansFromDailyAPI = planService.plans;
        
    // 如果从daily API获取到了数据，就使用这些数据
    if (plansFromDailyAPI.isNotEmpty) {
      print('MonthlyPlanDetailsWidget使用daily API数据，计划数量: ${plansFromDailyAPI.length}');
      return plansFromDailyAPI;
    }
    
    // 否则，使用优化后的方法从按日期分组的映射中获取数据
    final plansFromMonthlyAPI = planService.getMonthlyPlansForDate(widget.selectedDay);
    print('调试信息: 获取选中日期的计划plansFromMonthlyAPI，日期: ${DateFormat('yyyy-MM-dd').format(widget.selectedDay)}');
    print('MonthlyPlanDetailsWidget使用plansFromMonthlyAPI数据，计划数量: ${plansFromMonthlyAPI.length}');

    // 详细检查31号的情况
    if (widget.selectedDay.day == 31) {
      print('正在检查31号的数据匹配情况:');
      
      // 使用格式化的日期字符串检查dailyPlansMap
      final dateStr = "${widget.selectedDay.year}-${widget.selectedDay.month.toString().padLeft(2, '0')}-${widget.selectedDay.day.toString().padLeft(2, '0')}";
      print('日期字符串: $dateStr');
      print('dailyPlansMap中的所有日期: ${planService.dailyPlansMap.keys}');
      print('dailyPlansMap是否包含31日: ${planService.dailyPlansMap.containsKey(dateStr)}');
      
      if (planService.dailyPlansMap.containsKey(dateStr)) {
        final plans31 = planService.dailyPlansMap[dateStr]!;
        print('31号日期映射中的计划数量: ${plans31.length}');
        for (var plan in plans31) {
          print('- 计划标题: ${plan.title}, 日期: ${DateFormat('yyyy-MM-dd').format(plan.date!)}');
        }
      }
    }
        
    print('MonthlyPlanDetailsWidget使用monthly API数据，计划数量: ${plansFromMonthlyAPI.length}');
    print('===============================================');
    return plansFromMonthlyAPI;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanService>(
      builder: (context, planService, child) {
        final plans = _getPlansForSelectedDay(planService);
        
        // 如果没有计划，显示空状态
        if (plans.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 日期标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat("M月d日 · EEEE", "zh_CN").format(widget.selectedDay),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context, 
                          Routes.dailyPlan,
                          arguments: widget.selectedDay,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "查看详情",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 无计划提示
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_note,
                        size: 40,
                        color: Color(0xFFD1D5DB),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "这一天没有计划",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          AddPlanModal.show(context, selectedDate: widget.selectedDay);
                        },
                        child: const Text(
                          "添加计划",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        // 打印日志，显示获取到的计划
        print('MonthlyPlanDetailsWidget 获取到的计划数量: ${plans.length}');
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat("M月d日 · EEEE", "zh_CN").format(widget.selectedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        Routes.dailyPlan,
                        arguments: widget.selectedDay,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "查看详情",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 按时间段分组显示计划
              _buildTimeGroupPlans('上午', 0, 12, plans),
              _buildTimeGroupPlans('下午', 12, 18, plans),
              _buildTimeGroupPlans('晚间', 18, 24, plans),
            ],
          ),
        );
      },
    );
  }

  // 构建时间段计划
  Widget _buildTimeGroupPlans(String title, int startHour, int endHour, List<Plan> allPlans) {
    // 过滤出该时间段的计划
    final List<Plan> plans = allPlans
        .where((plan) {
          final int planHour = plan.startTime?.hour ?? 0;
          return planHour >= startHour && planHour < endHour;
        })
        .toList();

    if (plans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 时间段标题
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        
        // 该时间段的计划列表
        ...plans.map((plan) => _buildPlanCard(plan)).toList(),
      ],
    );
  }

  // 构建计划卡片
  Widget _buildPlanCard(Plan plan) {
    // 获取类别颜色
    Color getCategoryColor(String category) {
      // 将类别转换为小写，以便不区分大小写
      final lowerCategory = category.toLowerCase();
      
      switch (lowerCategory) {
        case 'work': return const Color(0xFF60a5fa); // 工作
        case 'personal': return const Color(0xFFf97316); // 个人
        case 'health': return const Color(0xFF22c55e); // 健康
        case 'family': return const Color(0xFFa855f7); // 家庭
        case 'study': return const Color(0xFF6366F1); // 学习
        case 'reading': return const Color(0xFFD946EF); // 阅读
        case 'exercise': return const Color(0xFFF43F5E); // 锻炼
        case 'diet': return const Color(0xFFF97316); // 饮食
        case 'finance': return const Color(0xFF65A30D); // 财务
        case 'social': return const Color(0xFF0EA5E9); // 社交
        case 'project': return const Color(0xFF475569); // 项目
        case 'event': return const Color(0xFF84CC16); // 活动
        default: return const Color(0xFF60a5fa); // 默认蓝色
      }
    }
    
    final categoryColor = getCategoryColor(plan.category);
    
    // 显示所有计划，但未启用的计划透明度降低
    return Opacity(
      opacity: plan.isEnabled ? 1.0 : 0.5,
      child: MonthlyPlanCard(
        plan: plan,
        categoryColor: categoryColor,
      ),
    );
  }
} 