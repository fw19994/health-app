import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 预测柱状图
class ForecastBarChart extends StatelessWidget {
  final bool isIncome;
  final Color mainColor;
  final double height;

  const ForecastBarChart({
    super.key,
    required this.isIncome,
    required this.mainColor,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartWidth = constraints.maxWidth;
          final chartHeight = height - 40; // 为底部月份标签留出空间
          
          return Stack(
            children: [
              // 分隔线
              Positioned(
                left: chartWidth * 0.5,
                top: 0,
                bottom: 30,
                child: Container(
                  width: 2,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              
              // "现在"标签
              Positioned(
                left: chartWidth * 0.5 - 15,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '现在',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              
              // 历史柱状图
              ..._generateBarItems(chartWidth, chartHeight, isHistorical: true),
              
              // 预测柱状图
              ..._generateBarItems(chartWidth, chartHeight, isHistorical: false),
            ],
          );
        }
      ),
    );
  }
  
  // 生成柱状图项
  List<Widget> _generateBarItems(double totalWidth, double height, {required bool isHistorical}) {
    final items = <Widget>[];
    final barWidth = totalWidth * 0.08;
    final baseHeight = height * 0.7;
    
    // 历史数据值
    final historicalValues = isIncome 
        ? [0.85, 0.8, 0.9, 1.0, 0.95, 0.97] 
        : [0.4, 0.5, 0.45, 0.42, 0.45, 0.48];
    
    // 预测数据值
    final forecastValues = isIncome 
        ? [0.97, 0.99, 1.01, 1.03, 1.04, 1.08] 
        : [0.48, 0.53, 0.5, 0.48, 0.52, 0.49];
    
    // 月份标签
    final monthLabels = isHistorical 
        ? ['-6月', '-5月', '-4月', '-3月', '-2月', '-1月']
        : ['+1月', '+2月', '+3月', '+4月', '+5月', '+6月'];
    
    final values = isHistorical ? historicalValues : forecastValues;
    
    for (int i = 0; i < values.length; i++) {
      final leftPercentage = isHistorical 
          ? 0.04 + (i * 0.09) 
          : 0.54 + ((i - 0.5) * 0.09);
          
      final left = totalWidth * leftPercentage - barWidth / 2;
      final barHeight = baseHeight * values[i];
      
      // 柱状图
      items.add(
        Positioned(
          left: left,
          bottom: 30, // 为底部月份标签留出空间
          child: Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: isHistorical 
                  ? mainColor 
                  : Colors.transparent,
              border: Border.all(
                color: mainColor,
                width: 1,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              gradient: !isHistorical ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  mainColor.withOpacity(0.5),
                  mainColor.withOpacity(0.8),
                ],
              ) : null,
            ),
            child: !isHistorical ? CustomPaint(
              painter: StripePainter(
                stripeColor: mainColor,
                stripeWidth: 5,
              ),
            ) : null,
          ),
        ),
      );
      
      // 月份标签
      items.add(
        Positioned(
          left: left,
          bottom: 0,
          child: SizedBox(
            width: barWidth,
            child: Text(
              monthLabels[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }
    
    return items;
  }
}

/// 条纹绘制器
class StripePainter extends CustomPainter {
  final Color stripeColor;
  final double stripeWidth;

  StripePainter({
    required this.stripeColor,
    required this.stripeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor.withOpacity(0.5)
      ..strokeWidth = stripeWidth
      ..style = PaintingStyle.stroke;

    for (double i = -size.width; i <= size.width + size.height; i += 2 * stripeWidth) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 储蓄目标进度条
class SavingGoalProgress extends StatelessWidget {
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final int monthsToComplete;
  final Color progressColor;

  const SavingGoalProgress({
    super.key,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthsToComplete,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final currentPercentage = (currentAmount / targetAmount * 100).toStringAsFixed(1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              goalName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
            RichText(
              text: TextSpan(
                text: '¥${targetAmount.toStringAsFixed(0)} ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
                children: [
                  TextSpan(
                    text: '($currentPercentage% → 100%)',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            // 背景条
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 当前进度
            FractionallySizedBox(
              widthFactor: currentAmount / targetAmount,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // 预测进度（半透明）
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '当前: ¥${currentAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '预计达成: ${monthsToComplete}个月后',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 财务建议卡片
class FinancialAdviceCard extends StatelessWidget {
  final String title;
  final String description;
  final Color cardColor;
  final IconData icon;

  const FinancialAdviceCard({
    super.key,
    required this.title,
    required this.description,
    required this.cardColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: cardColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
