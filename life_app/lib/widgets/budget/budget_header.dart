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
  final bool isFamilyBudget;
  final int? familyId;
  
  const BudgetHeader({
    Key? key,
    this.onMonthSelected,
    this.selectedDate,
    this.isFamilyBudget = false,
    this.familyId,
  }) : super(key: key);
  
  @override
  State<BudgetHeader> createState() => BudgetHeaderState();
}

class BudgetHeaderState extends State<BudgetHeader> {
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
  
  // 公开刷新数据的方法
  void refreshData() {
    _loadBudgetData();
  }
  
  // 加载预算数据
  Future<void> _loadBudgetData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _budgetService.getMonthlyBudget(
        year: _currentDate.year,
        month: _currentDate.month,
        context: context,
        isFamilyBudget: widget.isFamilyBudget,
        familyId: widget.familyId,
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Column(
          children: [
              // 顶部导航栏和月份选择器
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                  // 返回按钮和标题
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
                          fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                        ),

                  // 预算周期选择器
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
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 预算金额和进度条
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // 金额和百分比
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 预算金额
                            Row(
                              children: [
                                const Text(
                                  '预算: ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '¥${_totalBudget.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            // 已用百分比
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                '已用 ${_usagePercent}%',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        
                        const SizedBox(height: 8),
                        
                        // 进度条
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: ProgressBar(
                                progress: _usagePercent,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                fillColor: Colors.white,
                            height: 4,
                                borderRadius: 4,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // 已用和剩余金额
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '已用: ¥${_totalSpent.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '剩余: ¥${_remainingAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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