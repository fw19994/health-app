import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 标题
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
              ),
            ],
          ),
          child: const Text(
            '一键登录',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 社交媒体图标
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: FontAwesomeIcons.weixin,
              color: const Color(0xFF07C160),
              onTap: () {
                // 微信登录
              },
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.qq,
              color: const Color(0xFF12B7F5),
              onTap: () {
                // QQ登录
              },
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.apple,
              color: Colors.black,
              onTap: () {
                // Apple登录
              },
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.twitter,
              color: const Color(0xFF1DA1F2),
              onTap: () {
                // Twitter登录
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
