import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' if (dart.library.html) 'utils/web_stub.dart' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workmanager/workmanager.dart';
import 'utils/stagewise_integration.dart';
import 'screens/home_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/finance/family_finance/family_finance_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/transaction_history/transaction_history_screen.dart';
import 'screens/plan/daily_plan_screen.dart';
import 'screens/plan/monthly_plan_screen.dart';
import 'screens/plan/add_edit_plan_screen.dart';
import 'screens/plan/plan_settings_screen.dart';
import 'screens/plan/plan_analysis_screen.dart';
import 'screens/plan/special_projects_list_screen.dart';
import 'screens/plan/special_project_detail_screen.dart';
import 'themes/app_theme.dart';
import 'widgets/assistant/assistant_floating_button.dart';
import 'widgets/assistant/assistant_chat_screen.dart';
import 'services/auth_service.dart';
import 'services/plan_service.dart';
import 'services/special_project_service.dart';
import 'services/project_phase_service.dart';
import 'services/plan_monitor_service.dart';
import 'constants/api_constants.dart';
import 'constants/routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/family_management_screen.dart';
import 'screens/finance/family_finance/family_finance_router.dart';
import 'utils/app_icons.dart';
import 'services/reminder_service.dart';
import 'services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 全局NavigatorKey，用于在服务中获取BuildContext
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 后台任务回调入口点
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('执行后台任务: $taskName');
    
    // 调用PlanMonitorService中定义的回调逻辑而不是自身
    if (taskName == 'com.lifeapp.checkPlansTask') {
      try {
        // 初始化必要服务
        final reminderService = ReminderService();
        await reminderService.initialize();
        
        // 检查今天的计划
        final planService = PlanService();
        final plans = await planService.fetchTodayPlans();
        
        final now = DateTime.now();
        
        // 从SharedPreferences获取已通知的计划ID
        final prefs = await SharedPreferences.getInstance();
        final Set<String> notifiedPlanIds = 
            prefs.getStringList('already_notified_plans')?.toSet() ?? <String>{};
        
        // 检查需要提醒的计划
        for (final plan in plans) {
          // 如果计划已经提醒过或已完成，跳过
          if (notifiedPlanIds.contains(plan.id) || plan.isCompleted) {
            continue;
          }
          
          // 获取计划时间
          final planDateTime = plan.toDateTime();
          if (planDateTime == null) {
            continue;
          }
          
          // 计算时间差（单位：分钟）
          final differenceInMinutes = planDateTime.difference(now).inMinutes;
          
          // 如果计划即将开始或已开始不超过5分钟（后台任务间隔较大，放宽条件），发送提醒
          if (differenceInMinutes <= 0 && differenceInMinutes >= -5) {
            // 获取提醒方式设置
            final playSound = prefs.getBool('notification_sound_enabled') ?? true;
            final enableVibration = prefs.getBool('notification_vibration_enabled') ?? true;
            
            // 根据声音设置决定是否使用闹钟提醒
            if (playSound) {
              // 有声音则使用闹钟式提醒
              await reminderService.showAlarmNotification(
                title: '计划开始提醒',
                body: '计划"${plan.title}"已经开始，请及时处理。\n${plan.description}\n${plan.timeRangeString}',
                payload: plan.id,
              );
            } else {
              // 无声音则使用普通通知
              await reminderService.showNormalNotification(
                title: '计划开始提醒',
                body: '计划"${plan.title}"已经开始，请及时处理。\n${plan.description}\n${plan.timeRangeString}',
                payload: plan.id,
              );
            }
            
            // 记录已提醒的计划ID
            notifiedPlanIds.add(plan.id);
            await prefs.setStringList('already_notified_plans', notifiedPlanIds.toList());
          }
        }
        
        // 清理超过24小时的通知记录
        final lastCleanupTime = prefs.getInt('last_cleanup_time') ?? 0;
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        
        if (currentTime - lastCleanupTime > 24 * 60 * 60 * 1000) {
          // 如果上次清理时间超过24小时，则清理通知记录
          await prefs.setStringList('already_notified_plans', []);
          await prefs.setInt('last_cleanup_time', currentTime);
        }
        
        debugPrint('后台任务执行成功');
        return true;
      } catch (e) {
        debugPrint('后台任务执行失败: $e');
        return false;
      }
    }
    
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize stagewise in web debug mode
  if (kIsWeb) {
    StagewiseIntegration.initialize();
  }
  
  // 添加网络调试 - 仅在Android平台
  if (!kIsWeb && io.Platform.isAndroid) {
    try {
      io.HttpOverrides.global = MyHttpOverrides();
    } catch (e) {
      debugPrint('设置HttpOverrides失败: $e');
    }
  }
  
  // 请求必要权限 - 仅在移动平台
  if (!kIsWeb) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.notification, // 添加通知权限
    ].request();
    
    statuses.forEach((permission, status) {
      debugPrint('$permission: $status');
    });
  }
  
  // 初始化本地化日期格式数据
  await initializeDateFormatting('zh_CN', null);
  
  // 设置API环境 - 可以根据打包环境自动切换
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  ApiConstants.setEnvironment(
    isProduction ? Environment.production : Environment.local
  );
  
  // 仅在移动平台设置屏幕方向
  if (!kIsWeb) {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  }
  
  // 初始化WorkManager (用于后台任务)
  if (!kIsWeb) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // 生产环境设置为false
    );
    debugPrint('WorkManager初始化成功');
  }
  
  // 创建认证服务实例
  final authService = AuthService();
  // 尝试从本地存储恢复用户会话
  await authService.init();
  
  // 初始化提醒服务
  final reminderService = ReminderService();
  await reminderService.initialize();
  
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  
  const MyApp({super.key, required this.authService});

  // 创建ScaffoldMessengerKey用于全局控制SnackBar
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<ApiService>(
          create: (context) => ApiService(),
        ),
        ChangeNotifierProvider<PlanService>(
          create: (context) => PlanService(),
          lazy: false, // 确保立即创建
        ),
        ChangeNotifierProvider<SpecialProjectService>(create: (_) => SpecialProjectService()),
        ChangeNotifierProvider<ProjectPhaseService>(create: (_) => ProjectPhaseService()),
        ChangeNotifierProvider<ReminderService>(
          create: (context) => ReminderService(),
          lazy: false, // 确保立即创建
        ),
        ChangeNotifierProvider<PlanMonitorService>(
          create: (context) => PlanMonitorService(),
          lazy: false, // 确保立即创建
        ),
      ],
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: MaterialApp(
          title: '悦管家',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          // 根据登录状态决定初始页面
          home: authService.isLoggedIn ? const MainScreen() : const LoginScreen(),
          routes: {
            '/main': (context) {
              // 获取路由参数
              final args = ModalRoute.of(context)?.settings.arguments;
              // 如果提供了索引参数，则传递给MainScreen
              return MainScreen(initialIndex: args is int ? args : null);
            },
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/family_management': (context) => const FamilyManagementScreen(),
            '/transaction_history': (context) => const TransactionHistoryScreen(),
            
            // 计划相关路由
            Routes.dailyPlan: (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              return DailyPlanScreen(
                initialDate: args is DateTime ? args : null,
              );
            },
            Routes.monthlyPlan: (context) => const MonthlyPlanScreen(),
            Routes.addPlan: (context) => const AddEditPlanScreen(),
            Routes.editPlan: (context) => const AddEditPlanScreen(planId: 'dummy-plan-id'),
            Routes.planSettings: (context) => const PlanSettingsScreen(),
            Routes.planAnalysis: (context) => const PlanAnalysisScreen(),
            
            // 专项计划相关路由
            Routes.specialProjectsList: (context) => const SpecialProjectsListScreen(),
            Routes.specialProjectDetail: (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is String) {
                return SpecialProjectDetailScreen(projectId: args);
              }
              // 如果没有传递ID或格式不正确，返回列表页面
              return const SpecialProjectsListScreen();
            },
          },
          // 添加本地化支持
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          locale: const Locale('zh', 'CN'),
          // 确保SnackBar可以正确显示
          builder: (context, child) {
            // 在应用启动后设置PlanService的context
            final planService = Provider.of<PlanService>(context, listen: false);
            // 使用microtask确保在build完成后设置context
            Future.microtask(() async {
              planService.setContext(context);
              
              // 设置SpecialProjectService的context
              final specialProjectService = Provider.of<SpecialProjectService>(context, listen: false);
              specialProjectService.setContext(context);
              
              // 设置ProjectPhaseService的context
              final projectPhaseService = Provider.of<ProjectPhaseService>(context, listen: false);
              projectPhaseService.setContext(context);
              
              // 初始化ReminderService
              final reminderService = Provider.of<ReminderService>(context, listen: false);
              await reminderService.initialize();
              
              // 启动计划监控服务（不需要检查是否开启）
              final planMonitorService = Provider.of<PlanMonitorService>(context, listen: false);
              if (authService.isLoggedIn) {
                // 默认自动启动计划监控服务
                if (!planMonitorService.isRunning) {
                  await planMonitorService.startMonitoring();
                  debugPrint('计划监控服务已在应用启动时启动');
                } else {
                  debugPrint('计划监控服务已经在运行中');
                }
              }
            });
            return MediaQuery(
              // 防止文字缩放影响布局
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child ?? Container(),
            );
          },
          // 处理命名路由和传参
          onGenerateRoute: (settings) {
            if (settings.name == Routes.editPlan) {
              // 从路由参数中获取planId
              final args = settings.arguments as Map<String, dynamic>;
              final planId = args['planId'] as String;
              return MaterialPageRoute(
                builder: (context) => AddEditPlanScreen(planId: planId),
              );
            } else if (settings.name == Routes.specialProjectDetail) {
              // 从路由参数中获取projectId
              final args = settings.arguments as Map<String, dynamic>;
              final projectId = args['projectId'] as String;
              return MaterialPageRoute(
                builder: (context) => SpecialProjectDetailScreen(projectId: projectId),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  // 添加可选的初始索引参数
  final int? initialIndex;
  
  const MainScreen({super.key, this.initialIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isAssistantVisible = true;

  // 主要页面
  final List<Widget> _pages = [
    const HomeScreen(),
    const DailyPlanScreen(initialDate: null, noAutoLoad: true),
    const FamilyManagementScreen(),
    const FinanceScreen(),
    const ProfileScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    // 如果提供了初始索引，使用它
    if (widget.initialIndex != null) {
      _currentIndex = widget.initialIndex!;
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 检查是否有参数传入
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args >= 0 && args < _pages.length) {
      // 延迟设置索引，避免在build过程中setState
      Future.microtask(() {
        setState(() {
          _currentIndex = args;
        });
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAssistantChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AssistantChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 当前页面
          _pages[_currentIndex],
          
          // 智能助手悬浮按钮
          if (_isAssistantVisible)
            AssistantFloatingButton(
              onTap: _openAssistantChat,
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, AppIcons.home, AppIcons.home, '首页'),
              _buildNavItem(1, AppIcons.plan, AppIcons.plan, '计划'),
              _buildNavItem(2, FontAwesomeIcons.moneyBillWave, FontAwesomeIcons.moneyBillWave, '家庭财务'),
              _buildNavItem(3, AppIcons.finance, AppIcons.finance, '财务'),
              _buildNavItem(4, AppIcons.profile, AppIcons.profile, '我的'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// 添加自定义HTTP覆盖
class MyHttpOverrides extends io.HttpOverrides {
  @override
  io.HttpClient createHttpClient(io.SecurityContext? context) {
    // 直接使用父类方法创建基础HttpClient
    final client = super.createHttpClient(context);
    
    // 然后自定义配置
    client.badCertificateCallback = (cert, host, port) {
      debugPrint('=== SSL证书验证 ===');
      debugPrint('主机: $host');
      debugPrint('端口: $port');
      debugPrint('证书: ${cert.subject}');
      return true; // 允许所有证书，仅用于调试
    };
    client.connectionTimeout = const Duration(seconds: 15);
    client.maxConnectionsPerHost = 5;
    client.findProxy = (uri) {
      // 添加DNS配置
      debugPrint('=== DNS解析 ===');
      debugPrint('正在解析域名: ${uri.host}');
      return 'DIRECT';
    };
    return client;
  }
  
  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    // 添加DNS配置
    debugPrint('=== DNS解析 (环境) ===');
    debugPrint('正在解析域名: ${url.host}');
    return 'DIRECT';
  }
}
