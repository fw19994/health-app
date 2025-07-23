import 'package:flutter/material.dart';
import '../../../models/plan/special_project_model.dart';

class SpecialProjectSummary extends StatelessWidget {
  final SpecialProject project;
  
  const SpecialProjectSummary({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 计算项目进度
    final progress = project.completedTasks / (project.totalTasks > 0 ? project.totalTasks : 1);
    final progressPercent = (progress * 100).toInt();
    
    // 计算剩余天数
    final daysLeft = project.endDate != null
        ? project.endDate!.difference(DateTime.now()).inDays
        : 0;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目名称
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          // 进度百分比
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '总进度:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          
          // 进度条
          const SizedBox(height: 8),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Container(
                  height: 10,
                  width: MediaQuery.of(context).size.width * 0.8 * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          
          // 任务完成情况和剩余天数
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 任务完成情况
              Row(
                children: [
                  const Icon(
                    Icons.task_alt,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${project.completedTasks}/${project.totalTasks} 已完成',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              
              // 剩余天数
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '还剩 $daysLeft 天',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
} 