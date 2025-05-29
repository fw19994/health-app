import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/family_member.dart';
import '../../member_detail/member_detail_screen.dart';

class MemberCard extends StatelessWidget {
  final FamilyMember member;

  const MemberCard({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 成员信息头部
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: member.avatarBgColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    member.icon,
                    color: member.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${member.role} (${member.name})",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getRoleDescription(member.role),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // 查看详情链接
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemberDetailScreen(
                          member: member,
                          // 这里如果有后端数据模型可以传递
                          // backendMember: backendMember,
                        ),
                      ),
                    );
                  },
                  icon: const Text(
                    "查看详情",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  label: const Icon(
                    FontAwesomeIcons.chevronRight,
                    size: 12,
                    color: Color(0xFF4F46E5),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          
          // 财务指标网格
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // 第一行: 月收入和月支出
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        label: "月收入",
                        value: "¥${member.income.toStringAsFixed(0)}",
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        label: "月支出",
                        value: "¥${member.expenses.toStringAsFixed(0)}",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 第二行: 储蓄率和消费主力
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricItem(
                        label: "结余",
                        value: "¥${(member.income - member.expenses).toStringAsFixed(0)}",
                        valueColor: _getBalanceColor(member.income - member.expenses),
                      ),
                    ),
                    Expanded(
                      child: _buildMetricItem(
                        label: "消费主力",
                        value: member.mainConsumption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 财务健康度
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "财务健康度",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      _getFinancialHealthLabel(member.income, member.expenses),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _getFinancialHealthColor(member.income, member.expenses),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // 财务健康进度条
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _getFinancialHealthPercentage(member.income, member.expenses),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getFinancialHealthColor(member.income, member.expenses),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建指标项组件
  Widget _buildMetricItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1F2937),
          ),
        ),
      ],
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
  
  // 获取结余颜色
  Color _getBalanceColor(double balance) {
    if (balance >= 5000) {
      return const Color(0xFF10B981);  // 绿色 (优秀)
    } else if (balance >= 2000) {
      return const Color(0xFF059669);  // 浅绿色 (良好)
    } else if (balance >= 0) {
      return const Color(0xFFF59E0B);  // 黄色 (一般)
    } else {
      return const Color(0xFFEF4444);  // 红色 (不足)
    }
  }
  
  // 获取财务健康标签
  String _getFinancialHealthLabel(double income, double expenses) {
    if (income <= 0) return '无收入';
    
    double savingsRatio = (income - expenses) / income;
    
    if (savingsRatio >= 0.5) {
      return '优秀';
    } else if (savingsRatio >= 0.3) {
      return '良好';
    } else if (savingsRatio >= 0.1) {
      return '一般';
    } else if (savingsRatio >= 0) {
      return '不足';
    } else {
      return '危险';
    }
  }
  
  // 获取财务健康颜色
  Color _getFinancialHealthColor(double income, double expenses) {
    if (income <= 0) return const Color(0xFF6B7280); // 灰色
    
    double savingsRatio = (income - expenses) / income;
    
    if (savingsRatio >= 0.5) {
      return const Color(0xFF10B981);  // 绿色 (优秀)
    } else if (savingsRatio >= 0.3) {
      return const Color(0xFF059669);  // 浅绿色 (良好)
    } else if (savingsRatio >= 0.1) {
      return const Color(0xFFF59E0B);  // 黄色 (一般)
    } else if (savingsRatio >= 0) {
      return const Color(0xFFF97316);  // 橙色 (不足)
    } else {
      return const Color(0xFFEF4444);  // 红色 (危险)
    }
  }
  
  // 获取财务健康百分比显示
  double _getFinancialHealthPercentage(double income, double expenses) {
    if (income <= 0) return 0.3; // 基础健康度
    
    double savingsRatio = (income - expenses) / income;
    
    if (savingsRatio < 0) {
      // 负结余，财务健康度低
      return 0.25;
    } else if (savingsRatio > 1) {
      // 结余超过收入，财务健康度满
      return 1.0;
    } else {
      // 根据结余比例映射到0.3-1.0之间的值
      // 0%结余比例 -> 0.3健康度
      // 100%结余比例 -> 1.0健康度
      return 0.3 + savingsRatio * 0.7;
    }
  }
}
