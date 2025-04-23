import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../themes/app_theme.dart';
import '../widgets/forecast_widgets.dart';

/// 预测规划屏幕 - 提供财务预测和规划功能
class ForecastPlanningScreen extends StatefulWidget {
  const ForecastPlanningScreen({super.key});

  @override
  State<ForecastPlanningScreen> createState() => _ForecastPlanningScreenState();
}

class _ForecastPlanningScreenState extends State<ForecastPlanningScreen> {
  // 预测周期，默认为6个月
  int _forecastPeriod = 6;
  
  // 当前选中的预测场景
  int _selectedScenario = 0; // 0: 基本场景, 1: 乐观场景, 2: 保守场景
  
  // 场景名称
  final List<String> _scenarioNames = ['基本场景', '乐观场景', '保守场景'];
  
  // 场景描述
  final List<String> _scenarioDescriptions = [
    '基于您过去12个月的财务数据，结合当前经济环境和个人收支模式预测。收入年增长率+8%，支出年增长率+10%。',
    '假设您获得额外收入来源或现有收入增加。收入年增长率+15%，支出年增长率+5%。',
    '假设经济下行或收入减少的情况。收入年增长率+3%，支出年增长率+7%。'
  ];
  
  // 场景图标
  final List<IconData> _scenarioIcons = [
    FontAwesomeIcons.chartLine,
    FontAwesomeIcons.arrowUp,
    FontAwesomeIcons.arrowDown,
  ];
  
  // 支出类别变化数据
  final List<Map<String, dynamic>> _expenseCategoryChanges = [
    {
      'category': '住房',
      'previousAmount': 2500.0,
      'predictedAmount': 2650.0,
      'change': '+6%',
      'isIncreasing': true,
    },
    {
      'category': '餐饮',
      'previousAmount': 1200.0,
      'predictedAmount': 1150.0,
      'change': '-4%',
      'isIncreasing': false,
    },
    {
      'category': '交通',
      'previousAmount': 800.0,
      'predictedAmount': 880.0,
      'change': '+10%',
      'isIncreasing': true,
    },
    {
      'category': '娱乐',
      'previousAmount': 600.0,
      'predictedAmount': 650.0,
      'change': '+8%',
      'isIncreasing': true,
    },
  ];
  
  // 财务建议数据
  final List<Map<String, dynamic>> _financialAdvice = [
    {
      'icon': FontAwesomeIcons.piggyBank,
      'title': '增加应急基金',
      'description': '根据预测，建议您增加应急基金至¥30,000，以应对可能的收入波动。',
      'color': Colors.purple,
    },
    {
      'icon': FontAwesomeIcons.houseChimney,
      'title': '优化住房支出',
      'description': '住房支出占比过高且仍在增长。考虑重新协商房租或评估更经济的住房选择。',
      'color': Colors.orange,
    },
    {
      'icon': FontAwesomeIcons.moneyBillTransfer,
      'title': '增加投资比例',
      'description': '预计未来6个月您将有更多盈余资金，建议增加每月定投金额。',
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScenarioSelector(),
                  const SizedBox(height: 20),
                  _buildIncomeSection(),
                  const SizedBox(height: 20),
                  _buildExpenseSection(),
                  const SizedBox(height: 20),
                  _buildSavingsSection(),
                  const SizedBox(height: 20),
                  _buildAdviceSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建场景选择器
  Widget _buildScenarioSelector() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '预测场景',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: List.generate(
                  _scenarioNames.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedScenario = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedScenario == index
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _selectedScenario == index
                              ? [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 1),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          _scenarioNames[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedScenario == index
                                ? Colors.indigo.shade600
                                : Colors.grey.shade700,
                            fontWeight: _selectedScenario == index
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _scenarioIcons[_selectedScenario],
                      color: Colors.indigo.shade600,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_scenarioNames[_selectedScenario]}假设',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _scenarioDescriptions[_selectedScenario],
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
            ),
          ],
        ),
      ),
    );
  }

  // 构建收入预测部分
  Widget _buildIncomeSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '收入预测',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '调整参数',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ForecastBarChart(
              isIncome: true,
              mainColor: Colors.indigo.shade400,
              height: 220,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      FontAwesomeIcons.arrowTrendUp,
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
                          '预测收入增加',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '根据${_scenarioNames[_selectedScenario]}，您未来6个月的平均月收入预计将增加8.4%，达到¥10,370。',
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
            ),
          ],
        ),
      ),
    );
  }

  // 构建支出预测部分
  Widget _buildExpenseSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '支出预测',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '调整参数',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ForecastBarChart(
              isIncome: false,
              mainColor: Colors.orange.shade400,
              height: 220,
            ),
            const SizedBox(height: 24),
            const Text(
              '支出类别变化',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _expenseCategoryChanges.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildExpenseCategoryItem(_expenseCategoryChanges[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建支出类别条目
  Widget _buildExpenseCategoryItem(Map<String, dynamic> data) {
    final Color changeColor = data['isIncreasing'] ? Colors.red : Colors.green;
    
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            data['category'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '¥${data['previousAmount'].toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '¥${data['predictedAmount'].toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                data['change'],
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                data['isIncreasing']
                    ? FontAwesomeIcons.arrowTrendUp
                    : FontAwesomeIcons.arrowTrendDown,
                color: changeColor,
                size: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建储蓄预测部分
  Widget _buildSavingsSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '储蓄预测',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '累计预计储蓄',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¥36,520',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '未来6个月',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '月均储蓄能力',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.purple.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¥6,087',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.arrowTrendUp,
                              color: Colors.green.shade600,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+15.2%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
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
            const SizedBox(height: 24),
            const Text(
              '储蓄目标进度',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SavingGoalProgress(
              currentAmount: 72500,
              targetAmount: 100000,
              goalName: '购房首付',
              monthsToComplete: 21,
              progressColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  // 构建财务建议部分
  Widget _buildAdviceSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '财务规划建议',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _financialAdvice.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FinancialAdviceCard(
                  icon: _financialAdvice[index]['icon'],
                  title: _financialAdvice[index]['title'],
                  description: _financialAdvice[index]['description'],
                  cardColor: _financialAdvice[index]['color'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
