import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/transaction.dart';

class RecentTransactions extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onViewAll;

  const RecentTransactions({
    super.key,
    required this.transactions,
    required this.onViewAll,
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
          // 标题和"查看全部"按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "近期交易",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  "查看全部",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 交易列表
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildTransactionItem(transactions[index]);
            },
          ),
        ],
      ),
    );
  }

  // 构建单个交易项
  Widget _buildTransactionItem(Transaction transaction) {
    final DateFormat dateFormat = DateFormat('yyyy年M月d日', 'zh_CN');
    
    // 使用Transaction对象自带的iconName属性
    // 如果iconName为空，则使用默认逻辑确定图标名称
    String iconName = transaction.iconName;
    
    // 如果iconName为空，则根据图标类型推断
    if (iconName.isEmpty) {
      if (transaction.icon == FontAwesomeIcons.house) {
        iconName = "住房";
      } else if (transaction.icon == FontAwesomeIcons.car) {
        iconName = "交通";
      } else if (transaction.icon == FontAwesomeIcons.utensils) {
        iconName = "餐饮";
      } else if (transaction.icon == FontAwesomeIcons.briefcase) {
        iconName = "工作";
      } else if (transaction.icon == FontAwesomeIcons.shoppingBag) {
        iconName = "购物";
      } else if (transaction.icon == FontAwesomeIcons.medkit) {
        iconName = "医疗";
      } else {
        iconName = transaction.type == TransactionType.income ? "收入" : "支出";
      }
    }
    
    return Row(
      children: [
        // 图标
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: transaction.iconBgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            transaction.icon,
            color: transaction.iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        
        // 交易信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 显示图标名称作为主要信息
              Text(
                iconName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              // 日期后面显示原标题信息
              Row(
                children: [
                  Text(
                    dateFormat.format(transaction.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "•",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 金额
        Text(
          transaction.formattedAmount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: transaction.amountColor,
          ),
        ),
      ],
    );
  }
}
