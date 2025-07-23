import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 习惯分析部分组件
class HabitAnalysisSection extends StatelessWidget {
  final DateTime date;
  final String periodType;
  
  const HabitAnalysisSection({
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
                // 习惯卡片
                _buildHabitCard(
                  icon: FontAwesomeIcons.dumbbell,
                  title: '每日健身',
                  description: '连续完成21天，已形成稳定习惯',
                  status: 'good',
                  statusText: '优秀',
                ),
                
                const SizedBox(height: 12),
                
                _buildHabitCard(
                  icon: FontAwesomeIcons.book,
                  title: '晨间阅读',
                  description: '完成率85%，建议保持',
                  status: 'good',
                  statusText: '良好',
                ),
                
                const SizedBox(height: 12),
                
                _buildHabitCard(
                  icon: FontAwesomeIcons.laptopCode,
                  title: '编程学习',
                  description: '完成率仅58%，建议调整时间或降低频率',
                  status: 'warning',
                  statusText: '需改进',
                ),
                
                const SizedBox(height: 12),
                
                _buildHabitCard(
                  icon: FontAwesomeIcons.bed,
                  title: '早睡早起',
                  description: '完成率仅40%，建议重新设定更合理的目标',
                  status: 'bad',
                  statusText: '不稳定',
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
            FontAwesomeIcons.repeat,
            size: 16,
            color: Color(0xFF8B5CF6),
          ),
          SizedBox(width: 8),
          Text(
            '习惯分析',
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
  
  // 构建习惯卡片
  Widget _buildHabitCard({
    required IconData icon,
    required String title,
    required String description,
    required String status,
    required String statusText,
  }) {
    // 根据状态设置不同的样式
    Color iconBgColor;
    Color iconColor;
    Color badgeBgColor;
    Color badgeTextColor;
    
    switch (status) {
      case 'good':
        iconBgColor = const Color(0xFFD1FAE5);
        iconColor = const Color(0xFF059669);
        badgeBgColor = const Color(0xFFD1FAE5);
        badgeTextColor = const Color(0xFF059669);
        break;
      case 'warning':
        iconBgColor = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        badgeBgColor = const Color(0xFFFEF3C7);
        badgeTextColor = const Color(0xFFD97706);
        break;
      case 'bad':
        iconBgColor = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFDC2626);
        badgeBgColor = const Color(0xFFFEE2E2);
        badgeTextColor = const Color(0xFFDC2626);
        break;
      default:
        iconBgColor = const Color(0xFFD1FAE5);
        iconColor = const Color(0xFF059669);
        badgeBgColor = const Color(0xFFD1FAE5);
        badgeTextColor = const Color(0xFF059669);
    }
    
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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 内容部分
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
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