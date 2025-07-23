import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/routes.dart';
import '../../../themes/app_theme.dart';
import '../../../services/plan_service.dart';
import 'widgets/ai_summary_section.dart';
import 'widgets/completion_stats_section.dart';
import 'widgets/trend_analysis_section.dart';
import 'widgets/improvement_suggestions_section.dart';
import 'widgets/habit_analysis_section.dart';

class PlanAnalysisScreen extends StatefulWidget {
  const PlanAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<PlanAnalysisScreen> createState() => _PlanAnalysisScreenState();
}

class _PlanAnalysisScreenState extends State<PlanAnalysisScreen> {
  // 时间周期类型
  final List<String> _timePeriods = ['周', '月', '季度', '年'];
  int _selectedPeriodIndex = 1; // 默认选择"月"
  
  // 当前分析的日期
  DateTime _analysisDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366f1),
            Color(0xFF4f46e5),
          ],
        ),
      ),
      child: Column(
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              const Text(
                'AI计划分析',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // 占位元素，保持标题居中
              const SizedBox(width: 24),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 时间段选择器
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(_timePeriods.length, (index) {
                final isSelected = index == _selectedPeriodIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPeriodIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ] : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _timePeriods[index],
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF4f46e5) : Colors.white,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 日期导航
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '分析周期',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedPeriod(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildNavigationButton(
                    icon: Icons.chevron_left,
                    onTap: _navigateToPreviousPeriod,
                  ),
                  const SizedBox(width: 8),
                  _buildNavigationButton(
                    icon: Icons.chevron_right,
                    onTap: _navigateToNextPeriod,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建导航按钮
  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
  
  // 导航到上一个周期
  void _navigateToPreviousPeriod() {
    setState(() {
      switch (_timePeriods[_selectedPeriodIndex]) {
        case '周':
          _analysisDate = _analysisDate.subtract(const Duration(days: 7));
          break;
        case '月':
          _analysisDate = DateTime(
            _analysisDate.year,
            _analysisDate.month - 1,
            1,
          );
          break;
        case '季度':
          _analysisDate = DateTime(
            _analysisDate.year,
            _analysisDate.month - 3,
            1,
          );
          break;
        case '年':
          _analysisDate = DateTime(
            _analysisDate.year - 1,
            1,
            1,
          );
          break;
      }
    });
  }
  
  // 导航到下一个周期
  void _navigateToNextPeriod() {
    setState(() {
      switch (_timePeriods[_selectedPeriodIndex]) {
        case '周':
          _analysisDate = _analysisDate.add(const Duration(days: 7));
          break;
        case '月':
          _analysisDate = DateTime(
            _analysisDate.year,
            _analysisDate.month + 1,
            1,
          );
          break;
        case '季度':
          _analysisDate = DateTime(
            _analysisDate.year,
            _analysisDate.month + 3,
            1,
          );
          break;
        case '年':
          _analysisDate = DateTime(
            _analysisDate.year + 1,
            1,
            1,
          );
          break;
      }
    });
  }
  
  // 获取格式化后的周期文本
  String _getFormattedPeriod() {
    switch (_timePeriods[_selectedPeriodIndex]) {
      case '周':
        // 获取本周的起止日期
        final startOfWeek = _analysisDate.subtract(Duration(days: _analysisDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${DateFormat('MM/dd').format(startOfWeek)}-${DateFormat('MM/dd').format(endOfWeek)}';
      case '月':
        return DateFormat('yyyy年MM月').format(_analysisDate);
      case '季度':
        final quarter = ((_analysisDate.month - 1) ~/ 3) + 1;
        return '${_analysisDate.year}年第$quarter季度';
      case '年':
        return '${_analysisDate.year}年';
      default:
        return '';
    }
  }
  
  // 构建内容区域
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // AI总结
          AISummarySection(date: _analysisDate, periodType: _timePeriods[_selectedPeriodIndex]),
          
          const SizedBox(height: 16),
          
          // 完成情况统计
          CompletionStatsSection(date: _analysisDate, periodType: _timePeriods[_selectedPeriodIndex]),
          
          const SizedBox(height: 16),
          
          // 趋势分析
          TrendAnalysisSection(date: _analysisDate, periodType: _timePeriods[_selectedPeriodIndex]),
          
          const SizedBox(height: 16),
          
          // 改进建议
          ImprovementSuggestionsSection(date: _analysisDate, periodType: _timePeriods[_selectedPeriodIndex]),
          
          const SizedBox(height: 16),
          
          // 习惯分析
          HabitAnalysisSection(date: _analysisDate, periodType: _timePeriods[_selectedPeriodIndex]),
          
          const SizedBox(height: 16),
          
          // 分享报告按钮
          _buildShareButton(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  // 构建分享按钮
  Widget _buildShareButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: 实现分享功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('分享功能开发中')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4f46e5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.share, size: 20),
          SizedBox(width: 8),
          Text(
            '分享月度报告',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 