import 'package:flutter/material.dart';

class TransactionTrendChart extends StatelessWidget {
  final List<double> incomeData;
  final List<double> expenseData;
  final List<String> labels;
  final String periodText;

  const TransactionTrendChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
    required this.labels,
    required this.periodText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图表标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '收支趋势',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                periodText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 图表区域
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                // 网格线
                GridLines(
                  horizontalLinesCount: 5,
                ),
                
                // 折线图
                LineChartWidget(
                  incomeData: incomeData,
                  expenseData: expenseData,
                ),
                
                // 图例
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '收入',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '支出',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
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
          const SizedBox(height: 8),
          
          // 时间标签
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                labels.length,
                (index) => Text(
                  labels[index],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridLines extends StatelessWidget {
  final int horizontalLinesCount;

  const GridLines({
    super.key,
    this.horizontalLinesCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: GridPainter(
        horizontalLinesCount: horizontalLinesCount,
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int horizontalLinesCount;

  GridPainter({required this.horizontalLinesCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 1;

    // 绘制水平线
    final double space = size.height / (horizontalLinesCount - 1);
    for (int i = 0; i < horizontalLinesCount; i++) {
      final double y = i * space;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class LineChartWidget extends StatelessWidget {
  final List<double> incomeData;
  final List<double> expenseData;

  const LineChartWidget({
    super.key,
    required this.incomeData,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: LineChartPainter(
        incomeData: incomeData,
        expenseData: expenseData,
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> incomeData;
  final List<double> expenseData;

  LineChartPainter({
    required this.incomeData,
    required this.expenseData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (incomeData.isEmpty || expenseData.isEmpty) return;

    // 收入线的画笔
    final incomePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 支出线的画笔
    final expensePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 分别找出收入和支出的最大值，各自归一化
    final maxIncome = incomeData.isNotEmpty ? incomeData.reduce((a, b) => a > b ? a : b) : 1.0;
    final maxExpense = expenseData.isNotEmpty ? expenseData.reduce((a, b) => a > b ? a : b) : 1.0;
    
    // 确保最大值不为0，避免除以0
    final safeMaxIncome = maxIncome > 0 ? maxIncome : 1.0;
    final safeMaxExpense = maxExpense > 0 ? maxExpense : 1.0;

    // 绘制收入折线
    final incomePath = Path();
    final incomePoints = _getPoints(incomeData, size, safeMaxIncome);
    
    if (incomePoints.isNotEmpty) {
    incomePath.moveTo(incomePoints[0].dx, incomePoints[0].dy);

    for (int i = 1; i < incomePoints.length; i++) {
      incomePath.lineTo(incomePoints[i].dx, incomePoints[i].dy);
      }
      
      canvas.drawPath(incomePath, incomePaint);
      
      // 绘制收入数据点
      for (final point in incomePoints) {
        canvas.drawCircle(
          point,
          3,
          Paint()..color = const Color(0xFF10B981),
        );
      }
    }

    // 绘制支出折线
    final expensePath = Path();
    final expensePoints = _getPoints(expenseData, size, safeMaxExpense);
    
    if (expensePoints.isNotEmpty) {
    expensePath.moveTo(expensePoints[0].dx, expensePoints[0].dy);

    for (int i = 1; i < expensePoints.length; i++) {
      expensePath.lineTo(expensePoints[i].dx, expensePoints[i].dy);
    }

    canvas.drawPath(expensePath, expensePaint);
      
      // 绘制支出数据点
      for (final point in expensePoints) {
        canvas.drawCircle(
          point,
          3,
          Paint()..color = const Color(0xFFEF4444),
        );
      }
    }

    // 绘制收入Y轴刻度
    _drawYAxisLabels(
      canvas, 
      size, 
      safeMaxIncome, 
      const Color(0xFF10B981), 
      true
    );
    
    // 绘制支出Y轴刻度
    _drawYAxisLabels(
      canvas, 
      size, 
      safeMaxExpense, 
      const Color(0xFFEF4444), 
      false
    );
  }
  
  // 绘制Y轴刻度
  void _drawYAxisLabels(Canvas canvas, Size size, double maxValue, Color color, bool isIncome) {
    final textStyle = TextStyle(
      color: color,
      fontSize: 10,
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    final steps = 5; // 分5个刻度
    for (int i = 0; i <= steps; i++) {
      final value = maxValue * i / steps;
      final y = size.height - (value / maxValue * size.height);
      
      // 只在左右两侧绘制刻度
      if (i > 0 && i < steps) {
        final text = value.toInt().toString();
        textPainter.text = TextSpan(
          text: text,
          style: textStyle,
        );
        textPainter.layout();
        
        final x = isIncome ? 0.0 : size.width - textPainter.width;
        textPainter.paint(canvas, Offset(x, y - textPainter.height / 2));
      }
    }
  }

  // 计算点的位置
  List<Offset> _getPoints(List<double> data, Size size, double maxValue) {
    if (data.isEmpty) return [];
    
    final result = <Offset>[];
    final segmentWidth = data.length > 1 ? size.width / (data.length - 1) : size.width;

    for (int i = 0; i < data.length; i++) {
      final x = i * segmentWidth;
      final y = size.height - (data[i] / maxValue * size.height);
      result.add(Offset(x, y));
    }

    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
