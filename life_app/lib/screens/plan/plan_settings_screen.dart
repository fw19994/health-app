import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/reminder_service.dart';
import '../../services/plan_monitor_service.dart';
import '../../services/foreground_service.dart';
import '../../widgets/common/app_alert_dialog.dart';
import '../../widgets/plan/plan_monitor_status_badge.dart';

class PlanSettingsScreen extends StatefulWidget {
  const PlanSettingsScreen({super.key});

  @override
  State<PlanSettingsScreen> createState() => _PlanSettingsScreenState();
}

class _PlanSettingsScreenState extends State<PlanSettingsScreen> {
  // 设置状态
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _monitoringActive = false;
  
  // 服务实例
  late ReminderService _reminderService;
  late PlanMonitorService _monitorService;
  
  @override
  void initState() {
    super.initState();
    
    _reminderService = Provider.of<ReminderService>(context, listen: false);
    _monitorService = Provider.of<PlanMonitorService>(context, listen: false);
    
    // 加载设置
    _loadSettings();
  }
  
  // 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notification_enabled') ?? true;
      _soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('notification_vibration_enabled') ?? true;
      _monitoringActive = _monitorService.isRunning;
    });
  }
  
  // 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', _notificationsEnabled);
    await prefs.setBool('notification_sound_enabled', _soundEnabled);
    await prefs.setBool('notification_vibration_enabled', _vibrationEnabled);
  }
  
  // 测试计划提醒
  Future<void> _testPlanStartReminder() async {
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
      );
      
      if (mounted) {
        // 显示提示信息，说明提醒类型是基于声音设置的
        final reminderType = _soundEnabled ? '闹钟式提醒' : '普通提醒';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('测试$reminderType已发送，请检查设备通知栏'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('发送测试计划提醒失败: $e');
      if (mounted) {
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

  // 发送测试通知
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

  // 发送闹钟通知
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
      await _reminderService.showAlarmNotification(
        title: '测试闹钟通知',
        body: '这是一条测试闹钟通知，带有持续声音和强烈震动',
        payload: 'test_alarm',
      );
      
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
  
  // 请求禁用电池优化
  Future<void> _requestBatteryOptimizationDisable() async {
    try {
      // 跳转至电池优化设置页面
      await openAppSettings();
      
      // 显示指导提示
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('电池优化设置指南'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('请按照以下步骤操作:'),
                  SizedBox(height: 8),
                  Text('1. 找到"悦管家"应用'),
                  Text('2. 点击"电池"或"电池优化"选项'),
                  Text('3. 选择"不优化"或"允许后台活动"'),
                  Text('4. 保存设置并返回应用'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('知道了'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint('无法打开应用设置: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法打开设置，请手动在系统设置中调整电池优化')),
      );
    }
  }
  
  // 重置后台任务
  Future<void> _resetBackgroundTasks() async {
    final progressIndicator = const CircularProgressIndicator();
    final snackBar = SnackBar(
      content: Row(
        children: [
          progressIndicator,
          const SizedBox(width: 10),
          const Text('重置中...'),
        ],
      ),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    
    try {
      // 先停止监控服务
      await _monitorService.stopMonitoring();
      
      // 等待一秒
      await Future.delayed(Duration(seconds: 1));
      
      // 重新启动监控服务
      await _monitorService.startMonitoring();
      
      setState(() {
        _monitoringActive = _monitorService.isRunning;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('后台任务已重置'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('重置后台任务失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重置失败: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          
          // 后台任务状态
          ListTile(
            title: const Text('后台提醒服务'),
            subtitle: Text(_monitoringActive 
                ? '后台服务已启用，应用关闭后也能收到提醒' 
                : '后台服务未启用，应用关闭后将无法收到提醒'),
            leading: Icon(
              _monitoringActive ? Icons.cloud_done : Icons.cloud_off,
              color: _monitoringActive ? Colors.green : Colors.grey,
            ),
          ),
          
          // 电池优化提示
          Material(
            color: Colors.yellow[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.battery_alert, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        '电池优化提示', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '为确保计划提醒正常工作，请在系统设置中关闭本应用的电池优化，允许应用在后台运行。',
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _requestBatteryOptimizationDisable();
                    },
                    child: Text('前往设置'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400],
                      foregroundColor: Colors.white,
                      minimumSize: Size(120, 36),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
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
          
          // 重置后台任务按钮
          InkWell(
            onTap: () {
              _resetBackgroundTasks();
            },
            child: const ListTile(
              title: Text('重置后台任务'),
              subtitle: Text('如果后台提醒不工作，可以尝试重置后台任务'),
              leading: Icon(Icons.refresh, color: Colors.blue),
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
} 