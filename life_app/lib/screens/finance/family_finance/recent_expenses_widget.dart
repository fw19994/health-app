import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'models.dart';

class RecentExpensesWidget extends StatelessWidget {
  final List<FamilyExpense> expenses;
  final VoidCallback onViewAll;
  final bool isLoading;

  const RecentExpensesWidget({
    Key? key,
    required this.expenses,
    required this.onViewAll,
    this.isLoading = false,
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
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (expenses.isEmpty)
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
                padding: EdgeInsets.only(bottom: index < expenses.length - 1 ? 16.0 : 0),
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
      formattedDate = '今天 ${DateFormat('HH:mm', 'zh_CN').format(expense.date)}';
    } else if (expenseDate == today.subtract(const Duration(days: 1))) {
      formattedDate = '昨天 ${DateFormat('HH:mm', 'zh_CN').format(expense.date)}';
    } else {
      formattedDate = DateFormat('MM-dd HH:mm', 'zh_CN').format(expense.date);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: expense.iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                expense.icon,
                color: expense.iconColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 中间信息区
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图标名称 - 如果有的话
                if (expense.iconName.isNotEmpty)
                  Text(
                    expense.iconName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 1),
                
                // 时间和交易标签行
                Row(
                  children: [
                    // 支出标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '支出',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    
                    // 时间
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                    
                    // 备注信息(如果有)
                    if (expense.notes.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '•',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        expense.notes,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // 标题
                    if (expense.notes.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '•',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    
                    Expanded(
                      child: Text(
                        expense.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF555555),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 右侧区域 - 金额和用户
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 金额
              Text(
                '¥${expense.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // 用户信息
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 用户头像
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: expense.avatarUrl.isNotEmpty
                        ? Image.network(
                            expense.avatarUrl,
                            width: 16,
                            height: 16,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar(expense.payerName, 16);
                            },
                          )
                        : _buildDefaultAvatar(expense.payerName, 16),
                  ),
                  const SizedBox(width: 4),
                  // 用户名称
                  Text(
                    expense.payerName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 创建默认头像
  Widget _buildDefaultAvatar(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 