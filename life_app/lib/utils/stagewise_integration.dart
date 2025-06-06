import 'package:flutter/foundation.dart';
// 条件导入，确保只在Web平台引用dart:html
import 'stagewise_web.dart' if (dart.library.io) 'stagewise_stub.dart';

/// Stagewise开发工具集成
/// 只在Web平台的Debug模式下生效
class StagewiseIntegration {
  /// 初始化Stagewise工具
  static void initialize() {
    if (kDebugMode && kIsWeb) {
      // 调用平台特定的实现
      StagewiseImplementation.injectStagewiseScript();
    }
  }
} 