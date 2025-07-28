import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/plan/special_project_model.dart';
import '../../services/special_project_service.dart';
import '../../widgets/common/date_picker_modal.dart';
import '../../widgets/common/app_alert_dialog.dart';

/// 添加专项计划弹窗
/// 可在多个页面复用的添加专项计划弹窗组件
class AddSpecialProjectModal extends StatefulWidget {
  /// 创建成功后的回调
  final Function(SpecialProject)? onCreated;

  const AddSpecialProjectModal({
    Key? key,
    this.onCreated,
  }) : super(key: key);

  /// 显示添加专项计划弹窗的静态方法
  static Future<void> show(BuildContext context, {Function(SpecialProject)? onCreated}) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSpecialProjectModal(onCreated: onCreated),
    );
  }

  @override
  State<AddSpecialProjectModal> createState() => _AddSpecialProjectModalState();
}

class _AddSpecialProjectModalState extends State<AddSpecialProjectModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 选择日期的方法
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate 
        ? _startDate ?? DateTime.now() 
        : _endDate ?? (_startDate != null ? _startDate!.add(const Duration(days: 7)) : DateTime.now());
    
    final date = await DatePickerModal.show(
      context: context,
      initialDate: initialDate,
    );
    
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          // 如果结束日期早于开始日期，更新结束日期
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 7));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  // 提交表单
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      AppAlertDialog.show(
        context: context,
        message: '请选择项目周期',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 创建新的专项计划
      final newProject = SpecialProject(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 临时ID，实际应由后端生成
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        status: ProjectStatus.planned,
        completedTasks: 0,
        totalTasks: 0,
        budget: double.tryParse(_budgetController.text) ?? 0.0,
        spent: 0.0,
        tasks: [],
      );

      // 添加到服务
      await Provider.of<SpecialProjectService>(context, listen: false).addProject(newProject);

      // 调用创建成功回调
      if (widget.onCreated != null) {
        widget.onCreated!(newProject);
      }

      // 关闭弹窗
      if (mounted) {
        Navigator.of(context).pop();
        AppAlertDialog.showSuccess(
          context: context,
          message: '专项计划创建成功',
        );
      }
    } catch (e) {
      if (mounted) {
        AppAlertDialog.showError(
          context: context,
          message: '创建失败: ${e.toString()}',
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

  @override
  Widget build(BuildContext context) {
    // 计算键盘高度，确保弹窗不被键盘遮挡
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 拖动条
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // 标题和关闭按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '添加专项计划',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 表单
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 专项名称
                  _buildFormField(
                    icon: Icons.bookmark,
                    label: '专项名称',
                    child: TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('请输入专项计划名称'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入专项名称';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 项目周期
                  _buildFormField(
                    icon: Icons.calendar_today,
                    label: '项目周期',
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              child: Text(
                                _startDate == null
                                    ? '开始日期'
                                    : DateFormat('yyyy-MM-dd').format(_startDate!),
                                style: TextStyle(
                                  color: _startDate == null
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('至', style: TextStyle(color: Color(0xFF6B7280))),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              child: Text(
                                _endDate == null
                                    ? '结束日期'
                                    : DateFormat('yyyy-MM-dd').format(_endDate!),
                                style: TextStyle(
                                  color: _endDate == null
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 项目预算
                  _buildFormField(
                    icon: Icons.attach_money,
                    label: '项目预算',
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('请输入预算金额').copyWith(
                        prefixText: '¥ ',
                        prefixStyle: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 计划描述
                  _buildFormField(
                    icon: Icons.description,
                    label: '计划描述',
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _inputDecoration('请输入计划描述'),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            foregroundColor: const Color(0xFF374151),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '取消',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  '创建计划',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
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

  // 构建表单字段
  Widget _buildFormField({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF4F46E5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // 输入框装饰
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFF4F46E5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
} 