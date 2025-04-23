import 'package:flutter/material.dart';
import '../../themes/budget_theme.dart';
import '../common/progress_bar.dart';
import '../common/month_picker_modal.dart';
import 'package:intl/intl.dart';
import '../../services/budget_service.dart';
import '../../models/monthly_budget.dart';

class BudgetHeader extends StatefulWidget {
  final Function(DateTime)? onMonthSelected;
  final DateTime? selectedDate;
  
  const BudgetHeader({
    Key? key,
    this.onMonthSelected,
    this.selectedDate,
  }) : super(key: key);
  
  @override
  State<BudgetHeader> createState() => _BudgetHeaderState();
}

class _BudgetHeaderState extends State<BudgetHeader> {
  late DateTime _currentDate;
  late List<DateTime> recentMonths;
  final BudgetService _budgetService = BudgetService();
  
  double _totalBudget = 0;
  double _totalSpent = 0;
  double _remainingAmount = 0;
  double _usagePercent = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _currentDate = widget.selectedDate ?? DateTime.now();
    
    // 初始化最近3个月的记录
    final now = DateTime.now();
    recentMonths = [];
    for (int i = 1; i <= 3; i++) {
      recentMonths.add(DateTime(now.year, now.month - i));
    }
    
    // 加载预算数据
    _loadBudgetData();
  }
  
  @override
  void didUpdateWidget(BudgetHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 当选择的日期变化时重新加载数据
    if (oldWidget.selectedDate != widget.selectedDate && widget.selectedDate != null) {
      setState(() {
        _currentDate = widget.selectedDate!;
      });
      _loadBudgetData();
    }
  }
  
  // 加载预算数据
  Future<void> _loadBudgetData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _budgetService.getMonthlyBudget(
        year: _currentDate.year,
        month: _currentDate.month,
        context: context
      );
      
      setState(() {
        _totalBudget = data.totalBudget;
        _totalSpent = data.totalSpent;
        _remainingAmount = data.remainingAmount;
        _usagePercent = data.usagePercent;
        _isLoading = false;
      });
    } catch (e) {
      print('加载预算数据失败: $e');
      setState(() {
        _isLoading = false;
        // 发生错误时设置默认值
        _totalBudget = 0;
        _totalSpent = 0;
        _remainingAmount = 0;
        _usagePercent = 0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('加载预算数据失败，请稍后重试')),
      );
    }
  }
  
  // 显示月份选择器
  void _showMonthPicker() async {
    final result = await MonthPickerModal.show(
      context: context,
      initialDate: _currentDate,
      recentMonths: recentMonths,
    );
    
    if (result != null) {
      setState(() {
        _currentDate = result;
      });
      
      // 更新最近记录
      if (!recentMonths.any((date) => 
        date.year == result.year && date.month == result.month
      )) {
        setState(() {
          recentMonths.insert(0, result);
          if (recentMonths.length > 5) {
            recentMonths.removeLast();
          }
        });
      }
      
      // 通知父组件月份已变更
      if (widget.onMonthSelected != null) {
        widget.onMonthSelected!(result);
      }
      
      // 重新加载新月份的数据
      _loadBudgetData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF97316),  // 橙色
            Color(0xFFF59E0B),  // 浅橙色
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 月度预算概览
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // 预算标题和编辑按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () => Navigator.of(context).pop(),
                                    padding: EdgeInsets.all(4),
                                    constraints: BoxConstraints(),
                                    iconSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_currentDate.month}月预算',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            // 移除编辑按钮
                          ],
                        ),

                        // 预算金额
                        const SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '¥${_totalBudget.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 预算周期 (可点击)
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _showMonthPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getDateRangeText(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 预算进度
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '已用 ¥${_totalSpent.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_usagePercent}%',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: ProgressBar(
                                progress: _usagePercent,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                fillColor: Colors.white,
                                height: 5,
                                borderRadius: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getDateRangeText() {
    final formatter = DateFormat('M月d日', 'zh_CN');
    
    // 计算当前月份的起始日期和结束日期
    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    
    return '${formatter.format(firstDay)} - ${formatter.format(lastDay)}';
  }
} 