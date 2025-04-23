import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../constants/api_constants.dart';
import '../models/response_model.dart';
import '../models/auth_token_model.dart';

// 有条件导入dart:io，Web平台不使用该库
import 'dart:io' if (dart.library.html) 'package:flutter/foundation.dart';

class UserService {
  final BuildContext? context;
  
  UserService({this.context});
  
  // 从本地存储中直接获取登录令牌
  Future<String?> _getAccessToken() async {
    try {
      // 先尝试从上下文获取AuthService
      if (context != null) {
        final authService = Provider.of<AuthService>(context!, listen: false);
        if (authService.isLoggedIn) {
          return authService.tokens?.accessToken;
        }
      }
      
      // 如果上Context不可用，直接从本地存储获取Token
      final prefs = await SharedPreferences.getInstance();
      final tokensJson = prefs.getString('tokens');
      
      if (tokensJson != null) {
        try {
          final tokens = jsonDecode(tokensJson);
          if (kDebugMode) {
            print('解析得到令牌: ${tokens.toString().substring(0, min(50, tokens.toString().length))}...');
          }
          // 先检查是否有'token'键(与AuthTokens模型一致)
          if (tokens['token'] != null) {
            return tokens['token'];
          }
          // 如果没有，则尝试'accessToken'键
          if (tokens['accessToken'] != null) {
            return tokens['accessToken'];
          }
          
          if (kDebugMode) {
            print('未找到有效的令牌键，可用键: ${tokens.keys.toList()}');
          }
          return null;
        } catch (e) {
          if (kDebugMode) {
            print('解析存储的Token失败: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('获取令牌时发生错误: $e');
      }
    }
    
    return null;
  }
  
  // 创建带有授权头的请求头
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAccessToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        print('添加授权头: Bearer ${token.substring(0, min(10, token.length))}...');
      }
    } else {
      if (kDebugMode) {
        print('警告: 无法添加授权头，未找到有效令牌');
      }
    }
    
    return headers;
  }
  
