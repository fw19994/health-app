import 'package:flutter/material.dart';
import './api_service.dart'; // 导入 ApiService
import 'dart:convert'; // 用于 jsonEncode
import 'package:intl/intl.dart'; // 用于日期格式化

class FinanceService {
  final ApiService _apiService;

  // 恢复 BuildContext 参数，ApiService 需要它来获取认证令牌
  FinanceService() : _apiService = ApiService(); 

  /// 添加一笔交易记录
  Future<ApiResponse<void>> addTransaction({
    required BuildContext context, // 添加 context 参数用于获取认证令牌
    required String type, // "expense" or "income"
    required double amount,
    required int iconId,
    required DateTime date,
    String? merchant,
    String? notes,
    required int recorderId,
    bool? isFamilyExpense,
    String? imageUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'type': type,
        'amount': amount,
        'icon_id': iconId,
        'date': DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", 'en_US').format(date.toUtc()), 
        'recorder_id': recorderId,
      };
      
      if (merchant != null && merchant.isNotEmpty) {
        data['merchant'] = merchant;
      }
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }
      if (isFamilyExpense != null) {
        data['is_family_expense'] = isFamilyExpense;
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        data['image_url'] = imageUrl;
      }

      print("Sending transaction data: ${jsonEncode(data)}");

      // 传递 context 以便 ApiService 可以获取认证令牌
      final responseData = await _apiService.post(
        path: '/api/v1/finance/transaction', 
        data: data,
        context: context, // 传递 context 参数
      );

      print("Received response data: $responseData"); 
      
      bool success = responseData['code'] == 0 || responseData['code'] == 200;
      String message = responseData['message'] ?? (success ? '添加成功' : '添加失败');

