import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/family_member_model.dart';
import '../../../models/monthly_budget.dart';
import '../../../themes/app_theme.dart';
import '../../family_members_screen.dart';

class FamilyFinanceHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final List<FamilyMember> familyMembers;
  final bool isLoadingMembers;
  final MonthlyBudget? monthlyBudget;
  final Function(DateTime) onMonthSelected;
  final VoidCallback onBack;

  const FamilyFinanceHeader({
    Key? key,
    required this.selectedMonth,
    required this.familyMembers,
    required this.isLoadingMembers,
    required this.monthlyBudget,
    required this.onMonthSelected,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // 格式化月份显示
    final monthFormat = DateFormat('MM月', 'zh_CN');
    final currentMonth = monthFormat.format(selectedMonth);
    
    // 使用月度预算数据
    double totalExpense = monthlyBudget?.totalSpent ?? 0.0;
    double budget = monthlyBudget?.totalBudget ?? 0.0;
    double remaining = monthlyBudget?.remainingAmount ?? 0.0;
    double usagePercent = monthlyBudget?.usagePercent ?? 0.0;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 5, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF059669),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题、返回按钮和成员列表放在同一行
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                '家庭财务',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isLoadingMembers)
                      Container(
                        width: 36,
                        height: 36,
                        padding: const EdgeInsets.all(4),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      for (var member in familyMembers)
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: member.avatarUrl.isNotEmpty 
                                ? NetworkImage(member.avatarUrl) 
                                : null,
                              child: member.avatarUrl.isEmpty
                                ? Text(
                                    member.name.isNotEmpty ? member.name[0] : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                              backgroundColor: member.avatarUrl.isEmpty 
                                ? Colors.blueGrey 
                                : null,
                            ),
                          ),
                        ),
                    // 添加成员按钮
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FamilyMembersScreen()),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '共同管理家庭收支',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          
          // 月度摘要
          Container(
            padding: const EdgeInsets.all(12),
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
                      '月家庭总开销',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showMonthPicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currentMonth,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                monthlyBudget == null
                  ? const SizedBox(
                      height: 24, 
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      )
                    )
                  : Row(
                      children: [
                        const SizedBox(width: 30),
                        
                        // 左侧：总开销
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '总开销',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${monthlyBudget?.totalSpent ?? 0}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 中间分隔线
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          height: 40,
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        
                        // 右侧：总预算
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '总预算',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${monthlyBudget?.totalBudget ?? 0}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 30),
                      ],
                    ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已用预算: ${monthlyBudget?.usagePercent ?? 0}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '剩余: ¥${monthlyBudget?.remainingAmount ?? 0}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // 进度条
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: usagePercent / 100,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
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

  // 显示月份选择器
  void _showMonthPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (picked != null && picked != selectedMonth) {
      onMonthSelected(picked);
    }
  }
} 