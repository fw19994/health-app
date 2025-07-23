import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

/// 专项计划阶段服务类，负责管理专项计划阶段数据
class ProjectPhaseService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;
  BuildContext? _context;
  
  // 加载状态
  bool get isLoading => _isLoading;
  
  // 错误信息
  String? get error => _error;
  
  // 构造函数
  ProjectPhaseService({BuildContext? context}) {
    _context = context;
  }

  // 设置上下文
  void setContext(BuildContext context) {
    _context = context;
  }
  
  // 获取专项计划的所有阶段
  Future<List<Map<String, dynamic>>> getProjectPhases(String projectId) async {
    if (_context == null) {
      print('警告：ProjectPhaseService中context为空，无法获取登录态');
      return [];
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiService.get(
        path: '${ApiConstants.getProjectPhases}/$projectId',
        context: _context,
      );
      
      if (response['code'] == 0 && response['data'] != null) {
        final List<dynamic> phasesData = response['data'] is List 
            ? response['data'] 
            : (response['data']['phases'] ?? []);
        
        _error = null;
        _isLoading = false;
        notifyListeners();
        return List<Map<String, dynamic>>.from(phasesData);
      } else {
        _error = response['message'] ?? '获取专项计划阶段失败';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      print('获取专项计划阶段失败: $e');
      _error = '获取专项计划阶段失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // 创建专项计划阶段
  Future<Map<String, dynamic>?> createPhase({
    required String projectId, 
    required String name, 
    String? description,
    String? referencePhaseId, // 参考阶段ID
    String? position, // 位置：before - 在参考阶段前添加，after - 在参考阶段后添加
  }) async {
    if (_context == null) {
      print('警告：ProjectPhaseService中context为空，无法获取登录态');
      return null;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 将项目ID转换为整数类型
      int projectIdInt;
      try {
        projectIdInt = int.parse(projectId);
      } catch (e) {
        print('项目ID转换为整数失败: $e');
        _error = '项目ID格式错误';
        _isLoading = false;
        notifyListeners();
        return null;
      }
      
      // 如果提供了参考阶段ID，将其转换为整数
      int? referencePhaseIdInt;
      if (referencePhaseId != null && referencePhaseId.isNotEmpty) {
        try {
          referencePhaseIdInt = int.parse(referencePhaseId);
        } catch (e) {
          print('参考阶段ID转换为整数失败: $e');
          _error = '参考阶段ID格式错误';
          _isLoading = false;
          notifyListeners();
          return null;
        }
      }
      
      final data = {
        'special_project_id': projectIdInt,
        'name': name,
        'description': description ?? '',
      };
      
      // 添加参考阶段ID和位置参数
      if (referencePhaseIdInt != null && position != null) {
        data['reference_phase_id'] = referencePhaseIdInt;
        data['position'] = position;
      }
      
      final response = await _apiService.post(
        path: ApiConstants.createPhase,
        data: data,
        context: _context,
      );
      
      if (response['code'] == 0 && response['data'] != null) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return response['data'];
      } else {
        _error = response['message'] ?? '创建专项计划阶段失败';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      print('创建专项计划阶段失败: $e');
      _error = '创建专项计划阶段失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // 更新专项计划阶段
  Future<bool> updatePhase({
    required String phaseId, 
    required String name, 
    String? description,
  }) async {
    if (_context == null) {
      print('警告：ProjectPhaseService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 将阶段ID转换为整数类型
      int phaseIdInt;
      try {
        phaseIdInt = int.parse(phaseId);
      } catch (e) {
        print('阶段ID转换为整数失败: $e');
        _error = '阶段ID格式错误';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final data = {
        'name': name,
        'description': description ?? '',
      };
      
      final response = await _apiService.put(
        path: '${ApiConstants.updatePhase}/$phaseIdInt',
        data: data,
        context: _context,
      );
      
      _isLoading = false;
      if (response['code'] == 0) {
        _error = null;
      } else {
        _error = response['message'] ?? '更新专项计划阶段失败';
      }
      notifyListeners();
      return response['code'] == 0;
    } catch (e) {
      print('更新专项计划阶段失败: $e');
      _error = '更新专项计划阶段失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 删除专项计划阶段
  Future<bool> deletePhase(String phaseId) async {
    if (_context == null) {
      print('警告：ProjectPhaseService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 将阶段ID转换为整数类型
      int phaseIdInt;
      try {
        phaseIdInt = int.parse(phaseId);
      } catch (e) {
        print('阶段ID转换为整数失败: $e');
        _error = '阶段ID格式错误';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final response = await _apiService.delete(
        path: '${ApiConstants.deletePhase}/$phaseIdInt',
        context: _context,
      );
      
      _isLoading = false;
      if (response['code'] == 0) {
        _error = null;
      } else {
        _error = response['message'] ?? '删除专项计划阶段失败';
      }
      notifyListeners();
      return response['code'] == 0;
    } catch (e) {
      print('删除专项计划阶段失败: $e');
      _error = '删除专项计划阶段失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 重新排序专项计划阶段
  Future<bool> reorderPhases({
    required String projectId, 
    required List<String> phaseIds,
  }) async {
    if (_context == null) {
      print('警告：ProjectPhaseService中context为空，无法获取登录态');
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final data = {
        'phase_ids': phaseIds,
      };
      
      final response = await _apiService.put(
        path: '${ApiConstants.reorderPhases}/$projectId/reorder',
        data: data,
        context: _context,
      );
      
      _isLoading = false;
      if (response['code'] == 0) {
        _error = null;
      } else {
        _error = response['message'] ?? '重新排序专项计划阶段失败';
      }
      notifyListeners();
      return response['code'] == 0;
    } catch (e) {
      print('重新排序专项计划阶段失败: $e');
      _error = '重新排序专项计划阶段失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // 获取阶段的所有计划
  Future<List<Map<String, dynamic>>> getPlansByPhaseID(String phaseId) async {
    if (_context == null) {
      print('警告：ProjectPhaseService中context为空，无法获取登录态');
      return [];
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiService.get(
        path: '${ApiConstants.getPlansByPhaseID}/$phaseId/plans',
        context: _context,
      );
      
      if (response['code'] == 0 && response['data'] != null) {
        final List<dynamic> plansData = response['data'] is List 
            ? response['data'] 
            : (response['data']['plans'] ?? []);
        
        _error = null;
        _isLoading = false;
        notifyListeners();
        return List<Map<String, dynamic>>.from(plansData);
      } else {
        _error = response['message'] ?? '获取阶段计划失败';
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      print('获取阶段计划失败: $e');
      _error = '获取阶段计划失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
  
  // 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 