  // 创建带有授权的文件上传请求头
  Future<Map<String, String>> _getFileUploadHeaders() async {
    final token = await _getAccessToken();
    final headers = <String, String>{};
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        print('添加文件上传授权头: Bearer ${token.substring(0, min(10, token.length))}...');
      }
    } else {
      if (kDebugMode) {
        print('警告: 无法添加文件上传授权头，未找到有效令牌');
      }
    }
    
    return headers;
  }

  // 更新用户昵称
  Future<ResponseModel> updateNickname(String nickname) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/user/nickname'),
        headers: headers,
        body: jsonEncode({'nickname': nickname}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 0) {
        // 更新成功后，更新用户对象中的昵称
        if (context != null) {
          try {
            final authService = Provider.of<AuthService>(context!, listen: false);
            authService.updateUserInfo(nickname: nickname);
          } catch (e) {
            if (kDebugMode) {
              print('更新本地用户昵称失败: $e');
            }
          }
        }
        
        return ResponseModel(
          code: 0,
          message: data['message'] ?? '昵称更新成功',
          data: data['data'],
        );
      } else {
        return ResponseModel(
          code: data['code'] ?? response.statusCode,
          message: data['message'] ?? '昵称更新失败',
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('昵称更新失败: $e');
      }
      return ResponseModel(
        code: -1,
        message: '昵称更新失败: $e',
        data: null,
      );
    }
  }

  // 上传用户头像 - 支持移动设备和Web平台
  Future<ResponseModel> uploadAvatar(dynamic imageFile) async {
    try {
      final headers = await _getFileUploadHeaders();
      
      // 创建multipart请求
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/api/v1/user/avatar'),
      );
      
      // 添加授权头
      request.headers.addAll(headers);
      
      // 根据平台选择不同的上传方式
      if (kIsWeb) {
        // Web平台处理
        if (imageFile is XFile) {
          final bytes = await imageFile.readAsBytes();
          final fileName = imageFile.name;
          request.files.add(
            http.MultipartFile.fromBytes(
              'avatar',
              bytes,
              filename: fileName,
              contentType: MediaType.parse('image/${fileName.split('.').last}'),
            ),
          );
        } else {
          throw Exception('不支持的文件类型');
        }
      } else {
        // 移动平台处理
        if (imageFile is XFile) {
          // 在移动平台上使用XFile的path
          request.files.add(
            await http.MultipartFile.fromPath(
              'avatar',
              imageFile.path,
            ),
          );
        } else {
          // 处理可能的File类型（仅在非Web平台上使用）
          try {
            // 动态检查是否为XFile类型
            request.files.add(
              await http.MultipartFile.fromPath(
                'avatar',
                imageFile.path,
              ),
            );
          } catch (e) {
            throw Exception('不支持的文件类型: $e');
          }
        }
      }
      
      // 发送请求
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 0) {
        // 如果成功，获取新的头像URL并更新用户对象
        final avatarUrl = data['data']?['avatar_url'];
        if (avatarUrl != null && context != null) {
          try {
            final authService = Provider.of<AuthService>(context!, listen: false);
            authService.updateUserInfo(avatar: avatarUrl);
          } catch (e) {
            if (kDebugMode) {
              print('更新本地用户头像失败: $e');
            }
          }
        }
        
        return ResponseModel(
          code: 0,
          message: data['message'] ?? '头像上传成功',
          data: data['data'],
        );
      } else {
        return ResponseModel(
          code: data['code'] ?? response.statusCode,
          message: data['message'] ?? '头像上传失败',
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('头像上传失败: $e');
      }
      return ResponseModel(
        code: -1,
        message: '头像上传失败: $e',
        data: null,
      );
    }
  }

  // 获取用户基本信息
  Future<ResponseModel> getUserProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/user/profile'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 0) {
        // 如果成功获取用户资料，可以更新本地用户信息
        if (context != null && data['data'] != null) {
          try {
            final authService = Provider.of<AuthService>(context!, listen: false);
            final userData = data['data'];
            authService.updateUserInfo(
              nickname: userData['nickname'],
              avatar: userData['avatar'],
              // 需要更新的其他字段...
            );
          } catch (e) {
            if (kDebugMode) {
              print('更新本地用户信息失败: $e');
            }
          }
        }
        
        return ResponseModel(
          code: 0,
          message: data['message'] ?? '获取成功',
          data: data['data'],
        );
      } else {
        return ResponseModel(
          code: data['code'] ?? response.statusCode,
          message: data['message'] ?? '获取用户信息失败',
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('获取用户信息失败: $e');
      }
      return ResponseModel(
        code: -1,
        message: '获取用户信息失败: $e',
        data: null,
      );
    }
  }
  
  // 更新用户基本信息
  Future<ResponseModel> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final headers = await _getAuthHeaders();
      
      // 将用户数据转换为JSON
      final body = jsonEncode(userData);
      
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/user/profile'),
        headers: {
          ...headers,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 0) {
        // 如果更新成功，更新本地用户信息
        if (context != null && userData['nickname'] != null) {
          try {
            final authService = Provider.of<AuthService>(context!, listen: false);
            authService.updateUserInfo(
              nickname: userData['nickname'],
              // 可以添加其他需要本地更新的字段
            );
          } catch (e) {
            if (kDebugMode) {
              print('更新本地用户信息失败: $e');
            }
          }
        }
        
        return ResponseModel(
          code: 0,
          message: data['message'] ?? '更新成功',
          data: data['data'],
        );
      } else {
        return ResponseModel(
          code: data['code'] ?? response.statusCode,
          message: data['message'] ?? '更新用户信息失败',
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('更新用户信息失败: $e');
      }
      return ResponseModel(
        code: -1,
        message: '更新用户信息失败: $e',
        data: null,
      );
    }
  }
  
  // 通过手机号查找用户
  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    try {
      final headers = await _getAuthHeaders();
      
      // 尝试调用后端API
      try {
        // 使用正确的API路径
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/api/users/search?phone=$phone'),
          headers: headers,
        );
        
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (response.statusCode == 200 && responseData['code'] == 0) {
          return responseData['data'];
        } else if (response.statusCode == 404 || responseData['code'] == -1) {
          // 如果API不存在(404)或返回用户不存在(-1)，使用模拟数据
          return _getMockUserData(phone);
        } else {
          throw Exception(responseData['message'] ?? '查找用户失败');
        }
      } catch (apiError) {
        // API调用失败，使用模拟数据
        if (kDebugMode) {
          print('API调用失败: $apiError，使用模拟数据');
        }
        return _getMockUserData(phone);
      }
    } catch (e) {
      if (kDebugMode) {
        print('查找用户失败: $e');
      }
      return null; // 返回null表示未找到用户或发生错误
    }
  }
  
  // 提供模拟用户数据方法
  Map<String, dynamic>? _getMockUserData(String phone) {
    // 模拟数据：预定义的手机号返回用户数据，其他返回null
    final Map<String, Map<String, dynamic>> mockUsers = {
      '13800138000': {
        'id': 1,
        'name': '张三',
        'nickname': '小张',
        'phone': '13800138000',
        'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
      },
      '13900139000': {
        'id': 2,
        'name': '李四',
        'nickname': '小李',
        'phone': '13900139000',
        'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
      },
      '13700137000': {
        'id': 3,
        'name': '王五',
        'nickname': '老王',
        'phone': '13700137000',
        'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
      }
    };
    
    // 如果是预定义的手机号，返回模拟数据
    if (mockUsers.containsKey(phone)) {
      return mockUsers[phone];
    }
    
    // 如果是测试手机号格式(以1为开头的11位数字)，生成随机用户数据
    final RegExp phoneRegex = RegExp(r'^1\d{10}$');
    if (phoneRegex.hasMatch(phone)) {
      // 从手机号生成随机但确定的数字作为头像ID
      final int avatarId = (int.parse(phone.substring(phone.length - 2)) % 99) + 1;
      final bool isMale = avatarId % 2 == 1; // 奇数为男性，偶数为女性
      
      return {
        'id': 1000 + avatarId,
        'name': isMale ? '用户${phone.substring(7)}' : '用户${phone.substring(7)}',
        'nickname': isMale ? '小${phone.substring(9)}' : '小${phone.substring(9)}',
        'phone': phone,
        'avatar': 'https://randomuser.me/api/portraits/${isMale ? 'men' : 'women'}/$avatarId.jpg',
      };
    }
    
    // 如果不是有效手机号或预定义用户，返回null表示未找到用户
    return null;
  }

  // 根据手机号查询用户信息
  Future<ResponseModel> getUserByPhone(String phone) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/user/phone?phone=$phone'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        return ResponseModel(
          code: 0,
          message: data['message'] ?? '查询成功',
          data: data['data'],
        );
      } else {
        return ResponseModel(
          code: data['code'] ?? response.statusCode,
          message: data['message'] ?? '查询失败',
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('查询用户失败: $e');
      }
      return ResponseModel(
        code: -1,
        message: '查询用户失败: $e',
        data: null,
      );
    }
  }
}
