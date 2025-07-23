import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/plan/plan_model.dart';
import '../../services/plan_service.dart';
import '../../widgets/common/date_picker_modal.dart';
import 'custom_time_picker.dart';
import '../../widgets/common/category_selector.dart';
import 'package:uuid/uuid.dart';

class AddPlanModal {
  /// 显示添加/编辑计划弹窗
  /// 
  /// [selectedDate] 选中的日期
  /// [planToEdit] 要编辑的计划，如果为null则表示添加新计划
  /// 返回一个Future<bool>，表示操作是否成功
  static Future<bool> show(
    BuildContext context, {
    DateTime? selectedDate,
    Plan? planToEdit,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddPlanModalContent(
            selectedDate: selectedDate ?? DateTime.now(),
            planToEdit: planToEdit,
          ),
        );
      },
    );
    
    // 如果result为null，表示用户取消了操作
    return result ?? false;
  }
}

class _AddPlanModalContent extends StatefulWidget {
  final DateTime selectedDate;
  final Plan? planToEdit;

  const _AddPlanModalContent({
    Key? key, 
    required this.selectedDate,
    this.planToEdit,
  }) : super(key: key);

  @override
  State<_AddPlanModalContent> createState() => _AddPlanModalContentState();
}

class _AddPlanModalContentState extends State<_AddPlanModalContent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedCategory = 'work';
  int _reminderOption = 0; // 使用整数而不是字符串
  String _recurrenceOption = 'once';
  bool _isPinned = false;
  bool _remindIfNotCompleted = true;
  bool _isEnabled = true;

  // 类别选择项
  final List<CategoryItem> _categories = [
    CategoryItem(icon: FontAwesomeIcons.briefcase, label: '工作', color: const Color(0xFF3B82F6), id: 1),
    CategoryItem(icon: FontAwesomeIcons.user, label: '个人', color: const Color(0xFFF59E0B), id: 2),
    CategoryItem(icon: FontAwesomeIcons.heartPulse, label: '健康', color: const Color(0xFF10B981), id: 3),
    CategoryItem(icon: FontAwesomeIcons.house, label: '家庭', color: const Color(0xFF8B5CF6), id: 4),
    CategoryItem(icon: FontAwesomeIcons.graduationCap, label: '学习', color: const Color(0xFF6366F1), id: 5),
    CategoryItem(icon: FontAwesomeIcons.bookOpen, label: '阅读', color: const Color(0xFFD946EF), id: 6),
    CategoryItem(icon: FontAwesomeIcons.dumbbell, label: '锻炼', color: const Color(0xFFF43F5E), id: 7),
    CategoryItem(icon: FontAwesomeIcons.utensils, label: '饮食', color: const Color(0xFFF97316), id: 8),
    CategoryItem(icon: FontAwesomeIcons.coins, label: '财务', color: const Color(0xFF65A30D), id: 9),
    CategoryItem(icon: FontAwesomeIcons.userFriends, label: '社交', color: const Color(0xFF0EA5E9), id: 10),
    CategoryItem(icon: FontAwesomeIcons.laptopCode, label: '项目', color: const Color(0xFF475569), id: 11),
    CategoryItem(icon: FontAwesomeIcons.calendar, label: '活动', color: const Color(0xFF84CC16), id: 12),
  ];
  
  // 当前选中的类别索引
  int _selectedCategoryIndex = 0;
  
  // 是否为编辑模式
  bool get _isEditMode => widget.planToEdit != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    
    // 如果是编辑模式，初始化表单数据
    if (_isEditMode) {
      final plan = widget.planToEdit!;
      _titleController.text = plan.title;
      _descriptionController.text = plan.description;
      _selectedDate = plan.date ?? _selectedDate;
      _startTime = plan.startTime ?? _startTime;
      _endTime = plan.endTime ?? _endTime;
      _selectedCategory = plan.category;
      _isPinned = plan.isPinned;
      _isEnabled = plan.isEnabled;
      
      // 设置提醒选项
      if (plan.reminderType == 'none' || plan.reminderMinutes == null || plan.reminderMinutes == 0) {
        _reminderOption = 0;
      } else {
        // 根据分钟数设置选项
        switch (plan.reminderMinutes) {
          case 5:
            _reminderOption = 5;
            break;
          case 10:
            _reminderOption = 10;
            break;
          case 15:
            _reminderOption = 15;
            break;
          case 30:
            _reminderOption = 30;
            break;
          case 60:
            _reminderOption = 60;
            break;
          default:
            _reminderOption = 0;
            break;
        }
      }
      
      // 设置重复选项，并检查是否是有效的选项
      final validRecurrenceOptions = ['once', 'daily', 'weekly', 'monthly', 'weekdays', 'weekends'];
      _recurrenceOption = validRecurrenceOptions.contains(plan.recurrenceType) 
          ? plan.recurrenceType 
          : 'once'; // 如果不是有效的选项，则使用默认值
    }
    
    // 初始化选中的类别索引
    _initSelectedCategoryIndex();
  }
  
  // 初始化选中的类别索引
  void _initSelectedCategoryIndex() {
    // 根据_selectedCategory的值找到对应的索引
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].label.toLowerCase() == _selectedCategory) {
        _selectedCategoryIndex = i;
        break;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 获取当前选中类别的颜色
  Color get _selectedColor {
    return _selectedCategoryIndex < _categories.length 
        ? _categories[_selectedCategoryIndex].color 
        : const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 弹窗标题栏
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  _isEditMode ? '编辑计划' : '添加计划',
                  style: TextStyle(
                    color: _selectedColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 40), // 占位，保持标题居中
              ],
            ),
          ),
          
          // 表单内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 计划标题
                  _buildFormGroup(
                    label: '计划标题',
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '输入计划标题',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _selectedColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  
                  // 时间段选择
                  _buildFormGroup(
                    label: '时间段',
                    child: CustomTimePicker(
                      startTime: _startTime,
                      endTime: _endTime,
                      onStartTimeChanged: (newTime) {
                        setState(() {
                          _startTime = newTime;
                        });
                      },
                      onEndTimeChanged: (newTime) {
                        setState(() {
                          _endTime = newTime;
                        });
                      },
                    ),
                  ),
                  
                  // 日期选择
                  _buildFormGroup(
                    label: '日期',
                    child: GestureDetector(
                      onTap: () async {
                        // 使用自定义日期选择器
                        final date = await DatePickerModal.show(
                          context: context,
                          initialDate: _selectedDate,
                          recentDates: null, // 可以传入最近使用的日期
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('yyyy年MM月dd日').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today, size: 20, color: Color(0xFF6B7280)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 类别选择
                  _buildFormGroup(
                    label: '类别',
                    child: CategorySelector(
                      categories: _categories,
                      selectedIndex: _selectedCategoryIndex,
                      onCategorySelected: (index) {
                        setState(() {
                          _selectedCategoryIndex = index;
                          _selectedCategory = _categories[index].label.toLowerCase();
                        });
                      },
                      onAddCategory: (name, icon, color) {
                        // 这里不需要实现，因为我们不允许添加新类别
                      },
                      showAddButton: false,
                      isExpenseType: false,
                      title: '请选择计划类别',
                      itemsPerPage: 12,
                    ),
                  ),
                  
                  // 计划描述
                  _buildFormGroup(
                    label: '描述（可选）',
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '添加计划描述...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _selectedColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  
                  // 高级设置
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            '高级设置',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        _buildSettingRow(
                          title: '启用计划',
                          subtitle: '随时可以启用或停用此计划',
                          trailing: Switch(
                            value: _isEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isEnabled = value;
                              });
                            },
                            activeColor: _selectedColor,
                          ),
                        ),
                        _buildSettingRow(
                          title: '提醒',
                          subtitle: '设置在计划开始前多久提醒',
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<int>(
                              value: _reminderOption,
                              items: const [
                                DropdownMenuItem(value: 0, child: Text('不提醒')),
                                DropdownMenuItem(value: 5, child: Text('提前5分钟')),
                                DropdownMenuItem(value: 10, child: Text('提前10分钟')),
                                DropdownMenuItem(value: 15, child: Text('提前15分钟')),
                                DropdownMenuItem(value: 30, child: Text('提前30分钟')),
                                DropdownMenuItem(value: 60, child: Text('提前1小时')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _reminderOption = value;
                                  });
                                }
                              },
                              underline: Container(),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        _buildSettingRow(
                          title: '重复',
                          subtitle: '设置计划重复周期',
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _recurrenceOption,
                              items: const [
                                DropdownMenuItem(value: 'once', child: Text('一次性')),
                                DropdownMenuItem(value: 'daily', child: Text('每天')),
                                DropdownMenuItem(value: 'weekly', child: Text('每周')),
                                DropdownMenuItem(value: 'monthly', child: Text('每月')),
                                DropdownMenuItem(value: 'weekdays', child: Text('工作日')),
                                DropdownMenuItem(value: 'weekends', child: Text('周末')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _recurrenceOption = value;
                                  });
                                }
                              },
                              underline: Container(),
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        _buildSettingRow(
                          title: '置顶计划',
                          subtitle: '将此计划显示在置顶区域',
                          trailing: Switch(
                            value: _isPinned,
                            onChanged: (value) {
                              setState(() {
                                _isPinned = value;
                              });
                            },
                            activeColor: _selectedColor,
                          ),
                        ),
                        _buildSettingRow(
                          title: '未完成提醒',
                          subtitle: '如果计划未完成，在指定时间提醒',
                          trailing: Switch(
                            value: _remindIfNotCompleted,
                            onChanged: (value) {
                              setState(() {
                                _remindIfNotCompleted = value;
                              });
                            },
                            activeColor: _selectedColor,
                          ),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  
                  // 操作按钮
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        // 取消按钮
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F4F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 保存按钮
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _isEditMode ? '更新' : '保存',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _submitForm() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入计划标题')),
      );
      return;
    }
    
    // 直接使用_reminderOption作为提醒分钟数
    int? reminderMinutes = _reminderOption > 0 ? _reminderOption : null;
    
    // 从选中的类别获取类别值
    final String categoryValue = _selectedCategory;
    
    final planService = Provider.of<PlanService>(context, listen: false);
    
    final plan = Plan(
      id: widget.planToEdit?.id ?? const Uuid().v4(), // 如果是编辑，使用原id；如果是新建，生成新id
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      category: categoryValue,
      reminderType: reminderMinutes != null && reminderMinutes > 0 ? 'time' : 'none',
      reminderMinutes: reminderMinutes,
      recurrenceType: _recurrenceOption,
      isPinned: _isPinned,
      isCompleted: widget.planToEdit?.isCompleted ?? false,
      completedAt: widget.planToEdit?.completedAt,
      isEnabled: _isEnabled,
      createdAt: widget.planToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    try {
      Map<String, dynamic> result;
      
      if (widget.planToEdit != null) {
        // 更新计划
        result = await planService.updatePlan(plan, context: context);
      } else {
        // 添加计划
        result = await planService.addPlan(plan, context: context);
      }
      
      if (result['success']) {
        // 操作成功后刷新数据
        // 刷新每日计划数据
        await planService.loadPlans(date: _selectedDate);
        
        // 刷新月度计划数据
        await planService.loadMonthlyPlans(
          year: _selectedDate.year,
          month: _selectedDate.month,
        );
        
        // 操作成功，关闭弹窗并返回true
        Navigator.pop(context, true);
      } else {
        // 显示错误信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '操作失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // 操作失败，返回false
        Navigator.pop(context, false);
      }
    } catch (e) {
      // 捕获其他可能的异常
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发生错误: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // 操作失败，返回false
      Navigator.pop(context, false);
    }
  }
  
  // 构建表单组
  Widget _buildFormGroup({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
  
  // 构建设置行
  Widget _buildSettingRow({
    required String title, 
    required String subtitle, 
    required Widget trailing, 
    bool isLast = false
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast 
            ? null 
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}