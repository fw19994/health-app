import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../screens/expense_tracking/models/transaction_category.dart';
import '../../../screens/expense_tracking/models/transaction_type.dart';
import '../../../services/icon_service.dart';
import '../../../models/icon.dart';
import '../../../widgets/common/icon_selector_modal.dart';
import '../../../widgets/common/date_picker_modal.dart';
import '../../../widgets/common/custom_date_range_picker.dart';
import '../models/filter_options.dart';

class TransactionFilters extends StatefulWidget {
  // 初始筛选条件
  final FilterOptions initialFilters;
  
  // 筛选条件变化时的回调
  final Function(FilterOptions)? onFilterChanged;
  
  const TransactionFilters({
    super.key, 
    this.initialFilters = const FilterOptions(),
    this.onFilterChanged,
  });

  @override
  State<TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends State<TransactionFilters> {
  // 筛选选项的状态
  late FilterOptions _filters;
  TransactionCategory? _selectedCategory;
  
  // 多选分类支持
  List<TransactionCategory> _selectedCategories = [];
  
  // 日期范围
  DateTime? _startDate;
  DateTime? _endDate;
  String _periodFilter = '近30天';  // 默认值改为"近30天"
  
  // 图标服务实例
  final IconService _iconService = IconService();
  
  // 自定义类别缓存
  List<TransactionCategory> _customCategories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    // 初始化筛选条件
    _filters = widget.initialFilters;
    
    // 加载自定义类别
    _loadCustomCategories();
    
    // 初始化日期范围
    _updateDateRangeFromFilters();
    
    // 更新时间范围文本
    _updatePeriodFilterText();
  }
  
