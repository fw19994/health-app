import 'package:intl/intl.dart';

class Family {
  final int id;
  final String name;
  final DateTime createdAt;
  final int memberCount;
  final bool isActive;
  final String ownerName;
  final String avatarUrl;
  final String description;

  Family({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.memberCount,
    required this.isActive,
    required this.ownerName,
    this.avatarUrl = '',
    this.description = '',
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    // 解析创建时间
    DateTime createdDate;
    try {
      createdDate = DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toString());
    } catch (e) {
      createdDate = DateTime.now();
    }

    return Family(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '未命名家庭',
      createdAt: createdDate,
      memberCount: json['member_count'] ?? json['memberCount'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      ownerName: json['owner_name'] ?? json['ownerName'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'] ?? '',
      description: json['description'] ?? '',
    );
  }

  String get formattedCreatedDate {
    return DateFormat('yyyy年MM月dd日').format(createdAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'member_count': memberCount,
      'is_active': isActive,
      'owner_name': ownerName,
      'avatar_url': avatarUrl,
      'description': description,
    };
  }
} 