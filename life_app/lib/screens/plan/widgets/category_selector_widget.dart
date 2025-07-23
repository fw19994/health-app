import 'package:flutter/material.dart';
import '../../../constants/plan_constants.dart';

class CategorySelectorWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategorySelectorWidget({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: PlanConstants.categories.entries.map((entry) {
        final category = entry.key;
        final data = entry.value;
        
        return _buildCategoryItem(
          context: context,
          category: category,
          label: data['name'],
          iconBackground: Color(data['iconBackground']),
          iconColor: Color(data['iconColor']),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String category,
    required String label,
    required Color iconBackground,
    required Color iconColor,
  }) {
    final isSelected = selectedCategory == category;
    
    // 根据类别选择图标
    IconData iconData;
    switch (category) {
      case 'work':
        iconData = Icons.business_center;
        break;
      case 'personal':
        iconData = Icons.person;
        break;
      case 'health':
        iconData = Icons.favorite;
        break;
      case 'family':
        iconData = Icons.home;
        break;
      default:
        iconData = Icons.category;
    }

    return InkWell(
      onTap: () => onCategoryChanged(category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                iconData,
                size: 12,
                color: isSelected ? Colors.white : iconColor,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 