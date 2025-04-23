import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class AssistantFloatingButton extends StatefulWidget {
  final VoidCallback onTap;
  
  const AssistantFloatingButton({
    super.key,
    required this.onTap,
  });

  @override
  State<AssistantFloatingButton> createState() => _AssistantFloatingButtonState();
}

class _AssistantFloatingButtonState extends State<AssistantFloatingButton> {
  // 按钮位置
  late Offset _position;
  // 屏幕尺寸
  late Size _screenSize;
  // 按钮大小
  final double _buttonSize = 60.0;
  
  @override
  void initState() {
    super.initState();
    _position = const Offset(0, 0); // 初始位置会在didChangeDependencies中更新
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取屏幕尺寸
    _screenSize = MediaQuery.of(context).size;
    
    // 设置初始位置：右下角
    if (_position == const Offset(0, 0)) {
      _position = Offset(
        _screenSize.width - _buttonSize - 16.0,
        _screenSize.height - _buttonSize - 80.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx.toDouble(),
      top: _position.dy.toDouble(),
      child: GestureDetector(
        onTap: widget.onTap,
        onPanUpdate: _updatePosition,
        child: Container(
          width: _buttonSize,
          height: _buttonSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7F6CFF), Color(0xFF6F57FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 金色微笑脸背景
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                ),
                // 笑脸表情
                const Text(
                  "小财",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _updatePosition(DragUpdateDetails details) {
    setState(() {
      double dx = _position.dx + details.delta.dx;
      double dy = _position.dy + details.delta.dy;
      
      // 确保助手不会移出屏幕
      dx = dx.clamp(0.0, _screenSize.width - _buttonSize);
      dy = dy.clamp(
        MediaQuery.of(context).padding.top.toDouble(), 
        _screenSize.height - _buttonSize - MediaQuery.of(context).padding.bottom
      );
      
      _position = Offset(dx, dy);
    });
  }
}
