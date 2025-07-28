import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import '../../../models/plan/project_task_model.dart';
import '../special_project_detail_screen.dart';
import 'add_task_button.dart';
import 'action_buttons.dart';

class SpecialProjectTimeline extends StatefulWidget {
  final String phaseId;
  final List<ProjectTask> tasks;
  final VoidCallback onAddTask;
  final Function(String taskId)? onAddTaskBefore;
  final Function(ProjectTask task)? onEditTask;
  final Function(String taskId)? onDeleteTask;
  final Function(ProjectTask task)? onCompleteTask; // 修改为传递整个任务对象
  final Map<String, Color>? phaseColors; // 新增：阶段颜色方案
  
  const SpecialProjectTimeline({
    Key? key,
    required this.phaseId,
    required this.tasks,
    required this.onAddTask,
    this.onAddTaskBefore,
    this.onEditTask,
    this.onDeleteTask,
    this.onCompleteTask, // 修改为传递整个任务对象
    this.phaseColors, // 新增参数
  }) : super(key: key);

  @override
  State<SpecialProjectTimeline> createState() => _SpecialProjectTimelineState();
}

class _SpecialProjectTimelineState extends State<SpecialProjectTimeline> {
  @override
  Widget build(BuildContext context) {
    final addButtonController = Provider.of<AddButtonController>(context);
    
    // 圆点的宽度
    const double dotSize = 12.0;
    // 圆点的一半，用于计算中心位置
    const double dotHalfSize = dotSize / 2;
    
    // 时间线竖线位置应为0，因为父容器已经处理了边距
    const double leftPosition = 0.0;
    
    return Container( // 使用Container替代Padding，不添加额外边距
      child: Column(
        children: [
          // 时间线
          Stack(
              children: [
              // 时间线竖线 - 放在最左侧
                Positioned(
                left: leftPosition + dotHalfSize - 1, // 圆点中心位置减去线宽的一半(1px)
                  top: 0,
                  bottom: 0,
                  width: 2,
                  child: Container(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                
                // 时间线项目
                Column(
                  children: [
                    ...widget.tasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      final bool showAddButton = addButtonController.activeTaskId == task.id;
                      
                      return Column(
                        children: [
                          // 任务项
                          _buildTimelineItem(task, dotSize, addButtonController),
                        ],
                      );
                    }).toList(),
                    
                  // 添加任务按钮 - 适配新的风格
                  if (widget.tasks.isEmpty)
                    _buildEmptyStateWithAddButton(dotSize)
                  else
                    _buildAddTaskButton(dotSize),
                      ],
                    ),
                  ],
          ),
        ],
      ),
    );
  }
  
