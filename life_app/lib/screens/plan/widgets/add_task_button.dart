import 'package:flutter/material.dart';

class AddTaskButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? text;
  final Map<String, Color>? phaseColors; // 添加颜色方案参数
  
  const AddTaskButton({
    Key? key,
    required this.onTap,
    this.text,
    this.phaseColors, // 新增参数
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用传入的颜色方案或默认颜色
    final colors = phaseColors ?? {
      'primary': const Color(0xFF4F46E5),
      'darker': const Color(0xFF4338CA),
      'lighter': const Color(0xFFF5F3FF),
    };
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
            bottom: BorderSide(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 12),
            Icon(
              Icons.add,
              size: 16,
              color: colors['primary'], // 使用主题色
            ),
            const SizedBox(width: 4),
            Text(
              text ?? '添加计划',
              style: TextStyle(
                fontSize: 14,
                color: colors['primary'], // 使用主题色
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}