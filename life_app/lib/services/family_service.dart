import 'package:flutter/material.dart';
import './api_service.dart';
import '../models/family_model.dart';

class FamilyService {
  final ApiService _apiService;

  FamilyService() : _apiService = ApiService();

  // 获取用户的家庭列表
  Future<ApiResponse<List<Family>>> getFamilies({
    required BuildContext context,
  }) async {
    try {
      final response = await _apiService.get(
        path: '/api/v1/family/familyInfo/',
        context: context,
      );

      bool success = response['code'] == 0 || response['code'] == 200;
      
      if (success && response['data'] != null) {
        List<dynamic> dataList = [];
        
        // 处理不同格式的响应
        var rawData = response['data'];
        if (rawData is List) {
          dataList = rawData;
        } else if (rawData is Map && rawData.containsKey('items')) {
          dataList = rawData['items'] is List ? rawData['items'] : [];
        } else if (rawData is Map && rawData.containsKey('families')) {
          dataList = rawData['families'] is List ? rawData['families'] : [];
        }
        
        // 解析家庭对象
        final List<Family> families = [];
        for (var item in dataList) {
          try {
            families.add(Family.fromJson(item));
          } catch (parseError) {
            print('解析家庭数据失败: $parseError');
          }
        }
        
        return ApiResponse<List<Family>>(
          success: true,
          message: response['message'] ?? '获取成功',
          data: families,
        );
      } else {
        return ApiResponse<List<Family>>(
          success: false,
          message: response['message'] ?? '获取家庭列表失败',
          data: [],
        );
      }
    } catch (e) {
      print("Error in FamilyService.getFamilies: $e");
      return ApiResponse<List<Family>>(
        success: false,
        message: '获取家庭列表失败: $e',
        data: [],
      );
    }
  }

  // 创建新家庭
  Future<ApiResponse<Family>> createFamily({
    required BuildContext context,
    required String name,
    String? description,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description ?? '',
      };
      
      final response = await _apiService.post(
        path: '/api/v1/family/familyInfo/',
        data: data,
        context: context,
      );
      
      bool success = response['code'] == 0 || response['code'] == 200;
      
      if (success && response['data'] != null) {
        return ApiResponse<Family>(
          success: true,
          message: '创建成功',
          data: Family.fromJson(response['data']),
        );
      } else {
        return ApiResponse<Family>(
          success: false,
          message: response['message'] ?? '创建家庭失败',
          data: null,
        );
      }
    } catch (e) {
      print("Error in FamilyService.createFamily: $e");
      return ApiResponse<Family>(
        success: false,
        message: '创建家庭失败: $e',
        data: null,
      );
    }
  }

  // 更新家庭信息
  Future<ApiResponse<bool>> updateFamily({
    required BuildContext context,
    required int familyId,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    try {
      final data = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (isActive != null) 'is_active': isActive,
      };
      
      final response = await _apiService.put(
        path: '/api/v1/family/familyInfo/$familyId',
        data: data,
        context: context,
      );
      
      bool success = response['code'] == 0 || response['code'] == 200;
      
      return ApiResponse<bool>(
        success: success,
        message: success ? '更新成功' : (response['message'] ?? '更新家庭失败'),
        data: success,
      );
    } catch (e) {
      print("Error in FamilyService.updateFamily: $e");
      return ApiResponse<bool>(
        success: false,
        message: '更新家庭失败: $e',
        data: false,
      );
    }
  }

  // 删除家庭
  Future<ApiResponse<bool>> deleteFamily({
    required BuildContext context,
    required int familyId,
  }) async {
    try {
      final response = await _apiService.delete(
        path: '/api/v1/family/familyInfo/$familyId',
        context: context,
      );
      
      bool success = response['code'] == 0 || response['code'] == 200;
      
      return ApiResponse<bool>(
        success: success,
        message: success ? '删除成功' : (response['message'] ?? '删除家庭失败'),
        data: success,
      );
    } catch (e) {
      print("Error in FamilyService.deleteFamily: $e");
      return ApiResponse<bool>(
        success: false,
        message: '删除家庭失败: $e',
        data: false,
      );
    }
  }
  
  // 设置家庭状态
  Future<ApiResponse<bool>> setFamilyStatus({
    required BuildContext context,
    required int familyId,
    required bool isActive,
  }) async {
    try {
      final data = {
        'is_active': isActive,
      };
      
      final response = await _apiService.put(
        path: '/api/v1/family/familyInfo/$familyId/status',
        data: data,
        context: context,
      );
      
      bool success = response['code'] == 0 || response['code'] == 200;
      
      return ApiResponse<bool>(
        success: success,
        message: success ? (isActive ? '家庭已激活' : '家庭已停用') : (response['message'] ?? '设置家庭状态失败'),
        data: success,
      );
    } catch (e) {
      print("Error in FamilyService.setFamilyStatus: $e");
      return ApiResponse<bool>(
        success: false,
        message: '设置家庭状态失败: $e',
        data: false,
      );
    }
  }
  
  // 通过邀请码加入家庭
  Future<ApiResponse<Family>> joinFamilyByCode({
    required BuildContext context,
    required String code,
  }) async {
    try {
      final data = {
        'code': code,
      };
      
      final response = await _apiService.post(
        path: '/api/v1/family/familyInfo/join',
        data: data,
        context: context,
      );
      
      bool success = response['code'] == 0 || response['code'] == 200;
      
      if (success && response['data'] != null) {
        return ApiResponse<Family>(
          success: true,
          message: '加入家庭成功',
          data: Family.fromJson(response['data']),
        );
      } else {
        return ApiResponse<Family>(
          success: false,
          message: response['message'] ?? '加入家庭失败',
          data: null,
        );
      }
    } catch (e) {
      print("Error in FamilyService.joinFamilyByCode: $e");
      return ApiResponse<Family>(
        success: false,
        message: '加入家庭失败: $e',
        data: null,
      );
    }
  }
}

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