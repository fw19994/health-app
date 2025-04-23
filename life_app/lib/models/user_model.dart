class User {
  final int id;
  final String phone;
  final String nickname;
  final String? avatar;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.phone,
    required this.nickname,
    this.avatar,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'],
      status: json['status'] ?? 1,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
