import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan/plan_model.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'reminder_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart'; // Added for DateFormat

/// 计划服务类，负责管理计划数据
class PlanService extends ChangeNotifier {
  List<Plan> _plans = [];
  Map<String, List<Plan>> _dailyPlansMap = {}; // 按日期存储的计划映射
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();
  final ReminderService _reminderService = ReminderService();
  BuildContext? _context;
  
  // 记录上一次加载的日期
  DateTime? _lastLoadedDate;
  
  // 获取所有计划
  List<Plan> get plans => _plans;
  
  // 获取按日期分组的计划
  Map<String, List<Plan>> get dailyPlansMap => _dailyPlansMap;
  
  // 兼容现有视图的月度计划getter
  List<Plan> get monthlyPlans {
    // 将所有日期的计划合并为一个列表
    List<Plan> allPlans = [];
    _dailyPlansMap.forEach((date, plans) {
      allPlans.addAll(plans);
    });
    return allPlans;
  }
  
  // 获取当天计划
  List<Plan> getTodayPlans() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _plans.where((plan) {
      if (plan.date == null) return false;
      
      final planDate = DateTime(plan.date!.year, plan.date!.month, plan.date!.day);
      
      // 检查一次性计划
      if (plan.recurrenceType == 'once') {
        return planDate.isAtSameMomentAs(startOfDay);
      }
      
      // 检查每天重复
      if (plan.recurrenceType == 'daily') {
        return true;
      }
      
      // 检查每周重复
      if (plan.recurrenceType == 'weekly') {
        return planDate.weekday == today.weekday;
      }
      
      // 检查每月重复
      if (plan.recurrenceType == 'monthly') {
        return planDate.day == today.day;
      }
      
      // 检查工作日重复
      if (plan.recurrenceType == 'weekdays') {
        return today.weekday >= 1 && today.weekday <= 5;
      }
      
      // 检查周末重复
      if (plan.recurrenceType == 'weekends') {
        return today.weekday == 6 || today.weekday == 7;
      }
      
      return false;
    }).toList();
  }
  
  // 从API获取今天的计划
  Future<List<Plan>> fetchTodayPlans() async {
    try {
      // 确保已有计划数据
      if (_plans.isEmpty) {
        await loadPlans();
      } else {
        // 如果距离上次加载已超过12小时，则重新加载
        final now = DateTime.now();
        if (_lastLoadedDate == null || 
            now.difference(_lastLoadedDate!).inHours > 12) {
          await loadPlans();
        }
      }
      
      // 获取今天的计划
      return getTodayPlans();
    } catch (e) {
      debugPrint('获取今日计划失败: $e');
      return _plans.isEmpty ? [] : getTodayPlans();
    }
  }
  
  // 获取指定日期的计划
  List<Plan> getPlansForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return _plans.where((plan) {
      if (plan.date == null) return false;
      
      final planDate = DateTime(plan.date!.year, plan.date!.month, plan.date!.day);
      
      // 检查一次性计划
      if (plan.recurrenceType == 'once') {
        return planDate.isAtSameMomentAs(targetDate);
      }
      
      // 检查每天重复
      if (plan.recurrenceType == 'daily') {
        return true;
      }
      
      // 检查每周重复
      if (plan.recurrenceType == 'weekly') {
        return planDate.weekday == date.weekday;
      }
      
      // 检查每月重复
      if (plan.recurrenceType == 'monthly') {
        return planDate.day == date.day;
      }
      
      // 检查工作日重复
      if (plan.recurrenceType == 'weekdays') {
        return date.weekday >= 1 && date.weekday <= 5;
      }
      
      // 检查周末重复
      if (plan.recurrenceType == 'weekends') {
        return date.weekday == 6 || date.weekday == 7;
      }
      
      return false;
    }).toList();
  }
  
  // 获取置顶计划
  List<Plan> get pinnedPlans => _plans.where((plan) => plan.isPinned).toList();
  
  // 根据ID获取计划
  Plan? getPlanById(String id) {
    try {
      return _plans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // 加载状态
  bool get isLoading => _isLoading;
  
  // 错误信息
  String? get error => _error;
  
  // 获取带有登录态的context
  BuildContext? get context => _context;
  
  // 构造函数，接收上下文参数
  PlanService({BuildContext? context}) {
    _context = context;
    init();
  }
  
  // 初始化方法
  Future<void> init() async {
    try {
      // 初始化提醒服务
      await _reminderService.initialize();
    } catch (e) {
      debugPrint('初始化提醒服务失败: $e');
    }
  }
  
  // 设置上下文并加载数据
  Future<void> setContext(BuildContext context) async {
    _context = context;
    // 设置了上下文后加载数据
    await loadPlans();
  }
      
  // 加载计划
  Future<void> loadPlans({DateTime? date, bool forceReload = true}) async {
    if (_context == null) {
      print('警告：PlanService中context为空，无法获取登录态');
      await _loadFromCache();
      return;
      }
      
    // 打印详细的调用信息
    String dateStr = date != null ? DateFormat('yyyy-MM-dd').format(date) : "null";
    print('===== PlanService.loadPlans被调用 =====');
    print('日期: $dateStr, forceReload: $forceReload');
    print('调用栈:\n${StackTrace.current}');
    
    // 如果日期没有变化且不强制重新加载，则跳过
    if (!forceReload && date != null && _lastLoadedDate != null && 
        date.year == _lastLoadedDate!.year && 
        date.month == _lastLoadedDate!.month && 
        date.day == _lastLoadedDate!.day) {
      print('日期未变化且不强制重新加载，跳过API调用: $dateStr');
      return;
    }
    
    // 更新上一次加载的日期
    _lastLoadedDate = date;
      
    try {
      // 打印API调用信息
      print('执行API调用，加载日期: $dateStr');
      
      await _loadFromApi(context: _context, date: date);
    } catch (e) {
      debugPrint('加载计划失败: $e');
      await _loadFromCache();
    }
  }
  
  // 从本地缓存加载计划
  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? plansJson = prefs.getString('plans');
    
    if (plansJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(plansJson);
        _plans = decoded.map((item) => Plan.fromJson(item)).toList();
      } catch (e) {
        debugPrint('解析缓存计划数据失败: $e');
        // 解析失败但不抛出异常，继续尝试从API加载
      }
    }
  }
  
  // 从API加载计划
  Future<void> _loadFromApi({BuildContext? context, DateTime? date}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 准备查询参数
      Map<String, String>? params;
      if (date != null) {
        // 格式化日期为 YYYY-MM-DD 格式
        String dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        params = {'date': dateStr};
        debugPrint('加载指定日期的计划: $dateStr');
      }
      
      // 获取日计划
      final response = await _apiService.get(
        path: ApiConstants.getPlans,
        params: params,
        context: context ?? _context,
      );
      
      debugPrint('API响应: ${response.toString().substring(0, min(100, response.toString().length))}...');
      
      if (response['code'] == 0 && response['data'] != null) {
        final List<dynamic> plansData = response['data'];
        debugPrint('获取到 ${plansData.length} 条计划数据');
        
        // 记录第一条数据的结构，帮助调试
        if (plansData.isNotEmpty) {
          debugPrint('第一条计划数据示例: ${plansData[0].toString().substring(0, min(200, plansData[0].toString().length))}...');
          debugPrint('ID类型: ${plansData[0]['id'].runtimeType}');
          debugPrint('类别: ${plansData[0]['category']}');
        }
        
        _plans = plansData.map((item) {
          try {
            // 确保类别字段存在且有效
            if (item['category'] == null || item['category'] == '') {
              item['category'] = 'work'; // 设置默认类别
            }
            
            final plan = Plan.fromJson(item);
            debugPrint('解析计划: ${plan.title}, 类别: ${plan.category}');
            return plan;
          } catch (e) {
            debugPrint('解析计划数据失败: $e，数据: ${item.toString().substring(0, min(100, item.toString().length))}...');
            return null;
          }
        }).whereType<Plan>().toList();
        
        debugPrint('成功解析 ${_plans.length} 条计划');
        await _saveToCache();
        _isLoading = false;
        notifyListeners();
      } else {
        _error = response['message'] ?? '加载计划失败';
        debugPrint('API错误: $_error');
        _isLoading = false;
        notifyListeners();
        // 当API调用失败时，尝试加载本地缓存
        await _loadFromCache();
      }
    } catch (e) {
      debugPrint('从API加载计划失败: $e');
      _error = '加载计划失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
      // 当API调用失败时，尝试加载本地缓存
      await _loadFromCache();
    }
  }
  
  // 模拟加载数据（仅用于开发阶段）
  void _loadMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _plans = [
      // 上午计划
      Plan(
        id: '1',
        title: '晨间慢跑',
        description: '沿着小区慢跑30分钟',
        date: today,
        startTime: const TimeOfDay(hour: 6, minute: 30),
        endTime: const TimeOfDay(hour: 7, minute: 0),
        category: 'health',
        reminderType: '10min',
        reminderMinutes: 10,
        recurrenceType: 'daily',
        isPinned: false,
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Plan(
        id: '2',
        title: '项目会议',
        description: '与团队讨论新功能的实施方案',
        date: today,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        category: 'work',
        reminderType: '15min',
        reminderMinutes: 15,
        recurrenceType: 'once',
        isPinned: false,
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      
      // 下午计划
      Plan(
        id: '3',
        title: '健康午餐',
        description: '地中海风格沙拉，搭配全麦面包',
        date: today,
        startTime: const TimeOfDay(hour: 12, minute: 30),
        endTime: const TimeOfDay(hour: 13, minute: 30),
        category: 'personal',
        reminderType: '5min',
        reminderMinutes: 5,
        recurrenceType: 'daily',
        isPinned: false,
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Plan(
        id: '4',
        title: '编写代码',
        description: '完成前端页面的开发任务',
        date: today,
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 0),
        category: 'work',
        reminderType: '10min',
        reminderMinutes: 10,
        recurrenceType: 'weekdays',
        isPinned: false,
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      
      // 晚间计划
      Plan(
        id: '5',
        title: '力量训练',
        description: '健身房进行45分钟的力量训练',
        date: today,
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 45),
        category: 'health',
        reminderType: '30min',
        reminderMinutes: 30,
        recurrenceType: 'weekly',
        isPinned: false,
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      Plan(
        id: '6',
        title: '家庭聚餐',
        description: '与家人共进晚餐，讨论周末出游计划',
        date: today,
        startTime: const TimeOfDay(hour: 20, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        category: 'family',
        reminderType: '15min',
        reminderMinutes: 15,
        recurrenceType: 'once',
        isPinned: false,
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      
      // 明天的计划
      Plan(
        id: '7',
        title: '客户演示',
        description: '向客户展示产品最新功能',
        date: today.add(const Duration(days: 1)),
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 30),
        category: 'work',
        reminderType: '30min',
        reminderMinutes: 30,
        recurrenceType: 'once',
        isPinned: false,
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    
    _saveToCache();
  }
  
  // 将计划保存到本地缓存
  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String plansJson = jsonEncode(_plans.map((plan) => plan.toJson()).toList());
    await prefs.setString('plans', plansJson);
  }
  
  // 添加计划
  Future<Map<String, dynamic>> addPlan(Plan plan, {BuildContext? context}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 准备计划数据，适应后端API格式
      final planData = {
        'title': plan.title,
        'description': plan.description,
        'date': plan.date?.toIso8601String().split('T')[0], // 仅使用日期部分 YYYY-MM-DD
        'start_time': _timeOfDayToString(plan.startTime),
        'end_time': _timeOfDayToString(plan.endTime),
        'category': plan.category,
        'reminder_type': plan.reminderType,
        'reminder_minutes': plan.reminderMinutes,
        'recurrence_type': plan.recurrenceType,
        'is_pinned': plan.isPinned,
        'is_completed': plan.isCompleted,
        'is_enabled': plan.isEnabled,
      };
      
      debugPrint('添加计划: ${jsonEncode(planData)}');
      
      // 调用API创建计划
      final response = await _apiService.post(
        path: ApiConstants.createPlan,
        data: planData,
        context: context ?? _context,
      );
      
      debugPrint('API响应: ${response.toString().substring(0, min(100, response.toString().length))}...');
      
      if (response['code'] == 0) {
        // 创建成功，更新本地数据
        final String newId = response['data']['id'].toString();
        final newPlan = plan.copyWith(id: newId);
        _plans.add(newPlan);
        await _saveToCache();
        
        // 设置提醒（新增：如果计划有提醒设置）
        if (newPlan.reminderType == 'time' && newPlan.reminderMinutes != null && newPlan.reminderMinutes! > 0) {
          try {
            // 获取提醒服务
            final reminderService = ReminderService();
            await reminderService.initialize();
            
            // 设置提醒
            await reminderService.scheduleReminder(newPlan);
          } catch (e) {
            debugPrint('设置提醒失败: $e');
          }
        }
        
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': '计划已添加'};
      } else {
        // API调用失败但有错误信息
        final errorMsg = response['message'] ?? '添加计划失败';
        debugPrint('API错误: $errorMsg');
        
        // 仍然添加到本地作为备份
        _plans.add(plan);
        await _saveToCache();
        
        // 如果有提醒，设置提醒
        if (plan.reminderType == 'time' && plan.reminderMinutes != null && plan.reminderMinutes! > 0) {
          await _setupReminder(plan);
        }
        
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      // 捕获到异常
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      debugPrint('添加计划失败: $errorMsg');
      
      // 错误情况下仍然添加到本地
    _plans.add(plan);
    await _saveToCache();
    
    // 如果有提醒，设置提醒
    if (plan.reminderType == 'time' && plan.reminderMinutes != null && plan.reminderMinutes! > 0) {
      await _setupReminder(plan);
    }
    
      _isLoading = false;
    notifyListeners();
      return {'success': false, 'message': errorMsg};
    }
  }
  
  // 辅助方法：将TimeOfDay转换为字符串
  String? _timeOfDayToString(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  // 更新计划
  Future<Map<String, dynamic>> updatePlan(Plan updatedPlan, {BuildContext? context}) async {
    final index = _plans.indexWhere((plan) => plan.id == updatedPlan.id);
    if (index == -1) return {'success': false, 'message': '找不到要更新的计划'};
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 获取旧计划
      final oldPlan = _plans[index];
      
      // 如果旧计划有提醒，先取消
      if (oldPlan.reminderType == 'time' && oldPlan.reminderMinutes != null && oldPlan.reminderMinutes! > 0) {
        await _cancelReminder(oldPlan.id);
      }
      
      // 准备更新数据，适应后端API格式
      final planData = {
        'title': updatedPlan.title,
        'description': updatedPlan.description,
        'date': updatedPlan.date?.toIso8601String().split('T')[0], // 仅使用日期部分 YYYY-MM-DD
        'start_time': _timeOfDayToString(updatedPlan.startTime),
        'end_time': _timeOfDayToString(updatedPlan.endTime),
        'category': updatedPlan.category,
        'reminder_type': updatedPlan.reminderType,
        'reminder_minutes': updatedPlan.reminderMinutes,
        'recurrence_type': updatedPlan.recurrenceType,
        'is_pinned': updatedPlan.isPinned,
        'is_completed': updatedPlan.isCompleted,
        'is_enabled': updatedPlan.isEnabled,
      };
      
      // 检查ID格式，尝试从本地存储获取服务器ID
      int? serverId;
      try {
        // 尝试将ID解析为整数
        serverId = int.tryParse(updatedPlan.id);
      } catch (e) {
        debugPrint('ID不是整数格式: ${updatedPlan.id}');
      }
      
      // 如果没有有效的服务器ID，则使用创建新计划的API
      if (serverId == null) {
        debugPrint('没有有效的服务器ID，使用创建API');
        final response = await _apiService.post(
          path: ApiConstants.createPlan,
          data: planData,
          context: context ?? _context,
        );
        
        if (response['code'] == 0) {
          // 更新本地计划
          _plans[index] = updatedPlan;
          await _saveToCache();
          
          // 如果新计划需要提醒，设置提醒
          if (updatedPlan.reminderType == 'time' && updatedPlan.reminderMinutes != null && updatedPlan.reminderMinutes! > 0) {
            await _setupReminder(updatedPlan);
          }
          
          _isLoading = false;
          notifyListeners();
          return {'success': true, 'message': '计划更新成功'};
        } else {
          final errorMsg = response['message'] ?? '更新计划失败';
          debugPrint('API错误: $errorMsg');
          
          // 仍然更新本地数据
          _plans[index] = updatedPlan;
          await _saveToCache();
          
          _isLoading = false;
          notifyListeners();
          return {'success': false, 'message': errorMsg};
        }
      }
      
      // 使用服务器ID发送更新请求
      final response = await _apiService.put(
        path: '${ApiConstants.updatePlan}/$serverId',
        data: planData,
        context: context ?? _context,
      );
      
      if (response['code'] == 0) {
        // 更新本地计划
        _plans[index] = updatedPlan;
        
        // 保存到本地缓存
        await _saveToCache();
        
        // 如果新计划需要提醒，设置提醒
        if (updatedPlan.reminderType == 'time' && updatedPlan.reminderMinutes != null && updatedPlan.reminderMinutes! > 0) {
          await _setupReminder(updatedPlan);
        }
        
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'message': '计划更新成功'};
      } else {
        // 如果API调用失败但有错误信息
        final errorMsg = response['message'] ?? '更新计划失败';
        debugPrint('API错误: $errorMsg');
        
        // API调用失败，仍然更新本地数据
        _plans[index] = updatedPlan;
        await _saveToCache();
        
        // 如果新计划需要提醒，设置提醒
        if (updatedPlan.reminderType == 'time' && updatedPlan.reminderMinutes != null && updatedPlan.reminderMinutes! > 0) {
          await _setupReminder(updatedPlan);
        }
        
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      // 捕获到异常
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      debugPrint('更新计划失败: $errorMsg');
      
      // 错误情况下仍然更新本地数据
      _plans[index] = updatedPlan;
      await _saveToCache();
      
      // 如果新计划需要提醒，设置提醒
      if (updatedPlan.reminderType == 'time' && updatedPlan.reminderMinutes != null && updatedPlan.reminderMinutes! > 0) {
        await _setupReminder(updatedPlan);
      }
      
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': errorMsg};
    }
  }
  
  // 删除计划
  Future<Map<String, dynamic>> deletePlan(String id, {BuildContext? context}) async {
    final plan = getPlanById(id);
    if (plan == null) return {'success': false, 'message': '找不到要删除的计划'};
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 检查ID格式，尝试从本地存储获取服务器ID
      int? serverId;
      try {
        // 尝试将ID解析为整数
        serverId = int.tryParse(id);
      } catch (e) {
        debugPrint('ID不是整数格式: $id');
      }
      
      // 如果有有效的服务器ID，则发送删除请求
      if (serverId != null) {
        // 发送API请求
        final response = await _apiService.delete(
          path: '${ApiConstants.deletePlan}/$serverId',
          context: context ?? _context,
        );
        
        if (response['code'] != 0) {
          // API调用失败但有错误信息
          final errorMsg = response['message'] ?? '删除计划失败';
          debugPrint('API错误: $errorMsg');
        }
      }
      
      // 无论API调用成功与否，都从本地删除
      _plans.removeWhere((plan) => plan.id == id);
      await _saveToCache();
      
      // 取消提醒
      await _cancelReminder(id);
      
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'message': '计划已删除'};
    } catch (e) {
      // 捕获到异常
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      debugPrint('删除计划失败: $errorMsg');
      
      // 错误情况下仍然从本地删除
      _plans.removeWhere((plan) => plan.id == id);
      await _saveToCache();
      
      // 取消提醒
      await _cancelReminder(id);
      
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': errorMsg};
    }
  }
  
  // 标记计划为已完成
  Future<Map<String, dynamic>> markAsCompleted(String id, {BuildContext? context, DateTime? date}) async {
    final index = _plans.indexWhere((plan) => plan.id == id);
    if (index == -1) return {'success': false, 'message': '找不到要标记的计划'};
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 获取当前计划
      final plan = _plans[index];
      final completionDate = date ?? DateTime.now();
      
      // 创建完成状态的计划
      final completedPlan = plan.copyWith(
        isCompleted: true, 
        isCompletedToday: true,
        completedAt: completionDate
      );
      
      // 检查ID格式，尝试从本地存储获取服务器ID
      int? serverId;
      try {
        // 尝试将ID解析为整数
        serverId = int.tryParse(id);
      } catch (e) {
        debugPrint('ID不是整数格式: $id');
      }
      
      // 如果有有效的服务器ID，则发送完成请求
      if (serverId != null) {
        // 格式化日期为 YYYY-MM-DD 格式
        String dateStr = "${completionDate.year}-${completionDate.month.toString().padLeft(2, '0')}-${completionDate.day.toString().padLeft(2, '0')}";
        debugPrint('发送完成计划请求，日期: $dateStr');
        
        // 发送API请求
        final response = await _apiService.put(
          path: '${ApiConstants.completePlan}/$serverId/complete',
          data: {
            'completed': true,
            'date': dateStr,
          },
          context: context ?? _context,
        );
        
        if (response['code'] != 0) {
          // API调用失败但有错误信息
          final errorMsg = response['message'] ?? '标记计划完成失败';
          debugPrint('API错误: $errorMsg');
        }
      }
      
      // 无论API调用成功与否，都更新本地数据
      _plans[index] = completedPlan;
      await _saveToCache();
      
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'message': '计划已标记为完成'};
    } catch (e) {
      // 捕获到异常
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      debugPrint('标记计划完成失败: $errorMsg');
      
      // 错误情况下仍然更新本地数据
      final plan = _plans[index];
      final completionDate = date ?? DateTime.now();
      
      _plans[index] = plan.copyWith(
        isCompleted: true, 
        isCompletedToday: true,
        completedAt: completionDate
      );
      
      await _saveToCache();
      
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': errorMsg};
    }
  }
  
  // 标记计划为未完成
  Future<Map<String, dynamic>> markAsIncomplete(String id, {BuildContext? context}) async {
    final index = _plans.indexWhere((plan) => plan.id == id);
    if (index == -1) return {'success': false, 'message': '找不到要标记的计划'};
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 获取当前计划
      final plan = _plans[index];
      
      // 创建未完成状态的计划
      final incompletePlan = plan.copyWith(
        isCompleted: false, 
        completedAt: null
      );
      
      // 检查ID格式，尝试从本地存储获取服务器ID
      int? serverId;
      try {
        // 尝试将ID解析为整数
        serverId = int.tryParse(id);
      } catch (e) {
        debugPrint('ID不是整数格式: $id');
      }
      
      // 如果有有效的服务器ID，则发送取消完成请求
      if (serverId != null) {
        // 发送API请求
        final response = await _apiService.put(
          path: '${ApiConstants.completePlan}/$serverId/cancel',
          data: {'completed': false},
          context: context ?? _context,
        );
        
        if (response['code'] != 0) {
          // API调用失败但有错误信息
          final errorMsg = response['message'] ?? '取消计划完成状态失败';
          debugPrint('API错误: $errorMsg');
        }
      }
      
      // 无论API调用成功与否，都更新本地数据
      _plans[index] = incompletePlan;
      await _saveToCache();
      
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'message': '计划已标记为未完成'};
    } catch (e) {
      // 捕获到异常
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      debugPrint('取消计划完成状态失败: $errorMsg');
      
      // 错误情况下仍然更新本地数据
      final plan = _plans[index];
      _plans[index] = plan.copyWith(
        isCompleted: false, 
        completedAt: null
      );
      await _saveToCache();
      
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': errorMsg};
    }
  }
  
  // 设置计划是否置顶
  Future<void> togglePinned(String id) async {
    final index = _plans.indexWhere((plan) => plan.id == id);
    if (index != -1) {
      _plans[index] = _plans[index].copyWith(isPinned: !_plans[index].isPinned);
      await _saveToCache();
      notifyListeners();
    }
  }
  
  // 切换计划启用/停用状态
  Future<void> togglePlanEnabled(String id, {BuildContext? context}) async {
    final index = _plans.indexWhere((plan) => plan.id == id);
    if (index == -1) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 获取当前计划
      final plan = _plans[index];
      final newStatus = !plan.isEnabled;
      
      // 创建新状态的计划
      final updatedPlan = plan.copyWith(isEnabled: newStatus);
      
      // 发送API请求 - 使用cancelPlan接口来停用计划
      final response = await _apiService.put(
        path: '${ApiConstants.cancelPlan}/$id/cancel',
        data: {'cancelled': !newStatus}, // 启用对应cancelled=false，停用对应cancelled=true
        context: context ?? _context,
      );
      
      // 无论API调用成功与否，都更新本地数据
      _plans[index] = updatedPlan;
      await _saveToCache();
      
      // 如果禁用，取消提醒
      if (!newStatus) {
        await _cancelReminder(id);
      } 
      // 如果启用且需要提醒，设置提醒
      else if (updatedPlan.reminderType == 'time' && 
               updatedPlan.reminderMinutes != null && 
               updatedPlan.reminderMinutes! > 0) {
        await _setupReminder(updatedPlan);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('切换计划状态失败: $e');
      
      // 错误情况下仍然更新本地数据
      final plan = _plans[index];
      final newStatus = !plan.isEnabled;
      _plans[index] = plan.copyWith(isEnabled: newStatus);
      await _saveToCache();
      
      // 如果禁用，取消提醒
      if (!newStatus) {
        await _cancelReminder(id);
      } 
      // 如果启用且需要提醒，设置提醒
      else if (plan.reminderType == 'time' && 
               plan.reminderMinutes != null && 
               plan.reminderMinutes! > 0) {
        await _setupReminder(_plans[index]);
      }
      
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 获取指定日期的月度计划
  List<Plan> getMonthlyPlansForDate(DateTime date) {
final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _dailyPlansMap[dateStr] ?? [];
  }
  
  // 获取指定月份的计划
  List<Plan> getPlansForMonth(DateTime month) {
    // 过滤出指定月份的计划
    return _plans.where((plan) {
      // 如果计划没有日期，则跳过
      if (plan.date == null) return false;
      
      // 比较年月
      return plan.date!.year == month.year && plan.date!.month == month.month;
    }).toList();
  }
  
  // 从API加载月度计划
  Future<void> loadMonthlyPlans({required int year, required int month}) async {
    if (_context == null) {
      print('警告：PlanService中context为空，无法获取登录态');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();
      
      // 准备查询参数
      Map<String, String> params = {
        'year': year.toString(),
        'month': month.toString(),
        'group_by_date': 'true', // 启用按日期分组
      };
      
      debugPrint('加载月度计划: $year-$month');
      
      // 获取月度计划
      final response = await _apiService.get(
        path: ApiConstants.getMonthlyPlans,
        params: params,
        context: _context,
      );
      
      debugPrint('API响应: ${response.toString().substring(0, min(100, response.toString().length))}...');
      
      if (response['code'] == 0 && response['data'] != null) {
        final data = response['data'];
        
        // 清空旧数据
        _dailyPlansMap = {};
        
        // 处理分组格式的响应
        if (data is Map<String, dynamic> && data.containsKey('daily_plans')) {
          List<dynamic> dailyPlans = data['daily_plans'];
          
          // 遍历每天的计划分组
          for (var dailyGroup in dailyPlans) {
            if (dailyGroup is Map<String, dynamic> && dailyGroup.containsKey('plans')) {
              String dateStr = dailyGroup['date'] as String;
              List<dynamic> plansJson = dailyGroup['plans'];
              List<Plan> dayPlans = [];
              
              // 解析每个计划
              for (var item in plansJson) {
          try {
            if (item['category'] == null || item['category'] == '') {
              item['category'] = 'work'; // 设置默认类别
            }
            
            final plan = Plan.fromJson(item);
                  dayPlans.add(plan);
          } catch (e) {
            debugPrint('解析计划数据失败: $e，数据: ${item.toString().substring(0, min(100, item.toString().length))}...');
          }
              }
              
              // 将当天的计划存储到映射中
              _dailyPlansMap[dateStr] = dayPlans;
            }
          }
          
          debugPrint('成功解析月度计划，共 ${_dailyPlansMap.length} 天，总计划数: ${monthlyPlans.length}');
        } else {
          debugPrint('API返回的数据格式不正确，期望包含daily_plans字段的Map');
          _error = '数据格式不正确';
        }
        
        _isLoading = false;
        notifyListeners();
      } else {
        _error = response['message'] ?? '加载月度计划失败';
        debugPrint('API错误: $_error');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('从API加载月度计划失败: $e');
      _error = '加载月度计划失败，请检查网络连接';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 获取指定周的计划
  List<Plan> getPlansForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    // 过滤出指定周的计划
    return _plans.where((plan) {
      // 如果计划没有日期，则跳过
      if (plan.date == null) return false;
      
      // 规范化日期（只保留年月日，忽略时间）
      final normalizedDate = DateTime(plan.date!.year, plan.date!.month, plan.date!.day);
      
      // 检查日期是否在周范围内
      return normalizedDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
             normalizedDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }
  
  // 获取已完成的计划
  List<Plan> getCompletedPlans() {
    return _plans.where((plan) => plan.isCompleted).toList();
  }
  
  // 按类别筛选计划
  List<Plan> filterPlansByCategory(String category) {
    return _plans.where((plan) => plan.category == category).toList();
  }
  
  // 设置所有计划的提醒
  Future<void> _setupReminders() async {
    // 遍历所有计划，为即将到来的计划设置提醒
    for (Plan plan in _plans) {
      // 跳过没有提醒的计划
      if (plan.reminderMinutes == null || plan.reminderMinutes! <= 0) {
        continue;
      }
      
      // 跳过已完成的计划
      if (plan.isCompleted) {
        continue;
      }
      
      // 跳过过期的计划
      if (plan.date != null && plan.date!.isBefore(DateTime.now()) && !_isRecurringPlan(plan)) {
        continue;
      }
      
      // 设置提醒 - 使用新的提醒方法
      await _setupReminder(plan); // 使用我们已经实现的单个计划提醒方法
    }
  }
  
  // 检查计划是否为重复计划
  bool _isRecurringPlan(Plan plan) {
    return plan.isRecurring;
  }
  
  // 设置提醒
  Future<void> _setupReminder(Plan plan) async {
    try {
      // 检查是否可以设置提醒
      if (!plan.canReceiveReminder) {
        debugPrint('该计划不需要设置提醒: ${plan.id}');
      return;
    }
    
      // 初始化提醒服务
      final reminderService = ReminderService();
      await reminderService.initialize();
    
    // 设置提醒
      final success = await reminderService.scheduleReminder(plan);
      
      if (success) {
        debugPrint('成功设置计划提醒: ${plan.id}');
      } else {
        debugPrint('设置计划提醒失败: ${plan.id}, 错误: ${reminderService.error}');
      }
    } catch (e) {
      debugPrint('设置提醒出现异常: $e');
    }
  }
  
  // 取消提醒
  Future<void> _cancelReminder(String planId) async {
    try {
      // 初始化提醒服务
      final reminderService = ReminderService();
      await reminderService.initialize();
      
      // 取消提醒
      final success = await reminderService.cancelReminder(planId);
      
      if (success) {
        debugPrint('成功取消计划提醒: $planId');
      } else {
        debugPrint('取消计划提醒失败: $planId, 错误: ${reminderService.error}');
      }
    } catch (e) {
      debugPrint('取消提醒出现异常: $e');
    }
  }
  
  // 兼容旧代码的切换计划完成状态方法
  Future<void> togglePlanCompletion(String id, {BuildContext? context}) async {
    final index = _plans.indexWhere((plan) => plan.id == id);
    if (index != -1) {
      final plan = _plans[index];
      if (plan.isCompleted) {
        await markAsIncomplete(id, context: context);
      } else {
        await markAsCompleted(id, context: context);
      }
    }
  }
  
  // 兼容旧代码的切换计划置顶状态方法
  Future<void> togglePlanPin(String id) async {
    await togglePinned(id);
  }
} 