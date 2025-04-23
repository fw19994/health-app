import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FinancialHealth extends StatelessWidget {
  final int score; // 总分
  final List<HealthMetric> metrics;
  final int lastMonthScore;

  const FinancialHealth({
    super.key,
    required this.score,
    required this.metrics,
    required this.lastMonthScore,
  });

  @override
  Widget build(BuildContext context) {
    final scoreDiff = score - lastMonthScore;
    final String healthStatus = _getHealthStatus(score);
    final Color statusColor = _getStatusColor(score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "财务健康评估",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // 总分和状态
          Row(
            children: [
              // 进度环
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  children: [
                    // 背景环
                    SizedBox(
                      width: 112,
                      height: 112,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 12,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE5E7EB)),
                      ),
                    ),
                    
                    // 进度环
                    SizedBox(
                      width: 112,
                      height: 112,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    
                    // 中心分数显示
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$score",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const Text(
                            "总分100",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // 健康状态和变化
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      healthStatus,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "您的财务状况健康且稳定",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          scoreDiff >= 0 ? FontAwesomeIcons.arrowTrendUp : FontAwesomeIcons.arrowTrendDown,
                          size: 16,
                          color: scoreDiff >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "比上个月${scoreDiff >= 0 ? '提升' : '下降'}了${scoreDiff.abs()}分",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 指标明细
          ...metrics.map((metric) => _buildMetricItem(metric)).toList(),
        ],
      ),
    );
  }

  // 构建指标项
  Widget _buildMetricItem(HealthMetric metric) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  metric.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            Text(
              "${_getMetricStatus(metric.score / metric.maxScore)} (${metric.score}/${metric.maxScore})",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getMetricStatusColor(metric.score / metric.maxScore),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // 进度条
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: metric.score / metric.maxScore,
            child: Container(
              decoration: BoxDecoration(
                color: _getProgressColor(metric.score / metric.maxScore),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // 获取健康状态描述
  String _getHealthStatus(int score) {
    if (score >= 90) return "优秀";
    if (score >= 80) return "良好";
    if (score >= 70) return "一般";
    if (score >= 60) return "待改进";
    return "风险";
  }

  // 获取健康状态颜色
  Color _getStatusColor(int score) {
    if (score >= 80) return const Color(0xFF10B981); // 绿色
    if (score >= 70) return const Color(0xFFFCD34D); // 黄色
    if (score >= 60) return const Color(0xFFF97316); // 橙色
    return const Color(0xFFEF4444); // 红色
  }

  // 获取指标状态描述
  String _getMetricStatus(double ratio) {
    if (ratio >= 0.9) return "优秀";
    if (ratio >= 0.8) return "良好";
    if (ratio >= 0.7) return "一般";
    if (ratio >= 0.6) return "待改进";
    return "风险";
  }

  // 获取指标状态颜色
  Color _getMetricStatusColor(double ratio) {
    if (ratio >= 0.8) return const Color(0xFF10B981); // 绿色
    if (ratio >= 0.7) return const Color(0xFFFCD34D); // 黄色
    if (ratio >= 0.6) return const Color(0xFFF97316); // 橙色
    return const Color(0xFFEF4444); // 红色
  }
  
  // 获取进度条颜色
  Color _getProgressColor(double ratio) {
    if (ratio >= 0.8) return const Color(0xFF4F46E5); // 蓝色/紫色
    if (ratio >= 0.7) return const Color(0xFFFCD34D); // 黄色
    return const Color(0xFFEF4444); // 红色
  }
}

class HealthMetric {
  final String name;
  final int score;
  final int maxScore;
  
  const HealthMetric({
    required this.name,
    required this.score,
    required this.maxScore,
  });
}
