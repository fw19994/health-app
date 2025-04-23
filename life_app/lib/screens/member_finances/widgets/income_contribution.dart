import 'package:flutter/material.dart';
import '../models/family_member.dart';

class IncomeContribution extends StatelessWidget {
  final List<FamilyMember> members;

  const IncomeContribution({
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
            "收入贡献",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // 贡献柱状图
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: _buildContributionSegments(individualMembers),
            ),
          ),
          const SizedBox(height: 12),
          
          // 成员贡献明细
          ...individualMembers.map((member) => _buildContributionItem(member)),
        ],
      ),
    );
  }
  
  List<Widget> _buildContributionSegments(List<FamilyMember> members) {
    double currentPosition = 0;
    List<Widget> segments = [];
    
    for (var member in members) {
      segments.add(
        Positioned(
          left: currentPosition / 100 * 100,
          width: member.incomeContribution / 100 * 100,
          top: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: member.color,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(currentPosition == 0 ? 6 : 0),
                right: Radius.circular(currentPosition + member.incomeContribution >= 100 ? 6 : 0),
              ),
            ),
          ),
        ),
      );
      currentPosition += member.incomeContribution;
    }
    
    return segments;
  }
  
  Widget _buildContributionItem(FamilyMember member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: member.color,
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
            "¥${member.income.toStringAsFixed(0)} (${member.incomeContribution}%)",
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
