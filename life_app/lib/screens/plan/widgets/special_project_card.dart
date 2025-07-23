import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/plan/special_project_model.dart';
import '../../../constants/routes.dart';

class SpecialProjectCard extends StatelessWidget {
  final SpecialProject project;
  
  const SpecialProjectCard({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 导航到专项计划详情页面
        Navigator.pushNamed(
          context,
          Routes.specialProjectDetail,
          arguments: project.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                _buildStatusBadge(project.status),
              ],
            ),
            
            // 日期
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _formatDateRange(project.startDate, project.endDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            
            // 任务完成情况和预算
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '已完成: ${project.completedTasks}/${project.totalTasks}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    '总预算: ¥${_formatNumber(project.budget)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // 进度条
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7 * _getClampedProgress(_getCorrectProgress(project)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: _getProgressGradient(project.status),
                    ),
                  ),
                ],
              ),
            ),
            
            // 进度和剩余时间
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '进度: ${_formatProgress(_getCorrectProgress(project))}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    _getRemainingTimeText(project),
                    style: const TextStyle(
                      fontSize: 12,
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

  // 构建状态标签
  Widget _buildStatusBadge(ProjectStatus status) {
    String text;
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case ProjectStatus.active:
        text = '进行中';
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      case ProjectStatus.completed:
        text = '已完成';
        backgroundColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0369A1);
        break;
      case ProjectStatus.planned:
        text = '未开始';
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
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

  // 获取进度条渐变色
  LinearGradient _getProgressGradient(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case ProjectStatus.completed:
        return const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case ProjectStatus.planned:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }

  // 格式化日期范围
  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return '${formatter.format(start)} 至 ${formatter.format(end)}';
  }

  // 格式化数字（添加千位分隔符）
  String _formatNumber(double number) {
    final NumberFormat formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // 获取剩余时间文本
  String _getRemainingTimeText(SpecialProject project) {
    if (project.status == ProjectStatus.completed) {
      return '已完成';
    }
    
    if (project.status == ProjectStatus.planned) {
      return '未开始';
    }
    
    if (project.endDate == null) {
      return '无截止日期';
    }
    
    final now = DateTime.now();
    final difference = project.endDate!.difference(now).inDays;
    
    if (difference < 0) {
      return '已逾期${-difference}天';
    }
    
    return '还剩: ${difference}天';
  }

  // 格式化进度百分比
  String _formatProgress(double progress) {
    // 计算百分比，确保使用正确的进度值
    int percentage = (progress * 100).clamp(0, 100).toInt();
    return '${percentage}%';
  }
  
  // 获取正确的进度值用于UI显示
  double _getCorrectProgress(SpecialProject project) {
    // 计算实际进度（已完成/总任务）
    if (project.totalTasks > 0) {
      return project.completedTasks / project.totalTasks;
    }
    return 0.0;
  }
  
  // 获取已完成的进度（确保不超过100%）
  double _getClampedProgress(double progress) {
    return progress.clamp(0.0, 1.0);
  }
} 