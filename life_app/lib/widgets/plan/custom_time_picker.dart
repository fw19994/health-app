import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(TimeOfDay) onEndTimeChanged;
  
  const CustomTimePicker({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  }) : super(key: key);
  
  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  // 用于控制小时和分钟选择器的显示
  OverlayEntry? _overlayEntry;
  bool _isStartTimeActive = false;
  bool _isEndTimeActive = false;
  
  // 创建焦点控制器以便在需要时隐藏键盘
  final FocusNode _startFocus = FocusNode();
  final FocusNode _endFocus = FocusNode();
  
  // 控制器，用于显示时间值
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  
  // 保存输入框的位置信息
  final GlobalKey _startTimeKey = GlobalKey();
  final GlobalKey _endTimeKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _updateControllerValues();
  }
  
  @override
  void didUpdateWidget(CustomTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startTime != widget.startTime || oldWidget.endTime != widget.endTime) {
      _updateControllerValues();
    }
  }
  
  void _updateControllerValues() {
    _startController.text = _formatTime(widget.startTime);
    _endController.text = _formatTime(widget.endTime);
  }
  
  @override
  void dispose() {
    _removeOverlay();
    _startFocus.dispose();
    _endFocus.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }
  
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  // 显示时间选择器浮层
  void _showTimePicker({
    required GlobalKey fieldKey,
    required TimeOfDay selectedTime,
    required Function(TimeOfDay) onTimeSelected,
    required bool isStartTime,
  }) {
    // 确保移除之前的浮层
    _removeOverlay();
    
    // 获取输入框的位置信息
    final RenderBox renderBox = fieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    
    setState(() {
      _isStartTimeActive = isStartTime;
      _isEndTimeActive = !isStartTime;
    });
    
    // 创建透明的全屏覆盖层，用于检测点击外部事件
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 透明全屏层，用于捕获点击事件
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _removeOverlay();
                setState(() {
                  _isStartTimeActive = false;
                  _isEndTimeActive = false;
                });
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // 时间选择器浮层
          Positioned(
            left: offset.dx,
            top: offset.dy + renderBox.size.height + 4,
            width: renderBox.size.width,
            child: GestureDetector(
              // 防止点击选择器自身时关闭
              onTap: () {},
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildCustomTimePicker(
                    selectedTime,
                    (newTime) {
                      onTimeSelected(newTime);
                      _removeOverlay();
                      setState(() {
                        _isStartTimeActive = false;
                        _isEndTimeActive = false;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    
    // 添加浮层到Overlay
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTimeField(
            key: _startTimeKey,
            controller: _startController,
            focusNode: _startFocus,
            onTap: () {
              _startFocus.unfocus();
              _showTimePicker(
                fieldKey: _startTimeKey,
                selectedTime: widget.startTime,
                onTimeSelected: widget.onStartTimeChanged,
                isStartTime: true,
              );
            },
            isActive: _isStartTimeActive,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          '至',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTimeField(
            key: _endTimeKey,
            controller: _endController,
            focusNode: _endFocus,
            onTap: () {
              _endFocus.unfocus();
              _showTimePicker(
                fieldKey: _endTimeKey,
                selectedTime: widget.endTime,
                onTimeSelected: widget.onEndTimeChanged,
                isStartTime: false,
              );
            },
            isActive: _isEndTimeActive,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeField({
    required Key key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return TextField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isActive ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981)),
        ),
        suffixIcon: const Icon(Icons.access_time, size: 20, color: Color(0xFF6B7280)),
      ),
      style: const TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  }
  
  Widget _buildCustomTimePicker(TimeOfDay currentTime, Function(TimeOfDay) onTimeSelected) {
    return Row(
      children: [
        // 小时选择器
        Expanded(
          child: _buildNumberPicker(
            minValue: 0,
            maxValue: 23,
            currentValue: currentTime.hour,
            onValueChanged: (int hour) {
              onTimeSelected(TimeOfDay(hour: hour, minute: currentTime.minute));
            },
          ),
        ),
        
        // 分钟选择器
        Expanded(
          child: _buildNumberPicker(
            minValue: 0,
            maxValue: 59,
            currentValue: currentTime.minute,
            onValueChanged: (int minute) {
              onTimeSelected(TimeOfDay(hour: currentTime.hour, minute: minute));
            },
            stepSize: 5, // 每5分钟一个选项
            formatNumber: (value) => value.toString().padLeft(2, '0'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNumberPicker({
    required int minValue,
    required int maxValue,
    required int currentValue,
    required Function(int) onValueChanged,
    int stepSize = 1,
    String Function(int)? formatNumber,
  }) {
    final items = List<int>.generate(
      ((maxValue - minValue) ~/ stepSize) + 1,
      (index) => minValue + (index * stepSize),
    );
    
    // 设置初始滚动位置
    final initialScrollOffset = items.indexOf(items.firstWhere(
      (item) => item >= currentValue, 
      orElse: () => items.last
    )) * 40.0;
    
    return ListView.builder(
      controller: ScrollController(initialScrollOffset: initialScrollOffset),
      itemCount: items.length,
      itemExtent: 40.0, // 每个选项高度
      itemBuilder: (context, index) {
        final itemValue = items[index];
        final isSelected = itemValue == currentValue;
        
        // 格式化数字显示，例如保持两位数
        final displayText = formatNumber != null 
          ? formatNumber(itemValue) 
          : itemValue.toString();
        
        return GestureDetector(
          onTap: () => onValueChanged(itemValue),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
} 