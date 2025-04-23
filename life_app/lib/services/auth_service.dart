import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // 添加Material导入以获取BuildContext
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/auth_token_model.dart';
import 'api_service.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  AuthTokens? _tokens;
  final ApiService _apiService = ApiService();
  
  User? get currentUser => _currentUser;
  AuthTokens? get tokens => _tokens;
  bool get isLoggedIn => _currentUser != null && _tokens != null;
  
  // 初始化方法 - 在应用启动时调用，尝试从本地存储恢复用户会话
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final tokensJson = prefs.getString('tokens');
    
    if (userJson != null && tokensJson != null) {
      try {
        _currentUser = User.fromJson(json.decode(userJson));
        _tokens = AuthTokens.fromJson(json.decode(tokensJson));
        notifyListeners();
        return true;
      } catch (e) {
        // 解析错误，清除存储
        await prefs.remove('user');
        await prefs.remove('tokens');
      }
    }
    
    return false;
  }
  
  // 使用短信验证码登录
  Future<ApiResponse<void>> loginWithSMS(String phone, String code) async {
    final response = await _apiService.loginWithSMS(phone, code);
    
    if (response.success && response.data != null) {
      _currentUser = response.data!['user'];
      _tokens = response.data!['tokens'];
      
      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_currentUser!.toJson()));
      await prefs.setString('tokens', json.encode(_tokens!.toJson()));
      
      notifyListeners();
    }
    
    return ApiResponse(
      success: response.success,
      message: response.message,
      error: response.error,
    );
  }
  
  // 发送短信验证码
  Future<ApiResponse<void>> sendSMSCode(String phone) async {
    return await _apiService.sendSMSCode(phone);
  }
  
  // 注册新用户
  Future<ApiResponse<void>> register(String phone, String code, String nickname) async {
    final response = await _apiService.register(phone, code, nickname);
    
    if (response.success && response.data != null) {
      _currentUser = response.data!['user'];
      _tokens = response.data!['tokens'];
      
      // 保存到本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_currentUser!.toJson()));
      await prefs.setString('tokens', json.encode(_tokens!.toJson()));
      
      notifyListeners();
    }
    
    return ApiResponse(
      success: response.success,
      message: response.message,
      error: response.error,
    );
  }
  
  // 刷新令牌
  Future<bool> refreshTokens({BuildContext? context}) async {
    if (_tokens == null) return false;
    
    print('开始刷新令牌，当前刷新令牌: ${_tokens!.refreshToken.substring(0, 10)}...');
    final response = await _apiService.refreshToken(_tokens!.refreshToken, context: context);
    
    if (response.success && response.data != null) {
      // 使用空安全操作符
      print('令牌刷新成功, 新AccessToken: ${response.data?.accessToken?.substring(0, 10) ?? 'unknown'}...');
      _tokens = response.data;
      
      // 更新本地存储中的令牌
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tokens', json.encode(_tokens!.toJson()));
      
      notifyListeners();
      return true;
    } else {
      // 刷新失败，记录错误
      print('令牌刷新失败: ${response.message}');
      return false;
    }
  }
  
  // 登出
  Future<void> logout() async {
    _currentUser = null;
    _tokens = null;
    
    // 清除本地存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('tokens');
    
    notifyListeners();
  }
  
  // 更新用户信息
  Future<void> updateUserInfo({String? nickname, String? avatar, String? phone}) async {
    if (_currentUser == null) return;
    
    // 创建新的用户对象，替换现有信息
    final updatedUser = User(
      id: _currentUser!.id,
      phone: phone ?? _currentUser!.phone,
      nickname: nickname ?? _currentUser!.nickname,
      avatar: avatar ?? _currentUser!.avatar,
      status: _currentUser!.status,
      createdAt: _currentUser!.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
    
    _currentUser = updatedUser;
    
    // 保存到本地存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(_currentUser!.toJson()));
    
    notifyListeners();
  }
}
