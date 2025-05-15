import 'package:flutter/material.dart';
import '../models/family_member_model.dart';

class FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // 在构建卡片前打印成员信息供调试
    final displayName = member.nickname.isNotEmpty ? member.nickname : member.name;
    print('渲染家庭成员卡片: ID=${member.id}, 显示名称=$displayName, 角色=${member.role}');
    
    // 角色颜色映射
    final Map<MemberRole, Color> roleColors = {
      MemberRole.head: const Color(0xFF4F46E5),  // 紫色（家庭主账户）
      MemberRole.spouse: const Color(0xFFEC4899), // 粉色（配偶）
      MemberRole.child: const Color(0xFF0EA5E9),  // 蓝色（子女）
      MemberRole.other: const Color(0xFFA855F7),  // 紫色（其他）
    };
    
    // 安全获取角色枚举和颜色
    MemberRole roleEnum;
    try {
      roleEnum = member.getRoleEnum();
    } catch (e) {
      print('角色解析错误: $e');
      roleEnum = MemberRole.other; // 异常情况下使用默认角色
    }
    
    final Color roleColor = roleColors[roleEnum] ?? const Color(0xFFA855F7);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // 成员信息区域
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: member.avatarUrl.isNotEmpty
                              ? NetworkImage(member.avatarUrl)
                              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // 在线状态标记
                    if (member.isCurrentUser)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                // 成员信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            displayName + (member.isCurrentUser ? ' (我)' : ''),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              member.role,
                              style: TextStyle(
                                fontSize: 11,
                                color: roleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (member.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          member.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 右上角操作按钮
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!member.isCurrentUser)
                      InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            Icons.person_remove_outlined,
                            color: const Color(0xFFEF4444),
                            size: 16,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          member.isCurrentUser
                              ? Icons.person_outline
                              : Icons.edit_outlined,
                          color: const Color(0xFF4F46E5),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 分隔线
          Container(
            height: 1,
            color: const Color(0xFFF3F4F6),
          ),
          // 详细信息区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (member.phone.isNotEmpty) ...[
                  _buildInfoRow(
                    Icons.phone_outlined,
                    '电话',
                    member.phone,
                  ),
                  const SizedBox(height: 4),
                ],
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  '加入时间',
                  member.joinTime,
                ),
                const SizedBox(height: 4),
                // _buildInfoRow(
                //   Icons.security_outlined,
                //   '权限',
                //   member.permission,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
