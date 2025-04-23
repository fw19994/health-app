import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../themes/app_theme.dart';
import '../widgets/budget/savings_goal_card.dart';
import '../widgets/budget/savings_goal_modal.dart';
import '../widgets/budget/budget_tips.dart';
import '../models/savings_goal.dart';
import '../data/dummy_savings_goals.dart';
import '../widgets/common/month_picker_modal.dart';
import '../services/budget_service.dart';
import '../services/icon_service.dart';
import '../models/icon.dart';
import 'package:intl/intl.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final BudgetService _budgetService = BudgetService();
  final IconService _iconService = IconService();
  
  // 储蓄目标列表
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<SavingsGoal> _completedGoals = [];
  bool _isLoadingCompleted = false;
  String _completedErrorMessage = '';

  @override
  void initState() {
    super.initState();
    
    // 加载储蓄目标数据
    _loadSavingsGoals();
    _loadCompletedGoals();
  }

  // 加载储蓄目标数据
  Future<void> _loadSavingsGoals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // 获取储蓄目标数据，只加载进行中的目标
      final goals = await _budgetService.getSavingsGoals(status: 'in_progress', context: context);
      
      // 为每个目标加载真实图标
      for (var goal in goals) {
        await goal.loadRealIcon(context: context);
      }
      
      if (mounted) {
        setState(() {
          _savingsGoals = goals;
          _isLoading = false;
        });
      }
      print('成功加载储蓄目标: ${goals.length}个');
    } catch (e) {
      print('加载储蓄目标失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '加载储蓄目标失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  // 加载已完成的储蓄目标
  Future<void> _loadCompletedGoals() async {
    setState(() {
      _isLoadingCompleted = true;
      _completedErrorMessage = '';
    });
    
    try {
      // 获取已完成的储蓄目标数据
      final goals = await _budgetService.getSavingsGoals(status: 'completed', context: context);
      
      // 为每个已完成目标加载真实图标
      for (var goal in goals) {
        await goal.loadRealIcon(context: context);
      }
      
      if (mounted) {
        setState(() {
          _completedGoals = goals;
          _isLoadingCompleted = false;
        });
      }
      print('成功加载已完成目标: ${goals.length}个');
    } catch (e) {
      print('加载已完成目标失败: $e');
      if (mounted) {
        setState(() {
          _completedErrorMessage = '加载已完成目标失败: $e';
          _isLoadingCompleted = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSavingsGoals(),
                  const SizedBox(height: 16),
                  _buildCompletedGoals(),
                  const SizedBox(height: 16),
                  _buildSavingsTips(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSavingsGoalModal(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),  // 蓝色
            Color(0xFF60A5FA),  // 浅蓝色
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              const SizedBox(width: 8),
              const Text(
                '储蓄目标设置',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSavingsSummary(),
        ],
      ),
    );
  }

  Widget _buildSavingsSummary() {
    // 计算总目标金额和当前总金额（进行中的目标）
    double totalTargetInProgress = 0;
    double totalCurrentInProgress = 0;
    
    for (var goal in _savingsGoals) {
      totalTargetInProgress += goal.targetAmount;
      totalCurrentInProgress += goal.currentAmount;
    }
    
    // 计算已完成目标的总金额
    double totalCompletedAmount = 0;
    for (var goal in _completedGoals) {
      totalCompletedAmount += goal.targetAmount;
    }
    
    // 计算所有目标的总金额（进行中 + 已完成）
    double totalAllTargets = totalTargetInProgress + totalCompletedAmount;
    
    // 计算进行中目标的进度百分比
    double inProgressProgress = totalTargetInProgress > 0 ? totalCurrentInProgress / totalTargetInProgress : 0;
    int inProgressPercent = (inProgressProgress * 100).round();
    
    // 计算整体完成率（已存金额 + 已完成目标金额）/ 总目标金额
    double overallCompletion = totalAllTargets > 0 
        ? (totalCurrentInProgress + totalCompletedAmount) / totalAllTargets 
        : 0;
    int overallCompletionPercent = (overallCompletion * 100).round();
    
    // 计算目标完成数量比例
    int totalGoalsCount = _savingsGoals.length + _completedGoals.length;
    double goalsCompletionRate = totalGoalsCount > 0 
        ? _completedGoals.length / totalGoalsCount 
        : 0;
    int goalsCompletionPercent = (goalsCompletionRate * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '总储蓄进度',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                '$overallCompletionPercent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: overallCompletion,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '已储蓄/已完成',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '¥${(totalCurrentInProgress + totalCompletedAmount).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '总目标',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '¥${totalAllTargets.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                '进行中目标进度', 
                '$inProgressPercent%',
                '${_savingsGoals.length}个目标'
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                '目标完成率', 
                '$goalsCompletionPercent%',
                '已完成${_completedGoals.length}个目标'
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建统计卡片
  Widget _buildStatCard(String title, String value, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 储蓄目标区域
  Widget _buildSavingsGoals() {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '进行中目标',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 加载状态
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          // 错误状态
          else if (_errorMessage.isNotEmpty && _savingsGoals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSavingsGoals,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          // 数据为空
          else if (_savingsGoals.isEmpty) 
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '没有储蓄目标',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '点击右下角的"+"按钮创建您的第一个储蓄目标',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          // 储蓄目标列表
          else
            ...List.generate(
              _savingsGoals.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index < _savingsGoals.length - 1 ? 12 : 0),
                child: GestureDetector(
                  onTap: () => _showSavingsGoalModal(context, _savingsGoals[index]),
                  child: SavingsGoalCard(
                    goal: _savingsGoals[index],
                    onEdit: () => _showSavingsGoalModal(context, _savingsGoals[index]),
                    onMarkAsCompleted: () => _markGoalAsCompleted(_savingsGoals[index]),
                    onMarkAsDeleted: () => _markGoalAsDeleted(_savingsGoals[index]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 已完成目标区域
  Widget _buildCompletedGoals() {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '已完成目标',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '这些是您已经成功实现的储蓄目标',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          // 加载状态
          if (_isLoadingCompleted)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          // 错误状态
          else if (_completedErrorMessage.isNotEmpty && _completedGoals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _completedErrorMessage,
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadCompletedGoals,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            )
          // 数据为空
          else if (_completedGoals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '暂无已完成的目标',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '当您完成储蓄目标时，将会显示在这里',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          // 已完成目标列表
          else
            ...List.generate(
              _completedGoals.length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index < _completedGoals.length - 1 ? 12 : 0),
                child: _buildCompletedGoalCard(
                  context,
                  _completedGoals[index],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 已完成目标卡片 - 使用真实数据
  Widget _buildCompletedGoalCard(BuildContext context, SavingsGoal goal) {
    // 格式化完成日期
    String completedDate;
    if (goal.completedAt != null) {
      completedDate = "${goal.completedAt!.year}年${goal.completedAt!.month}月${goal.completedAt!.day}日";
    } else {
      // 如果没有完成日期，回退到目标日期
      completedDate = "${goal.targetDate.year}年${goal.targetDate.month}月";
    }
    
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: goal.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    goal.icon,
                    color: goal.color,
                    size: 22,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 文本信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (goal.note != null && goal.note!.isNotEmpty)
                    Text(
                      goal.note!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '完成于 $completedDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '¥${goal.targetAmount.toStringAsFixed(0)} → ¥${goal.currentAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                color: Colors.amber[700],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 储蓄提示区域
  Widget _buildSavingsTips() {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(
                FontAwesomeIcons.lightbulb,
                size: 16,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 8),
              const Text(
                '储蓄小贴士',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            '50/30/20法则',
            '将收入的50%用于必需品，30%用于个人需求，20%用于储蓄和投资。',
            Colors.blue[100]!,
            Colors.blue[700]!,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            '自动化储蓄',
            '设置自动转账，每月将一定金额转入储蓄账户，养成储蓄习惯。',
            Colors.green[100]!,
            Colors.green[700]!,
          ),
          const SizedBox(height: 12),
          _buildTipCard(
            '紧急备用金',
            '建立相当于3-6个月生活费用的紧急备用金，应对突发情况。',
            Colors.orange[100]!,
            Colors.orange[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String content, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showSavingsGoalModal(BuildContext context, [SavingsGoal? goal]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SavingsGoalModal(goal: goal),
    );
    
    // 模态框关闭后重新加载数据
    _loadSavingsGoals();
  }

  // 标记目标为已完成
  void _markGoalAsCompleted(SavingsGoal goal) async {
    try {
      // 显示确认对话框
      final confirm = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
              elevation: 8,
            ),
          ),
          child: Dialog(
            backgroundColor: Colors.white,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '确认完成',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '确定要将此储蓄目标标记为已完成吗？',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('确认'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
      
      if (confirm != true) return;
      
      // 调用服务更新目标状态
      await _budgetService.updateSavingsGoalStatus(goal.id, 'completed', context: context);
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已成功标记为完成'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // 重新加载数据 - 同时更新进行中和已完成的目标列表
      _loadSavingsGoals();
      _loadCompletedGoals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // 标记目标为已作废
  void _markGoalAsDeleted(SavingsGoal goal) async {
    try {
      // 显示确认对话框
      final confirm = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
              elevation: 8,
            ),
          ),
          child: Dialog(
            backgroundColor: Colors.white,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '确认作废',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '确定要将此储蓄目标作废吗？此操作不可撤销。',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('作废'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
      
      if (confirm != true) return;
      
      // 调用服务更新目标状态
      await _budgetService.updateSavingsGoalStatus(goal.id, 'deleted', context: context);
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('目标已作废'),
            backgroundColor: Colors.grey,
          ),
        );
      }
      
      // 重新加载数据 - 同时更新进行中和已完成的目标列表
      _loadSavingsGoals();
      _loadCompletedGoals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 