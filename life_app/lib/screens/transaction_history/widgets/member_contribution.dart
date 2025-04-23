import 'package:flutter/material.dart';
import '../../member_finances/models/family_member.dart';

class MemberExpenseContribution extends StatelessWidget {
  final List<FamilyMember> members;
  final String periodText;

  const MemberExpenseContribution({
    super.key,
    required this.members,
    required this.periodText,
  });

  @override
  Widget build(BuildContext context) {
    // 筛选掉"全家"成员，只保留具体家庭成员
    final familyMembers = members.where((member) => member.role != '家庭主账户').toList();
    
    // 计算总支出
    final totalExpense = familyMembers.fold(0.0, (sum, member) => sum + member.expenses);
    
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
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '成员支出占比',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                periodText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 24,
              child: Row(
                children: List.generate(
                  familyMembers.length,
                  (index) {
                    final member = familyMembers[index];
                    final contribution = (member.expenses / totalExpense);
                    return _buildContributionSegment(
                      contribution: contribution,
                      color: member.color,
                      label: member.role,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 图例
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(
              familyMembers.length,
              (index) {
                final member = familyMembers[index];
                final contribution = (member.expenses / totalExpense);
                return _buildLegendItem(
                  color: member.color,
                  label: member.role,
                  name: member.name,
                  amount: member.expenses,
                  percentage: contribution * 100,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建贡献进度条段
  Widget _buildContributionSegment({
    required double contribution,
    required Color color,
    required String label,
  }) {
    return Expanded(
      flex: (contribution * 100).round(),
      child: Container(
        color: color,
        alignment: Alignment.center,
        child: contribution > 0.1 ? Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ) : null,
      ),
    );
  }

  // 构建图例项
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String name,
    required double amount,
    required double percentage,
  }) {
    return SizedBox(
      width: 150,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: ${percentage.toStringAsFixed(0)}% (¥${amount.toStringAsFixed(0)})",
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
