import 'package:flutter/material.dart';

/// 操作按钮类型
enum ActionButtonType {
  add,
  edit,
  delete,
}

/// 操作按钮目标类型
enum ActionTargetType {
  phase,
  task,
}

/// 操作按钮组件
class ActionButtons extends StatelessWidget {
  final bool isVisible;
  final List<ActionButtonType> actions;
  final Function()? onAdd;
  final Function()? onEdit;
  final Function()? onDelete;
  final ActionTargetType targetType;
  
  const ActionButtons({
    Key? key,
    required this.isVisible,
    required this.actions,
    required this.targetType,
    this.onAdd,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 根据目标类型设置不同的颜色和标签
    final Color primaryColor = targetType == ActionTargetType.phase 
        ? const Color(0xFF6366F1) // 阶段使用紫色
        : const Color(0xFF4F46E5); // 计划使用蓝色
    
    final Color backgroundColor = targetType == ActionTargetType.phase
        ? const Color(0xFFEEF2FF) // 阶段使用淡紫色背景
        : Colors.white; // 计划使用白色背景
    
    final String targetLabel = targetType == ActionTargetType.phase ? '阶段' : '计划';
    
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: targetType == ActionTargetType.phase 
                ? const Color(0xFFD1D5DB) 
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 添加目标类型标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                targetLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ),
            
            if (actions.contains(ActionButtonType.add))
              _buildButton(
                icon: Icons.add_circle_outline,
                label: '添加',
                color: primaryColor,
                onTap: onAdd,
              ),
              
            if (actions.contains(ActionButtonType.edit))
              _buildButton(
                icon: Icons.edit_outlined,
                label: '编辑',
                color: primaryColor,
                onTap: onEdit,
              ),
              
            if (actions.contains(ActionButtonType.delete))
              _buildButton(
                icon: Icons.delete_outline,
                label: '删除',
                color: const Color(0xFFDC2626),
                onTap: onDelete,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 任务操作按钮组件
class TaskActionButtons extends StatelessWidget {
  final bool isVisible;
  final Function()? onAdd;
  final Function()? onEdit;
  final Function()? onDelete;
  
  const TaskActionButtons({
    Key? key,
    required this.isVisible,
    this.onAdd,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -18,
      right: 10,
      child: ActionButtons(
        isVisible: isVisible,
        targetType: ActionTargetType.task,
        actions: [
          if (onAdd != null) ActionButtonType.add,
          if (onEdit != null) ActionButtonType.edit,
          if (onDelete != null) ActionButtonType.delete,
        ],
        onAdd: onAdd,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

/// 阶段操作按钮组件
class PhaseActionButtons extends StatelessWidget {
  final bool isVisible;
  final Function()? onAdd;
  final Function()? onEdit;
  final Function()? onDelete;
  
  const PhaseActionButtons({
    Key? key,
    required this.isVisible,
    this.onAdd,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -20,
      right: 16,
      child: ActionButtons(
        isVisible: isVisible,
        targetType: ActionTargetType.phase,
        actions: [
          if (onAdd != null) ActionButtonType.add,
          if (onEdit != null) ActionButtonType.edit,
          if (onDelete != null) ActionButtonType.delete,
        ],
        onAdd: onAdd,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
} 