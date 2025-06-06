import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../models/family_member_model.dart';
import '../services/auth_service.dart';

class FamilyMemberService {
  final BuildContext? context;
  final ApiService _apiService = ApiService();
  
  FamilyMemberService({this.context});

  // 获取家庭成员列表
  Future<ApiResponse<List<FamilyMember>>> getFamilyMembers({int? familyId}) async {
    try {
      print('开始获取家庭成员列表...');
      // 检查授权状态
      if (context != null) {
        try {
          // 强制类型转换为非空上下文
          final BuildContext ctx = context!;
          final authService = Provider.of<AuthService>(ctx, listen: false);
          final token = authService.tokens?.accessToken;
          if (token != null) {
            print('使用令牌: ${token.substring(0, math.min(10, token.length))}...');
          } else {
            print('警告: 未找到访问令牌，请求可能会失败');
            // 如果没有令牌，返回空列表而不是尝试发送请求
            return ApiResponse<List<FamilyMember>>(
              success: true,
              message: '您尚未登录，请先登录账户',
              data: [],
            );
          }
          
          // 检查用户ID
          final userId = authService.currentUser?.id;
          if (userId == null || userId == 0) {
            print('警告: 未找到有效的用户ID');
            return ApiResponse<List<FamilyMember>>(
              success: true,
              message: '用户信息不完整',
              data: [],
            );
          }
          print('当前用户ID: $userId');
        } catch (e) {
          print('获取认证服务时出错: $e');
          // 继续执行，尝试不使用认证信息进行请求
        }
      }
      
      // 构建查询参数
      Map<String, String> params = {};
      if (familyId != null) {
        params['family_id'] = familyId.toString();
      }
      
      // 确保路径与后端路由完全一致
      print('调用API端点: GET /api/v1/family/members');
      final response = await _apiService.get(
        path: '/api/v1/family/members',
        params: params, // 添加查询参数
        context: context,
      );
      print('原始响应: $response');
      print('响应码: ${response['code']}, 消息: ${response['message']}');
      
      // 检查响应中是否有data字段并输出相关信息
      if (response.containsKey('data')) {
        final dataValue = response['data'];
        print('原始数据类型: ${dataValue?.runtimeType}');
        if (dataValue is List) {
          print('数据是列表，长度: ${dataValue.length}');
          if (dataValue.isNotEmpty) {
            print('第一个元素示例: ${dataValue.first}');
            if (dataValue.first is Map) {
              print('元素字段: ${(dataValue.first as Map).keys.toList()}');
            }
          } else {
            print('列表为空');
          }
        } else if (dataValue is Map) {
          print('数据是对象，字段: ${dataValue.keys.toList()}');
          // 如果包含members字段，可能数据嵌套在里面
          if (dataValue.containsKey('members') && dataValue['members'] is List) {
            print('找到members字段，长度: ${(dataValue['members'] as List).length}');
          }
        } else {
          print('数据类型非列表也非对象: $dataValue');
        }
      } else {
        print('响应中没有data字段，只有的字段: ${response.keys.toList()}');
      }
      
      if (response['code'] == 0) {
        // 防止数据为null
        if (response['data'] == null) {
          print('警告: 数据为空');
          return ApiResponse<List<FamilyMember>>(
            success: true,
            message: '没有家庭成员数据',
            data: [],  // 返回空列表而不是null
          );
        }
        
        // 确保数据是一个列表
        var rawData = response['data'];
        List<dynamic> dataList;
        
        // 处理不同格式的响应
        if (rawData is List) {
          dataList = rawData;
        } else if (rawData is Map) {
          // 可能数据嵌套在另一个字段中
          if (rawData.containsKey('members')) {
            dataList = rawData['members'] is List ? rawData['members'] : [];
          } else if (rawData.containsKey('items')) {
            dataList = rawData['items'] is List ? rawData['items'] : [];
          } else if (rawData.containsKey('data')) {
            dataList = rawData['data'] is List ? rawData['data'] : [];
          } else {
            // 尝试查找带有数组的字段
            var arrayField = rawData.entries.firstWhere(
              (entry) => entry.value is List,
              orElse: () => MapEntry('', []),
            );
            dataList = arrayField.value is List ? arrayField.value : [];
          }
        } else {
          dataList = [];
        }
        
        print('处理后的数据列表长度: ${dataList.length}');
        
        // 解析成员对象
        final List<FamilyMember> members = [];
        for (var item in dataList) {
          try {
            print('解析成员: $item');
            members.add(FamilyMember.fromJson(item));
          } catch (parseError) {
            print('解析家庭成员数据失败: $parseError');
            print('数据: $item');
          }
        }
        
        print('成功解析 ${members.length} 个家庭成员');
        return ApiResponse<List<FamilyMember>>(
          success: true,
          message: response['message'] ?? '获取成功',
          data: members,
        );
      } else {
        print('从后端获取家庭成员失败: ${response['message']}');
        return ApiResponse<List<FamilyMember>>(
          success: false,
          message: response['message'] ?? '获取家庭成员失败',
          error: response['message'],
        );
      }
    } catch (e) {
      print('获取家庭成员时发生异常: $e');
      return ApiResponse<List<FamilyMember>>(
        success: false,
        message: '获取家庭成员失败',
        error: e.toString(),
      );
    }
  }

