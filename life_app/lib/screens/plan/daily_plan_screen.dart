import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../constants/routes.dart';
import '../../constants/plan_constants.dart';
import '../../services/plan_service.dart';
import '../../services/special_project_service.dart';
import '../../models/plan/plan_model.dart';
import '../../models/plan/special_project_model.dart';
import '../../widgets/plan/add_special_project_modal.dart';
import '../../widgets/plan/add_plan_modal.dart';
import '../../widgets/plan/action_buttons.dart';
import '../../widgets/plan/plan_monitor_status_badge.dart';
import 'package:intl/intl.dart';

class DailyPlanScreen extends StatefulWidget {
  final DateTime? initialDate;
  final bool noAutoLoad;
  
  const DailyPlanScreen({
    Key? key, 
    this.initialDate,
    this.noAutoLoad = false,
  }) : super(key: key);

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  // 当前选中日期
  late DateTime _selectedDate;
  
  @override
  void initState() {
    super.initState();
    // 使用传入的初始日期或当前日期
    _selectedDate = widget.initialDate ?? DateTime.now();
    print('DailyPlanScreen初始化，日期: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}');
    
    // 只在DailyPlanScreen作为独立页面时加载数据，而不是作为底部导航栏的一部分
    // 或者当noAutoLoad为false时加载数据
    if (widget.initialDate != null && !widget.noAutoLoad) {
      _loadPlans();
    }
    
    // 加载专项计划数据
    _loadSpecialProjects();
  }
  
  Future<void> _loadPlans() async {
    print('DailyPlanScreen._loadPlans被调用，日期: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}');
    final planService = Provider.of<PlanService>(context, listen: false);
    await planService.loadPlans(date: _selectedDate);
  }
  
