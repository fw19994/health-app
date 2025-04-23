import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _bubbleController;
  late AnimationController _waveController;
  late List<BubbleModel> bubbles;

  @override
  void initState() {
    super.initState();
    
    // 渐变动画控制器
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    
    // 气泡动画控制器
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    
    // 波浪动画控制器
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 初始化气泡
    _initBubbles();
  }

  void _initBubbles() {
    final random = Random();
    bubbles = List.generate(6, (index) {
      final size = random.nextDouble() * 60 + 40; // 40到100之间
      return BubbleModel(
        size: size,
        position: Offset(
          random.nextDouble() * 300, 
          random.nextDouble() * 600
        ),
        delay: random.nextDouble() * 15,
        duration: random.nextDouble() * 10 + 10, // 10到20秒
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _bubbleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // 渐变背景
        AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            return Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                    0.0,
                    _gradientController.value * 0.25,
                    _gradientController.value * 0.5,
                    _gradientController.value * 0.75,
                    1.0,
                  ],
                  colors: const [
                    Color(0xFF0EA5E9), // 青色
                    Color(0xFF10B981), // 绿色
                    Color(0xFF8B5CF6), // 紫色
                    Color(0xFFEC4899), // 粉色
                    Color(0xFFF59E0B), // 橙色
                  ],
                ),
              ),
            );
          },
        ),
        
        // 背景光斑效果
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _gradientController.value * 2 * pi,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // 气泡效果
        ...bubbles.map((bubble) => _buildBubble(bubble, screenSize)),
        
        // 波浪效果
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: screenSize.height * 0.4,
          child: _buildWaves(screenSize),
        ),
      ],
    );
  }

  Widget _buildBubble(BubbleModel bubble, Size screenSize) {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        final animationProgress = (_bubbleController.value + bubble.delay / 15) % 1.0;
        
        // 计算当前位置
        final xOffset = sin(animationProgress * 2 * pi) * 20.0;
        final yOffset = cos(animationProgress * 2 * pi) * 30.0 - 50.0 * animationProgress;
        
        return Positioned(
          left: (bubble.position.dx + xOffset) % screenSize.width,
          top: (bubble.position.dy + yOffset) % (screenSize.height * 0.8),
          child: Transform.rotate(
            angle: sin(animationProgress * 2 * pi) * 0.2,
            child: Container(
              width: bubble.size,
              height: bubble.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaves(Size screenSize) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Stack(
          children: [
            // 第一层波浪
            _buildWave(
              screenSize, 
              _waveController.value, 
              0.8, 
              Colors.white.withOpacity(0.3),
              -25,
            ),
            
            // 第二层波浪
            _buildWave(
              screenSize, 
              _waveController.value - 0.2, 
              0.6, 
              Colors.white.withOpacity(0.4),
              -5,
            ),
            
            // 第三层波浪
            _buildWave(
              screenSize, 
              _waveController.value - 0.4, 
              0.4, 
              Colors.white.withOpacity(0.2),
              3,
            ),
          ],
        );
      },
    );
  }

  Widget _buildWave(Size screenSize, double value, double opacity, Color color, double yOffset) {
    return CustomPaint(
      size: Size(screenSize.width, screenSize.height * 0.4),
      painter: WavePainter(
        animation: value % 1.0,
        waveColor: color,
        yOffset: yOffset,
      ),
    );
  }
}

// 气泡模型
class BubbleModel {
  final double size;
  final Offset position;
  final double delay;
  final double duration;
  final Curve curve;

  BubbleModel({
    required this.size,
    required this.position,
    required this.delay,
    required this.duration,
    required this.curve,
  });
}

// 波浪绘制器
class WavePainter extends CustomPainter {
  final double animation;
  final Color waveColor;
  final double yOffset;

  WavePainter({
    required this.animation,
    required this.waveColor,
    this.yOffset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;
    
    // 波浪参数
    const waveHeight = 20.0;
    const waveLength = 120.0;
    final startOffset = animation * waveLength * 2;

    // 起始点
    path.moveTo(0, height / 2 + yOffset);

    // 绘制波浪路径
    for (double i = 0; i <= width + waveLength; i += 1) {
      final x = i;
      final waveY = sin((i - startOffset) / waveLength * 2 * pi) * waveHeight;
      final y = height / 2 + waveY + yOffset;
      path.lineTo(x, y);
    }

    // 封闭路径
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    // 填充
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      animation != oldDelegate.animation ||
      waveColor != oldDelegate.waveColor;
}
