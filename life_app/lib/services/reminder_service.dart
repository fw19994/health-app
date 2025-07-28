import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
// 移除: import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan/plan_model.dart';
import 'dart:typed_data' show Int64List;

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
      // 使用固定时区代替获取设备时区
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
      
      // 创建Android通知渠道
      final AndroidNotificationChannelGroup channelGroup = AndroidNotificationChannelGroup(
        'life_app_group',
        '家庭生活助手',
        description: '家庭生活助手应用的所有通知',
      );
      
      // 尝试创建带有自定义铃声的渠道
      AndroidNotificationChannel channel;
      try {
        channel = AndroidNotificationChannel(
          'reminder_channel',
          '计划提醒',
          description: '提醒您即将开始的计划',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 200, 200, 200]),
          enableLights: true,
          ledColor: Colors.blue,
          sound: const RawResourceAndroidNotificationSound('alarm_sound'), // 指定渠道默认铃声
        );
      } catch (e) {
        debugPrint('创建带自定义铃声的通知渠道失败: $e，将创建使用默认铃声的渠道');
        // 创建使用默认铃声的渠道
        channel = AndroidNotificationChannel(
          'reminder_channel',
          '计划提醒',
          description: '提醒您即将开始的计划',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 200, 200, 200]),
          enableLights: true,
          ledColor: Colors.blue,
        );
      }
      
      // 注册通知渠道组和渠道
      try {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannelGroup(channelGroup);
            
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
            
        debugPrint('成功创建通知渠道: ${channel.id}');
      } catch (e) {
        debugPrint('注册通知渠道失败: $e');
      }
      
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
  Future<void> showTestNotification({
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        '计划提醒',
        channelDescription: '提醒您即将开始的计划',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: playSound,  // 使用传入的参数
        enableVibration: enableVibration, // 使用传入的参数
        vibrationPattern: enableVibration ? Int64List.fromList([0, 200, 200, 200]) : null,
        sound: playSound ? const RawResourceAndroidNotificationSound('alarm_sound') : null, // 使用自定义铃声
        audioAttributesUsage: AudioAttributesUsage.alarm, // 使用闹钟音频属性
      );
      
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound, // 使用传入的参数
          sound: playSound ? 'alarm_sound.mp3' : null, // iOS自定义声音文件名
        ),
      );
      
      await _notificationsPlugin.show(
        0,
        '测试通知',
        '这是一条测试通知，测试提醒功能是否正常',
        notificationDetails,
        payload: 'test',
      );
      
      debugPrint('测试通知已发送 (声音: $playSound, 震动: $enableVibration)');
    } catch (e) {
      debugPrint('尝试使用自定义铃声发送通知失败: $e，将使用默认铃声');
      // 如果自定义铃声失败，使用默认铃声
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        '计划提醒',
        channelDescription: '提醒您即将开始的计划',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: playSound,
        enableVibration: enableVibration,
        vibrationPattern: enableVibration ? Int64List.fromList([0, 200, 200, 200]) : null,
        // 不指定sound参数，使用系统默认声音
      );
      
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound,
          // 不指定sound参数，使用系统默认声音
        ),
      );
      
      await _notificationsPlugin.show(
        0,
        '测试通知',
        '这是一条测试通知，测试提醒功能是否正常',
        notificationDetails,
        payload: 'test',
      );
      
      debugPrint('使用默认铃声的测试通知已发送');
    }
  }
  
  // 测试方法：发送闹钟式通知（响铃更持久）
  Future<void> showAlarmNotification({
    String title = '重要计划提醒',
    String body = '您有一个重要计划需要立即查看！点击查看详情。',
    String payload = 'alarm_test',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // 创建特殊闹钟通知渠道
      final AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
        'alarm_channel',
        '闹钟提醒',
        description: '像闹钟一样的计划提醒',
        importance: Importance.high, // 高优先级
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.red,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('alarm_sound'),
      );
      
      // 注册通知渠道
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(alarmChannel);
      
      // 使用闹钟通知设置
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        alarmChannel.id,
        alarmChannel.name,
        channelDescription: alarmChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        fullScreenIntent: true, // 尝试全屏显示通知
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('alarm_sound'),
        audioAttributesUsage: AudioAttributesUsage.alarm, // 使用闹钟音频属性
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 500, 500, 500, 500, 500, 500]), // 更强的震动模式
        ticker: '计划提醒',
        visibility: NotificationVisibility.public,
        ongoing: true, // 持久通知，用户必须手动取消
      );
      
      // iOS设置
      final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alarm_sound.mp3',
        interruptionLevel: InterruptionLevel.timeSensitive, // 时间敏感的打断级别
      );
      
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );
      
      final int notificationId = _generateNotificationId(payload);
      
      await _notificationsPlugin.show(
        notificationId, // 使用生成的ID
      title,
      body,
        notificationDetails,
        payload: payload,
      );
      
      debugPrint('闹钟式通知已发送');
    } catch (e) {
      debugPrint('尝试使用自定义铃声发送闹钟通知失败: $e，将使用默认铃声');
      
      // 使用默认闹钟渠道
      final AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
        'default_alarm_channel',
        '默认闹钟提醒',
        description: '使用默认声音的闹钟提醒',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        ledColor: Colors.red,
        playSound: true,
        // 不指定sound参数，使用系统默认声音
      );
      
      // 注册通知渠道
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(defaultChannel);
      
      // 使用默认声音的闹钟通知设置
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        defaultChannel.id,
        defaultChannel.name,
        channelDescription: defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        fullScreenIntent: true,
        playSound: true,
        // 不指定sound参数
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 500, 500, 500, 500, 500, 500]),
        ticker: '计划提醒',
        visibility: NotificationVisibility.public,
        ongoing: true,
      );
      
      // iOS设置
      final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // 不指定sound参数
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
      
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );
      
      final int notificationId = _generateNotificationId(payload);
      
      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      
      debugPrint('使用默认铃声的闹钟式通知已发送');
    }
  }
  
  // 发送普通通知
  Future<void> showNormalNotification({
    String title = '计划提醒',
    String body = '您有一个计划需要查看',
    String payload = 'notification',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // 获取用户通知偏好设置
      final prefs = await SharedPreferences.getInstance();
      final bool playSound = prefs.getBool('notification_sound_enabled') ?? true;
      final bool enableVibration = prefs.getBool('notification_vibration_enabled') ?? true;
      
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        '计划提醒',
        channelDescription: '提醒您即将开始的计划',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: playSound,
        enableVibration: enableVibration,
        vibrationPattern: enableVibration ? Int64List.fromList([0, 200, 200, 200]) : null,
        sound: playSound ? const RawResourceAndroidNotificationSound('alarm_sound') : null,
        audioAttributesUsage: AudioAttributesUsage.alarm, // 添加此行，使用闹钟音频属性
      );
      
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound,
          sound: playSound ? 'alarm_sound.mp3' : null,
        ),
      );
      
      final int notificationId = _generateNotificationId(payload);
      
      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      
      debugPrint('普通通知已发送: $title');
    } catch (e) {
      debugPrint('发送普通通知失败: $e，尝试使用默认设置');
      
      // 使用默认设置重试
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        '计划提醒',
        channelDescription: '提醒您即将开始的计划',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm, // 使用闹钟音频属性
      );
      
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      
      final int notificationId = _generateNotificationId(payload);
      
      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
      payload: payload,
    );

      debugPrint('使用默认设置的普通通知已发送');
    }
  }
  
  // 生成通知ID
  int _generateNotificationId(String payload) {
    // 使用payload的hashCode生成通知ID，确保相同payload的通知ID一致
    return payload.hashCode.abs() % 1000000;
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
      
      // 获取用户通知偏好设置
      final prefs = await SharedPreferences.getInstance();
      final bool notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final bool playSound = prefs.getBool('notification_sound_enabled') ?? true;
      final bool enableVibration = prefs.getBool('notification_vibration_enabled') ?? true;
      
      // 如果通知被禁用，则不设置提醒
      if (!notificationsEnabled) {
        debugPrint('通知功能被禁用，不设置提醒');
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
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        '计划提醒',
        channelDescription: '提醒您即将开始的计划',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: playSound,  // 根据用户设置决定
        enableVibration: enableVibration, // 根据用户设置决定
        vibrationPattern: enableVibration ? Int64List.fromList([0, 200, 200, 200]) : null,
        sound: playSound ? const RawResourceAndroidNotificationSound('alarm_sound') : null, // 使用自定义铃声
        audioAttributesUsage: AudioAttributesUsage.alarm, // 使用闹钟音频属性
      );
      
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound, // 根据用户设置决定
          sound: playSound ? 'alarm_sound.mp3' : null, // iOS自定义声音文件名
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