  // 加载专项计划数据
  Future<void> _loadSpecialProjects() async {
    print('DailyPlanScreen._loadSpecialProjects被调用');
    final specialProjectService = Provider.of<SpecialProjectService>(context, listen: false);
    await specialProjectService.loadProjects();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<PlanService, SpecialProjectService>(
      builder: (context, planService, specialProjectService, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: planService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: _buildPlanList(planService, specialProjectService),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              AddPlanModal.show(context, selectedDate: _selectedDate);
            },
            backgroundColor: const Color(0xFF22c55e),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      }
    );
  }

  // 构建头部
  Widget _buildHeader(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight + 5, bottom: 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4ade80), Color(0xFF22c55e)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1022c55e),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '每日计划',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    // 添加计划监控状态徽章
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: PlanMonitorStatusBadge(),
                    ),
                    // 添加设置图标
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.planSettings);
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    // 原有的日历图标
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.monthlyPlan);
                  },
                  child: const FaIcon(
                    FontAwesomeIcons.calendar,
                    color: Colors.white,
                    size: 18,
                  ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDateNavigation(),
        ],
      ),
    );
  }

  // 构建日期导航
  Widget _buildDateNavigation() {
    // 获取一周的日期
    final List<DateTime> weekDates = [];
    final DateTime now = DateTime.now();
    final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    for (int i = -1; i < 6; i++) {
      weekDates.add(startOfWeek.add(Duration(days: i)));
    }

    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isToday = date.day == now.day && 
                          date.month == now.month && 
                          date.year == now.year;
          final isSelected = date.day == _selectedDate.day && 
                             date.month == _selectedDate.month && 
                             date.year == _selectedDate.year;
          
          // 获取星期几的中文表示
          String weekdayText;
          if (isToday) {
            weekdayText = '今天';
          } else {
            final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
            weekdayText = weekdayNames[date.weekday - 1];
          }
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              // 不再需要在这里加载计划，由DailyTasksWidget处理
            },
            child: Container(
              width: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF22c55e).withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF22c55e) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    weekdayText,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? const Color(0xFF22c55e) : Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 构建计划列表
  Widget _buildPlanList(PlanService planService, SpecialProjectService specialProjectService) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: [
        // 专项计划部分
        _buildSpecialProjectsSection(specialProjectService),
        
        // AI分析横幅
        _buildAIAnalysisBanner(),
        
        // 今日待办部分（使用单独的Widget）
        DailyTasksWidget(selectedDate: _selectedDate, noAutoLoad: widget.noAutoLoad),
      ],
    );
  }

  // 构建专项计划部分
  Widget _buildSpecialProjectsSection(SpecialProjectService projectService) {
    // 获取所有专项计划
    final projects = projectService.projects;
    
    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 专项计划标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  FaIcon(
                    FontAwesomeIcons.diagramProject,
                    size: 16,
                    color: Color(0xFF4F46E5),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '我的专项计划',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.specialProjectsList);
                },
                child: const Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          
          // 专项计划列表
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 120,
            child: projects.isEmpty
                ? _buildEmptySpecialProjects()
                : ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ...projects.map((project) => _buildSpecialProjectCard(project)).toList(),
                      _buildAddSpecialProjectCard(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // 添加空专项计划提示
  Widget _buildEmptySpecialProjects() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.folder_open,
            size: 32,
            color: Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 8),
          Text(
            '暂无专项计划',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // 构建专项计划卡片
  Widget _buildSpecialProjectCard(SpecialProject project) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.specialProjectDetail,
          arguments: project.id,
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: project.iconBackgroundGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(
                  project.icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            
            // 名称
            const SizedBox(height: 8),
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // 金额和进度
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '¥${NumberFormat('#,###').format(project.budget)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(project.progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
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
  
  // 更新添加专项计划卡片
  Widget _buildAddSpecialProjectCard() {
    return GestureDetector(
      onTap: () {
        // 使用新的弹窗组件替代导航
        AddSpecialProjectModal.show(context, onCreated: (project) {
          // 可以在这里添加创建成功后的逻辑
          setState(() {}); // 刷新列表
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 添加图标
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E7EB),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ),
            
            // 文字
            const SizedBox(height: 8),
            const Text(
              '添加专项',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 构建AI分析横幅
  Widget _buildAIAnalysisBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.insights,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI计划分析",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "本周完成率85%，比上周提高10%",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }

  // 构建计划卡片
  Widget _buildPlanCard(Plan plan, PlanService planService) {
    // 获取类别颜色
    Color getCategoryColor(String category) {
      // 将类别转换为小写，以便不区分大小写
      final lowerCategory = category.toLowerCase();
      
      // 打印类别信息，帮助调试
      debugPrint('计划类别: $category (${lowerCategory})');
      
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
      child: PlanCard(
        plan: plan,
        categoryColor: categoryColor,
      ),
    );
  }
}

/// 计划卡片组件
class PlanCard extends StatefulWidget {
  final Plan plan;
  final Color categoryColor;
  
  const PlanCard({
    Key? key,
    required this.plan,
    required this.categoryColor,
  }) : super(key: key);
  
  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
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
                              
                              // 获取DailyTasksWidget中的selectedDate
                              final dailyTasksWidget = context.findAncestorWidgetOfExactType<DailyTasksWidget>();
                              final selectedDate = dailyTasksWidget?.selectedDate ?? DateTime.now();
                              
                              // 传递选中的日期给markAsCompleted方法
                              planService.markAsCompleted(widget.plan.id, context: context, date: selectedDate);
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

/// 今日待办Widget
class DailyTasksWidget extends StatefulWidget {
  final DateTime selectedDate;
  final bool noAutoLoad;
  
  const DailyTasksWidget({
    Key? key,
    required this.selectedDate,
    this.noAutoLoad = false,
  }) : super(key: key);

  @override
  State<DailyTasksWidget> createState() => _DailyTasksWidgetState();
}

class _DailyTasksWidgetState extends State<DailyTasksWidget> {
  @override
  void initState() {
    super.initState();
    print('DailyTasksWidget初始化，日期: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}');
    
    // 只有当noAutoLoad为false时才自动加载数据
    if (!widget.noAutoLoad) {
    _loadPlans();
    }
  }
  
  @override
  void didUpdateWidget(DailyTasksWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当选中日期变化时，重新加载计划
    if (widget.selectedDate != oldWidget.selectedDate) {
      print('DailyTasksWidget日期变化: ${DateFormat('yyyy-MM-dd').format(oldWidget.selectedDate)} -> ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}');
      _loadPlans();
    } else {
      print('DailyTasksWidget日期未变化: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}，跳过加载');
    }
  }
  
  Future<void> _loadPlans() async {
    print('DailyTasksWidget._loadPlans被调用，日期: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}');
    final planService = Provider.of<PlanService>(context, listen: false);
    await planService.loadPlans(date: widget.selectedDate, forceReload: false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<PlanService>(
      builder: (context, planService, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日待办标题
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '今日待办',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Text(
                    DateFormat('yyyy年M月d日').format(widget.selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
            ),
            
            // 按时间段分组显示计划
            _buildTimeGroupPlans(planService, '上午', 0, 12),
            _buildTimeGroupPlans(planService, '下午', 12, 18),
            _buildTimeGroupPlans(planService, '晚间', 18, 24),
          ],
        );
      },
    );
  }
  
  // 构建时间段计划
  Widget _buildTimeGroupPlans(PlanService planService, String title, int startHour, int endHour) {
    // 过滤出该时间段的计划，删除isEnabled过滤条件
    final List<Plan> plans = planService.plans
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
          padding: const EdgeInsets.only(top: 16, bottom: 8),
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
        ...plans.map((plan) => _buildPlanCard(plan, planService)).toList(),
      ],
    );
  }
  
  // 构建计划卡片
  Widget _buildPlanCard(Plan plan, PlanService planService) {
    // 获取类别颜色
    Color getCategoryColor(String category) {
      // 将类别转换为小写，以便不区分大小写
      final lowerCategory = category.toLowerCase();
      
      // 打印类别信息，帮助调试
      debugPrint('计划类别: $category (${lowerCategory})');
      
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
      child: PlanCard(
        plan: plan,
        categoryColor: categoryColor,
      ),
    );
  }
}