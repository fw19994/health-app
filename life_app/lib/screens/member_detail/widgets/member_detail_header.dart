import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../member_finances/models/family_member.dart';

class MemberDetailHeader extends StatelessWidget {
  final FamilyMember member;

  const MemberDetailHeader({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, 4),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回按钮和标题
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '成员财务详情',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 成员头像和基本信息
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )],
                ),
                child: Icon(
                  member.icon,
                  size: 32,
                  color: member.color,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${member.role} (${member.name})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _getRoleDescription(member.role),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 财务概况指标
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                label: '月收入',
                value: '¥${member.income.toStringAsFixed(0)}',
              ),
              _buildMetricItem(
                label: '月支出',
                value: '¥${member.expenses.toStringAsFixed(0)}',
              ),
              _buildMetricItem(
                label: '储蓄率',
                value: '${member.savingsRate.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 获取角色描述
  String _getRoleDescription(String role) {
    switch (role) {
      case '爸爸':
        return '家庭主要收入来源';
      case '妈妈':
        return '家庭第二收入来源';
      case '女儿':
        return '大学生 / 兼职收入';
      case '儿子':
        return '中学生 / 零花钱';
      default:
        return '';
    }
  }

  // 构建指标项
  Widget _buildMetricItem({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
