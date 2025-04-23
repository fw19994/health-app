import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../services/icon_service.dart';
import '../../models/icon.dart';

class IconSelectorModal extends StatelessWidget {
  final Function(IconData icon, Color color, String name) onIconSelected;
  final IconData? selectedIcon;
  final Color? selectedColor;
  late final IconService _iconService;

  IconSelectorModal({
    super.key,
    required this.onIconSelected,
    this.selectedIcon,
    this.selectedColor,
  }) {
    _iconService = IconService();
  }

  static void show(
    BuildContext context, {
    required Function(IconData icon, Color color, String name) onIconSelected,
    IconData? selectedIcon,
    Color? selectedColor,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => IconSelectorModal(
        onIconSelected: onIconSelected,
        selectedIcon: selectedIcon,
        selectedColor: selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return FutureBuilder<List<IconModel>>(
          future: _iconService.getUserAvailableIcons(context: context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('加载图标失败: ${snapshot.error}'),
              );
            }

            final icons = snapshot.data ?? [];
            
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '选择图标',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(AppIcons.close),
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 4, // 四个分类：支出、收入、储蓄目标、通用
                      itemBuilder: (context, sectionIndex) {
                        // 根据sectionIndex获取对应的分类名称
                        final List<String> categoryNames = ['支出', '收入', '储蓄目标', '通用'];
                        final List<int> categoryIds = [1, 2, 3, 4];
                        
                        final sectionTitle = categoryNames[sectionIndex];
                        final categoryId = categoryIds[sectionIndex];
                        
                        // 筛选出该分类的图标
                        final sectionIcons = icons.where((icon) => icon.categoryId == categoryId).toList();
                        
                        // 如果该分类下没有图标，则不显示该分类
                        if (sectionIcons.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                sectionTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: sectionIcons.length,
                              itemBuilder: (context, iconIndex) {
                                final iconModel = sectionIcons[iconIndex];
                                final isSelected = selectedIcon == iconModel.icon && 
                                                selectedColor == iconModel.color;
                                
                                return GestureDetector(
                                  onTap: () {
                                    onIconSelected(
                                      iconModel.icon,
                                      iconModel.color,
                                      iconModel.name,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? iconModel.color.withOpacity(0.1)
                                              : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                          border: isSelected
                                              ? Border.all(
                                                  color: iconModel.color,
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                        child: Icon(
                                          iconModel.icon,
                                          color: iconModel.color,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        iconModel.name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected
                                              ? iconModel.color
                                              : AppTheme.textSecondary,
                                          fontWeight: isSelected
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
} 