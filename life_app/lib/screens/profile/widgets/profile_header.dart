import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditInfo;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEditAvatar,
    required this.onEditInfo,
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
        top: 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.4, 1.0],
          colors: [
            Color(0xFF5046E5), 
            Color(0xFF4F46E5), 
            Color(0xFF6366F1)
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 主要内容
          SafeArea(
        bottom: false,
        child: Column(
              mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
              '个人资料',
              style: TextStyle(
                              fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                              letterSpacing: 0.3,
              ),
            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onEditInfo,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '编辑',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像和相机按钮
                GestureDetector(
                  onTap: onEditAvatar,
                  child: Stack(
                    children: [
                          // 头像外部光晕
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: Center(
                              child: // 头像
                      Container(
                                width: 62,
                                height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _getProfileImage(profile.avatarUrl),
                            onError: (error, stackTrace) {
                              debugPrint('头像加载失败: $error');
                            },
                                  ),
                                ),
                          ),
                        ),
                      ),
                      // 相机按钮
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                              width: 20,
                              height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                              child: const Center(
                                child: Icon(
                            Icons.camera_alt,
                            color: Color(0xFF4F46E5),
                                  size: 12,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                    const SizedBox(width: 14),
                    // 用户基本信息
                    Expanded(
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${profile.age}岁',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    color: Colors.white70,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  profile.gender,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.phone_outlined,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                profile.phone,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          profile.bio.isNotEmpty
                              ? Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    profile.bio,
                                    style: const TextStyle(
                                      fontSize: 12,
                        color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ],
      ),
    );
  }
}

