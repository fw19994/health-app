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
            // 标题和编辑按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF4F46E5),
                    size: 20,
                  ),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 信息行
            Column(
              children: rows.map((row) {
                return Column(
                  children: [
                    _buildInfoRow(row),
                    if (rows.last != row) const Divider(height: 16),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(InfoRow row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          row.label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
          ),
        ),
        row.valueWidget ?? Text(
          row.value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

class InfoRow {
  final String label;
  final String value;
  final Widget? valueWidget;

  InfoRow({
    required this.label,
    required this.value,
    this.valueWidget,
  });
}