  // 根据筛选条件更新日期范围
  void _updateDateRangeFromFilters() {
    if (_filters.period == FilterPeriod.custom && _filters.customDateRange != null) {
      _startDate = _filters.customDateRange!.start;
      _endDate = _filters.customDateRange!.end;
    } else {
      final now = DateTime.now();
      _endDate = now;
      
      switch (_filters.period) {
        case FilterPeriod.last7Days:
          _startDate = now.subtract(const Duration(days: 7));
          break;
        case FilterPeriod.last30Days:
          _startDate = now.subtract(const Duration(days: 30));
          break;
        case FilterPeriod.last3Months:
          _startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case FilterPeriod.last6Months:
          _startDate = DateTime(now.year, now.month - 6, now.day);
          break;
        case FilterPeriod.last12Months:
          _startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        case FilterPeriod.thisMonth:
          _startDate = DateTime(now.year, now.month, 1);
          break;
        case FilterPeriod.lastMonth:
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0);
          break;
        case FilterPeriod.thisYear:
          _startDate = DateTime(now.year, 1, 1);
          break;
        case FilterPeriod.lastYear:
          _startDate = DateTime(now.year - 1, 1, 1);
          _endDate = DateTime(now.year, 1, 0);
          break;
        case FilterPeriod.custom:
          _startDate = now.subtract(const Duration(days: 30));
          break;
      }
    }
  }
  
  // 更新时间范围文本
  void _updatePeriodFilterText() {
    _periodFilter = _getDateRangeText();
  }
  
  // 获取日期范围的精确文本表示
  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      final DateFormat formatter = DateFormat('yyyy/MM/dd');
      return '${formatter.format(_startDate!)} - ${formatter.format(_endDate!)}';
    }
    return '近30天'; // 兜底默认值
  }
  
  // 加载自定义类别
  Future<void> _loadCustomCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _customCategories = []; // 初始化为空列表
    });
    
    try {
      // 从IconService获取自定义图标
      final availableIcons = await _iconService.getUserAvailableIcons(context: context);
      if (availableIcons.isNotEmpty) {
        final categories = <TransactionCategory>[];
        
        // 处理支出类别图标
        for (final icon in availableIcons.where((i) => i.categoryId == 1)) {
          categories.add(TransactionCategory(
            id: icon.id.toString(),
            name: icon.name,
            icon: icon.icon, // 直接使用IconModel中的icon属性，避免不必要的转换
            color: icon.color, // 直接使用IconModel中的color属性
            backgroundColor: icon.color.withOpacity(0.1),
            type: TransactionType.expense,
          ));
        }
        
        // 处理收入类别图标
        for (final icon in availableIcons.where((i) => i.categoryId == 2)) {
          categories.add(TransactionCategory(
            id: icon.id.toString(),
            name: icon.name,
            icon: icon.icon, // 直接使用IconModel中的icon属性，避免不必要的转换
            color: icon.color, // 直接使用IconModel中的color属性
            backgroundColor: icon.color.withOpacity(0.1),
            type: TransactionType.income,
          ));
        }
        
        setState(() {
          _customCategories = categories;
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _customCategories = [];
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('加载自定义类别失败: $e');
      setState(() {
        _customCategories = [];
        _isLoadingCategories = false;
      });
    }
  }
  
  // 从十六进制字符串获取颜色
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  
  // 从图标代码获取IconData
  IconData _getIconDataFromCode(String iconCode) {
    // 移除前缀"fa-"如果存在
    final code = iconCode.startsWith('fa-') ? iconCode.substring(3) : iconCode;
    
    // 尝试匹配FontAwesome图标
    switch (code) {
      case 'utensils': return FontAwesomeIcons.utensils;
      case 'home': return FontAwesomeIcons.home;
      case 'car': return FontAwesomeIcons.car;
      case 'shopping-bag': return FontAwesomeIcons.shoppingBag;
      case 'film': return FontAwesomeIcons.film;
      case 'graduation-cap': return FontAwesomeIcons.graduationCap;
      case 'briefcase': return FontAwesomeIcons.briefcase;
      case 'credit-card': return FontAwesomeIcons.creditCard;
      case 'medkit': return FontAwesomeIcons.medkit;
      case 'bus': return FontAwesomeIcons.bus;
      case 'gift': return FontAwesomeIcons.gift;
      case 'money-bill': return FontAwesomeIcons.moneyBill;
      case 'tag': return FontAwesomeIcons.tag;
      default: return FontAwesomeIcons.coins; // 默认图标
    }
  }
  
  // 更新筛选条件并通知父组件
  void _updateFilters(FilterOptions newFilters) {
    // 确保类别ID适合后端API
    final updatedFilters = _prepareFiltersForApi(newFilters);
    
    if (_filters != updatedFilters) {
      setState(() {
        _filters = updatedFilters;
      });
      
      // 通知父组件筛选条件变化
      widget.onFilterChanged?.call(updatedFilters);
    }
  }
  
  // 准备筛选条件以便后端API使用
  FilterOptions _prepareFiltersForApi(FilterOptions filters) {
    // 如果有选中的分类，确保ID是数字格式
    if (filters.categoryIds.isNotEmpty) {
      final List<String> numericIds = filters.categoryIds.map((id) {
        // 尝试将ID转换为整数
        int? numericId;
        try {
          numericId = int.tryParse(id);
        } catch (e) {
          // 转换失败，保留原始ID
        }
        
        // 如果能转换为整数，使用数字ID；否则默认为0（表示所有类别）
        return numericId != null ? numericId.toString() : '0';
      }).toList();
      
      return filters.copyWith(
        categoryId: filters.categoryId != null ? filters.categoryId : null,
        categoryIds: numericIds,
      );
    }
    
    return filters;
  }
  
  // 选择分类
  void _selectCategory(TransactionCategory? category) {
    if (category == null) {
      // 清除所有选中的分类
      setState(() {
        _selectedCategories.clear();
        _selectedCategory = null;
      });
      
      // 更新筛选条件
      _updateFilters(_filters.copyWith(
        categoryId: null,
        categoryIds: [],
      ));
    } else {
      // 检查分类是否已选中
      final index = _selectedCategories.indexWhere((item) => item.id == category.id);
      
      setState(() {
        if (index >= 0) {
          // 如果已选中，则移除
          _selectedCategories.removeAt(index);
        } else {
          // 如果未选中，则添加
          _selectedCategories.add(category);
        }
        
        // 更新单选分类（保持向后兼容）
        _selectedCategory = _selectedCategories.isNotEmpty ? _selectedCategories.last : null;
      });
      
      // 更新筛选条件
      _updateFilters(_filters.copyWith(
        categoryId: _selectedCategory?.id,
        categoryIds: _selectedCategories.map((c) => c.id).toList(),
      ));
    }
  }
  
  // 检查分类是否已被选中
  bool _isCategorySelected(String categoryId) {
    return _selectedCategories.any((category) => category.id == categoryId);
  }
  
  // 选择时间段
  void _selectPeriod(FilterPeriod period, {DateTimeRange? customRange}) {
    // 更新筛选条件
    setState(() {
      _filters = _filters.copyWith(
        period: period,
        customDateRange: customRange,
      );
      
      // 确保日期范围已更新
      _updateDateRangeFromFilters();
      _updatePeriodFilterText();
    });
    
    // 通知父组件筛选条件变化
    widget.onFilterChanged?.call(_filters);
  }
  
  // 清除所有筛选条件
  void _clearAllFilters() {
    setState(() {
      _filters = _filters.clearAll();
      _selectedCategories.clear();
      _selectedCategory = null;
      _updateDateRangeFromFilters();
      _updatePeriodFilterText();
    });
    
    // 通知父组件筛选条件变化
    widget.onFilterChanged?.call(_filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // 筛选标题和清除按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '筛选条件',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: const Text(
                    '清除全部',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            // 筛选选项
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildFilterChip(
                  label: '分类: ${_getSelectedCategoriesText()}',
                  onTap: _showCategoryFilterOptions,
                ),
                _buildFilterChip(
                  label: '时间: $_periodFilter',
                  onTap: _showDateRangeOptions,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建筛选芯片
  Widget _buildFilterChip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 2),
            const Opacity(
              opacity: 0.7,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示分类筛选选项
  void _showCategoryFilterOptions() {
    // 暂存当前选中状态，以便取消时恢复
    final List<TransactionCategory> previousSelectedCategories = List.from(_selectedCategories);
    final TransactionCategory? previousSelectedCategory = _selectedCategory;
    
    // 使用底部弹出框显示分类选择器
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '选择分类',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            // 清空按钮
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategories.clear();
                                  _selectedCategory = null;
                                });
                              },
                              child: const Text('清空'),
                            ),
                            // 关闭按钮
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                // 恢复之前的选择状态
                                _selectedCategories.clear();
                                _selectedCategories.addAll(previousSelectedCategories);
                                _selectedCategory = previousSelectedCategory;
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 全部分类选项
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3F4F6),
                      child: Icon(Icons.all_inclusive, color: Color(0xFF6B7280)),
                    ),
                    title: const Text('全部分类'),
                    trailing: _selectedCategories.isEmpty 
                      ? const Icon(Icons.check_circle, color: Color(0xFF059669))
                      : null,
                    onTap: () {
                      setState(() {
                        _selectedCategories.clear();
                        _selectedCategory = null;
                      });
                    },
                  ),
                  
                  // 这里显示所有可用的分类
                  Expanded(
                    child: _isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 支出分类组
                                if (_customCategories.any((c) => c.type == TransactionType.expense))
                                  _buildCategorySection(
                                    setState, 
                                    '支出', 
                                    _customCategories.where((c) => c.type == TransactionType.expense).toList()
                                  ),
                                
                                const SizedBox(height: 16),
                                
                                // 收入分类组
                                if (_customCategories.any((c) => c.type == TransactionType.income))
                                  _buildCategorySection(
                                    setState, 
                                    '收入', 
                                    _customCategories.where((c) => c.type == TransactionType.income).toList()
                                  ),
                              ],
                            ),
                          ),
                        ),
                  ),
                  
                  // 底部确认按钮
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // 更新筛选条件
                          _updateFilters(_filters.copyWith(
                            categoryId: _selectedCategory?.id,
                            categoryIds: _selectedCategories.map((c) => c.id).toList(),
                          ));
                          
                          // 关闭底部弹出框
                          Navigator.pop(context);
                        },
                        child: Text('确认选择 (${_selectedCategories.length})'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  // 构建分类部分
  Widget _buildCategorySection(StateSetter setState, String title, List<TransactionCategory> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
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
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategories.any((c) => c.id == category.id);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  final existingIndex = _selectedCategories.indexWhere((c) => c.id == category.id);
                  
                  if (existingIndex >= 0) {
                    // 如果已选中，则移除
                    _selectedCategories.removeAt(existingIndex);
                  } else {
                    // 如果未选中，则添加
                    _selectedCategories.add(category);
                  }
                  
                  // 更新单选分类（保持向后兼容）
                  _selectedCategory = _selectedCategories.isNotEmpty ? _selectedCategories.last : null;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? category.color.withOpacity(0.1)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: category.color,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 24,
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? category.color
                          : const Color(0xFF6B7280),
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
      ],
    );
  }
  
  // 显示日期筛选选项 - 直接使用优化的自定义日期选择器
  void _showDateRangeOptions() async {
    // 确保当前选中状态是最新的
    _updateDateRangeFromFilters();
    
    // 使用新的自定义日期选择器组件
    final dateRange = await CustomDateRangePicker.show(
      context: context,
      initialStartDate: _startDate,
      initialEndDate: _endDate,
      title: '选择日期范围',
    );
    
    // 如果用户选择了日期范围
    if (dateRange != null) {
      _selectPeriod(
        FilterPeriod.custom, 
        customRange: dateRange
      );
    }
  }

  // 获取已选分类的显示文本
  String _getSelectedCategoriesText() {
    if (_selectedCategories.isEmpty) {
      return '全部';
    } else if (_selectedCategories.length == 1) {
      return _selectedCategories.first.name;
    } else {
      return '已选${_selectedCategories.length}项';
    }
  }
} 