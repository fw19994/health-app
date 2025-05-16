import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' if (dart.library.html) 'package:yue_butler/utils/web_stub.dart' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/transaction_history/transaction_history_screen.dart';
import 'themes/app_theme.dart';
import 'widgets/assistant/assistant_floating_button.dart';
import 'widgets/assistant/assistant_chat_screen.dart';
import 'services/auth_service.dart';
import 'constants/api_constants.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 添加网络调试 - 仅在Android平台
  if (!kIsWeb && io.Platform.isAndroid) {
    io.HttpOverrides.global = MyHttpOverrides();
  }
  
  // 请求必要权限 - 仅在移动平台
  if (!kIsWeb) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
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
  
  // 创建认证服务实例
  final authService = AuthService();
  // 尝试从本地存储恢复用户会话
  await authService.init();
  
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  
  const MyApp({super.key, required this.authService});

  // 创建ScaffoldMessengerKey用于全局控制SnackBar
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>.value(
      value: authService,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: MaterialApp(
          title: '悦管家',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          // 根据登录状态决定初始页面
          home: authService.isLoggedIn ? const MainScreen() : const LoginScreen(),
          routes: {
            '/main': (context) => const MainScreen(),
            '/login': (context) => const LoginScreen(),
            '/transaction_history': (context) => const TransactionHistoryScreen(),
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
            return MediaQuery(
              // 防止文字缩放影响布局
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isAssistantVisible = true;

  // 主要页面
  final List<Widget> _pages = [
    const HomeScreen(),
    const Placeholder(child: Center(child: Text('健康'))), // 健康页面
    const FinanceScreen(),
    const ProfileScreen(), // 个人资料页面
  ];

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
              _buildNavItem(0, FontAwesomeIcons.house, FontAwesomeIcons.house, '首页'),
              _buildNavItem(1, FontAwesomeIcons.heartPulse, FontAwesomeIcons.heartPulse, '健康'),
              _buildNavItem(2, FontAwesomeIcons.wallet, FontAwesomeIcons.wallet, '财务'),
              _buildNavItem(3, FontAwesomeIcons.user, FontAwesomeIcons.user, '我的'),
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
    return super.createHttpClient(context)
      ..badCertificateCallback = (io.X509Certificate cert, String host, int port) {
        print('=== SSL证书验证 ===');
        print('主机: $host');
        print('端口: $port');
        print('证书: ${cert.subject}');
        return true; // 允许所有证书，仅用于调试
      }
      ..connectionTimeout = const Duration(seconds: 15)
      ..maxConnectionsPerHost = 5
      ..findProxy = (uri) {
        // 添加DNS配置
        print('=== DNS解析 ===');
        print('正在解析域名: ${uri.host}');
        return 'DIRECT';
      };
  }
}
