import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/plan_monitor_service.dart';

/// 计划监控状态徽章
/// 
/// 用于显示当前计划监控服务的状态
class PlanMonitorStatusBadge extends StatelessWidget {
  const PlanMonitorStatusBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanMonitorService>(
      builder: (context, service, _) {
        final bool isRunning = service.isRunning;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isRunning ? Colors.green[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRunning ? Colors.green : Colors.grey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isRunning ? Icons.notifications_active : Icons.notifications_off,
                size: 16,
                color: isRunning ? Colors.green[800] : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                isRunning ? '提醒已启用' : '提醒已关闭',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isRunning ? Colors.green[800] : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 