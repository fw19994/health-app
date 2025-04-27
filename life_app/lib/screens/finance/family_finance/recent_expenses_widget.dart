import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'models.dart';

class RecentExpensesWidget extends StatelessWidget {
  final List<FamilyExpense> expenses;
  final VoidCallback onViewAll;

  const RecentExpensesWidget({
    Key? key,
    required this.expenses,
    required this.onViewAll,
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
                '近期家庭支出',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF16A34A),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 近期支出列表
          if (expenses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '暂无近期支出记录',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...List.generate(
              expenses.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildExpenseItem(expenses[index]),
              ),
            ),
        ],
      ),
    );
  }
  
  // 支出项目
  Widget _buildExpenseItem(FamilyExpense expense) {
    // 格式化日期
    String formattedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
    
    if (expenseDate == today) {
      formattedDate = '今天';
    } else if (expenseDate == today.subtract(const Duration(days: 1))) {
      formattedDate = '昨天';
    } else {
      formattedDate = DateFormat('MM月dd日', 'zh_CN').format(expense.date);
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 类别图标
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: expense.iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FaIcon(
              expense.icon,
              color: expense.iconColor,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // 支出信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    expense.payerName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '•',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 金额和类别
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '-¥${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              expense.category,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 