package com.example.life_app;

import android.content.Intent;
import android.os.Build;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.life_app/foreground_service";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        // 注册方法通道，与Flutter层通信
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                // 处理Flutter发来的方法调用
                switch (call.method) {
                    case "startForegroundService":
                        String title = call.argument("title");
                        String content = call.argument("content");
                        startForegroundService(title, content);
                        result.success(true);
                        break;
                    case "stopForegroundService":
                        stopForegroundService();
                        result.success(true);
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            });
    }
    
    // 启动前台服务
    private void startForegroundService(String title, String content) {
        Intent serviceIntent = new Intent(this, ForegroundService.class);
        serviceIntent.putExtra("title", title);
        serviceIntent.putExtra("content", content);
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent);
        } else {
            startService(serviceIntent);
        }
    }
    
    // 停止前台服务
    private void stopForegroundService() {
        Intent serviceIntent = new Intent(this, ForegroundService.class);
        stopService(serviceIntent);
    }
}
