import 'package:flutter/material.dart';
import 'dart:ui';

enum DialogType { success, error, warning, info }

// 显示错误对话框
void showErrorDialog(BuildContext context, String message, {DialogType type = DialogType.error}) {
  // 确保消息不为空
  if (message.isEmpty) {
    message = '系统繁忙，请稍后再试';
  }
  
  // 根据类型确定图标、颜色、标题和动画
  IconData icon;
  Color color;
  String title;
  String buttonText;
  
  switch (type) {
    case DialogType.success:
      icon = Icons.check_circle_rounded;
      color = const Color(0xFF4CAF50);
      title = '操作成功';
      buttonText = '确定';
      break;
    case DialogType.warning:
      icon = Icons.warning_rounded;
      color = const Color(0xFFFFA726);
      title = '注意';
      buttonText = '知道了';
      break;
    case DialogType.info:
      icon = Icons.info_rounded;
      color = const Color(0xFF2196F3);
      title = '提示信息';
      buttonText = '知道了';
      break;
    case DialogType.error:
    default:
      icon = Icons.error_rounded;
      color = const Color(0xFFE53935);
      title = '操作失败';
      buttonText = '确定';
      break;
  }

  // 打印消息到控制台，方便调试
  print('显示对话框: $message, 类型: $type');
  
  // 使用Future.microtask确保在当前帧结束后显示对话框
  Future.microtask(() {
    try {
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: '',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (ctx, animation1, animation2) {
          return Container(); // 实际内容由transitionBuilder提供
        },
        transitionBuilder: (ctx, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOutCubic;
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );
          
          return ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 10,
                backgroundColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 图标
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 标题
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // 内容
                      Container(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF616161),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('显示错误对话框时出错: $e');
      // 尝试使用普通alert作为后备
      try {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(buttonText),
                ),
              ],
            );
          },
        );
      } catch (e2) {
        print('显示备用错误对话框也失败: $e2');
      }
    }
  });
}
