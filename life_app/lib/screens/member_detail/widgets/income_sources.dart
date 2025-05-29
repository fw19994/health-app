import 'package:flutter/material.dart';
import '../models/income_source.dart';

class IncomeSources extends StatelessWidget {
  final List<IncomeSource> sources;
  final VoidCallback onViewDetails;

  const IncomeSources({
    super.key,
    required this.sources,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
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
          // 标题（移除了"查看详情"按钮）
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "收入来源",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 收入来源列表
          ...List.generate(
            sources.length,
            (index) => _buildIncomeSourceItem(sources[index]),
          ),
        ],
      ),
    );
  }

  // 构建单个收入来源项
  Widget _buildIncomeSourceItem(IncomeSource source) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 名称和金额
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: source.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  source.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            Text(
              "¥${source.amount.toStringAsFixed(0)} (${source.percentage.toStringAsFixed(1)}%)",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
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
            widthFactor: source.percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: source.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
