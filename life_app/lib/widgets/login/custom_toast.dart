import 'package:flutter/material.dart';

enum ToastType { success, warning, error, info }

void showCustomToast(BuildContext context, String message, ToastType type) {
  // 确保消息不为空
  if (message.isEmpty) {
    message = '系统繁忙，请稍后再试';
  }
  
  // 打印消息到控制台，方便调试
  print('显示Toast: $message, 类型: $type');
  
  // 清除之前可能存在的toast
  ScaffoldMessenger.of(context).clearSnackBars();
  
  // 根据类型设置颜色和图标
  IconData icon;
  Color color;
  
  switch (type) {
    case ToastType.success:
      icon = Icons.check_circle_outline;
      color = Colors.green;
      break;
    case ToastType.warning:
      icon = Icons.warning_amber_outlined;
      color = Colors.orange;
      break;
    case ToastType.error:
      icon = Icons.error_outline;
      color = Colors.red;
      break;
    case ToastType.info:
    default:
      icon = Icons.info_outline;
      color = Colors.blue;
      break;
  }
  
  // 使用Future.microtask确保在当前帧结束后显示SnackBar
  Future.microtask(() {
    try {
      // 确保ScaffoldMessenger可用
      if (ScaffoldMessenger.maybeOf(context) != null) {
        // 显示新的toast
        final snackBar = SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4), // 增加显示时间
          action: SnackBarAction(
            label: '关闭',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        // 如果ScaffoldMessenger不可用，回退到使用普通警告对话框
        print('警告: ScaffoldMessenger不可用，无法显示SnackBar');
      }
    } catch (e) {
      print('在显示SnackBar时出错: $e');
    }
  });
}
