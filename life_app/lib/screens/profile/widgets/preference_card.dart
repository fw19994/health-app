import 'package:flutter/material.dart';

class PreferenceCard extends StatelessWidget {
  final String title;
  final List<PreferenceSection> sections;
  final VoidCallback onEdit;

  const PreferenceCard({
    super.key,
    required this.title,
    required this.sections,
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
            const SizedBox(height: 16),
            // 偏好选项部分
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sections.map((section) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: section.options.map((option) {
                          return PreferenceChip(
                            label: option.label,
                            isSelected: option.isSelected,
                            onTap: () => option.onTap?.call(),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class PreferenceSection {
  final String title;
  final List<PreferenceOption> options;

  PreferenceSection({
    required this.title,
    required this.options,
  });
}

class PreferenceOption {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  PreferenceOption({
    required this.label,
    required this.isSelected,
    this.onTap,
  });
}

class PreferenceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const PreferenceChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0E7FF) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF4F46E5), width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
