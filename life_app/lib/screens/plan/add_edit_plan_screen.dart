import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../constants/routes.dart';
import '../../models/plan/plan_model.dart';
import '../../services/plan_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/common/date_picker_modal.dart';
import 'widgets/category_selector_widget.dart';
import '../../widgets/plan/custom_time_picker.dart';
import 'widgets/advanced_settings_widget.dart';

class AddEditPlanScreen extends StatefulWidget {
  final String? planId; // 如果是编辑模式，传入计划ID
  
  const AddEditPlanScreen({
    Key? key,
    this.planId,
  }) : super(key: key);

  @override
  State<AddEditPlanScreen> createState() => _AddEditPlanScreenState();
}

class _AddEditPlanScreenState extends State<AddEditPlanScreen> {
  // 表单控制器
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // 日期和时间
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 10, minute: 0);
  
  // 类别
  String _selectedCategory = 'work'; // 默认工作类别
  
  // 高级设置
  int _reminderMinutes = 15; // 默认提前15分钟提醒
  String _recurrenceType = 'daily'; // 默认每天重复
  bool _isPinned = true; // 默认置顶
  bool _notifyIfNotCompleted = true; // 默认未完成提醒
  bool _isEnabled = true; // 新增的_isEnabled属性
  bool _isLoading = false; // 新增的_isLoading属性
  
  // 是否为编辑模式
  bool get _isEditMode => widget.planId != null;
  
  // 是否表单已修改
  bool _formChanged = false;
  
  final PlanService _planService = PlanService();
  
  @override
  void initState() {
    super.initState();
    
    // 如果是编辑模式，加载现有计划数据
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingPlan();
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  // 加载现有的计划数据
  void _loadExistingPlan() {
    final planService = Provider.of<PlanService>(context, listen: false);
    final plan = planService.getPlanById(widget.planId!);
    
    if (plan != null) {
      setState(() {
        _titleController.text = plan.title;
        _descriptionController.text = plan.description;
        _selectedDate = plan.date ?? DateTime.now();
        _startTime = plan.startTime ?? const TimeOfDay(hour: 9, minute: 0);
        _endTime = plan.endTime ?? const TimeOfDay(hour: 10, minute: 0);
        _selectedCategory = plan.category;
        _reminderMinutes = plan.reminderMinutes ?? 15;
        
        // 检查重复类型是否有效
        final validRecurrenceTypes = ['once', 'daily', 'weekly', 'monthly', 'weekdays', 'weekends', 'yearly', 'custom'];
        _recurrenceType = validRecurrenceTypes.contains(plan.recurrenceType) 
            ? plan.recurrenceType 
            : 'once'; // 如果不是有效的选项，则使用默认值
            
        _isPinned = plan.isPinned;
        _notifyIfNotCompleted = plan.reminderType == 'completion';
        _isEnabled = plan.isEnabled;
      });
    }
  }
  
  // 保存计划
  Future<void> _savePlan() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入计划标题")),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 创建计划对象
      final Plan plan = Plan(
        id: widget.planId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      category: _selectedCategory,
      reminderType: _reminderMinutes > 0 ? 'time' : 'none',
      reminderMinutes: _reminderMinutes,
      recurrenceType: _recurrenceType,
      isPinned: _isPinned,
        isCompleted: false,
      createdAt: DateTime.now(),
        isEnabled: _isEnabled,
    );
    
      // 保存计划
      if (widget.planId == null) {
        // 新增模式
        await _planService.addPlan(plan);
        
        // 刷新计划数据
        await _refreshPlanData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('计划创建成功')),
          );
          Navigator.of(context).pop();
        }
      } else {
        // 编辑模式
        await _planService.updatePlan(plan);
      
        // 刷新计划数据
        await _refreshPlanData();
      
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('计划更新成功')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存计划失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // 刷新计划数据
  Future<void> _refreshPlanData() async {
    // 刷新每日计划数据
    await _planService.loadPlans(date: _selectedDate);
    
    // 刷新月度计划数据
    await _planService.loadMonthlyPlans(
      year: _selectedDate.year,
      month: _selectedDate.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_formChanged) {
          // 如果表单已修改，显示确认对话框
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('放弃更改?'),
              content: const Text('您有未保存的更改，确定要放弃吗?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('放弃'),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
          ),
          Text(
            _isEditMode ? "编辑计划" : "添加计划",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 20), // 占位元素，保持标题居中
        ],
      ),
    );
  }
  
  // 构建表单
  Widget _buildForm() {
    return Column(
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
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(fontSize: 16),
            onChanged: (value) {
              setState(() {
                _formChanged = true;
              });
            },
          ),
        ),
        
        // 时间段选择
        _buildFormGroup(
          label: '时间段',
          child: CustomTimePicker(
            startTime: _startTime,
            endTime: _endTime,
            onStartTimeChanged: (time) {
              setState(() {
                _startTime = time;
                _formChanged = true;
              });
            },
            onEndTimeChanged: (time) {
              setState(() {
                _endTime = time;
                _formChanged = true;
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
                  _formChanged = true;
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
                    DateFormat('yyyy年MM月dd日', 'zh_CN').format(_selectedDate),
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
          child: CategorySelectorWidget(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
                _formChanged = true;
              });
            },
          ),
        ),
        
        // 描述（可选）
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
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(fontSize: 16),
            onChanged: (value) {
              setState(() {
                _formChanged = true;
              });
            },
          ),
        ),
        
        // 高级设置
        AdvancedSettingsWidget(
          reminderMinutes: _reminderMinutes,
          recurrenceType: _recurrenceType,
          isPinned: _isPinned,
          notifyIfNotCompleted: _notifyIfNotCompleted,
          isEnabled: _isEnabled,
          onReminderChanged: (value) {
            setState(() {
              _reminderMinutes = value;
              _formChanged = true;
            });
          },
          onRecurrenceChanged: (value) {
            setState(() {
              _recurrenceType = value;
              _formChanged = true;
            });
          },
          onPinnedChanged: (value) {
            setState(() {
              _isPinned = value;
              _formChanged = true;
            });
          },
          onNotifyIfNotCompletedChanged: (value) {
            setState(() {
              _notifyIfNotCompleted = value;
              _formChanged = true;
            });
          },
          onEnabledChanged: (value) {
            setState(() {
              _isEnabled = value;
              _formChanged = true;
            });
          },
        ),
        
        const SizedBox(height: 20),
        
        // 操作按钮
        Column(
          children: [
            // 保存按钮
            ElevatedButton(
              onPressed: _savePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                '保存计划',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 取消按钮
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
      ],
    );
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
} 