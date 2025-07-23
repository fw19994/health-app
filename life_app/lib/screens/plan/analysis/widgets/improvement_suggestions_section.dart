import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 改进建议部分组件
class ImprovementSuggestionsSection extends StatelessWidget {
  final DateTime date;
  final String periodType;
  
  const ImprovementSuggestionsSection({
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
                // 建议卡片
                _buildSuggestionCard(
                  icon: FontAwesomeIcons.clock,
                  title: '优化时间分配',
                  description: '将重要工作计划安排在上午9:00-11:30，这个时段您的完成率最高(92%)',
                ),
                
                const SizedBox(height: 12),
                
                _buildSuggestionCard(
                  icon: FontAwesomeIcons.listCheck,
                  title: '拆分复杂任务',
                  description: '将"项目策划"等大型工作计划拆分为更小的任务，提高完成率',
                ),
                
                const SizedBox(height: 12),
                
                _buildSuggestionCard(
                  icon: FontAwesomeIcons.bell,
                  title: '调整提醒时间',
                  description: '对于工作类计划，建议提前30分钟提醒，而非当前的15分钟',
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
        children: const [
          Icon(
            FontAwesomeIcons.lightbulb,
            size: 16,
            color: Color(0xFFF59E0B),
          ),
          SizedBox(width: 8),
          Text(
            '改进建议',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建建议卡片
  Widget _buildSuggestionCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图标容器
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 内容部分
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 