  // 添加家庭成员
  Future<ApiResponse<int>> addFamilyMember({
    int? userId,
    required String name,
    required String nickname,
    required String description,
    String? phone,
    required String role,
    String? gender,
    String? avatarUrl,
    required String permission,
    int? familyId, // 添加家庭ID参数
  }) async {
    try {
      final data = {
        'user_id': userId ?? 0, // 如果是虚拟成员，userID为0
        'name': name,
        'nickname': nickname,
        'description': description,
        'phone': phone ?? '',
        'role': role,
        'gender': gender ?? '',
        'avatar_url': avatarUrl ?? '',
        'permission': permission,
      };
      
      // 添加家庭ID参数，如果提供了
      if (familyId != null) {
        data['family_id'] = familyId.toString();
      }
      
      final response = await _apiService.post(
        path: '/api/v1/family/member',
        data: data,
        context: context,
      );
      
      if (response['code'] == 0) {
        return ApiResponse<int>(
          success: true,
          message: '成员添加成功',
          data: response['data']['id'],
        );
      } else {
        return ApiResponse<int>(
          success: false,
          message: response['message'],
          error: response['message'],
        );
      }
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        message: '添加家庭成员失败',
        error: e.toString(),
      );
    }
  }

  // 更新家庭成员
  Future<ApiResponse<bool>> updateFamilyMember({
    required int memberId,
    String? name,
    String? nickname,
    String? description,
    String? role,
    String? gender,
    String? permission,
    String? avatarUrl,
    int? familyId,
  }) async {
    try {
      final data = {
        'name': name,
        'nickname': nickname,
        'description': description,
        'role': role,
        'gender': gender,
        'permission': permission,
        'avatar_url': avatarUrl,
      };
      
      // 添加家庭ID参数，如果提供了
      if (familyId != null) {
        data['family_id'] = familyId.toString();
      }
      
      // 移除空值
      data.removeWhere((key, value) => value == null);
      
      final response = await _apiService.put(
        path: '/api/v1/family/member/$memberId',
        data: data,
        context: context,
      );
      
      if (response['code'] == 0) {
        return ApiResponse<bool>(
          success: true,
          message: '成员更新成功',
          data: true,
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          message: response['message'],
          error: response['message'],
        );
      }
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: '更新家庭成员失败',
        error: e.toString(),
      );
    }
  }

  // 移除家庭成员
  Future<ApiResponse<bool>> removeFamilyMember(int memberId, {int? familyId}) async {
    try {
      print('正在移除家庭成员 ID: $memberId');
      
      // 构建查询参数
      Map<String, String> params = {};
      if (familyId != null) {
        params['family_id'] = familyId.toString();
      }
      
      // 直接调用删除接口，不处理owner_id
      final response = await _apiService.delete(
        path: '/api/v1/family/member/$memberId',
        context: context,
        params: params, // 传递查询参数
      );
      
      print('删除成员响应: $response');
      
      if (response['code'] == 0) {
        return ApiResponse<bool>(
          success: true,
          message: '成员移除成功',
          data: true,
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          message: response['message'] ?? '删除失败',
          error: response['message'],
        );
      }
    } catch (e) {
      print('删除成员接口调用异常: $e');
      return ApiResponse<bool>(
        success: false,
        message: '移除家庭成员失败: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // 获取家庭角色和权限配置
  Future<ApiResponse<Map<String, dynamic>>> getFamilyRoles() async {
    try {
      final response = await _apiService.get(
        path: '/api/family/roles',
        context: context,
      );
      
      if (response['code'] == 0) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: '获取角色信息成功',
          data: response['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response['message'],
          error: response['message'],
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: '获取角色信息失败',
        error: e.toString(),
      );
    }
  }

  // 通过手机号查找用户
  Future<ApiResponse<Map<String, dynamic>>> findUserByPhone(String phone) async {
    try {
      final response = await _apiService.get(
        path: '/api/users/search?phone=$phone',
        context: context,
      );
      
      if (response['code'] == 0) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: '查找用户成功',
          data: response['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: response['message'],
          error: response['message'],
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: '查找用户失败',
        error: e.toString(),
      );
    }
  }
}
