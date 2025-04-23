import 'package:flutter/material.dart';

/// 通用表单字段组件，与UI设计保持一致
class FormFieldWidget extends StatelessWidget {
  final String label;
  final Widget child;
  final EdgeInsets padding;

  const FormFieldWidget({
    super.key,
    required this.label,
    required this.child,
    this.padding = const EdgeInsets.only(bottom: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// 带图标的文本输入字段
class IconTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;

  const IconTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF4F46E5)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
    );
  }
}

/// 性别选择选项组件
class GenderOption extends StatelessWidget {
  final String gender;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  const GenderOption({
    super.key,
    required this.gender,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(gender),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.1) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              gender == '男' ? Icons.male : Icons.female,
              color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 带图标的按钮
class IconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final bool isLoading;

  const IconButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(text),
              ],
            ),
    );
  }
}
