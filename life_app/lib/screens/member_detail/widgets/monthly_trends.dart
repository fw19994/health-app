import 'package:flutter/material.dart';

class MonthlyTrends extends StatelessWidget {
  final List<MonthData> monthlyData;
  final VoidCallback onViewMore;

  const MonthlyTrends({
    super.key,
    required this.monthlyData,
    required this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    // 计算平均月支出
    final double averageExpense = monthlyData.fold(0.0, (sum, month) => sum + month.expense) / monthlyData.length;
    
    // 找出最高支出月
    final MonthData highestMonth = monthlyData.reduce((curr, next) => curr.expense > next.expense ? curr : next);
    
    // 计算本月趋势（与上月相比）
    final double currentMonthTrend = monthlyData.isNotEmpty && monthlyData.length > 1
        ? (monthlyData.last.expense - monthlyData[monthlyData.length - 2].expense) / monthlyData[monthlyData.length - 2].expense * 100
        : 0.0;
    
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
        children: [
          // 标题和"查看更多"按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "月度消费趋势",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: onViewMore,
                child: const Text(
                  "查看更多",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 柱状图
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                monthlyData.length,
                (index) => _buildBar(monthlyData[index], highestMonth.expense),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 统计信息
          Column(
            children: [
              _buildStatRow(
                label: "平均月支出",
                value: "¥${averageExpense.toStringAsFixed(0)}",
              ),
              const SizedBox(height: 4),
              _buildStatRow(
                label: "本月趋势",
                value: "${currentMonthTrend >= 0 ? '+' : ''}${currentMonthTrend.toStringAsFixed(1)}% vs 上月",
                valueColor: currentMonthTrend < 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
              const SizedBox(height: 4),
              _buildStatRow(
                label: "最高支出月",
                value: "${highestMonth.label} (¥${highestMonth.expense.toStringAsFixed(0)})",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建单个柱状图条
  Widget _buildBar(MonthData month, double maxExpense) {
    final double height = 120 * (month.expense / maxExpense);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 柱子
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // 月份标签
        Text(
          month.label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  // 构建统计行
  Widget _buildStatRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

class MonthData {
  final String label;
  final double expense;
  
  const MonthData({
    required this.label,
    required this.expense,
  });
}
