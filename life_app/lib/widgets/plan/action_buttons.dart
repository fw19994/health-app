import 'package:flutter/material.dart';
import '../../models/plan/plan_model.dart';
import '../../services/plan_service.dart';
import 'add_plan_modal.dart';
import 'package:provider/provider.dart';

/// 计划卡片操作按钮组件
class PlanActionButtons extends StatefulWidget {
  final Plan plan;
  final VoidCallback? onActionComplete;
  final bool showMore;
  
  const PlanActionButtons({
    Key? key,
    required this.plan,
    this.onActionComplete,
    this.showMore = true,
  }) : super(key: key);
  
  @override
  State<PlanActionButtons> createState() => _PlanActionButtonsState();
}

class _PlanActionButtonsState extends State<PlanActionButtons> {
  Plan get plan => widget.plan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 编辑按钮
        _buildActionButton(
          icon: Icons.edit_outlined,
          color: const Color(0xFF6366F1),
          onTap: () {
            _editPlan();
          },
        ),
        
        // 删除按钮
        _buildActionButton(
          icon: Icons.delete_outline,
          color: const Color(0xFFEF4444),
          onTap: () {
            _deletePlan();
          },
        ),
      ],
    );
  }

  // 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
      ),
    );
  }

  // 删除计划
  void _deletePlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个计划吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final planService = Provider.of<PlanService>(context, listen: false);
              await planService.deletePlan(plan.id, context: context);
              
              // 刷新每日计划数据
              if (plan.date != null) {
                await planService.loadPlans(date: plan.date);
                
                // 刷新月度计划数据
                await planService.loadMonthlyPlans(
                  year: plan.date!.year,
                  month: plan.date!.month,
                );
              }
              
              Navigator.of(context).pop();
              if (widget.onActionComplete != null) {
                widget.onActionComplete!();
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // 编辑计划
  void _editPlan() async {
    final result = await AddPlanModal.show(
      context,
      selectedDate: plan.date ?? DateTime.now(),
      planToEdit: plan,
    );
    
    // 无论编辑是否成功，都尝试手动刷新数据
    final planService = Provider.of<PlanService>(context, listen: false);
    
    // 刷新每日计划数据
    if (plan.date != null) {
      await planService.loadPlans(date: plan.date);
      
      // 刷新月度计划数据
      await planService.loadMonthlyPlans(
        year: plan.date!.year,
        month: plan.date!.month,
      );
      
      // 输出调试信息
      debugPrint('已刷新计划数据 - 日期: ${plan.date}, 计划ID: ${plan.id}');
    }
    
    if (widget.onActionComplete != null) {
      widget.onActionComplete!();
    }
  }
} 