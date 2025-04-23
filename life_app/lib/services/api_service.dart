import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/auth_token_model.dart';
import '../services/auth_service.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });
}

class ApiService {
  final http.Client _client = http.Client();
  
  // GET请求
  Future<Map<String, dynamic>> get({
    required String path,
    Map<String, String>? params,
    BuildContext? context,
  }) async {
    try {
      // 创建 URI，包含查询参数
      final uri = params != null && params.isNotEmpty
          ? Uri.parse('${ApiConstants.baseUrl}$path').replace(queryParameters: params)
          : Uri.parse('${ApiConstants.baseUrl}$path');
      
      // 获取访问令牌 (如果有context)
      String? token;
      if (context != null) {
        try {
          final authService = Provider.of<AuthService>(context, listen: false);
          token = authService.tokens?.accessToken;
        } catch (e) {
          print('获取令牌失败: $e');
        }
      }
      
      // 设置请求头，如果有token则添加授权头
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      // 打印请求信息
      print('发送GET请求: $uri');
      print('请求参数: $params');
      
      // 发送请求
      final response = await http.get(uri, headers: headers);
      
      // 打印响应信息
      print('响应状态码: ${response.statusCode}');
      print('响应头: ${response.headers}');
      
      // 解析响应数据
      final jsonData = json.decode(response.body);
      print('响应数据: $jsonData');
      
      return jsonData;
    } catch (e) {
      print('GET请求失败: $e');
      return {
        'code': -1,
        'message': e.toString(),
      };
    }
  }
  
  // POST请求
  Future<Map<String, dynamic>> post({
    required String path,
    dynamic data,
    BuildContext? context,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$path');
      
      // 获取访问令牌 (如果有context)
      String? token;
      if (context != null) {
        try {
          final authService = Provider.of<AuthService>(context, listen: false);
          token = authService.tokens?.accessToken;
        } catch (e) {
          print('获取令牌失败: $e');
        }
      }
      
      // 设置请求头，如果有token则添加授权头
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      // 转换请求数据为JSON
      final body = data != null ? json.encode(data) : null;
      
      // 打印请求信息
      print('发送POST请求: $uri');
      print('请求数据: $data');
      
      // 发送请求
      final response = await http.post(uri, headers: headers, body: body);
      
      // 打印响应信息
      print('响应状态码: ${response.statusCode}');
      print('响应头: ${response.headers}');
      
      // 解析响应数据
      final jsonData = json.decode(response.body);
      print('响应数据: $jsonData');
      
      return jsonData;
    } catch (e) {
      print('POST请求失败: $e');
      return {
        'code': -1,
        'message': e.toString(),
      };
    }
  }
  
  // PUT请求
  Future<Map<String, dynamic>> put({
    required String path,
    dynamic data,
    BuildContext? context,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$path');
      
      // 获取访问令牌 (如果有context)
      String? token;
      if (context != null) {
        try {
          final authService = Provider.of<AuthService>(context, listen: false);
          token = authService.tokens?.accessToken;
        } catch (e) {
          print('获取令牌失败: $e');
        }
      }
      
      // 设置请求头，如果有token则添加授权头
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      // 转换请求数据为JSON
      final body = data != null ? json.encode(data) : null;
      
      // 打印请求信息
      print('发送PUT请求: $uri');
      print('请求数据: $data');
      
      // 发送请求
      final response = await http.put(uri, headers: headers, body: body);
      
      // 打印响应信息
      print('响应状态码: ${response.statusCode}');
      print('响应头: ${response.headers}');
      
      // 解析响应数据
      final jsonData = json.decode(response.body);
      print('响应数据: $jsonData');
      
      return jsonData;
    } catch (e) {
      print('PUT请求失败: $e');
      return {
        'code': -1,
        'message': e.toString(),
      };
    }
  }
  
