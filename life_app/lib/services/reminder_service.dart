import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan/plan_model.dart';

class ReminderService extends ChangeNotifier {
  // 单例模式
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();
  
  // 通知插件实例
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // 初始化状态
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // 错误信息
  String? _error;
  String? get error => _error;
  
  // 初始化通知服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // 初始化时区数据
      tz_data.initializeTimeZones();
      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      
      // 初始化通知设置
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher'); // 使用应用图标
          
      final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );
      
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      // 初始化插件
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );
      
      // 获取通知权限（iOS）
      await _requestPermissions();
      
      _isInitialized = true;
      notifyListeners();
      
      debugPrint('通知服务初始化成功');
    } catch (e) {
      _error = '通知服务初始化失败: $e';
      debugPrint(_error);
    }
  }
  
  // 请求通知权限
  Future<void> _requestPermissions() async {
    // iOS权限请求
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    // Android权限请求（Android 13+）
    // 在最新版本中不需要显式请求权限，通知渠道会自动创建
    // 如果需要深度权限管理，应该使用permission_handler插件
    debugPrint('已初始化Android通知权限');
  }
  
  // iOS 老版本通知回调（iOS 10以下）
  Future _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    // 不做处理，只是为了满足API要求
  }
  
  // 通知点击回调
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      debugPrint('通知被点击，payload: $payload');
      // 后续可以根据payload打开相应的页面
    }
  }
  
  // 测试方法：发送即时通知
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      '计划提醒',
      channelDescription: '提醒您即将开始的计划',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await _notificationsPlugin.show(
      0,
      '测试通知',
      '这是一条测试通知，测试提醒功能是否正常',
      notificationDetails,
      payload: 'test',
    );
    
    debugPrint('测试通知已发送');
  }
  
  // 为计划设置提醒
  Future<bool> scheduleReminder(Plan plan) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // 如果计划无法接收提醒，则返回
      if (!plan.canReceiveReminder || plan.date == null || plan.reminderMinutes == null) {
        debugPrint('计划无法设置提醒');
        return false;
      }
      
      // 获取计划的完整日期时间
      final DateTime planDateTime = plan.toDateTime() ?? DateTime.now();
      
      // 计算提醒时间（提前N分钟）
      final DateTime reminderTime = planDateTime.subtract(Duration(minutes: plan.reminderMinutes!));
      
      // 如果提醒时间已过，则不设置提醒
      if (reminderTime.isBefore(DateTime.now())) {
        debugPrint('提醒时间已过，不设置提醒');
        return false;
      }
      
      // 设置通知详情
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        '计划提醒',
        channelDescription: '提醒您即将开始的计划',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      
      // 生成通知ID
      final int notificationId = int.parse(plan.id.hashCode.toString().substring(0, 6).replaceAll('-', '1'));
      
      // 保存通知ID和计划ID的映射关系
      await _saveReminderMapping(notificationId.toString(), plan.id);
      
      // 设置定时通知
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        '计划提醒: ${plan.title}',
        plan.description.isNotEmpty
            ? '${plan.description}\n时间: ${_formatTimeRange(plan)}'
            : '时间: ${_formatTimeRange(plan)}',
        tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: plan.id,
      );
      
      debugPrint('已为计划 ${plan.title} 设置提醒，提醒时间: ${reminderTime.toString()}');
      return true;
    } catch (e) {
      _error = '设置提醒失败: $e';
      debugPrint(_error);
      return false;
    }
  }
  
  // 取消计划提醒
  Future<bool> cancelReminder(String planId) async {
    try {
      // 获取通知ID
      final String? notificationId = await _getNotificationIdByPlanId(planId);
      if (notificationId == null) {
        debugPrint('找不到计划对应的通知ID');
        return false;
      }
      
      // 取消通知
      await _notificationsPlugin.cancel(int.parse(notificationId));
      
      // 删除映射关系
      await _deleteReminderMapping(notificationId);
      
      debugPrint('已取消计划 $planId 的提醒');
      return true;
    } catch (e) {
      _error = '取消提醒失败: $e';
      debugPrint(_error);
      return false;
    }
  }
  
  // 保存通知ID和计划ID的映射关系
  Future<void> _saveReminderMapping(String notificationId, String planId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reminder_$notificationId', planId);
    } catch (e) {
      debugPrint('保存提醒映射失败: $e');
    }
  }
  
  // 获取计划ID对应的通知ID
  Future<String?> _getNotificationIdByPlanId(String planId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('reminder_')) {
          final value = prefs.getString(key);
          if (value == planId) {
            return key.replaceFirst('reminder_', '');
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('获取通知ID失败: $e');
      return null;
    }
  }
  
  // 删除通知ID和计划ID的映射关系
  Future<void> _deleteReminderMapping(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('reminder_$notificationId');
    } catch (e) {
      debugPrint('删除提醒映射失败: $e');
    }
  }
  
  // 格式化时间范围
  String _formatTimeRange(Plan plan) {
    return plan.timeRangeString;
  }
  
  // 取消所有提醒
  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('已取消所有提醒');
    } catch (e) {
      _error = '取消所有提醒失败: $e';
      debugPrint(_error);
    }
  }
} 