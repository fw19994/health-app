import 'package:flutter/material.dart';
import '../../../models/savings_goal.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final Function() onEdit;

  const SavingsGoalCard({
    Key? key,
    required this.goal,
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
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    IconData(
                      int.parse(goal.icon),
                      fontFamily: 'MaterialIcons',
                    ),
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '目标金额: ¥${goal.targetAmount.toStringAsFixed(2)}',
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
              value: goal.progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已存: ¥${goal.currentAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '每月存入: ¥${goal.monthlyContribution.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
