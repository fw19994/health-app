import 'package:flutter/material.dart';
import '../../../models/family_member_model.dart';

class FamilyMembersCard extends StatelessWidget {
  final List<FamilyMember> members;
  final VoidCallback onAddMember;
  final Function(FamilyMember) onMemberTap;

  const FamilyMembersCard({
    super.key,
    required this.members,
    required this.onAddMember,
    required this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    // 限制显示的成员数量
    final displayedMembers = members.take(3).toList();
    final hasMore = members.length > 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和添加按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '家庭成员',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF4F46E5),
                    size: 20,
                  ),
                  onPressed: onAddMember,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 成员列表
            if (members.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    '暂无家庭成员',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  ...displayedMembers.map((member) {
                    return Column(
                      children: [
                        _buildMemberRow(member),
                        if (displayedMembers.last != member) const Divider(height: 16),
                      ],
                    );
                  }).toList(),
                  // 显示查看更多按钮
                  if (hasMore) ...[
                    const Divider(height: 16),
                    InkWell(
                      onTap: onAddMember, // 使用相同的导航方法
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '查看全部 ${members.length} 位成员',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4F46E5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Color(0xFF4F46E5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberRow(FamilyMember member) {
    return InkWell(
      onTap: () => onMemberTap(member),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // 头像
            _buildAvatar(member),
            const SizedBox(width: 12),
            // 名称和关系
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.nickname.isNotEmpty ? member.nickname : member.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    member.role,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // 箭头图标
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFD1D5DB),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(FamilyMember member) {
    if (member.avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(member.avatarUrl),
        backgroundColor: Colors.grey[200],
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[200],
        child: Text(
          member.nickname.isNotEmpty ? member.nickname[0] : member.name[0],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4F46E5),
          ),
        ),
      );
    }
  }
}
