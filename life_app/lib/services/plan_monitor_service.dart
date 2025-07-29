import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../models/plan/plan_model.dart';
import '../main.dart'; // 导入navigatorKey
import 'foreground_service.dart'; // 导入前台服务管理器
import 'plan_service.dart';
import 'reminder_service.dart';

// 定义后台任务名称
const String checkPlansTask = "com.lifeapp.checkPlansTask";

/// 计划监控服务
/// 
/// 负责定时检查当天计划，并根据计划开始时间和设置发送提醒
class PlanMonitorService extends ChangeNotifier {
  // 单例模式
  static final PlanMonitorService _instance = PlanMonitorService._internal();
  factory PlanMonitorService() => _instance;
  PlanMonitorService._internal();
  
  // 服务状态
  bool _isRunning = false;
  bool get isRunning => _isRunning;
  
  // 定时器
  Timer? _timer;
  
  // 服务依赖
  final PlanService _planService = PlanService();
  final ReminderService _reminderService = ReminderService();
  
  // 已提醒的计划ID集合，避免重复提醒
  final Set<String> _alreadyNotifiedPlans = {};
  
  // 初始化WorkManager
  Future<void> _initWorkManager() async {
    // WorkManager的初始化和回调已经在main.dart中实现
    debugPrint('WorkManager配置已更新');
  }
  
  // 开始监控服务
  Future<void> startMonitoring() async {
    if (_isRunning) {
      debugPrint('计划监控服务已在运行中');
      return;
    }
    
    debugPrint('启动计划监控服务');
    await _reminderService.initialize();
    
    // 初始化WorkManager配置
    await _initWorkManager();
    
    try {
      // 注册周期性后台任务，仅在移动端平台执行
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        debugPrint('在移动端注册后台任务');
        await Workmanager().registerPeriodicTask(
          "plan-monitor-task",
          checkPlansTask,
          frequency: const Duration(minutes: 15), // 每15分钟检查一次
          constraints: Constraints(
            networkType: NetworkType.connected, // 需要网络连接
            requiresBatteryNotLow: false, // 低电量也能运行
            requiresCharging: false, // 不需要充电
            requiresDeviceIdle: false, // 不需要设备空闲
            requiresStorageNotLow: false, // 存储空间低也能运行
          ),
          existingWorkPolicy: ExistingWorkPolicy.replace, // 如果任务已存在则替换
          backoffPolicy: BackoffPolicy.linear, // 任务失败后线性延迟重试
          backoffPolicyDelay: const Duration(minutes: 5), // 重试延迟时间
        );
        debugPrint('后台任务注册成功');
        
        // 在Android平台默认启动前台服务
        if (Platform.isAndroid) {
          await ForegroundServiceManager.startService(
            title: '悦管家计划监控中',
            content: '应用正在后台运行，以便及时提醒您的计划',
          );
          debugPrint('前台服务已启动');
        }
      } else {
        debugPrint('当前平台不支持后台任务，仅使用前台定时器');
      }
    } catch (e) {
      debugPrint('注册后台任务失败: $e');
      debugPrint('将仅使用前台定时器进行监控');
    }
    
    // 清空已提醒计划记录
    _alreadyNotifiedPlans.clear();
    
    // 立即检查一次
    await _checkPlans();
    
