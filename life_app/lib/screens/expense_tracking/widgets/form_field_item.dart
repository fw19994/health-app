import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FormFieldItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const FormFieldItem({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FaIcon(
                    icon,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 日期选择字段
class DateFormField extends StatelessWidget {
  final DateTime date;
  final Function(DateTime) onDateChanged;

  const DateFormField({
    super.key,
    required this.date,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormFieldItem(
      icon: FontAwesomeIcons.calendarAlt,
      label: '日期',
      child: InkWell(
        onTap: () => _selectDate(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF97316), // 标题背景色
              onPrimary: Colors.white, // 标题文字颜色
              onSurface: Color(0xFF1F2937), // 日历文字颜色
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != date) {
      onDateChanged(picked);
    }
  }
}

// 账户选择字段
class AccountFormField extends StatelessWidget {
  final String value;
  final List<String> options;
  final Function(String) onChanged;

  const AccountFormField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormFieldItem(
      icon: FontAwesomeIcons.creditCard,
      label: '账户',
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF)),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// 文本输入字段
class TextFormFieldItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final Function(String) onChanged;

  const TextFormFieldItem({
    super.key,
    required this.icon,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormFieldItem(
      icon: icon,
      label: label,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1F2937),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
