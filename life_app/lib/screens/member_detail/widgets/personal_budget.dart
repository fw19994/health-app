import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/budget_item.dart';

class PersonalBudget extends StatelessWidget {
  final double totalBudget;
  final double usedAmount;
  final List<BudgetItem> budgetItems;
  final Function(BudgetItem) onEditBudget;

  const PersonalBudget({
    super.key,
    required this.totalBudget,
    required this.usedAmount,
    required this.budgetItems,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    // 计算已用百分比
    final double usedPercentage = (usedAmount / totalBudget * 100).clamp(0, 100);
    
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
            "个人月度预算",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // 总预算和已使用金额
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 总预算
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "总预算额度",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "¥${totalBudget.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
              
              // 已使用
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.chartPie,
                        size: 16,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "已使用",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          "¥${usedAmount.toStringAsFixed(0)} (${usedPercentage.toStringAsFixed(1)}%)",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
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
          
          // 预算分配
          ...budgetItems.map((item) => _buildBudgetItem(item)).toList(),
        ],
      ),
    );
  }

  // 构建单个预算项
  Widget _buildBudgetItem(BudgetItem item) {
    return Column(
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
                    color: item.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "¥${item.amount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onEditBudget(item),
                  child: const Icon(
                    FontAwesomeIcons.penToSquare,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 进度条
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: item.usagePercentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "¥${item.used.toStringAsFixed(0)} / ¥${item.amount.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