      return ApiResponse<void>(
        success: success,
        message: message,
        error: success ? null : (responseData['error'] ?? message),
      );

    } catch (e) {
      print("Error in FinanceService.addTransaction: $e"); 
      return ApiResponse<void>(
        success: false, 
        message: '发生未知错误: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // 获取近期交易
  Future<ApiResponse> getRecentTransactions({
    required BuildContext context,
    required String type, // 'expense' 或 'income'
  }) async {
    try {
      final responseData = await _apiService.get(
        path: '/api/v1/finance/recent-transactions',
        params: {'type': type},
        context: context,
      );

      bool success = responseData['code'] == 0 || responseData['code'] == 200;
      return ApiResponse(
        success: success,
        data: success ? responseData['data'] : null,
        message: responseData['message'] ?? (success ? '获取成功' : '获取失败'),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '获取近期交易失败: $e',
      );
    }
  }
  
  /// 获取交易统计摘要
  Future<ApiResponse> getTransactionSummary({
    required BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    int? memberId,
    int? categoryId,
    List<int>? categoryIds,
    int? familyId,
  }) async {
    try {
      print('开始获取交易摘要：');
      if (startDate != null) print('  开始日期：${DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate)}');
      if (endDate != null) print('  结束日期：${DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate)}');
      if (type != null) print('  交易类型：$type');
      if (memberId != null) print('  成员ID：$memberId');
      if (categoryId != null) print('  分类ID：$categoryId');
      if (categoryIds != null) print('  多选分类：$categoryIds');
      if (familyId != null) print('  家庭ID：$familyId');
      
      // 构建查询参数
      Map<String, String> params = {};
      
      // 添加日期范围参数
      if (startDate != null) {
        params['start_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);
      }
      if (endDate != null) {
        params['end_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate);
      }
      
      // 添加其他可选参数
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }
      if (memberId != null) {
        params['member'] = memberId.toString();
      }
      
      // 添加家庭ID参数
      if (familyId != null) {
        params['family_id'] = familyId.toString();
      }
      
      // 统一处理分类ID参数
      List<int> allCategoryIds = [];
      
      
      // 如果有多个分类ID，添加到列表
      if (categoryIds != null && categoryIds.isNotEmpty) {
        allCategoryIds.addAll(categoryIds.where((id) => id > 0));
      }
      
      // 处理分类ID参数
      if (allCategoryIds.isNotEmpty) {
        // 使用categories[]格式传递所有分类ID
        for (int i = 0; i < allCategoryIds.length; i++) {
          params['categories[$i]'] = allCategoryIds[i].toString();
        }
        print('  处理后的分类ID：$allCategoryIds');
      } else {
        print('  未找到有效的分类ID');
      }
      
      print('发送请求参数：$params');
      
      // 调用API
      final responseData = await _apiService.get(
        path: '/api/v1/finance/transactions',
        params: params,
        context: context,
      );
      
      bool success = responseData['code'] == 0 || responseData['code'] == 200;
      
      return ApiResponse(
        success: success,
        data: success ? responseData['data'] : null,
        message: responseData['message'] ?? (success ? '获取成功' : '获取失败'),
      );
    } catch (e) {
      print("Error in FinanceService.getTransactionSummary: $e");
      return ApiResponse(
        success: false,
        message: '获取交易统计摘要失败: $e',
      );
    }
  }
  
  /// 获取交易趋势数据
  Future<ApiResponse> getTransactionTrend({
    required BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
    String interval = 'day', // 'day', 'week', 'month'
    String? type, // 可选参数，用于筛选特定类型：'expense' 或 'income'
    int? memberId, // 成员ID
    List<int>? categoryIds, // 分类ID列表
    int? familyId, // 家庭ID
  }) async {
    try {
      if (endDate == null) {
        endDate = DateTime.now();
      }
      
      // 根据interval设置默认的开始日期
      if (startDate == null) {
        switch (interval) {
          case 'day':
            startDate = endDate.subtract(const Duration(days: 30)); // 近30天
            break;
          case 'week':
            startDate = endDate.subtract(const Duration(days: 84)); // 近12周
            break;
          case 'month':
            startDate = DateTime(endDate.year - 1, endDate.month, 1); // 近12个月
            break;
          default:
            interval = 'day'; // 默认使用天为单位
            startDate = endDate.subtract(const Duration(days: 30)); // 近30天
        }
      }
      
      // 构建查询参数
      Map<String, String> params = {
        'start_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate),
        'interval': interval,
      };
      
      // 添加类型参数（如果有）
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }
      
      // 添加成员ID（如果有）
      if (memberId != null) {
        params['member'] = memberId.toString();
      }
      
      // 添加家庭ID参数
      if (familyId != null) {
        params['family_id'] = familyId.toString();
      }
      
      // 处理分类ID参数
      if (categoryIds != null && categoryIds.isNotEmpty) {
        // 过滤掉无效的分类ID
        final validCategoryIds = categoryIds.where((id) => id > 0).toList();
        
        if (validCategoryIds.isNotEmpty) {
          // 使用categories[]格式传递所有分类ID
          for (int i = 0; i < validCategoryIds.length; i++) {
            params['categories[$i]'] = validCategoryIds[i].toString();
          }
          print('  分类ID：$validCategoryIds');
        }
      }
      
      print('发送请求参数：$params');
      
      // 调用API
      final responseData = await _apiService.get(
        path: '/api/v1/finance/trend',
        params: params,
        context: context,
      );
      
      bool success = responseData['code'] == 0 || responseData['code'] == 200;
      
      return ApiResponse(
        success: success,
        data: success ? responseData['data'] : null,
        message: responseData['message'] ?? (success ? '获取成功' : '获取失败'),
      );
    } catch (e) {
      print("Error in FinanceService.getTransactionTrend: $e");
      return ApiResponse(
        success: false,
        message: '获取交易趋势数据失败: $e',
      );
    }
  }

  /// 获取按日期分组的交易记录
  Future<ApiResponse> getTransactionGroups({
    required BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    int? memberId,
    List<int>? categoryIds,
    int? familyId,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      print('开始获取日期分组的交易记录：');
      if (startDate != null) print('  开始日期：${DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate)}');
      if (endDate != null) print('  结束日期：${DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate)}');
      if (type != null) print('  交易类型：$type');
      if (memberId != null) print('  成员ID：$memberId');
      if (categoryIds != null) print('  分类IDs：$categoryIds');
      if (familyId != null) print('  家庭ID：$familyId');
      print('  页码：$page，每页数量：$limit');
      
      // 构建查询参数
      Map<String, String> params = {
        'limit': limit.toString(),
        'page': page.toString(),
      };
      
      // 添加日期范围参数
      if (startDate != null) {
        params['start_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);
      }
      if (endDate != null) {
        params['end_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate);
      }
      
      // 添加其他可选参数
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }
      if (memberId != null) {
        params['member'] = memberId.toString();
      }
      
      // 添加家庭ID参数
      if (familyId != null) {
        params['family_id'] = familyId.toString();
      }
      
      // 处理分类ID参数
      if (categoryIds != null && categoryIds.isNotEmpty) {
        // 过滤掉无效的分类ID
        final validCategoryIds = categoryIds.where((id) => id > 0).toList();
        
        if (validCategoryIds.isNotEmpty) {
          // 使用categories[]格式传递所有分类ID
          for (int i = 0; i < validCategoryIds.length; i++) {
            params['categories[$i]'] = validCategoryIds[i].toString();
          }
          print('  分类ID：$validCategoryIds');
        }
      }
      
      print('发送请求参数：$params');
      
      // 调用API
      final responseData = await _apiService.get(
        path: '/api/v1/finance/transaction-groups',
        params: params,
        context: context,
      );
      
      bool success = responseData['code'] == 0 || responseData['code'] == 200;
      
      return ApiResponse(
        success: success,
        data: success ? responseData['data'] : null,
        message: responseData['message'] ?? (success ? '获取成功' : '获取失败'),
      );
    } catch (e) {
      print("Error in FinanceService.getTransactionGroups: $e");
      return ApiResponse(
        success: false,
        message: '获取交易记录分组失败: $e',
      );
    }
  }
  
  /// 获取支出分析数据，按类别统计
  Future<ApiResponse> getExpenseAnalysis({
    required BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
    int? memberId,
  }) async {
    try {
      // 构建查询参数
      Map<String, String> params = {};
      
      // 添加日期范围参数
      if (startDate != null) {
        params['start_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate);
      }
      if (endDate != null) {
        params['end_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate);
      }
      
      // 添加成员ID参数
      if (memberId != null) {
        params['member_id'] = memberId.toString();
      }
      
      print('获取支出分析数据，参数: $params');
      
      // 调用API
      final responseData = await _apiService.get(
        path: '/api/v1/finance/expense-analysis',
        params: params,
        context: context,
      );
      
      bool success = responseData['code'] == 0 || responseData['code'] == 200;
      
      return ApiResponse(
        success: success,
        data: success ? responseData['data'] : null,
        message: responseData['message'] ?? (success ? '获取成功' : '获取失败'),
      );
    } catch (e) {
      print("Error in FinanceService.getExpenseAnalysis: $e");
      return ApiResponse(
        success: false,
        message: '获取支出分析数据失败: $e',
      );
    }
  }

  // 获取家庭成员财务贡献数据
  Future<ApiResponse> getFamilyContributions({
    required BuildContext context,
    int? year,
    int? month,
  }) async {
    try {
      // 构建查询参数
      Map<String, String> params = {};
      if (year != null) params['year'] = year.toString();
      if (month != null) params['month'] = month.toString();
      
      // 发起请求
      final response = await _apiService.get(
        path: '/api/v1/finance/family-contributions',
        params: params,
        context: context,
      );
      
      // 返回响应
      bool success = response['code'] == 0 || response['code'] == 200;
      return ApiResponse(
        success: success,
        message: response['message'] ?? (success ? '获取成功' : '获取失败'),
        data: success ? response['data'] : null,
      );
    } catch (e) {
      debugPrint('获取家庭成员财务贡献数据失败: $e');
      return ApiResponse(
        success: false,
        message: '获取家庭成员财务贡献数据失败: $e',
        data: null,
      );
    }
  }
} 