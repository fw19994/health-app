import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionDateGroup> transactionGroups;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool hasMoreData;

  const TransactionList({
    super.key,
    required this.transactionGroups,
    required this.onLoadMore,
    required this.isLoadingMore,
    required this.hasMoreData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 日期分组的交易列表
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactionGroups.length,
          itemBuilder: (context, index) {
            final group = transactionGroups[index];
            return _buildDateGroup(group);
          },
        ),
        
        // 加载更多按钮
        const SizedBox(height: 16),
        if (isLoadingMore)
          // 加载中状态
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B7280)),
                    )
                  ),
                  SizedBox(width: 8),
                  Text(
                    '加载中...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (!hasMoreData && transactionGroups.isNotEmpty)
          // 全部加载完成状态
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 8),
                Text(
                  '已经到底啦',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )
        else
          // 加载更多按钮
          GestureDetector(
            onTap: hasMoreData ? onLoadMore : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: hasMoreData ? Colors.white : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: hasMoreData ? const Color(0xFFE5E7EB) : const Color(0xFFD1D5DB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 16,
                    color: hasMoreData ? const Color(0xFF6B7280) : const Color(0xFFA1A1AA),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasMoreData ? '加载更多' : '没有更多数据',
                    style: TextStyle(
                      fontSize: 14,
                      color: hasMoreData ? const Color(0xFF6B7280) : const Color(0xFFA1A1AA),
                    ),
                  ),
                ],
              ),
          ),
        ),
      ],
    );
  }

  // 构建日期分组
  Widget _buildDateGroup(TransactionDateGroup group) {
    return Column(
      children: [
        // 日期标题
        _buildDateHeader(group),
        
        // 交易列表容器
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.transactions.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Color(0xFFE5E7EB),
            ),
            itemBuilder: (context, index) {
              return _buildTransactionItem(group.transactions[index]);
            },
          ),
        ),
      ],
    );
  }

  // 构建日期标题
  Widget _buildDateHeader(TransactionDateGroup group) {
    final dateFormat = DateFormat('yyyy年M月d日');
    
    String dateText = dateFormat.format(group.date);
    if (group.isToday) {
      dateText += ' (今天)';
    } else if (group.isYesterday) {
      dateText += ' (昨天)';
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            '收支: ${group.formattedBalance}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: group.balance >= 0
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  // 构建交易项
  Widget _buildTransactionItem(Transaction transaction) {
    final timeFormat = DateFormat('HH:mm');
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 交易分类图标 - 使用与财务仪表盘相同的样式
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: transaction.categoryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
            child: Icon(
              transaction.categoryIcon,
              size: 20,
                color: transaction.categoryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          
          // 交易信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                    Text(
                  transaction.category,
                      style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                // 标签、日期和备注信息
                Row(
                  children: [
                    // 交易类型标签 - 显示为支出/收入
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: transaction.type == TransactionType.expense 
                            ? Colors.red.shade50 
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transaction.type == TransactionType.expense ? '支出' : '收入',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: transaction.type == TransactionType.expense 
                              ? Colors.red.shade700 
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 6),
                    
                    // 类别名称 - 添加类别标签
                    if (transaction.category.isNotEmpty && transaction.category != '未分类')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: transaction.categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: transaction.categoryColor,
                          ),
                        ),
                      ),
                    
                    const SizedBox(width: 6),
                    
                    // 日期时间
                    Text(
                      timeFormat.format(DateTime(
                        transaction.date.year,
                        transaction.date.month,
                        transaction.date.day,
                        transaction.time.hour,
                        transaction.time.minute,
                      )),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    // 如果有备注，添加分隔点
                    if (transaction.description != null && transaction.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '•',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    
                    // 备注 (如果有)
                    if (transaction.description != null && transaction.description!.isNotEmpty)
                      Flexible(
                        child: Text(
                          transaction.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                      ),
                    ),
                  ],
                ),
                
                // 成员标签 - 如果需要显示
                if (transaction.memberName.isNotEmpty && transaction.memberName != '未知')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: transaction.memberColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.memberName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: transaction.memberColor,
                        ),
                      ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 金额
          Text(
            transaction.formattedAmount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: transaction.amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
