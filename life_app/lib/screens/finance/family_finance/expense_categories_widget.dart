import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'models.dart';

class ExpenseCategoriesWidget extends StatelessWidget {
  final List<ExpenseCategoryData> categories;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ExpenseCategoriesWidget({
    Key? key,
    required this.categories,
    required this.isLoading,
    required this.onRefresh,
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
          const Text(
            '家庭支出分类',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (categories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    const Text(
                      '本月暂无支出数据',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onRefresh,
                      child: const Text('刷新分类数据', style: TextStyle(color: Color(0xFF16A34A))),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < categories.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Builder(builder: (context) {
                      try {
                        return _buildCategoryProgressBar(categories[i]);
                      } catch (e) {
                        return Text('分类 ${i+1} 数据错误: $e', 
                          style: const TextStyle(color: Colors.red, fontSize: 12));
                      }
                    }),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // 类别进度条
  Widget _buildCategoryProgressBar(ExpenseCategoryData category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (category.color ?? Colors.grey.shade600).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: FaIcon(
                      category.icon ?? FontAwesomeIcons.tag,
                      color: category.color ?? Colors.grey.shade600,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            Text(
              '¥${category.amount.toStringAsFixed(0)} (${category.percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
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
            widthFactor: category.percentage / 100,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 