import 'package:flutter/material.dart';
import '../../../models/plan/project_phase_model.dart';
import '../../../models/plan/project_task_model.dart';
import '../special_project_detail_screen.dart';
import 'special_project_phase.dart';
import 'special_project_timeline.dart';

/// 项目阶段列表组件 - 用于显示从API获取的阶段数据
class ProjectPhasesList extends StatelessWidget {
  final List<ProjectPhase> phases;
  final Function(String) onEditPhase;
  final Function(String?) onAddPhase;
  final Function(String) onDeletePhase;
  final Function(String, ProjectTask) onEditTask;
  final Function(String) onAddTask;
  final Function(String, String) onAddTaskBefore;
  final Function(String) onDeleteTask;
  final Function(ProjectTask) onCompleteTask;
  
  const ProjectPhasesList({
    Key? key,
    required this.phases,
    required this.onEditPhase,
    required this.onAddPhase,
    required this.onDeletePhase,
    required this.onEditTask,
    required this.onAddTask,
    required this.onAddTaskBefore,
    required this.onDeleteTask,
    required this.onCompleteTask,
  }) : super(key: key);

  // 获取阶段颜色
  Map<String, Color> _getPhaseColors(String phaseId) {
    // 预定义的颜色方案列表
    const List<Map<String, Color>> colorSchemes = [
      {
        'primary': Color(0xFF4F46E5),      // 紫色
        'lighter': Color(0xFFF5F3FF),
        'darker': Color(0xFF4338CA),
        'gradient1': Color(0xFFF5F3FF),
        'gradient2': Color(0xFFEEF2FF),
      },
      {
        'primary': Color(0xFF0EA5E9),      // 蓝色
        'lighter': Color(0xFFE0F2FE),
        'darker': Color(0xFF0369A1),
        'gradient1': Color(0xFFE0F7FF),
        'gradient2': Color(0xFFE0F2FE),
      },
      {
        'primary': Color(0xFF10B981),      // 绿色
        'lighter': Color(0xFFECFDF5),
        'darker': Color(0xFF047857),
        'gradient1': Color(0xFFECFDF5),
        'gradient2': Color(0xFFD1FAE5),
      },
      {
        'primary': Color(0xFFEF4444),      // 红色
        'lighter': Color(0xFFFEE2E2),
        'darker': Color(0xFFB91C1C),
        'gradient1': Color(0xFFFEE2E2),
        'gradient2': Color(0xFFFECACA),
      },
      {
        'primary': Color(0xFFF59E0B),      // 黄色
        'lighter': Color(0xFFFEF3C7),
        'darker': Color(0xFFB45309),
        'gradient1': Color(0xFFFEF3C7),
        'gradient2': Color(0xFFFDE68A),
      },
      {
        'primary': Color(0xFF8B5CF6),      // 亮紫色
        'lighter': Color(0xFFF3E8FF),
        'darker': Color(0xFF6D28D9),
        'gradient1': Color(0xFFF3E8FF),
        'gradient2': Color(0xFFEDE9FE),
      },
      {
        'primary': Color(0xFFEC4899),      // 粉色
        'lighter': Color(0xFFFCE7F3),
        'darker': Color(0xFFBE185D),
        'gradient1': Color(0xFFFCE7F3),
        'gradient2': Color(0xFFFBCFE8),
      },
    ];
    
    // 使用ID的哈希值来确定颜色方案索引
    final colorIndex = phaseId.hashCode.abs() % colorSchemes.length;
    return colorSchemes[colorIndex];
  }

  @override
  Widget build(BuildContext context) {
    if (phases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 16),
              const Text(
                '还没有阶段',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '点击"添加阶段"按钮来创建第一个阶段',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => onAddPhase(null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加阶段'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // 构建阶段列表
    return Column(
      children: [
        // 构建所有阶段
        ...phases.map((phase) {
          return SpecialProjectPhase(
            id: phase.id,
            title: phase.name,
            onEdit: () => onEditPhase(phase.id),
            onAddPhaseBefore: () => onAddPhase(phase.id),
            onDeletePhase: () => onDeletePhase(phase.id),
            children: [
              SpecialProjectTimeline(
                phaseId: phase.id,
                tasks: phase.tasks,
                onAddTask: () => onAddTask(phase.id),
                onAddTaskBefore: (taskId) => onAddTaskBefore(phase.id, taskId),
                onEditTask: (task) => onEditTask(phase.id, task),
                onDeleteTask: (taskId) => onDeleteTask(taskId),
                onCompleteTask: (task) => onCompleteTask(task),
                phaseColors: _getPhaseColors(phase.id),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
} 