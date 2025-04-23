import 'package:flutter/material.dart';
import '../../../models/budget_category.dart';

class BudgetCategoryCard extends StatelessWidget {
  final BudgetCategory category;
  final Function() onEdit;

  const BudgetCategoryCard({
    Key? key,
    required this.category,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse(category.color)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    IconData(
                      int.parse(category.icon),
                      fontFamily: 'MaterialIcons',
                    ),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '已使用: ¥${category.spent.toStringAsFixed(2)} / ¥${category.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: onEdit,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: category.progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(int.parse(category.color)),
              ),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }
}
