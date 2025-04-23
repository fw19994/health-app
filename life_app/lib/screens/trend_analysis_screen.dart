import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../themes/app_theme.dart';
import '../widgets/finance/finance_chart_widgets.dart';

/// 趋势分析屏幕 - 展示收入、支出和储蓄率的长期趋势
class TrendAnalysisScreen extends StatefulWidget {
  const TrendAnalysisScreen({super.key});

  @override
  State<TrendAnalysisScreen> createState() => _TrendAnalysisScreenState();
}

class _TrendAnalysisScreenState extends State<TrendAnalysisScreen> {
  // 月份数据 - 用于X轴标签
  final List<String> _months = ['4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月', '1月', '2月', '3月'];
  
  // 收入数据
  final List<double> _incomeData = [7850, 8100, 7950, 8250, 8400, 8650, 8850, 9050, 9200, 9350, 9450, 9580];
  
  // 支出数据
  final List<double> _expenseData = [3250, 3500, 3150, 3450, 3300, 3750, 3900, 3600, 3850, 3700, 3950, 4334];
  
  // 支出类别数据
  final List<CategoryTrend> _categoryTrends = [
    CategoryTrend(
      name: '住房', 
      color: Colors.red, 
      previousPercentage: 38, 
      currentPercentage: 40, 
      status: '稳定'
    ),
    CategoryTrend(
      name: '购物', 
      color: Colors.blue, 
      previousPercentage: 20, 
      currentPercentage: 25, 
      status: '+5%', 
      isIncreasing: true
    ),
    CategoryTrend(
      name: '餐饮', 
      color: Colors.green, 
      previousPercentage: 15, 
      currentPercentage: 12, 
      status: '-3%', 
      isIncreasing: false
    ),
  ];
  
  // 储蓄率数据
  final List<QuarterlySavings> _savingsRateData = [
    QuarterlySavings(quarter: 'Q2', period: '4-6月', year: 2024, percentage: 47.5),
    QuarterlySavings(quarter: 'Q3', period: '7-9月', year: 2024, percentage: 52.3),
    QuarterlySavings(quarter: 'Q4', period: '10-12月', year: 2024, percentage: 56.8),
    QuarterlySavings(quarter: 'Q1', period: '1-3月', year: 2025, percentage: 58.6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIncomeTrend(),
            const SizedBox(height: 16),
            _buildExpenseTrend(),
            const SizedBox(height: 16),
            _buildCategoryTrends(),
            const SizedBox(height: 16),
            _buildSavingsRateTrend(),
            const SizedBox(height: 16),
            _buildInsightSummary(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 收入趋势卡片
  Widget _buildIncomeTrend() {
    final currencyFormat = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 0,
    );
    
    return _buildCard(
      title: '收入趋势 (12个月)',
      actionText: '详细数据',
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LineChartWidget(
              data: _incomeData,
              labels: _months,
              color: Colors.green,
              showDots: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '2024年4月: ${currencyFormat.format(_incomeData.first)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '2025年3月: ${currencyFormat.format(_incomeData.last)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 年增长率
              Row(
                children: [
                  const Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '年增长: +22.0%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // 月平均
              Text(
                '月平均: ${currencyFormat.format(8640)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 支出趋势卡片
  Widget _buildExpenseTrend() {
    final currencyFormat = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 0,
    );
    
    return _buildCard(
      title: '支出趋势 (12个月)',
      actionText: '详细数据',
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LineChartWidget(
              data: _expenseData,
              labels: _months,
              color: Colors.red,
              showDots: true,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '2024年4月: ${currencyFormat.format(_expenseData.first)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '2025年3月: ${currencyFormat.format(_expenseData.last)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 年增长率
              Row(
                children: [
                  const Icon(
                    Icons.arrow_upward,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '年增长: +33.4%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // 月平均
              Text(
                '月平均: ${currencyFormat.format(3856)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 支出类别变化趋势卡片
  Widget _buildCategoryTrends() {
    return _buildCard(
      title: '支出类别变化趋势',
      child: Column(
        children: _categoryTrends.map((category) => _buildCategoryTrendItem(category)).toList(),
      ),
    );
  }

  // 单个支出类别趋势项
  Widget _buildCategoryTrendItem(CategoryTrend category) {
    Color statusColor = Colors.black;
    if (category.isIncreasing != null) {
      statusColor = category.isIncreasing! ? Colors.red : Colors.green;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                category.status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              // 灰色背景条
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // 当前百分比条
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width * (category.currentPercentage / 100) * 0.8,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // 上年同期百分比条
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width * (category.previousPercentage / 100) * 0.8,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '上年同期: ${category.previousPercentage}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '当前: ${category.currentPercentage}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 储蓄率变化趋势卡片
  Widget _buildSavingsRateTrend() {
    return _buildCard(
      title: '储蓄率变化',
      actionText: '详细数据',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '平均储蓄率 (过去12个月)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '54.8%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '年度变化',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_upward,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+6.2%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '储蓄率 = (收入 - 支出) / 收入 × 100%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ..._savingsRateData.map((data) => _buildQuarterlySavingsItem(data)).toList(),
        ],
      ),
    );
  }

  // 单个季度储蓄率项
  Widget _buildQuarterlySavingsItem(QuarterlySavings data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${data.year}年${data.quarter} (${data.period})',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              Text(
                '${data.percentage}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * (data.percentage / 100) * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade500,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 趋势分析洞察总结卡片
  Widget _buildInsightSummary() {
    return _buildCard(
      title: '趋势分析洞察',
      child: Column(
        children: [
          _buildAdviceItem(
            icon: FontAwesomeIcons.chartLine,
            title: '收入稳步增长',
            content: '过去一年您的收入增长了22.0%，这是个积极的趋势，高于通货膨胀率。',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildAdviceItem(
            icon: FontAwesomeIcons.triangleExclamation,
            title: '支出增速过快',
            content: '您的年度支出增长达33.4%，超过了收入增长。特别是购物类支出比例上升明显。',
            color: Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildAdviceItem(
            icon: FontAwesomeIcons.piggyBank,
            title: '储蓄率持续改善',
            content: '尽管支出增长较快，您的储蓄率仍然实现了从47.5%到58.6%的提升，这对长期财务健康非常有利。',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  // 单个洞察建议项
  Widget _buildAdviceItem({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: color,
                size: 16,
              ),
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
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
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
}

// 支出类别趋势数据模型
class CategoryTrend {
  final String name;
  final Color color;
  final double previousPercentage;
  final double currentPercentage;
  final String status;
  final bool? isIncreasing;

  CategoryTrend({
    required this.name,
    required this.color,
    required this.previousPercentage,
    required this.currentPercentage,
    required this.status,
    this.isIncreasing,
  });
}

// 季度储蓄数据模型
class QuarterlySavings {
  final String quarter;
  final String period;
  final int year;
  final double percentage;

  QuarterlySavings({
    required this.quarter,
    required this.period,
    required this.year,
    required this.percentage,
  });
}
