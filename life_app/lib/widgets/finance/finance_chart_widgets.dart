import 'package:flutter/material.dart';
import 'dart:math';

/// 折线图组件 - 用于显示财务趋势数据
class LineChartWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Color color;
  final bool showDots;
  final bool showFill;
  final double lineWidth;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.labels,
    required this.color,
    this.showDots = true,
    this.showFill = false,
    this.lineWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight * 0.8),
                painter: LineChartPainter(
                  data: data,
                  color: color,
                  showDots: showDots,
                  showFill: showFill,
                  lineWidth: lineWidth,
                ),
              ),
            ),
            SizedBox(
              height: constraints.maxHeight * 0.2,
              child: _buildLabels(),
            ),
          ],
        );
      },
    );
  }

  // 构建X轴标签
  Widget _buildLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 只显示部分月份标签以避免拥挤
        _buildLabel(labels.first),
        _buildLabel(labels[3]),
        _buildLabel(labels[6]),
        _buildLabel(labels[9]),
        _buildLabel(labels.last),
      ],
    );
  }

  // 构建单个标签
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade600,
      ),
    );
  }
}

/// 折线图绘制器
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool showDots;
  final bool showFill;
  final double lineWidth;

  LineChartPainter({
    required this.data,
    required this.color,
    required this.showDots,
    required this.showFill,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final height = size.height;
    final width = size.width;
    
    // 找出数据中的最大值和最小值，用于归一化
    final double maxValue = data.reduce(max);
    final double minValue = data.reduce(min);
    final double range = maxValue - minValue;
    
    // 给顶部和底部留出一些空间
    final padding = height * 0.1;
    
    // 将数据点转换为屏幕坐标
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * width / (data.length - 1);
      final normalizedValue = (data[i] - minValue) / range;
      final y = height - (normalizedValue * (height - 2 * padding) + padding);
      points.add(Offset(x, y));
    }
    
    // 绘制填充区域（如果启用）
    if (showFill) {
      final fillPath = Path()
        ..moveTo(0, height)
        ..lineTo(points.first.dx, points.first.dy);
      
      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
      
      fillPath.lineTo(width, height);
      fillPath.close();
      
      final fillPaint = Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(fillPath, fillPaint);
    }
    
    // 绘制线条
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final path = Path()
      ..moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, linePaint);
    
    // 绘制数据点（如果启用）
    if (showDots) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final dotOutlinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      for (int i = 0; i < points.length; i += 2) { // 每隔一个点显示一个圆点，避免过于拥挤
        canvas.drawCircle(points[i], 4, dotPaint);
        canvas.drawCircle(points[i], 4, dotOutlinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// 条形图组件
class BarChartWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final List<Color> colors;
  final double barWidth;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.labels,
    required this.colors,
    this.barWidth = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight * 0.8),
                painter: BarChartPainter(
                  data: data,
                  colors: colors,
                  barWidth: barWidth,
                ),
              ),
            ),
            SizedBox(
              height: constraints.maxHeight * 0.2,
              child: _buildLabels(),
            ),
          ],
        );
      },
    );
  }

  // 构建X轴标签
  Widget _buildLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) => _buildLabel(label)).toList(),
    );
  }

  // 构建单个标签
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade600,
      ),
    );
  }
}

/// 条形图绘制器
class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  final double barWidth;

  BarChartPainter({
    required this.data,
    required this.colors,
    required this.barWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final height = size.height;
    final width = size.width;
    
    // 找出数据中的最大值，用于归一化
    final double maxValue = data.reduce(max);
    
    // 给顶部留出一些空间
    final padding = height * 0.1;
    
    // 计算每个条形的位置
    final barSpacing = (width - (barWidth * data.length)) / (data.length + 1);
    
    for (int i = 0; i < data.length; i++) {
      final normalizedValue = data[i] / maxValue;
      final barHeight = normalizedValue * (height - padding);
      
      final x = barSpacing + i * (barWidth + barSpacing);
      final y = height - barHeight;
      
      final barRect = Rect.fromLTWH(x, y, barWidth, barHeight);
      
      final barPaint = Paint()
        ..color = i < colors.length ? colors[i] : colors.last
        ..style = PaintingStyle.fill;
      
      // 绘制条形
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// 环形图组件
class DonutChartWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final List<Color> colors;
  final double thickness;

  const DonutChartWidget({
    super.key,
    required this.data,
    required this.labels,
    required this.colors,
    this.thickness = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: DonutChartPainter(
              data: data,
              colors: colors,
              thickness: thickness,
            ),
            child: Center(
              child: _buildCenterLabel(),
            ),
          ),
        );
      },
    );
  }

  // 中心标签
  Widget _buildCenterLabel() {
    // 计算总和
    final total = data.reduce((a, b) => a + b);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '总计',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          total.toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 环形图绘制器
class DonutChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  final double thickness;

  DonutChartPainter({
    required this.data,
    required this.colors,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = (size.width < size.height ? size.width : size.height) / 2 - thickness / 2;
    
    // 计算总和
    final total = data.reduce((a, b) => a + b);
    
    // 开始角度（顶部）
    double startAngle = -pi / 2;
    
    for (int i = 0; i < data.length; i++) {
      final sweepAngle = 2 * pi * (data[i] / total);
      
      final paint = Paint()
        ..color = i < colors.length ? colors[i] : colors.last
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.butt;
      
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// 进度条组件
class ProgressBarWidget extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color color;
  final double height;
  final String? label;
  final String? valueLabel;

  const ProgressBarWidget({
    super.key,
    required this.value,
    this.maxValue = 100.0,
    required this.color,
    this.height = 8.0,
    this.label,
    this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || valueLabel != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (valueLabel != null)
                Text(
                  valueLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        if (label != null || valueLabel != null)
          const SizedBox(height: 4),
        Stack(
          children: [
            // 背景
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // 进度
            Container(
              height: height,
              width: value / maxValue * MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 多项比较进度条组件
class ComparisonProgressBarWidget extends StatelessWidget {
  final double currentValue;
  final double previousValue;
  final double maxValue;
  final Color color;
  final double height;
  final String? label;
  final String? currentLabel;
  final String? previousLabel;

  const ComparisonProgressBarWidget({
    super.key,
    required this.currentValue,
    required this.previousValue,
    this.maxValue = 100.0,
    required this.color,
    this.height = 8.0,
    this.label,
    this.currentLabel,
    this.previousLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (label != null)
          const SizedBox(height: 4),
        Stack(
          children: [
            // 背景
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // 上期数据
            Container(
              height: height,
              width: previousValue / maxValue * MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // 当前数据
            Container(
              height: height,
              width: currentValue / maxValue * MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ],
        ),
        if (currentLabel != null || previousLabel != null)
          const SizedBox(height: 4),
        if (currentLabel != null || previousLabel != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (previousLabel != null)
                Text(
                  previousLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              if (currentLabel != null)
                Text(
                  currentLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
