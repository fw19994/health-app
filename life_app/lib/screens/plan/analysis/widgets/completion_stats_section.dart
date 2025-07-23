import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 完成情况统计部分组件
class CompletionStatsSection extends StatelessWidget {
  final DateTime date;
  final String periodType;
  
  const CompletionStatsSection({
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
                // 统计数据网格
                _buildStatsGrid(),
                
                const SizedBox(height: 16),
                
                // 各类别完成进度条
                _buildProgressBars(context),
                
                const SizedBox(height: 16),
                
                // 计划完成热力图
                _buildHeatMap(),
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
                FontAwesomeIcons.chartPie,
                size: 16,
                color: Color(0xFF3B82F6),
              ),
              SizedBox(width: 8),
              Text(
                '完成情况',
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
  
  // 构建统计数据网格
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.0,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          value: '78%',
          label: '总完成率',
          valueColor: const Color(0xFF3B82F6),
        ),
        _buildStatCard(
          value: '+12%',
          label: '环比增长',
          valueColor: const Color(0xFF10B981),
        ),
        _buildStatCard(
          value: '42',
          label: '已完成计划',
          valueColor: const Color(0xFF111827),
        ),
        _buildStatCard(
          value: '12',
          label: '未完成计划',
          valueColor: const Color(0xFF111827),
        ),
      ],
    );
  }
  
  // 构建单个统计卡片
  Widget _buildStatCard({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建进度条
  Widget _buildProgressBars(BuildContext context) {
    return Column(
      children: [
        _buildProgressBar(
          context: context,
          category: '工作',
          percentage: 65,
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          context: context,
          category: '健康',
          percentage: 92,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          context: context,
          category: '个人',
          percentage: 75,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          context: context,
          category: '家庭',
          percentage: 80,
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }
  
  // 构建单个进度条
  Widget _buildProgressBar({
    required BuildContext context,
    required String category,
    required int percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8 * percentage / 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 构建热力图
  Widget _buildHeatMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          '计划完成热力图',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        _buildCalendarHeatmap(),
        const SizedBox(height: 4),
        _buildHeatmapLegend(),
      ],
    );
  }
  
  // 构建日历热力图
  Widget _buildCalendarHeatmap() {
    // 热力图级别定义
    final heatLevels = [
      const Color(0xFFF3F4F6), // 级别0
      const Color(0xFFDBEAFE), // 级别1
      const Color(0xFF93C5FD), // 级别2
      const Color(0xFF60A5FA), // 级别3
      const Color(0xFF3B82F6), // 级别4
    ];
    
    // 模拟数据
    final List<int> heatData = [
      0, 1, 3, 2, 4, 2, 1,
      1, 2, 4, 3, 2, 1, 0,
      0, 1, 2, 4, 3, 2, 1,
      1, 3, 4, 2, 1, 0, 1,
    ];
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children: List.generate(28, (index) {
        final level = heatData[index];
        return Container(
          decoration: BoxDecoration(
            color: heatLevels[level],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
  
  // 构建热力图图例
  Widget _buildHeatmapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '较少',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        Row(
          children: [
            _buildLegendItem(const Color(0xFFF3F4F6)),
            const SizedBox(width: 1),
            _buildLegendItem(const Color(0xFFDBEAFE)),
            const SizedBox(width: 1),
            _buildLegendItem(const Color(0xFF93C5FD)),
            const SizedBox(width: 1),
            _buildLegendItem(const Color(0xFF60A5FA)),
            const SizedBox(width: 1),
            _buildLegendItem(const Color(0xFF3B82F6)),
          ],
        ),
        Text(
          '较多',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
  
  // 构建图例项
  Widget _buildLegendItem(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
} 