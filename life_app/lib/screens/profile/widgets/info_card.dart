import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final List<InfoRow> rows;
  final VoidCallback onEdit;

  const InfoCard({
    super.key,
    required this.title,
    required this.rows,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
            // 标题和编辑按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF4F46E5),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                        fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                  ],
                ),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                    Icons.edit,
                    color: Color(0xFF4F46E5),
                          size: 16,
                  ),
                        SizedBox(width: 4),
                        Text(
                          '编辑',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // 信息行
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
              children: rows.map((row) {
                  final isLast = rows.last == row;
                return Column(
                  children: [
                    _buildInfoRow(row),
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

  Widget _buildInfoRow(InfoRow row) {
    final IconData rowIcon = row.icon ?? _getDefaultIcon(row.label);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
      children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              rowIcon,
              color: const Color(0xFF6B7280),
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
        Text(
          row.label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
        row.valueWidget ?? Text(
          row.value,
          style: const TextStyle(
            fontSize: 15,
              fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
      ),
    );
  }
  
  // 根据标签获取默认图标
  IconData _getDefaultIcon(String label) {
    switch (label.toLowerCase()) {
      case '姓名':
        return Icons.person_outline;
      case '年龄':
        return Icons.cake_outlined;
      case '性别':
        return Icons.wc_outlined;
      case '电话':
        return Icons.phone_outlined;
      case '邮箱':
        return Icons.email_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

class InfoRow {
  final String label;
  final String value;
  final Widget? valueWidget;
  final IconData? icon;

  InfoRow({
    required this.label,
    required this.value,
    this.valueWidget,
    this.icon,
  });
}
