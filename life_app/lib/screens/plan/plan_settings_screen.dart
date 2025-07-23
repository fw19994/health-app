import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reminder_service.dart';

class PlanSettingsScreen extends StatelessWidget {
  const PlanSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取提醒服务实例
    final reminderService = Provider.of<ReminderService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('计划设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('测试通知'),
            subtitle: const Text('发送一条测试通知以检查通知功能是否正常'),
            trailing: const Icon(Icons.notifications),
            onTap: () async {
              // 测试发送即时通知
              await reminderService.showTestNotification();
              
              // 显示提示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('测试通知已发送，请检查设备通知栏'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
} 