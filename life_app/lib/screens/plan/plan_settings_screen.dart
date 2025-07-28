import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reminder_service.dart';
import '../../services/plan_monitor_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanSettingsScreen extends StatefulWidget {
  const PlanSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PlanSettingsScreen> createState() => _PlanSettingsScreenState();
}

class _PlanSettingsScreenState extends State<PlanSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _useAlarmForPlanStart = false;
  bool _monitoringActive = false;
  
  // 直接引用ReminderService实例
  late final ReminderService _reminderService;
  late final PlanMonitorService _monitorService;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    // 在initState中获取服务实例
    _reminderService = ReminderService();
    _monitorService = PlanMonitorService();
    // 确保ReminderService已初始化
    _initReminderService();
    // 检查监控服务状态
    _monitoringActive = _monitorService.isRunning;
    debugPrint('PlanSettingsScreen initialized, ReminderService: $_reminderService');
  }
  
  // 初始化ReminderService
  Future<void> _initReminderService() async {
    try {
      await _reminderService.initialize();
      debugPrint('ReminderService初始化成功');
    } catch (e) {
      debugPrint('ReminderService初始化失败: $e');
    }
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('notification_vibration_enabled') ?? true;
      _useAlarmForPlanStart = prefs.getBool('use_alarm_for_plan_start') ?? false;
    });
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('notification_sound_enabled', _soundEnabled);
    await prefs.setBool('notification_vibration_enabled', _vibrationEnabled);
    await prefs.setBool('use_alarm_for_plan_start', _useAlarmForPlanStart);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('计划设置'),
      backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '基本设置',
            style: TextStyle(
                fontSize: 16,
              fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
      ),
          ),
          ListTile(
            title: const Text('启用计划提醒'),
            subtitle: const Text('打开或关闭计划提醒通知'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
          const Divider(height: 1),
          
          // 声音设置
          ListTile(
            enabled: _notificationsEnabled,
            title: const Text('通知声音'),
            subtitle: const Text('启用或禁用通知声音'),
            trailing: Switch(
              value: _soundEnabled && _notificationsEnabled,
              onChanged: _notificationsEnabled 
                ? (value) {
                  setState(() {
                      _soundEnabled = value;
                  });
                    _saveSettings();
                  }
                : null,
              activeColor: Theme.of(context).primaryColor,
            ),
              ),
          const Divider(height: 1),
          
          // 震动设置
          ListTile(
            enabled: _notificationsEnabled,
            title: const Text('通知震动'),
            subtitle: const Text('启用或禁用通知震动'),
            trailing: Switch(
              value: _vibrationEnabled && _notificationsEnabled,
              onChanged: _notificationsEnabled
                ? (value) {
                  setState(() {
                      _vibrationEnabled = value;
                  });
                    _saveSettings();
                  }
                : null,
              activeColor: Theme.of(context).primaryColor,
            ),
              ),
          const Divider(height: 1),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '计划开始提醒',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          
          // 计划开始提醒方式
          ListTile(
            enabled: _notificationsEnabled,
            title: const Text('使用闹钟提醒计划开始'),
            subtitle: const Text('开启后，计划开始时将使用闹钟式提醒，而不是普通通知'),
            trailing: Switch(
              value: _useAlarmForPlanStart && _notificationsEnabled,
              onChanged: _notificationsEnabled
                ? (value) {
                  setState(() {
                      _useAlarmForPlanStart = value;
                  });
                    _saveSettings();
                  }
                : null,
              activeColor: Theme.of(context).primaryColor,
            ),
              ),
          const Divider(height: 1),
          
          // 计划监控
          ListTile(
            enabled: _notificationsEnabled,
            title: const Text('启用计划开始提醒'),
            subtitle: Text(_monitoringActive ? '已启用，将在计划开始时收到提醒' : '未启用，不会在计划开始时收到提醒'),
            trailing: Switch(
              value: _monitoringActive && _notificationsEnabled,
              onChanged: _notificationsEnabled
                ? (value) async {
                    if (value) {
                      await _monitorService.startMonitoring();
                    } else {
                      _monitorService.stopMonitoring();
  }
                    setState(() {
                      _monitoringActive = _monitorService.isRunning;
                    });
                  }
                : null,
              activeColor: Theme.of(context).primaryColor,
        ),
      ),
          const Divider(height: 1),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '测试',
              style: TextStyle(
                    fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                  ),
                ),
          ),
          
          // 测试计划开始提醒按钮
          InkWell(
            onTap: () {
              debugPrint('测试计划开始提醒按钮被点击');
              _testPlanStartReminder();
            },
            child: const ListTile(
              title: Text('测试计划开始提醒'),
              subtitle: Text('发送一条计划开始提醒，按设置选择通知类型'),
              leading: Icon(Icons.notification_important, color: Colors.orange),
        ),
      ),
          const Divider(height: 1),
          
          // 测试通知按钮
          InkWell(
            onTap: () {
              debugPrint('测试通知按钮被点击');
              _sendTestNotification();
            },
            child: const ListTile(
              title: Text('测试通知'),
              subtitle: Text('发送一条测试通知以检查通知功能是否正常'),
              leading: Icon(Icons.notifications),
                ),
          ),
          const Divider(height: 1),
          
          // 测试闹钟通知按钮
          InkWell(
            onTap: () {
              debugPrint('测试闹钟通知按钮被点击');
              _sendAlarmNotification();
            },
            child: const ListTile(
              title: Text('测试闹钟通知'),
              subtitle: Text('发送一条像闹钟一样的通知，带有持续声音和强烈震动'),
              leading: Icon(Icons.alarm, color: Colors.red),
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
  
  Future<void> _sendTestNotification() async {
    debugPrint('测试通知按钮被点击');
    if (!_notificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('通知功能已禁用，请先启用通知'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final progressIndicator = const CircularProgressIndicator();
    final snackBar = SnackBar(
      content: Row(
        children: [
          progressIndicator,
          const SizedBox(width: 10),
          const Text('发送中...'),
              ],
            ),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      // 测试发送即时通知
      await _reminderService.showTestNotification(
        playSound: _soundEnabled,
        enableVibration: _vibrationEnabled,
                  );
      
      // 显示提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('测试通知已发送，请检查设备通知栏'),
            duration: Duration(seconds: 2),
              ),
        );
      }
    } catch (e) {
      debugPrint('发送测试通知失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发送通知失败: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
      ),
    );
  }
  }

  Future<void> _sendAlarmNotification() async {
    debugPrint('测试闹钟通知按钮被点击');
    if (!_notificationsEnabled || !_soundEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('通知功能或声音已禁用，请先启用'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final progressIndicator = const CircularProgressIndicator();
    final snackBar = SnackBar(
      content: Row(
        children: [
          progressIndicator,
          const SizedBox(width: 10),
          const Text('发送中...'),
              ],
            ),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      // 测试发送闹钟通知
      await _reminderService.showAlarmNotification();
      
      // 显示提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('闹钟式通知已发送，请检查设备通知栏'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('发送闹钟通知失败: $e');
              ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发送通知失败: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testPlanStartReminder() async {
    debugPrint('测试计划开始提醒按钮被点击');
    if (!_notificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('通知功能已禁用，请先启用通知'),
          duration: Duration(seconds: 2),
        ),
              );
      return;
    }

    final progressIndicator = const CircularProgressIndicator();
    final snackBar = SnackBar(
      content: Row(
        children: [
          progressIndicator,
          const SizedBox(width: 10),
          const Text('发送中...'),
        ],
      ),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      await _monitorService.sendReminder(
        playSound: _soundEnabled,
        enableVibration: _vibrationEnabled,
        useAlarm: _useAlarmForPlanStart,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('计划开始提醒已发送，请检查设备通知栏'),
            duration: Duration(seconds: 2),
            ),
        );
      }
    } catch (e) {
      debugPrint('发送计划开始提醒失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发送提醒失败: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
      ),
    );
    }
  }
} 