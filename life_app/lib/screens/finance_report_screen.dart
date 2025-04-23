import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../themes/app_theme.dart';
import 'monthly_report_screen.dart';
import 'trend_analysis_screen.dart';
import 'forecast_planning_screen.dart';

/// 财务报告主页面 - 包含三个标签页：月度报告、趋势分析和预测规划
class FinanceReportScreen extends StatefulWidget {
  const FinanceReportScreen({super.key});

  @override
  State<FinanceReportScreen> createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // 默认选中趋势分析
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MonthlyReportScreen(),
                TrendAnalysisScreen(),
                ForecastPlanningScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建页面顶部渐变背景标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8b5cf6), Color(0xFF6366f1)], // 紫色渐变背景
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    '趋势分析',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 40), // 平衡布局
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '查看长期财务变化趋势',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '2024年4月 - 2025年3月',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建标签栏
  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF8b5cf6),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: '月度报告'),
            Tab(text: '趋势分析'),
            Tab(text: '预测规划'),
          ],
        ),
      ),
    );
  }
}