  // DELETE请求
  Future<Map<String, dynamic>> delete({
    required String path,
    Map<String, String>? params,
    BuildContext? context,
  }) async {
    try {
      // 构建URL，添加查询参数
      var uri = Uri.parse('${ApiConstants.baseUrl}$path');
      if (params != null && params.isNotEmpty) {
        uri = uri.replace(queryParameters: params);
      }
      
      // 获取访问令牌 (如果有context)
      String? token;
      if (context != null) {
        try {
          final authService = Provider.of<AuthService>(context, listen: false);
          token = authService.tokens?.accessToken;
          if (token != null) {
            print('删除请求使用令牌: ${token.substring(0, math.min(10, token.length))}...');
          } else {
            print('警告: DELETE请求无法获取访问令牌');
          }
        } catch (e) {
          print('获取令牌失败: $e');
        }
      } else {
        print('警告: DELETE请求无上下文，无法获取授权令牌');
      }
      
      // 设置请求头，如果有token则添加授权头
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      // 打印请求信息
      print('发送DELETE请求: $uri');
      print('请求头: $headers');
      print('请求参数: $params');
      
      // 发送请求
      print('即将发送DELETE请求到服务器...');
      final response = await http.delete(uri, headers: headers);
      
      // 打印响应信息
      print('DELETE响应状态码: ${response.statusCode}');
      print('DELETE响应头: ${response.headers}');
      print('DELETE响应体原始内容: ${response.body}');
      
      // 解析响应数据
      Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(response.body);
        print('DELETE响应数据: $jsonData');
      } catch (jsonError) {
        print('DELETE响应JSON解析错误: $jsonError');
        jsonData = {
          'code': -1,
          'message': '服务器返回数据解析失败: $jsonError',
        };
      }
      
      return jsonData;
    } catch (e) {
      print('DELETE请求失败: $e');
      return {
        'code': -1,
        'message': e.toString(),
      };
    }
  }
  
  // 通用的HTTP请求方法
  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Map<String, dynamic>? data,
    String? token,
    bool isRetry = false, // 是否为重试请求
    BuildContext? context,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl + path);
    
    // 准备请求头
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      try {
        final previewLength = token.length > 10 ? 10 : token.length;
        print('添加授权头: Bearer ${token.substring(0, previewLength)}...');
        headers['Authorization'] = 'Bearer $token';
      } catch (e) {
        print('添加授权头时出错: $e, token长度: ${token.length}');
        // 即使出错也使用原始令牌
        headers['Authorization'] = 'Bearer $token';
      }
    } else {
      print('警告: 没有提供授权令牌，请求将以未认证状态发送');
    }
    
    http.Response response;
    
    try {
      print('发送 $method 请求到 $url');
      print('请求头: $headers');
      if (data != null) {
        print('请求体: ${json.encode(data)}');
      }
      
      if (method == 'GET') {
        response = await _client.get(url, headers: headers);
      } else if (method == 'POST') {
        response = await _client.post(
          url,
          headers: headers,
          body: data != null ? json.encode(data) : null,
        );
      } else if (method == 'PUT') {
        response = await _client.put(
          url,
          headers: headers,
          body: data != null ? json.encode(data) : null,
        );
      } else if (method == 'DELETE') {
        response = await _client.delete(url, headers: headers);
      } else {
        throw Exception('不支持的HTTP方法: $method');
      }
      
      print('响应状态码: ${response.statusCode}');
      print('响应头: ${response.headers}');
      
      // 解析响应体，处理各种可能的错误情况
      Map<String, dynamic> responseData;
      try {
        // 检查响应体是否为空
        if (response.bodyBytes.isEmpty) {
          print('响应体为空 - 状态码: ${response.statusCode}');
          throw FormatException('服务器返回了空响应');
        }
        
        // 尝试解析JSON
        responseData = json.decode(utf8.decode(response.bodyBytes));
      } catch (e) {
        // 捕获JSON解析错误
        print('响应体解析错误: ${e.toString()} - 状态码: ${response.statusCode}');
        print('原始响应体: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}');
        throw Exception('系统繁忙，请稍后再试');
      }
      
      // 输出详细的响应信息
      print('响应数据: $responseData');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 成功的响应
        return responseData;
      } else {
        // 处理授权错误，包括多种可能的错误码形式
        if (!isRetry && context != null && 
            (response.statusCode == 401 || 
             responseData['code'] == 401 || 
             responseData['code'] == -401 || 
             (responseData['message'] != null && responseData['message'].toString().contains('登录')))) {
             
          print('检测到授权错误，尝试刷新令牌');
          
          try {
            final authService = Provider.of<AuthService>(context, listen: false);
            if (authService.tokens == null || authService.tokens!.refreshToken.isEmpty) {
              print('刷新令牌不存在或为空，无法刷新');
              throw Exception('登录已过期，请重新登录');
            }
            
            print('开始刷新令牌，当前刷新令牌: ${authService.tokens!.refreshToken.substring(0, 10)}...');
            final refreshSuccess = await authService.refreshTokens(context: context);
            
            if (refreshSuccess) {
              print('令牌刷新成功，重试原始请求');
              final newToken = authService.tokens?.accessToken;
              print('新的访问令牌: ${newToken?.substring(0, math.min(10, newToken?.length ?? 0))}...');
              
              // 使用新令牌重试原请求
              return _request(
                method: method,
                path: path,
                data: data,
                token: newToken,
                isRetry: true, // 标记为重试请求以避免无限循环
                context: context,
              );
            } else {
              print('令牌刷新失败，需要重新登录');
              authService.logout(); // 清除登录状态
              throw Exception('登录已过期，请重新登录');
            }
          } catch (refreshError) {
            print('刷新令牌过程发生错误: $refreshError');
            throw Exception('登录已过期，请重新登录');
          }
        }
        
        // 非登录态失效错误或重试失败
        final errorMsg = responseData['message'] ?? '请求失败 (${response.statusCode})';
        final errorDetail = responseData['error'] ?? '';
        print('原始错误信息: $errorMsg, 详情: $errorDetail');
        
        // 返回原始错误信息
        throw Exception(errorMsg);
      }
    } catch (e) {
      // 记录原始错误信息，但向用户展示简化的错误
      print('原始错误信息: ${e.toString()}');
      throw Exception(e.toString().contains('登录已过期') ? e.toString() : '系统繁忙，请稍后再试');
    }
  }
  
  // 发送短信验证码
  Future<ApiResponse<void>> sendSMSCode(String phone) async {
    try {
      final response = await _request(
        method: 'POST',
        path: ApiConstants.sendSMSCode,
        data: {
          'phone': phone,
        },
      );
      
      return ApiResponse(
        success: response['code'] == 0,
        message: response['message'] ?? '验证码发送成功',
      );
    } catch (e) {
      // 记录原始错误信息到日志
      print('原始验证码错误: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: '系统繁忙，请稍后再试',
        error: '系统繁忙',
      );
    }
  }
  
  // 使用短信验证码登录
  Future<ApiResponse<Map<String, dynamic>>> loginWithSMS(String phone, String code) async {
    try {
      final response = await _request(
        method: 'POST',
        path: ApiConstants.login,
        data: {
          'phone': phone,
          'code': code,
          'deviceInfo': {
            'deviceId': 'flutter_device',
            'platform': 'flutter',
            'version': '1.0.0',
          },
        },
      );
      
      // 新的统一响应处理
      if (response['code'] == 0) {
        // 成功响应
        Map<String, dynamic> authData;
        if (response.containsKey('data')) {
          authData = response['data'];
        } else {
          // 如果没有data字段，直接使用response作为数据
          // 移除非数据字段
          authData = Map<String, dynamic>.from(response);
          authData.remove('code');
          authData.remove('message');
        }
        
        final user = User.fromJson(authData['user']);
        final tokens = AuthTokens.fromJson(authData);
        
        return ApiResponse(
          success: true,
          message: response['message'] ?? '登录成功',
          data: {
            'user': user,
            'tokens': tokens,
          },
        );
      } else {
        // 错误响应
        // 记录原始错误信息到日志
        print('原始登录错误: ${response['message']}, 错误码: ${response['code']}');
        return ApiResponse(
          success: false,
          message: response['message'] ?? '系统繁忙，请稍后再试',
          error: response['error'] ?? '系统繁忙',
        );
      }
    } catch (e) {
      // 记录原始错误信息到日志
      print('原始登录异常: ${e.toString()}');
      
      // 提取异常中的错误消息
      String errorMessage = '系统繁忙，请稍后再试';
      if (e is Exception) {
        // 如果是异常对象，尝试提取其消息
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      
      return ApiResponse(
        success: false,
        message: errorMessage,
        error: '系统繁忙',
      );
    }
  }
  
  // 注册新用户
  Future<ApiResponse<Map<String, dynamic>>> register(String phone, String code, String nickname) async {
    try {
      final response = await _request(
        method: 'POST',
        path: ApiConstants.register,
        data: {
          'phone': phone,
          'code': code,
          'nickname': nickname,
        },
      );
      
      // 新的统一响应处理
      if (response['code'] == 0) {
        // 成功响应
        Map<String, dynamic> authData;
        if (response.containsKey('data')) {
          authData = response['data'];
        } else {
          // 如果没有data字段，直接使用response作为数据
          // 移除非数据字段
          authData = Map<String, dynamic>.from(response);
          authData.remove('code');
          authData.remove('message');
        }
        
        final user = User.fromJson(authData['user']);
        final tokens = AuthTokens.fromJson(authData);
        
        return ApiResponse(
          success: true,
          message: response['message'] ?? '注册成功',
          data: {
            'user': user,
            'tokens': tokens,
          },
        );
      } else {
        // 错误响应
        // 记录原始错误信息到日志
        print('原始注册错误: ${response['message']}, 错误码: ${response['code']}');
        return ApiResponse(
          success: false,
          message: response['message'] ?? '系统繁忙，请稍后再试',
          error: response['error'] ?? '系统繁忙',
        );
      }
    } catch (e) {
      // 记录原始错误信息到日志
      print('原始注册异常: ${e.toString()}');
      // 提取异常中的错误消息
      String errorMessage = '系统繁忙，请稍后再试';
      if (e is Exception) {
        // 如果是异常对象，尝试提取其消息
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      
      return ApiResponse(
        success: false,
        message: errorMessage,
        error: '系统繁忙',
      );
    }
  }
  
  // 刷新访问令牌
  Future<ApiResponse<AuthTokens>> refreshToken(String refreshToken, {BuildContext? context}) async {
    try {
      print('开始刷新令牌...');
      final response = await _request(
        method: 'POST',
        path: ApiConstants.refreshToken,
        data: {
          'refresh_token': refreshToken,  // 与后端参数匹配
        },
        context: context,  // 传递上下文
      );
      
      if (response['code'] == 0 && response['data'] != null) {
        print('令牌刷新成功，解析响应数据...');
        print('响应数据: ${response['data']}');
        
        // 根据后端响应结构创建 AuthTokens 对象
        final data = response['data'] as Map<String, dynamic>;
        final tokens = AuthTokens(
          accessToken: data['token'] ?? '',
          refreshToken: data['refreshToken'] ?? '',
          expiresIn: data['expiresIn'] ?? 3600,
          tokenType: data['tokenType'] ?? 'Bearer',
        );
        
        return ApiResponse(
          success: true,
          message: response['message'] ?? '令牌刷新成功',
          data: tokens,
        );
      } else {
        // 记录原始错误信息到日志
        print('原始刷新令牌错误: ${response['message']}');
        return ApiResponse(
          success: false,
          message: response['message'] ?? '令牌刷新失败',
          error: response['message'] ?? '令牌刷新失败',
        );
      }
    } catch (e) {
      // 记录原始错误信息到日志
      print('原始刷新令牌异常: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: e.toString().contains('登录已过期') ? '登录已过期，请重新登录' : '令牌刷新失败',
        error: e.toString(),
      );
    }
  }
}
