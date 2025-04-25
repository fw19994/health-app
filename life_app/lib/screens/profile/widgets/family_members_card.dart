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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和添加/查看全部按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 标题部分
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                const Text(
                  '家庭成员',
                  style: TextStyle(
                        fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                  ],
                ),
                
                // 添加和查看全部按钮
                Row(
                  children: [
                    // 查看全部按钮
                    if (hasMore)
                      InkWell(
                        onTap: onAddMember,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '查看全部',
                    style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4F46E5),
                    ),
                  ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: Color(0xFF4F46E5),
                              ),
                      ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(width: 8),
                    
                    // 添加按钮
                    InkWell(
                      onTap: onAddMember,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '添加',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ],
            ),
            const SizedBox(height: 18),
            // 成员列表
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: members.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '暂无家庭成员',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '点击上方"添加"按钮添加成员',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: displayedMembers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;
                      final isLast = index == displayedMembers.length - 1;
                      
                      return Column(
                        children: [
                          _buildMemberRow(member),
                          if (!isLast)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberRow(FamilyMember member) {
    // 根据角色选择图标
    IconData roleIcon = _getRoleIcon(member.role);
    
    return InkWell(
      onTap: () => onMemberTap(member),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // 头像
            Stack(
              children: [
            _buildAvatar(member),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      roleIcon,
                      size: 10,
                      color: _getRoleColor(member.role),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // 名称和关系
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.nickname.isNotEmpty ? member.nickname : member.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(member.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                    member.role,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getRoleColor(member.role),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 箭头图标
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF9CA3AF),
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 根据角色获取图标
  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case '父亲':
      case '爸爸':
        return Icons.face;
      case '母亲':
      case '妈妈':
        return Icons.face_3;
      case '儿子':
      case '孩子':
        return Icons.child_care;
      case '女儿':
        return Icons.girl;
      case '伴侣':
      case '丈夫':
      case '妻子':
        return Icons.favorite;
      case '祖父':
      case '爷爷':
        return Icons.elderly;
      case '祖母':
      case '奶奶':
        return Icons.elderly_woman;
      default:
        return Icons.person;
    }
  }
  
  // 根据角色获取颜色
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case '父亲':
      case '爸爸':
      case '丈夫':
        return const Color(0xFF4F46E5); // 蓝紫色
      case '母亲':
      case '妈妈':
      case '妻子':
        return const Color(0xFFEC4899); // 粉色
      case '儿子':
      case '女儿':
      case '孩子':
        return const Color(0xFF10B981); // 绿色
      case '祖父':
      case '祖母':
      case '爷爷':
      case '奶奶':
        return const Color(0xFFF59E0B); // 橙色
      default:
        return const Color(0xFF6B7280); // 灰色
    }
  }

  Widget _buildAvatar(FamilyMember member) {
    if (member.avatarUrl.isNotEmpty) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(member.avatarUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getRoleColor(member.role).withOpacity(0.15),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
        child: Text(
          member.nickname.isNotEmpty ? member.nickname[0] : member.name[0],
            style: TextStyle(
            fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getRoleColor(member.role),
            ),
          ),
        ),
      );
    }
  }
}
