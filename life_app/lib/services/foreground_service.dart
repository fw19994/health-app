import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 前台服务管理
/// 
/// 用于在Android平台启动前台服务，保持应用在后台运行，确保计划提醒正常工作
class ForegroundServiceManager {
  static const _channel = MethodChannel('com.example.life_app/foreground_service');
  static bool _isRunning = false;
  
  /// 当前前台服务是否运行中
  static bool get isRunning => _isRunning;
  
  /// 启动前台服务
  /// 
  /// [title] 通知栏标题
  /// [content] 通知栏内容
  static Future<bool> startService({
    String title = '悦管家计划监控中',
    String content = '应用正在后台运行，以便及时提醒您的计划',
  }) async {
    if (!Platform.isAndroid) {
      debugPrint('前台服务仅支持Android平台');
      return false;
    }
    
    try {
      await _channel.invokeMethod('startForegroundService', {
        'title': title,
        'content': content,
      });
      _isRunning = true;
      debugPrint('前台服务已启动');
      return true;
    } on PlatformException catch (e) {
      debugPrint('启动前台服务失败: ${e.message}');
      return false;
    }
  }
  
  /// 停止前台服务
  static Future<bool> stopService() async {
    if (!Platform.isAndroid) {
      debugPrint('前台服务仅支持Android平台');
      return false;
    }
    
    try {
      await _channel.invokeMethod('stopForegroundService');
      _isRunning = false;
      debugPrint('前台服务已停止');
      return true;
    } on PlatformException catch (e) {
      debugPrint('停止前台服务失败: ${e.message}');
      return false;
    }
  }
} 