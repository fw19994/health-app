import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// AI总结部分组件
class AISummarySection extends StatelessWidget {
  final DateTime date;
  final String periodType;
  
  const AISummarySection({
    Key? key,
    required this.date,
    required this.periodType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // 标题部分
          _buildSectionHeader(context),
          
          // 内容部分
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // AI信息卡片
                _buildAIMessageCard(
                  message: '李明，本${periodType}您完成了78%的计划，比上${periodType}提高了12%。您在健康类计划方面表现最佳，完成率达到92%。',
                  type: 'info',
                ),
                
                const SizedBox(height: 12),
                
                // AI建议卡片
                _buildAIMessageCard(
                  message: '建议：工作类计划完成率较低(65%)，建议将复杂工作拆分为更小的任务，并在上午时段安排重要工作。',
                  type: 'suggestion',
                ),
                
                const SizedBox(height: 12),
                
                // AI警告卡片
                _buildAIMessageCard(
                  message: '注意：您有3个重复性计划连续3次未完成，可能需要调整计划难度或时间安排。',
                  type: 'warning',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建部分标题
  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(
                FontAwesomeIcons.robot,
                size: 16,
                color: Color(0xFF6366F1),
              ),
              SizedBox(width: 8),
              Text(
                'AI总结',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          Text(
            '更新于 2小时前',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建AI消息卡片
  Widget _buildAIMessageCard({required String message, required String type}) {
    // 根据类型设置不同的样式
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    
    switch (type) {
      case 'info':
        backgroundColor = const Color(0xFFF0F9FF);
        borderColor = const Color(0xFF3B82F6);
        textColor = const Color(0xFF1E3A8A);
        break;
      case 'suggestion':
        backgroundColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF065F46);
        break;
      case 'warning':
        backgroundColor = const Color(0xFFFFF7ED);
        borderColor = const Color(0xFFF97316);
        textColor = const Color(0xFF9A3412);
        break;
      default:
        backgroundColor = const Color(0xFFF0F9FF);
        borderColor = const Color(0xFF3B82F6);
        textColor = const Color(0xFF1E3A8A);
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4,
          ),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
      ),
    );
  }
} 