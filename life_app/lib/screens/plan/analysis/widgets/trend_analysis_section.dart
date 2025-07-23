import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 趋势分析部分组件
class TrendAnalysisSection extends StatelessWidget {
  final DateTime date;
  final String periodType;
  
  const TrendAnalysisSection({
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
                // 趋势图
                _buildTrendChart(),
                
                // 图例
                _buildChartLegend(),
                
                const SizedBox(height: 16),
                
                // 关键发现
                _buildKeyFindings(),
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
                FontAwesomeIcons.chartLine,
                size: 16,
                color: Color(0xFF10B981),
              ),
              SizedBox(width: 8),
              Text(
                '趋势分析',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // TODO: 跳转到详情页面
            },
            child: const Text(
              '详情',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建趋势图
  Widget _buildTrendChart() {
    // 在实际应用中，这里应该使用图表库（如fl_chart）绘制趋势图
    // 此处为简化实现，使用占位图
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.insert_chart_outlined,
              size: 48,
              color: Color(0xFF6B7280),
            ),
            SizedBox(height: 8),
            Text(
              '计划完成率趋势图',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建图例
  Widget _buildChartLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildLegendItem(
            color: const Color(0xFF3B82F6),
            label: '工作',
          ),
          _buildLegendItem(
            color: const Color(0xFF10B981),
            label: '健康',
          ),
          _buildLegendItem(
            color: const Color(0xFFF59E0B),
            label: '个人',
          ),
          _buildLegendItem(
            color: const Color(0xFF8B5CF6),
            label: '家庭',
          ),
        ],
      ),
    );
  }
  
  // 构建单个图例项
  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
  
  // 构建关键发现
  Widget _buildKeyFindings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '关键发现',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        _buildFindingsList(),
      ],
    );
  }
  
  // 构建发现列表
  Widget _buildFindingsList() {
    final findings = [
      '健康类计划完成率持续提高，近3周保持在90%以上',
      '工作类计划在周一、周二完成率最高，周五最低',
      '晚间8点后安排的计划完成率普遍较低',
    ];
    
    return Column(
      children: findings.map((finding) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF6B7280),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  finding,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 