import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/plan/plan_model.dart';
import '../../../services/plan_service.dart';
import '../../../widgets/plan/action_buttons.dart';

/// 计划卡片组件，用于月度计划和日计划的一致显示
class PlanCardWidget extends StatefulWidget {
  final Plan plan;
  final Color categoryColor;
  
  const PlanCardWidget({
    Key? key,
    required this.plan,
    required this.categoryColor,
  }) : super(key: key);
  
  @override
  State<PlanCardWidget> createState() => _PlanCardWidgetState();
}

class _PlanCardWidgetState extends State<PlanCardWidget> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    // 打印类别信息，帮助调试
    debugPrint('PlanCardWidget - 计划类别: ${widget.plan.category}, 颜色: ${widget.categoryColor}');
    
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
                        decoration: widget.plan.isCompleted ? TextDecoration.lineThrough : null,
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
                          onTap: () async {
                            if (widget.plan.isEnabled) {
                              final planService = Provider.of<PlanService>(context, listen: false);
                              if (widget.plan.isCompleted) {
                                await planService.markAsIncomplete(widget.plan.id, context: context);
                              } else {
                                await planService.markAsCompleted(widget.plan.id, context: context);
                              }
                              
                              // 刷新计划数据
                              if (widget.plan.date != null) {
                                // 刷新每日计划数据
                                await planService.loadPlans(date: widget.plan.date);
                                
                                // 刷新月度计划数据
                                await planService.loadMonthlyPlans(
                                  year: widget.plan.date!.year,
                                  month: widget.plan.date!.month,
                                );
                              }
                            }
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: widget.plan.isCompleted ? const Color(0xFF22c55e) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: widget.plan.isCompleted ? const Color(0xFF22c55e) : const Color(0xFFD1D5DB),
                                    width: 2,
                                  ),
                                ),
                                child: widget.plan.isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.plan.isCompleted ? '已完成' : '标记完成',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 更多操作按钮或操作按钮组
                        _showActions
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
                              ),
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