    // 设置定时器，每分钟检查一次
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _checkPlans();
    });
    
    _isRunning = true;
    notifyListeners();
    debugPrint('计划监控服务已启动');
  }
  
  // 停止监控服务
  Future<void> stopMonitoring() async {
    if (!_isRunning) {
      debugPrint('计划监控服务未在运行');
      return;
    }
    
    _timer?.cancel();
    _timer = null;
    
    try {
      // 取消后台任务，仅在移动端平台执行
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await Workmanager().cancelAll();
        debugPrint('已取消所有后台任务');
        
        // 在Android平台停止前台服务
        if (Platform.isAndroid) {
          await ForegroundServiceManager.stopService();
        }
      }
    } catch (e) {
      debugPrint('取消后台任务失败: $e');
    }
    
    _isRunning = false;
    notifyListeners();
    debugPrint('计划监控服务已停止');
  }
  
  // 检查计划
  Future<void> _checkPlans() async {
    debugPrint('检查今日计划...');
    try {
      final plans = await _planService.fetchTodayPlans();
      _checkPlansNeedReminder(plans);
    } catch (e) {
      debugPrint('检查计划时出错: $e');
    }
  }
  
  // 检查需要提醒的计划
  void _checkPlansNeedReminder(List<Plan> plans) {
    final now = DateTime.now();
    
    for (final plan in plans) {
      // 如果计划已经提醒过，跳过
      if (_alreadyNotifiedPlans.contains(plan.id)) {
        continue;
      }
      
      // 如果计划已完成，跳过
      if (plan.isCompleted) {
        continue;
      }
      
      // 获取计划时间
      final planDateTime = plan.toDateTime();
      if (planDateTime == null) {
        continue;
      }
      
      // 计算时间差（单位：分钟）
      final differenceInMinutes = planDateTime.difference(now).inMinutes;
      
      // 如果计划即将开始或已开始不超过1分钟，发送提醒
      if (differenceInMinutes <= 0 && differenceInMinutes >= -1) {
        _sendReminder(plan);
        // 记录已提醒，避免重复提醒
        _alreadyNotifiedPlans.add(plan.id);
        
        // 同时更新SharedPreferences中的记录，供后台任务使用
        _updateNotifiedPlansInPrefs();
      }
    }
  }
  
  // 更新已通知计划到SharedPreferences
  Future<void> _updateNotifiedPlansInPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('already_notified_plans', _alreadyNotifiedPlans.toList());
    } catch (e) {
      debugPrint('更新已通知计划到SharedPreferences失败: $e');
    }
  }
  
  // 发送提醒
  Future<void> _sendReminder(Plan plan) async {
    debugPrint('发送计划开始提醒: ${plan.title}');
    
    // 获取提醒方式设置
    final prefs = await SharedPreferences.getInstance();
    final playSound = prefs.getBool('notification_sound_enabled') ?? true;
    final enableVibration = prefs.getBool('notification_vibration_enabled') ?? true;
    
    // 根据通知声音设置决定是否使用闹钟提醒
    // 如果声音开启，则使用闹钟提醒；否则使用普通通知
    if (playSound) {
      // 有声音则使用闹钟式提醒
      await _reminderService.showAlarmNotification(
        title: '计划开始提醒',
        body: '计划"${plan.title}"已经开始，请及时处理。\n${plan.description}\n${plan.timeRangeString}',
        payload: plan.id,
      );
      debugPrint('已发送闹钟式提醒');
    } else {
      // 无声音则使用普通通知
      await _reminderService.showNormalNotification(
        title: '计划开始提醒',
        body: '计划"${plan.title}"已经开始，请及时处理。\n${plan.description}\n${plan.timeRangeString}',
        payload: plan.id,
      );
      debugPrint('已发送普通通知');
    }
  }
  
  // 加载监控服务状态
  Future<void> loadMonitoringState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 检查通知功能是否启用
    final bool notificationsEnabled = prefs.getBool('notification_enabled') ?? true;
    
    // 如果通知功能启用且监控服务未运行，则启动服务
    if (notificationsEnabled && !_isRunning) {
      await startMonitoring();
    }
    // 如果通知功能被禁用但监控服务正在运行，则停止服务
    else if (!notificationsEnabled && _isRunning) {
      await stopMonitoring();
    }
  }
  
  // 清除特定计划的提醒记录，允许再次提醒
  void clearNotificationRecord(String planId) {
    _alreadyNotifiedPlans.remove(planId);
    _updateNotifiedPlansInPrefs();
  }
  
  // 清除所有提醒记录
  void clearAllNotificationRecords() {
    _alreadyNotifiedPlans.clear();
    _updateNotifiedPlansInPrefs();
  }
  
  // 测试发送提醒（供设置页面使用）
  Future<void> sendReminder({
    bool playSound = true, 
    bool enableVibration = true
  }) async {
    debugPrint('测试发送计划提醒: playSound=$playSound, enableVibration=$enableVibration');
    
    // 创建一个测试计划
    final now = DateTime.now();
    final testPlan = Plan(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      title: '测试计划',
      description: '这是一个测试计划，用于测试不同类型的提醒',
      date: now,
      startTime: TimeOfDay(hour: now.hour, minute: now.minute),
      endTime: TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute),
      isCompleted: false,
      category: 'test', // 添加必要的category参数
      reminderType: 'time', // 添加必要的reminderType参数
      isPinned: false, // 添加必要的isPinned参数
      recurrenceType: 'once',
      createdAt: now, // 添加必要的createdAt参数
    );
    
    // 初始化提醒服务
    await _reminderService.initialize();
    
    // 根据声音设置决定使用哪种提醒类型
    if (playSound) {
      // 有声音则使用闹钟式提醒
      await _reminderService.showAlarmNotification(
        title: '测试计划开始提醒(闹钟式)',
        body: '计划"${testPlan.title}"已经开始，请及时处理。\n${testPlan.description}\n${testPlan.timeRangeString}',
        payload: testPlan.id,
      );
      debugPrint('已发送闹钟式提醒');
    } else {
      // 无声音则使用普通通知
      await _reminderService.showNormalNotification(
        title: '测试计划开始提醒(普通)',
        body: '计划"${testPlan.title}"已经开始，请及时处理。\n${testPlan.description}\n${testPlan.timeRangeString}',
        payload: testPlan.id,
      );
      debugPrint('已发送普通通知');
    }
  }
  
  // 释放资源
  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
} 