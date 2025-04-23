import 'package:flutter/material.dart';
import '../../models/savings_goal.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_icons.dart';
import '../common/number_input.dart';
import '../common/icon_selector_modal.dart';

class SavingsGoalModal extends StatefulWidget {
  // ... (existing code)
}

class _SavingsGoalModalState extends State<SavingsGoalModal> {
  // ... (existing code)

  // 显示图标选择模态窗口
  void _showIconSelector(BuildContext context) {
    IconSelectorModal.show(
      context,
      selectedIcon: _selectedIcon,
      selectedColor: _selectedColor,
      onIconSelected: (icon, color, name) {
        setState(() {
          _selectedIcon = icon;
          _selectedColor = color;
          if (_selectedCategoryName.isEmpty) {
            _selectedCategoryName = name;
          }
        });
      },
    );
  }

  // ... (rest of the existing code)
} 