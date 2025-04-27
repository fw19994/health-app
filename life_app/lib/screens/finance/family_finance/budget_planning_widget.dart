import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'models.dart';

class BudgetPlanningWidget extends StatelessWidget {
  final List<BudgetItem> budgetItems;
  final VoidCallback onEdit;

  const BudgetPlanningWidget({
    Key? key,
    required this.budgetItems,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '家庭预算规划',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 14,
                      color: Color(0xFF16A34A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '编辑',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 预算列表
          if (budgetItems.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '暂无预算规划',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              budgetItems.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildBudgetItem(budgetItems[index]),
              ),
            ),
        ],
      ),
    );
  }
  
  // 预算项目
  Widget _buildBudgetItem(BudgetItem item) {
    // 计算预算使用百分比
    double percentage = (item.currentAmount / item.budgetAmount) * 100;
    if (percentage > 100) {
      percentage = 100; // 限制为最大100%显示
    }
    
    // 确定进度条颜色
    Color progressColor;
    if (item.isOverBudget) {
      progressColor = const Color(0xFFEF4444); // 超出预算红色
    } else if (percentage > 80) {
      progressColor = const Color(0xFFF59E0B); // 接近预算琥珀色
    } else {
      progressColor = const Color(0xFF10B981); // 未超出预算绿色
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FaIcon(
                  item.icon,
                  color: const Color(0xFF6B7280),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            Text(
              '¥${item.currentAmount.toStringAsFixed(0)} / ¥${item.budgetAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 13,
                color: item.isOverBudget ? const Color(0xFFEF4444) : const Color(0xFF4B5563),
                fontWeight: item.isOverBudget ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 