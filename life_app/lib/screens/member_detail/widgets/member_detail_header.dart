import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/family_member_model.dart' as backend_model;
import '../../member_finances/models/family_member.dart';
import 'time_period_selector.dart';

class MemberDetailHeader extends StatelessWidget {
  final FamilyMember member;
  final backend_model.FamilyMember? backendMember;
  final int selectedTimeIndex;
  final Function(int) onPeriodSelected;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime)? onCustomDateRangeSelected;

  const MemberDetailHeader({
    super.key,
    required this.member,
    this.backendMember,
    required this.selectedTimeIndex,
    required this.onPeriodSelected,
    this.startDate,
    this.endDate,
    this.onCustomDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // 使用后端数据或前端数据
    final String displayName = backendMember != null
        ? (backendMember!.nickname.isNotEmpty ? backendMember!.nickname : backendMember!.name)
        : member.name;
    
    final String displayRole = backendMember != null
        ? backendMember!.getRoleName()
        : member.role;
        
    final String avatarUrl = backendMember != null ? backendMember!.avatarUrl : '';
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 10, 16, 16),
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
          // 返回按钮、标题和时间选择器
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
              const Spacer(),
              // 时间选择器
              SizedBox(
                width: 120, // 限制宽度
                child: TimePeriodSelector(
                  selectedIndex: selectedTimeIndex,
                  onPeriodSelected: onPeriodSelected,
                  startDate: startDate,
                  endDate: endDate,
                  onCustomDateRangeSelected: onCustomDateRangeSelected,
                  isHeader: true, // 在头部显示
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 成员头像和基本信息
          Row(
            children: [
              // 头像
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
                child: avatarUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        width: 64,
                        height: 64,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            member.icon,
                            size: 32,
                            color: member.color,
                          );
                        },
                      ),
                    )
                  : Icon(
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
                    '$displayRole ($displayName)',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    backendMember?.description ?? _getRoleDescription(member.role),
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
                value: '¥${(backendMember?.income ?? member.income).toStringAsFixed(0)}',
              ),
              _buildMetricItem(
                label: '月支出',
                value: '¥${(backendMember?.expense ?? member.expenses).toStringAsFixed(0)}',
              ),
              _buildMetricItem(
                label: '结余',
                value: '¥${_calculateBalance(
                  backendMember?.income ?? member.income,
                  backendMember?.expense ?? member.expenses,
                )}',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 计算结余
  String _calculateBalance(double income, double expense) {
    final balance = income - expense;
    return balance.toStringAsFixed(0);
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