  // 构建时间线项目
  Widget _buildTimelineItem(ProjectTask task, double dotSize, AddButtonController addButtonController) {
    final bool showEditButton = addButtonController.activeTaskId == task.id;
    
    // 获取颜色方案，如果没有传递则使用默认颜色
    final Map<String, Color> colors = widget.phaseColors ?? {
      'primary': const Color(0xFF4F46E5),
      'darker': const Color(0xFF4338CA),
      'lighter': const Color(0xFFF5F3FF),
    };
    
    return GestureDetector(
      onTap: () {
        // 点击时切换当前任务的激活状态
        if (addButtonController.activeTaskId == task.id) {
          addButtonController.clearAll();
        } else {
          addButtonController.setActiveTask(task.id);
        }
      },
      child: MouseRegion(
        onEnter: (_) => addButtonController.setActiveTask(task.id),
        onExit: (_) => addButtonController.clearAll(),
        cursor: SystemMouseCursors.click,
        child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线圆点
          SizedBox(
            width: dotSize,
            height: dotSize,
            child: Center(
              child: _buildTimelineDot(task.status, colors),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 时间线内容
          Expanded(
            child: Stack(
              clipBehavior: Clip.none, // 允许子组件超出边界
              children: [
                Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                      color: showEditButton 
                          ? colors['primary']! // 使用主题色
                          : const Color(0xFFE5E7EB),
                      width: showEditButton ? 1.5 : 1,
                ),
                    boxShadow: showEditButton ? [
                      BoxShadow(
                        color: colors['primary']!.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 类别和日期 - 上方
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 类别标签 - 左上角
                        _buildCategoryTag(task.category, colors),
                        
                        // 日期和时间 - 右上角
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 日期
                        Text(
                          _formatDate(task.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                            ),
                            // 时间段
                            if (task.startTime != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  task.timeRangeString,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors['primary']!.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 标题
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: showEditButton ? colors['darker']! : const Color(0xFF111827),
                        decoration: isCompleted(task) ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  
                  // 描述
                  if (task.description.isNotEmpty) 
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      child: Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  
                  // 费用和状态 - 下方
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 完成按钮 - 左下角（替换原来的费用显示）
                        GestureDetector(
                          onTap: () {
                            _toggleTaskComplete(task);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isCompleted(task) ? colors['primary'] : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isCompleted(task) ? colors['primary']! : const Color(0xFFD1D5DB),
                                    width: 2,
                                  ),
                                ),
                                child: isCompleted(task)
                                  ? Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                              ),
                              const SizedBox(width: 8),
                        Text(
                                isCompleted(task) ? '已完成' : '标记完成',
                                style: TextStyle(
                            fontSize: 14,
                                  color: isCompleted(task) ? colors['primary'] : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 费用展示移到状态标签旁边
                        Row(
                          children: [
                            // 费用 - 原本在左下角
                            Text(
                              '¥${_formatCost(task.cost)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colors['primary']!,
                          ),
                        ),
                            const SizedBox(width: 12),
                        
                        // 状态标签 - 右下角
                            _buildStatusBadge(task, colors),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
                
                // 使用新的操作按钮组件
                TaskActionButtons(
                  isVisible: showEditButton,
                  onAdd: widget.onAddTask != null ? () {
                    widget.onAddTask();
                    addButtonController.clearAll();
                  } : null,
                  onEdit: widget.onEditTask != null ? () {
                    widget.onEditTask!(task);
                  } : null,
                  onDelete: widget.onDeleteTask != null ? () {
                    _showDeleteConfirmation(context, task);
                  } : null,
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
  
  // 显示删除确认对话框
  void _showDeleteConfirmation(BuildContext context, ProjectTask task) {
    // 使用安全的context获取方式
    final scaffoldContext = context;
    showDialog(
      context: scaffoldContext,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFEEEEEE),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '确认删除',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 内容
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '确定要删除任务"${task.title}"吗？此操作无法撤销。',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 按钮区域
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 取消按钮
          TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            '取消',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // 删除按钮
                        ElevatedButton(
            onPressed: () {
                            // 先关闭对话框
                            Navigator.of(dialogContext).pop();
                            
                            // 使用Future.microtask确保在对话框完全关闭后再调用删除功能
                            Future.microtask(() {
              if (widget.onDeleteTask != null) {
                widget.onDeleteTask!(task.id);
              }
                            });
            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
            ),
                          child: const Text(
                            '删除',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          ),
        ],
          ),
        ),
      ),
    );
  }
  
  // 构建时间线圆点
  Widget _buildTimelineDot(TaskStatus status, Map<String, Color> colors) {
    Color borderColor;
    Color backgroundColor;
    double borderWidth = 0;
    
    switch (status) {
      case TaskStatus.completed:
        backgroundColor = colors['primary']!;
        borderColor = colors['primary']!;
        break;
      case TaskStatus.inProgress:
        backgroundColor = Colors.white;
        borderColor = colors['primary']!;
        borderWidth = 2;
        break;
      case TaskStatus.notStarted:
      default:
        backgroundColor = Colors.white;
        borderColor = const Color(0xFFD1D5DB);
        borderWidth = 1;
        break;
    }
    
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: status == TaskStatus.inProgress
            ? [
                BoxShadow(
                  color: colors['primary']!.withOpacity(0.2),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
  
  // 构建类别标签
  Widget _buildCategoryTag(String category, Map<String, Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors['lighter']!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: colors['primary']!.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Text(
        _getCategoryName(category),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors['darker']!,
        ),
      ),
    );
  }

  // 修改为带颜色参数的方法
  String _getCategoryName(String category) {
    if (category.startsWith('custom_')) {
      return category.substring(7);
    }
    switch (category) {
      case 'design':
        return '设计';
      case 'purchase':
        return '采购';
      case 'construction':
        return '施工';
      case 'inspection':
        return '验收';
      default:
        return category;
    }
  }
  
  // 构建状态标签
  Widget _buildStatusBadge(ProjectTask task, Map<String, Color> colors) {
    // 获取当前时间
    final now = DateTime.now();
    
    // 根据当前时间和任务完成状态判断实际状态
    String text = '';
    // 提供默认值，防止变量未初始化错误
    Color backgroundColor = const Color(0xFFF3F4F6); // 默认浅灰色背景
    Color textColor = const Color(0xFF6B7280); // 默认灰色文字
    
    // 使用isCompletedToday或当前状态作为是否完成的标识
    bool isCompleted = task.isCompletedToday || task.status == TaskStatus.completed;
    
    // 判断任务状态
    if (isCompleted) {
      // 已完成状态
        text = '已完成';
      backgroundColor = colors['lighter']!;
      textColor = colors['primary']!;
    } else {
      // 获取任务的开始和结束时间
      final bool isStarted = _isTaskStarted(task, now);
      final bool isEnded = _isTaskEnded(task, now);
      
      if (!isStarted) {
        // 未开始
        text = '未开始';
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
      } else if (isStarted && !isEnded) {
        // 进行中
        text = '进行中';
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
      } else if (isEnded) {
        // 已超时未完成
        text = '未完成';
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
  
  // 判断任务是否已经开始
  bool _isTaskStarted(ProjectTask task, DateTime now) {
    // 获取任务日期加上开始时间的完整DateTime
    if (task.startTime == null) {
      // 如果没有开始时间，则比较任务日期
      final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
      return now.isAfter(taskDate) || now.isAtSameMomentAs(taskDate);
    }
    
    // 创建任务开始的DateTime
    final taskStartDateTime = DateTime(
      task.date.year,
      task.date.month,
      task.date.day,
      task.startTime!.hour,
      task.startTime!.minute,
    );
    
    // 判断当前时间是否已经过了或等于任务开始时间
    return now.isAfter(taskStartDateTime) || now.isAtSameMomentAs(taskStartDateTime);
  }
  
  // 判断任务是否已经结束
  bool _isTaskEnded(ProjectTask task, DateTime now) {
    if (task.endTime == null) {
      // 如果没有结束时间但有开始时间，默认结束时间为开始时间后1小时
      if (task.startTime != null) {
        final taskEndDateTime = DateTime(
          task.date.year,
          task.date.month,
          task.date.day,
          task.startTime!.hour + 1,
          task.startTime!.minute,
        );
        return now.isAfter(taskEndDateTime);
      }
      
      // 如果既没有结束时间也没有开始时间，则认为任务结束时间是任务日期的结束
      final taskEndDate = DateTime(
        task.date.year,
        task.date.month,
        task.date.day,
        23, 59, 59,
      );
      return now.isAfter(taskEndDate);
    }
    
    // 创建任务结束的DateTime
    final taskEndDateTime = DateTime(
      task.date.year,
      task.date.month,
      task.date.day,
      task.endTime!.hour,
      task.endTime!.minute,
    );
    
    // 判断当前时间是否已经过了任务结束时间
    return now.isAfter(taskEndDateTime);
  }
  
  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
  
  // 格式化费用
  String _formatCost(double cost) {
    if (cost >= 10000) {
      return NumberFormat('#,##0.00').format(cost);
    } else {
      return NumberFormat('0.00').format(cost);
    }
    }
  
  // 为空阶段构建带有添加按钮的空状态
  Widget _buildEmptyStateWithAddButton(double dotSize) {
    // 获取颜色方案，如果没有传递则使用默认颜色
    final Map<String, Color> colors = widget.phaseColors ?? {
      'primary': const Color(0xFF4F46E5),
      'darker': const Color(0xFF4338CA),
      'lighter': const Color(0xFFF5F3FF),
    };
    
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线圆点位置的占位
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: colors['lighter'],
              shape: BoxShape.circle,
              border: Border.all(
                color: colors['primary']!.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 添加任务按钮(作为空状态)
          Expanded(
            child: GestureDetector(
              onTap: widget.onAddTask,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: colors['lighter']!.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors['primary']!.withOpacity(0.3),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 20,
                      color: colors['primary'],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '添加第一个计划',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors['primary'],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建添加任务按钮
  Widget _buildAddTaskButton(double dotSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 时间线圆点位置的占位
        SizedBox(width: dotSize),
        
        const SizedBox(width: 12),
        
        // 添加任务按钮
        Expanded(
          child: AddTaskButton(
            onTap: widget.onAddTask,
            phaseColors: widget.phaseColors,
          ),
        ),
      ],
    );
  }

  // 切换任务完成状态
  void _toggleTaskComplete(ProjectTask task) {
    // 如果任务今天已完成，不需要再次触发完成操作
    if (!task.isCompletedToday && task.status != TaskStatus.completed && widget.onCompleteTask != null) {
      widget.onCompleteTask!(task);
    }
  }

  // 判断任务是否已完成
  bool isCompleted(ProjectTask task) {
    return task.isCompletedToday || task.status == TaskStatus.completed;
  }
  }