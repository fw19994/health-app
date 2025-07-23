import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/plan/special_project_model.dart';

class SpecialProjectHeader extends StatelessWidget {
  final SpecialProject project;
  
  const SpecialProjectHeader({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
        ),
      ),
      child: Column(
        children: [
          // 标题和返回按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Text(
                '专项计划',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // 占位，保持标题居中
              const SizedBox(width: 24),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 日期和状态
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '开始: ${_formatDate(project.startDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE0E7FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA5B4FC),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '预计完成: ${_formatDate(project.endDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE0E7FF),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(project.status),
            ],
          ),
        ],
      ),
    );
  }
  
  // 格式化日期
  String _formatDate(DateTime? date) {
    if (date == null) return '未设置';
    return '${date.year}年${date.month}月${date.day}日';
  }
  
  // 构建状态标签
  Widget _buildStatusBadge(ProjectStatus status) {
    String text;
    
    switch (status) {
      case ProjectStatus.active:
        text = '进行中';
        break;
      case ProjectStatus.completed:
        text = '已完成';
        break;
      case ProjectStatus.planned:
        text = '未开始';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
} 