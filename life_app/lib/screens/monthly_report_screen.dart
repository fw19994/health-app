import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../themes/app_theme.dart';

/// 月度报告屏幕 - 展示当月财务状况的详细报告
class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  // 当前选择的月份 - 默认为当前月份
  final DateTime _selectedMonth = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthlyOverview(),
            const SizedBox(height: 16),
            _buildExpenseCategories(),
            const SizedBox(height: 16),
            _buildSixMonthTrend(),
            const SizedBox(height: 16),
            _buildFinancialHealthScore(),
            const SizedBox(height: 24),
            _buildReportActions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 本月财务概览
  Widget _buildMonthlyOverview() {
    return _buildCard(
      title: '本月财务概览',
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildOverviewItem(
                title: '总收入',
                amount: '¥9,580.00',
                change: '+5.2%',
                isIncrease: true,
                bgColor: Colors.blue.shade50,
                textColor: Colors.blue.shade600,
              ),
              _buildOverviewItem(
                title: '总支出',
                amount: '¥4,334.25',
                change: '+8.7%',
                isIncrease: true,
                isNegative: true,
                bgColor: Colors.red.shade50,
                textColor: Colors.red.shade600,
              ),
              _buildOverviewItem(
                title: '储蓄金额',
                amount: '¥5,245.75',
                change: '+12.5%',
                isIncrease: true,
                bgColor: Colors.green.shade50,
                textColor: Colors.green.shade600,
              ),
              _buildOverviewItem(
                title: '预算使用',
                amount: '65%',
                change: '-3.8%',
                isIncrease: false,
                bgColor: Colors.amber.shade50,
                textColor: Colors.amber.shade600,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  FontAwesomeIcons.lightbulb,
                  color: Colors.purple.shade500,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '您的收入增长率高于支出增长率，财务状况正在改善。建议继续保持，可以考虑增加高收益储蓄。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 概览项目
  Widget _buildOverviewItem({
    required String title,
    required String amount,
    required String change,
    required bool isIncrease,
    bool isNegative = false,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Row(
            children: [
              Icon(
                isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isNegative && isIncrease ? Colors.red.shade600 : Colors.green.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '较上月 $change',
                style: TextStyle(
                  fontSize: 10,
                  color: isNegative && isIncrease ? Colors.red.shade600 : Colors.green.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 支出分类分析
  Widget _buildExpenseCategories() {
    return _buildCard(
      title: '支出分类分析',
      actionText: '查看详情',
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: _buildDonutChart(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryItem('住房', 33, Colors.red),
                      const SizedBox(height: 8),
                      _buildCategoryItem('餐饮', 21, Colors.blue),
                      const SizedBox(height: 8),
                      _buildCategoryItem('交通', 16, Colors.green),
                      const SizedBox(height: 8),
                      _buildCategoryItem('娱乐', 12, Colors.amber),
                      const SizedBox(height: 8),
                      _buildCategoryItem('其他', 18, Colors.purple),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.chartPie,
                    color: Colors.blue.shade700,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '支出洞察',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '住房支出占比最高，可以考虑优化其他类别支出，如减少餐饮外卖频率。',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 环形图
  Widget _buildDonutChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: DonutChartPainter(
              sections: [
                PieSection(value: 33, color: Colors.red),
                PieSection(value: 21, color: Colors.blue),
                PieSection(value: 16, color: Colors.green),
                PieSection(value: 12, color: Colors.amber),
                PieSection(value: 18, color: Colors.purple),
              ],
            ),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '总支出',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '¥4,334',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 类别项
  Widget _buildCategoryItem(String name, int percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 近六个月趋势
  Widget _buildSixMonthTrend() {
    return _buildCard(
      title: '近六个月趋势',
      actionText: '查看详情',
      child: Column(
        children: [
          SizedBox(
            height: 250, // 增加容器高度
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth = (availableWidth - 20) / 6; // 20是总边距
                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20), // 增加底部padding
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBarItem('10月', 3800, 3100, itemWidth * 0.5),
                      _buildBarItem('11月', 4100, 3400, itemWidth * 0.5),
                      _buildBarItem('12月', 3900, 3600, itemWidth * 0.5),
                      _buildBarItem('1月', 4300, 3500, itemWidth * 0.5),
                      _buildBarItem('2月', 4800, 3900, itemWidth * 0.5),
                      _buildBarItem('3月', 5200, 4300, itemWidth * 0.5),
                    ],
                  ),
                );
              }
            ),
          ),
          _buildLegend(), // 添加图例
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '收入',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '支出',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 柱状图项
  Widget _buildBarItem(String month, double income, double expense, double width) {
    final maxValue = 6000.0;
    final incomeHeight = (income / maxValue) * 120; // 减小最大高度
    final expenseHeight = (expense / maxValue) * 120; // 减小最大高度
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: width,
          height: incomeHeight,
          decoration: BoxDecoration(
            color: Colors.blue.shade300,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: width,
          height: expenseHeight,
          decoration: BoxDecoration(
            color: Colors.red.shade300,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8), // 增加月份文本和柱状图之间的距离
        Text(
          month,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // 财务健康评分
  Widget _buildFinancialHealthScore() {
    return _buildCard(
      title: '财务健康评分',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: ProgressRingPainter(
                      progress: 0.82,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      progressColor: Colors.green,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      '82',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '优秀',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildScoreItem('收入稳定性', 90, Colors.green),
                const SizedBox(height: 12),
                _buildScoreItem('支出控制', 75, Colors.green),
                const SizedBox(height: 12),
                _buildScoreItem('储蓄率', 85, Colors.green),
                const SizedBox(height: 12),
                _buildScoreItem('债务水平', 95, Colors.green),
                const SizedBox(height: 12),
                _buildScoreItem('投资多样性', 65, Colors.amber),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.award,
                    color: Colors.green.shade700,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '财务建议',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '您的财务状况总体良好，建议增加投资多样性，分散风险，可以考虑配置一些指数基金或ETF产品。',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 评分项
  Widget _buildScoreItem(String title, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              '$score分',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              height: 6,
              width: MediaQuery.of(context).size.width * 0.8 * (score / 100),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 报告操作按钮
  Widget _buildReportActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('导出报告'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.purple,
              side: const BorderSide(color: Colors.purple),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              // TODO: 导出报告功能
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('分享'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              // TODO: 分享功能
            },
          ),
        ),
      ],
    );
  }

  // 通用卡片构建器
  Widget _buildCard({
    required String title,
    String? actionText,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                if (actionText != null)
                  Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }

  // 添加图例
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '收入',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '支出',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 环形图绘制器
class DonutChartPainter extends CustomPainter {
  final List<PieSection> sections;
  
  DonutChartPainter({required this.sections});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // 计算总值
    final total = sections.fold(0.0, (sum, section) => sum + section.value);
    
    // 起始角度 (-90度)
    double startAngle = -90 * (3.14159265359 / 180);
    
    for (var section in sections) {
      // 计算扇形角度
      final sweepAngle = (section.value / total) * 2 * 3.14159265359;
      
      // 绘制扇形
      final paint = Paint()
        ..color = section.color
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      
      // 更新起始角度
      startAngle += sweepAngle;
    }
    
    // 绘制中心空白区域 (环形效果)
    final innerRadius = radius * 0.6;
    
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 环形进度绘制器
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  
  ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // 绘制背景圆环
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 绘制进度圆环
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // 起始角度 (-90度)
    const startAngle = -90 * (3.14159265359 / 180);
    // 扫过的角度
    final sweepAngle = progress * 2 * 3.14159265359;
    
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 饼图扇区数据
class PieSection {
  final double value;
  final Color color;
  
  PieSection({required this.value, required this.color});
}
