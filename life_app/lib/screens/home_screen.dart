import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'family_finance_screen.dart';
import 'expense_tracking_screen.dart';
import 'budget_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserService _userService;
  String _userName = '';
  String _avatarUrl = '';
  bool _isLoading = true;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userService = UserService(context: context);
    _loadUserData();
  }
  
  // 加载用户数据
  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // 首先尝试从AuthService获取已缓存的用户信息
    setState(() {
      _userName = authService.currentUser?.nickname ?? '';
      _avatarUrl = authService.currentUser?.avatar ?? '';
    });
    
    // 然后从服务器请求最新数据
    try {
      final response = await _userService.getUserProfile();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _userName = response.data['nickname'] ?? _userName;
          _avatarUrl = response.data['avatar'] ?? _avatarUrl;
          _isLoading = false;
        });
        
        if (kDebugMode) {
          print('首页加载到的用户名: $_userName');
          print('首页加载到的头像URL: $_avatarUrl');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('加载用户资料失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFinancialSummary(context),
                const SizedBox(height: 16),
                _buildHealthSummary(context),
                  const SizedBox(height: 16),
                  _buildTodayPlans(context),
                ],
              ),
            ),
          ],
      ),
    );
  }

  // 首页头部 - 蓝紫色渐变背景
  Widget _buildHeader(BuildContext context) {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // 获取当前日期和时间
    final now = DateTime.now();
    final hour = now.hour;
    
    // 根据时间显示不同的问候语
    String greeting;
    if (hour < 6) {
      greeting = '夜深了';
    } else if (hour < 9) {
      greeting = '早安';
    } else if (hour < 12) {
      greeting = '上午好';
    } else if (hour < 14) {
      greeting = '中午好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else if (hour < 22) {
      greeting = '晚上好';
    } else {
      greeting = '夜深了';
    }
    
    // 格式化日期
    final dateFormat = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN');
    final dateStr = dateFormat.format(now);
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 10, 16, 10),
      decoration: const BoxDecoration(
        gradient: AppTheme.homeGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40635BFF),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像和问候语在同一行
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 用户头像
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: _avatarUrl.isNotEmpty
                        ? Image.network(
                            _avatarUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                              ));
                            },
                            errorBuilder: (context, error, stackTrace) {
                              if (kDebugMode) {
                                print('首页头像加载错误: $error');
                              }
                              return Image.asset(
                                'assets/images/avatar_placeholder.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/avatar_placeholder.png',
                            fit: BoxFit.cover,
                          ),
                    ),
                  ),
                  // 皇冠徽章
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.workspace_premium,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 12),
              
              // 问候语和用户名
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting，${_userName.isNotEmpty ? _userName : '用户'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '今天有2个重要提醒，点击查看详情',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 整合天气信息和快捷操作到一行
          Row(
            children: [
              // 天气信息 - 占据左侧60%
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny,
                          color: Colors.amber,
                        size: 24,
                        ),
                      const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '北京市 21°C',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              fontSize: 14,
                              ),
                            ),
                            Text(
                            dateStr,
                              style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ),
          ),
          
              const SizedBox(width: 8),
          
              // 快捷按钮 - 占据右侧40%
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BudgetSettingsScreen()),
    );
                  },
                  borderRadius: BorderRadius.circular(16),
        child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                          padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                  color: Colors.white,
                            size: 12,
                ),
              ),
                        const SizedBox(width: 4),
                        const Text(
                          '查看预算',
                          style: TextStyle(
                  color: Colors.white,
                            fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 健康概览卡片
  Widget _buildHealthSummary(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '健康概览',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 点击查看健康详情
                  },
                  child: const Text(
                    '查看详情',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSimpleHealthItem(
                    icon: FontAwesomeIcons.heartPulse,
                    bgColor: const Color(0xFFEEF2FF),
                    iconColor: const Color(0xFF6366F1),
                    title: '今日步数',
                    value: '8,752',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSimpleHealthItem(
                    icon: FontAwesomeIcons.utensils,
                    bgColor: const Color(0xFFF0FDF4),
                    iconColor: const Color(0xFF22C55E),
                    title: '卡路里',
                    value: '1,286',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSimpleHealthItem(
                    icon: FontAwesomeIcons.moon,
                    bgColor: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFFA855F7),
                    title: '睡眠',
                    value: '7.5小时',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 简化版健康项目卡片
  Widget _buildSimpleHealthItem({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // 财务概览模块
  Widget _buildFinancialSummary(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '财务概览',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 跳转到财务详情页面
                  },
                  child: const Text(
                    '查看详情',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 本月预算使用情况
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '本月花销',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '¥3,245',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            '剩余预算',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '¥1,755',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '已使用预算',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '65%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.65,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 快捷操作按钮
            Row(
              children: [
                Expanded(
                  child: _buildFinanceActionButton(
                    icon: FontAwesomeIcons.plus,
                    label: '记一笔',
                    bgColor: const Color(0xFFEEF2FF),
                    textColor: const Color(0xFF6366F1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExpenseTrackingScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinanceActionButton(
                    icon: FontAwesomeIcons.users,
                    label: '家庭账本',
                    bgColor: const Color(0xFFFEF3C7),
                    textColor: const Color(0xFFD97706),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FamilyFinanceScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 财务操作按钮
  Widget _buildFinanceActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: textColor,
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 今日计划
  Widget _buildTodayPlans(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '今日计划',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPlanItem(
              time: '10:00',
              title: '预算规划会议',
              subtitle: '与家庭成员讨论本月预算分配',
              bgColor: const Color(0xFFEEF2FF),
              borderColor: AppTheme.homeHeaderLight,
              isCompleted: true,
            ),
            const SizedBox(height: 12),
            _buildPlanItem(
              time: '14:30',
              title: '缴纳水电费',
              subtitle: '本月水电费账单支付',
              bgColor: const Color(0xFFFFF7ED),
              borderColor: AppTheme.primaryColor,
              isCompleted: false,
            ),
            const SizedBox(height: 12),
            _buildPlanItem(
              time: '20:00',
              title: '家庭财务周报',
              subtitle: '查看并分析本周家庭支出情况',
              bgColor: const Color(0xFFF0FDF4),
              borderColor: const Color(0xFF22C55E),
              isCompleted: false,
            ),
          ],
        ),
      ),
    );
  }

  // 计划项目
  Widget _buildPlanItem({
    required String time,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color borderColor,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: borderColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isCompleted,
            onChanged: (_) {},
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: borderColor,
          ),
        ],
      ),
    );
  }
}
