import 'package:flutter/material.dart';
import '../models/family_member.dart';

class ExpenseDistribution extends StatelessWidget {
  final List<FamilyMember> members;

  const ExpenseDistribution({
    super.key,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    // 排除"全家"这一项
    final List<FamilyMember> individualMembers = members.where((member) => member.name != '全家').toList();
    
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
            "支出分布",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // 支出分布柱状图
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: _buildDistributionSegments(individualMembers),
            ),
          ),
          const SizedBox(height: 12),
          
          // 成员支出明细
          ...individualMembers.map((member) => _buildDistributionItem(member)),
        ],
      ),
    );
  }
  
  List<Widget> _buildDistributionSegments(List<FamilyMember> members) {
    double currentPosition = 0;
    List<Widget> segments = [];
    
    // 为支出分布设置不同的颜色
    final List<Color> colors = [
      const Color(0xFFEF4444),  // 红色
      const Color(0xFFF59E0B),  // 橙色
      const Color(0xFF10B981),  // 绿色
      const Color(0xFF3B82F6),  // 蓝色
    ];
    
    int colorIndex = 0;
    for (var member in members) {
      final color = colorIndex < colors.length 
          ? colors[colorIndex] 
          : member.color;
          
      segments.add(
        Positioned(
          left: currentPosition / 100 * 100,
          width: member.expenseContribution / 100 * 100,
          top: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(currentPosition == 0 ? 6 : 0),
                right: Radius.circular(currentPosition + member.expenseContribution >= 100 ? 6 : 0),
              ),
            ),
          ),
        ),
      );
      currentPosition += member.expenseContribution;
      colorIndex++;
    }
    
    return segments;
  }
  
  Widget _buildDistributionItem(FamilyMember member) {
    // 为了复现UI设计中的颜色方案
    final Map<String, Color> roleColors = {
      '爸爸': const Color(0xFFEF4444),
      '妈妈': const Color(0xFFF59E0B),
      '女儿': const Color(0xFF10B981),
      '儿子': const Color(0xFF3B82F6),
    };
    
    final color = roleColors[member.role] ?? member.color;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${member.role} (${member.name})",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Text(
            "¥${member.expenses.toStringAsFixed(0)} (${member.expenseContribution}%)",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
