import 'package:flutter/material.dart';

class FeaturePreview extends StatelessWidget {
  const FeaturePreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFeatureItem(
            icon: Icons.trending_up,
            label: '财务追踪',
          ),
          _buildFeatureItem(
            icon: Icons.favorite,
            label: '健康管理',
          ),
          _buildFeatureItem(
            icon: Icons.people,
            label: '家庭共享',
          ),
          _buildFeatureItem(
            icon: Icons.emoji_events,
            label: '成就解锁',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
