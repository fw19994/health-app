import 'package:flutter/material.dart';
import '../../../constants/plan_constants.dart';

class AdvancedSettingsWidget extends StatelessWidget {
  final int reminderMinutes;
  final String recurrenceType;
  final bool isPinned;
  final bool notifyIfNotCompleted;
  final bool isEnabled;
  final Function(int) onReminderChanged;
  final Function(String) onRecurrenceChanged;
  final Function(bool) onPinnedChanged;
  final Function(bool) onNotifyIfNotCompletedChanged;
  final Function(bool) onEnabledChanged;

  const AdvancedSettingsWidget({
    Key? key,
    required this.reminderMinutes,
    required this.recurrenceType,
    required this.isPinned,
    required this.notifyIfNotCompleted,
    required this.isEnabled,
    required this.onReminderChanged,
    required this.onRecurrenceChanged,
    required this.onPinnedChanged,
    required this.onNotifyIfNotCompletedChanged,
    required this.onEnabledChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '高级设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // 启用/停用计划
          _buildSettingRow(
            label: '启用计划',
            description: '随时可以启用或停用此计划',
            control: _buildCustomSwitch(
              value: isEnabled, 
              onChanged: onEnabledChanged
            ),
          ),
          
          // 提醒设置
          _buildSettingRow(
            label: '提醒',
            description: '设置在计划开始前多久提醒',
            control: _buildReminderSelector(context),
          ),
          
          // 重复设置
          _buildSettingRow(
            label: '重复',
            description: '设置计划重复周期',
            control: _buildRecurrenceSelector(context),
          ),
          
          // 置顶设置
          _buildSettingRow(
            label: '置顶计划',
            description: '将此计划显示在置顶区域',
            control: _buildCustomSwitch(
              value: isPinned, 
              onChanged: onPinnedChanged
            ),
          ),
          
          // 未完成提醒
          _buildSettingRow(
            label: '未完成提醒',
            description: '如果计划未完成，在指定时间提醒',
            control: _buildCustomSwitch(
              value: notifyIfNotCompleted, 
              onChanged: onNotifyIfNotCompletedChanged
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // 简化的提醒选择器
  Widget _buildReminderSelector(BuildContext context) {
    // 获取当前选择的提醒文本
    final selectedText = PlanConstants.reminderOptions[reminderMinutes] ?? '不提醒';
    
    return GestureDetector(
      onTap: () {
        _showSimpleReminderDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF10B981)),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Text(
          selectedText,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }
  
  // 简单的提醒选择弹窗
  void _showSimpleReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择提醒时间',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                ...PlanConstants.reminderOptions.entries.map((entry) {
                  return InkWell(
                    onTap: () {
                      onReminderChanged(entry.key);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: reminderMinutes == entry.key 
                            ? const Color(0xFFF3F9F7) 
                            : Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          if (reminderMinutes == entry.key)
                            const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // 重复选择器
  Widget _buildRecurrenceSelector(BuildContext context) {
    // 验证recurrenceType是否有效，如果无效则使用默认值
    final validRecurrenceTypes = PlanConstants.recurrenceOptions.keys.toList();
    final validRecurrenceType = validRecurrenceTypes.contains(recurrenceType) 
        ? recurrenceType 
        : 'once';
    
    // 获取当前选择的重复文本
    final selectedText = PlanConstants.recurrenceOptions[validRecurrenceType] ?? '一次性';
    
    return GestureDetector(
      onTap: () {
        _showSimpleRecurrenceDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedText,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
  
  // 简单的重复选择弹窗
  void _showSimpleRecurrenceDialog(BuildContext context) {
    // 验证recurrenceType是否有效，如果无效则使用默认值
    final validRecurrenceTypes = PlanConstants.recurrenceOptions.keys.toList();
    final validRecurrenceType = validRecurrenceTypes.contains(recurrenceType) 
        ? recurrenceType 
        : 'once';
        
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择重复周期',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                ...PlanConstants.recurrenceOptions.entries.map((entry) {
                  return InkWell(
                    onTap: () {
                      onRecurrenceChanged(entry.key);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: validRecurrenceType == entry.key 
                            ? const Color(0xFFF3F9F7) 
                            : Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          if (validRecurrenceType == entry.key)
                            const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // 自定义开关组件
  Widget _buildCustomSwitch({required bool value, required Function(bool) onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? const Color(0xFF10B981) : Colors.grey.shade300,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 20 : 0,
              top: 5,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String label,
    required String description,
    required Widget control,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFF3F4F6),
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
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: control,
          ),
        ],
      ),
    );
  }
} 