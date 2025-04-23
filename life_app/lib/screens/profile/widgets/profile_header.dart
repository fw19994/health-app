import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditAvatar;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEditAvatar,
  });
  
  // 获取头像图片，处理空值和错误情况
  ImageProvider _getProfileImage(String imageUrl) {
    if (kDebugMode) {
      print('头像URL: $imageUrl');
    }
    
    if (imageUrl.isEmpty) {
      return const AssetImage('assets/images/avatar_placeholder.png');
    }
    
    try {
      return NetworkImage(imageUrl);
    } catch (e) {
      if (kDebugMode) {
        print('创建NetworkImage失败: $e');
      }
      return const AssetImage('assets/images/avatar_placeholder.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF4F46E5),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '个人资料',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // 头像和相机按钮
                GestureDetector(
                  onTap: onEditAvatar,
                  child: Stack(
                    children: [
                      // 头像
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _getProfileImage(profile.avatarUrl),
                            onError: (error, stackTrace) {
                              debugPrint('头像加载失败: $error');
                            },
                          ),
                        ),
                      ),
                      // 相机按钮
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF4F46E5),
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 只显示用户名
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
