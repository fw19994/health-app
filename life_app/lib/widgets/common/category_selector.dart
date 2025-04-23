import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/icon.dart';
import '../../services/icon_service.dart';
import '../../widgets/common/icon_selector_modal.dart';

// 类别项数据模型
class CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  final int id; // 添加ID属性，用于识别类别

  CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    this.id = 0,
  });

  // 从IconModel创建CategoryItem
  factory CategoryItem.fromIconModel(IconModel model) {
    return CategoryItem(
      icon: model.icon,
      label: model.name,
      color: model.color,
      id: model.id,
    );
  }
}

class CategorySelector extends StatefulWidget {
  // 必要的参数
  final List<CategoryItem> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final Function(String, IconData, Color) onAddCategory; // 修改为接收新类别信息的回调
  
  // 可选参数
  final String title;
  final bool isExpenseType;
  final bool showAddButton;
  final int itemsPerPage;
  final Function(int)? onLongPress;
  final BuildContext? parentContext; // 添加父级context用于API调用

  const CategorySelector({
    Key? key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.onAddCategory,
    this.title = '类别',
    this.isExpenseType = true,
    this.showAddButton = true,
    this.itemsPerPage = 8,
    this.onLongPress,
    this.parentContext,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late PageController _pageController;
  late List<CategoryItem> _displayCategories;
  
  // 添加新类别所需的控制器和状态变量
  final TextEditingController _newCategoryNameController = TextEditingController();
  Color _newCategoryColor = Colors.blue;
  IconData _newCategoryIcon = FontAwesomeIcons.tag;
  
  // IconService实例
  late IconService _iconService;
  
  @override
  void initState() {
    super.initState();
    _updateDisplayCategories();
    _iconService = IconService();
    
    // 计算当前选中项应该在哪一页
    final int currentPage = (widget.selectedIndex / widget.itemsPerPage).floor();
    _pageController = PageController(initialPage: currentPage);
  }
  
  @override
  void didUpdateWidget(CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 当类别列表或选中索引变化时更新状态
    if (oldWidget.categories != widget.categories || 
        oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.showAddButton != widget.showAddButton) {
      _updateDisplayCategories();
      
      // 计算并滚动到正确的页面
      final int currentPage = (widget.selectedIndex / widget.itemsPerPage).floor();
      if (_pageController.hasClients && _pageController.page?.round() != currentPage) {
        _pageController.jumpToPage(currentPage);
      }
    }
  }
  
  void _updateDisplayCategories() {
    _displayCategories = List.from(widget.categories);
    
    // 如果需要显示添加按钮，则添加到列表
    if (widget.showAddButton) {
      _displayCategories.add(CategoryItem(
        icon: FontAwesomeIcons.plus, 
        label: '添加', 
        color: Colors.grey
      ));
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _newCategoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 计算分页
    final int totalPages = (_displayCategories.length / widget.itemsPerPage).ceil();
    
    // 主题颜色
    final Color themeColor = widget.isExpenseType ? Colors.red : Colors.green;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '类别',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          
          // 分类标题和页面指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.isExpenseType ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
              ),
              
              // 如果有多页，显示页面指示器
              if (totalPages > 1)
                Row(
                  children: [
                    Text(
                      '滑动查看更多',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.swipe,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // 图标展示区域
          SizedBox(
            height: 210, // 固定高度
            child: _displayCategories.isEmpty
                ? Center(
                    child: Text(
                      '暂无类别',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: totalPages,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (int page) {
                            HapticFeedback.lightImpact();
                          },
                          itemBuilder: (context, pageIndex) {
                            final startIndex = pageIndex * widget.itemsPerPage;
                            final endIndex = startIndex + widget.itemsPerPage;
                            final pageItems = _displayCategories.sublist(
                              startIndex, 
                              endIndex > _displayCategories.length ? _displayCategories.length : endIndex
                            );
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GridView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero, // 移除所有垂直内边距
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.75, // 增加宽高比以使图标更紧凑
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 0, // 完全消除行间距
                                ),
                                itemCount: pageItems.length,
                                itemBuilder: (context, index) {
                                  final category = pageItems[index];
                                  final absoluteIndex = startIndex + index;
                                  final isSelected = absoluteIndex == widget.selectedIndex;
                                  
                                  bool isAddButton = widget.showAddButton && absoluteIndex == _displayCategories.length - 1;
                              
                                  return GestureDetector(
                                    onTap: () {
                                      if (isAddButton) {
                                        _showAddCategoryDialog(context);
                                      } else {
                                        widget.onCategorySelected(absoluteIndex);
                                      }
                                    },
                                    onLongPress: () {
                                      if (!isAddButton && widget.onLongPress != null) {
                                        widget.onLongPress!(absoluteIndex);
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // 图标容器
                                          Container(
                                            width: 46,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? category.color.withOpacity(0.2) 
                                                  : isAddButton 
                                                      ? Colors.grey.shade100 
                                                      : category.color.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(23),
                                              border: isSelected
                                                  ? Border.all(color: category.color, width: 2)
                                                  : Border.all(color: Colors.grey.shade200, width: 1),
                                              boxShadow: isSelected ? [
                                                BoxShadow(
                                                  color: category.color.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                )
                                              ] : null,
                                            ),
                                            child: Center(
                                              child: FaIcon(
                                                category.icon,
                                                color: isSelected ? category.color : isAddButton ? Colors.grey : category.color,
                                                size: isSelected ? 22 : 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2), // 减少图标和文本间的距离
                                          // 类别名称
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                            child: Text(
                                              category.label,
                                              style: TextStyle(
                                                fontSize: 11,
                                                height: 1.0, // 减少文本行高
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                color: isSelected ? category.color : Colors.grey.shade700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // 页面指示器
                      if (totalPages > 1)
                        Container(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(totalPages, (index) {
                              return AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, child) {
                                  double page = _pageController.hasClients 
                                      ? _pageController.page ?? 0 
                                      : 0;
                                      
                                  bool isCurrentPage = index == page.round();
                                  double distanceFromCurrentPage = (index - page).abs();
                                  double indicatorSize = isCurrentPage ? 8.0 : 6.0;
                                  
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    height: indicatorSize,
                                    width: indicatorSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrentPage
                                          ? (widget.isExpenseType 
                                              ? Colors.red.shade400 
                                              : Colors.green.shade400)
                                          : Colors.grey.shade300.withOpacity(1.0 - (distanceFromCurrentPage * 0.3).clamp(0.0, 0.7)),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  // 显示添加类别对话框
  void _showAddCategoryDialog(BuildContext context) {
    // 重置控制器和状态
    _newCategoryNameController.clear();
    _newCategoryColor = widget.isExpenseType ? Colors.red : Colors.green;
    _newCategoryIcon = FontAwesomeIcons.tag;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '添加新类别',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newCategoryNameController,
                    decoration: const InputDecoration(
                      labelText: '类别名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      IconSelectorModal.show(
                        context,
                        selectedIcon: _newCategoryIcon,
                        selectedColor: _newCategoryColor,
                        onIconSelected: (icon, color, name) {
                          setState(() {
                            _newCategoryIcon = icon;
                            _newCategoryColor = color;
                            if (_newCategoryNameController.text.isEmpty) {
                              _newCategoryNameController.text = name;
                            }
                          });
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(_newCategoryIcon, color: _newCategoryColor),
                          const SizedBox(width: 8),
                          const Text('选择图标'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (_newCategoryNameController.text.isNotEmpty) {
                            try {
                              // 显示加载提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('正在创建类别...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              
                              // 回调父组件的添加方法
                              widget.onAddCategory(
                                _newCategoryNameController.text,
                                _newCategoryIcon,
                                _newCategoryColor
                              );
                              
                              // 关闭对话框
                              Navigator.pop(context);
                              
                              // 显示成功提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('类别创建成功'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              // 显示错误提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('创建类别失败: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            // 显示输入验证错误
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('请输入类别名称'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}