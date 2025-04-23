class FamilyMember {
  final int id;
  final int ownerId;
  final int? userId;
  final String name;
  final String nickname;
  final String description;
  final String phone;
  final String role;
  final String gender;
  final String avatarUrl;
  final String joinTime;
  final String permission;
  final bool isCurrentUser;

  FamilyMember({
    required this.id,
    required this.ownerId,
    this.userId,
    required this.name,
    required this.nickname,
    required this.description,
    required this.phone,
    required this.role,
    this.gender = '',
    required this.avatarUrl,
    required this.joinTime,
    required this.permission,
    required this.isCurrentUser,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    // 调试日志
    print('解析家庭成员JSON: $json');
    print('字段列表: ${json.keys.toList()}');
    
    // 尝试不同的字段名称映射
    final id = json['id'] ?? json['ID'] ?? json['member_id'] ?? 0;
    var ownerId = json['owner_id'] ?? json['ownerId'] ?? json['family_id'] ?? 0;
    final userId = json['user_id'] ?? json['userId'] ?? json['user'] ?? null;
    final name = json['name'] ?? json['userName'] ?? json['user_name'] ?? '';
    final phone = json['phone'] ?? json['phoneNumber'] ?? json['phone_number'] ?? '';
    final gender = json['gender'] ?? '';
    final avatarUrl = json['avatar'] ?? json['avatarUrl'] ?? json['avatar_url'] ?? json['icon'] ?? '';
    final joinDate = json['joinTime'] ?? json['joinDate'] ?? json['created_at'] ?? '';
    final currentUser = json['isCurrentUser'] ?? json['is_current_user'] ?? json['is_me'] ?? false;
    
    print('处理后的字段 - ID: $id, 名称: $name, 角色: ${json['role']}, 性别: $gender, 家主ID: $ownerId, 用户ID: $userId');
    
    return FamilyMember(
      id: id is int ? id : int.tryParse(id.toString()) ?? 0,
      ownerId: ownerId is int ? ownerId : int.tryParse(ownerId.toString()) ?? 0,
      userId: userId is int ? userId : userId != null ? int.tryParse(userId.toString()) : null,
      name: name,
      nickname: json['nickname'] ?? '',
      description: json['description'] ?? '',
      phone: phone,
      role: json['role'] ?? '其他',
      gender: gender,
      avatarUrl: avatarUrl,
      joinTime: joinDate,
      permission: json['permission'] ?? '',
      isCurrentUser: currentUser is bool ? currentUser : currentUser.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'user_id': userId,
      'name': name,
      'nickname': nickname,
      'description': description,
      'phone': phone,
      'role': role,
      'gender': gender,
      'avatar_url': avatarUrl,
      'permission': permission,
    };
  }

  // 将角色字符串转换为MemberRole枚举
  MemberRole getRoleEnum() {
    // 将角色字符串转换为小写进行匹配，增强容错性
    final String normalizedRole = role.toLowerCase().trim();
    
    // 根据关键词匹配角色
    if (normalizedRole.contains('主') || 
        normalizedRole.contains('head') || 
        normalizedRole.contains('owner') || 
        normalizedRole.contains('admin')) {
      return MemberRole.head;
    } else if (normalizedRole.contains('配偶') || 
              normalizedRole.contains('spouse') || 
              normalizedRole.contains('wife') || 
              normalizedRole.contains('husband')) {
      return MemberRole.spouse;
    } else if (normalizedRole.contains('子') || 
              normalizedRole.contains('女') || 
              normalizedRole.contains('child') || 
              normalizedRole.contains('son') || 
              normalizedRole.contains('daughter')) {
      return MemberRole.child;
    } else {
      return MemberRole.other;
    }
  }
  
  // 获取角色对应的中文名称
  String getRoleName() {
    switch (getRoleEnum()) {
      case MemberRole.head:
        return '家庭主账户';
      case MemberRole.spouse:
        return '配偶';
      case MemberRole.child:
        return '子女';
      case MemberRole.other:
        return role.isNotEmpty ? role : '其他';
    }
  }
}

// 成员角色枚举，与现有的前端枚举保持一致
enum MemberRole {
  head,
  spouse,
  child,
  other,
}
