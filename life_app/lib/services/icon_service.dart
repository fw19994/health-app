import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/icon.dart';
import 'auth_service.dart';
import 'api_service.dart';

class IconService {
  final ApiService _apiService = ApiService();
  
  // 缓存已加载的图标，避免重复请求
  static List<IconModel> _cachedIcons = [];
  static bool _isLoadingIcons = false;
  static DateTime? _lastCacheRefresh;

  // 获取用户可用的图标
  Future<List<IconModel>> getUserAvailableIcons({BuildContext? context}) async {
    debugPrint('🔍 开始获取用户可用图标, 缓存状态: ${_cachedIcons.isNotEmpty ? "有缓存(${_cachedIcons.length}个)" : "无缓存"}, 最后刷新: ${_lastCacheRefresh?.toString() ?? "从未"}');
    
    // 如果缓存不为空且刷新时间在10分钟内，直接返回缓存
    if (_cachedIcons.isNotEmpty && _lastCacheRefresh != null) {
      final cacheAge = DateTime.now().difference(_lastCacheRefresh!);
      if (cacheAge.inMinutes < 10) {
        debugPrint('✅ 使用现有缓存的${_cachedIcons.length}个图标，缓存时间: ${cacheAge.inMinutes}分钟前');
        return _cachedIcons;
      }
    }
    
    // 避免同时多次请求
    if (_isLoadingIcons) {
      debugPrint('⏳ 图标正在加载中，等待现有请求完成...');
      // 等待正在进行的加载完成
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (_cachedIcons.isNotEmpty && !_isLoadingIcons) {
          debugPrint('✅ 等待结束，图标加载完成，缓存中有${_cachedIcons.length}个图标');
          return _cachedIcons;
        }
      }
    }
    
    _isLoadingIcons = true;
    
    try {
      debugPrint('🌐 发起API请求获取图标，路径: /api/v1/icons/get');
      final response = await _apiService.get(
        path: '/api/v1/icons/get',
        context: context,
      );
      
      debugPrint('📦 图标API响应: code=${response['code']}, 是否有数据: ${response['data'] != null}');
      
      if (response['code'] == 0 && response['data'] != null) {
        final List<dynamic> data = response['data'];
        debugPrint('✅ 成功获取${data.length}个图标，准备解析...');
        
        try {
          final List<IconModel> icons = [];
          for (var json in data) {
            try {
              final icon = IconModel.fromJson(json);
              icons.add(icon);
              debugPrint('✓ 解析图标成功: ID=${icon.id}, 名称=${icon.name}, 类型=${icon.iconType}');
            } catch (e) {
              debugPrint('❌ 解析单个图标失败: $e, 原始数据: $json');
            }
          }
          
          _cachedIcons = icons;
          _lastCacheRefresh = DateTime.now();
          _isLoadingIcons = false;
          
          if (icons.isEmpty) {
            debugPrint('⚠️ 解析完成但无有效图标');
          } else {
            debugPrint('✅ 成功解析${icons.length}个图标并更新缓存');
          }
          
          return icons;
        } catch (e) {
          debugPrint('❌ 解析图标列表失败: $e');
          _isLoadingIcons = false;
          return [];
        }
      } else {
        // 如果没有数据，返回空列表
        debugPrint('❌ 获取图标API响应错误: ${response['message'] ?? "未知错误"}');
        _isLoadingIcons = false;
        return [];
      }
    } catch (e) {
      debugPrint('❌ 获取图标API请求失败: $e');
      _isLoadingIcons = false;
      // 错误时返回空列表，避免应用崩溃
      return [];
    }
  }

  // 根据ID获取图标，如果本地缓存没有则请求服务器
  Future<IconModel?> getIconById(int iconId, {BuildContext? context}) async {
    debugPrint('🔍 开始获取图标ID=$iconId, 缓存状态: ${_cachedIcons.isNotEmpty ? "有缓存(${_cachedIcons.length}个)" : "无缓存"}');
    
    // 先从缓存中查找
    if (_cachedIcons.isNotEmpty) {
      try {
        final cachedIcon = _cachedIcons.firstWhere(
          (icon) => icon.id == iconId,
          orElse: () => IconModel(
            id: -1, // 使用-1表示未找到
            name: '未知',
            code: 'unknown',
            iconType: 'fontawesome',
            iconCode: 'fa-tag',
            colorCode: '#808080',
            categoryId: 1,
            category: '支出',
            isCustom: false,
          ),
        );
        
        if (cachedIcon.id != -1) {
          debugPrint('✅ 在现有缓存中找到图标: ID=$iconId, 名称=${cachedIcon.name}, 代码=${cachedIcon.code}, 颜色=${cachedIcon.colorCode}');
          return cachedIcon;
        }
        
        debugPrint('⚠️ 图标ID=$iconId 在现有缓存中未找到，将刷新缓存');
      } catch (e) {
        debugPrint('❌ 从缓存获取图标时出错: $e');
      }
    } else {
      debugPrint('⚠️ 缓存为空，将请求服务器获取所有图标');
    }
    
    // 缓存中没有，请求所有图标并更新缓存
    debugPrint('🌐 请求服务器获取所有图标...');
    final icons = await getUserAvailableIcons(context: context);
    
    if (icons.isEmpty) {
      debugPrint('⚠️ 服务器返回空图标列表，无法获取图标ID=$iconId');
    } else {
      debugPrint('✅ 成功从服务器获取${icons.length}个图标，再次查找ID=$iconId');
      // 打印缓存中的所有图标ID，便于调试
      final allIds = _cachedIcons.map((icon) => icon.id).toList();
      debugPrint('📋 缓存中的所有图标ID: $allIds');
    }
    
    // 再次从更新后的缓存中查找
    if (_cachedIcons.isNotEmpty) {
      try {
        final foundIcon = _cachedIcons.firstWhere(
          (icon) => icon.id == iconId,
          orElse: () => IconModel(
            id: -1,
            name: '未知',
            code: 'unknown',
            iconType: 'fontawesome',
            iconCode: 'fa-tag',
            colorCode: '#808080',
            categoryId: 1,
            category: '支出',
            isCustom: false,
          ),
        );
        
        if (foundIcon.id != -1) {
          debugPrint('✅ 在更新后的缓存中找到图标: ID=$iconId, 名称=${foundIcon.name}, 颜色=${foundIcon.colorCode}');
          return foundIcon;
        }
        
        debugPrint('⚠️ 在更新后的缓存中仍未找到图标ID=$iconId，将返回默认图标');
      } catch (e) {
        debugPrint('❌ 从更新后的缓存查找图标时出错: $e');
      }
    } else {
      debugPrint('⚠️ 更新后的缓存仍为空，无法获取图标ID=$iconId，将返回默认图标');
    }
    
    // 无法找到图标，返回默认图标
    debugPrint('🔄 为图标ID=$iconId 创建默认图标');
    
    // 为特定ID创建固定颜色的图标，以确保不同ID的目标有不同的颜色
    final defaultColors = [
      '#FF5722', '#2196F3', '#4CAF50', '#FFC107', '#9C27B0', 
      '#F44336', '#3F51B5', '#8BC34A', '#FFEB3B', '#673AB7',
      '#E91E63', '#00BCD4', '#CDDC39', '#FF9800', '#795548'
    ];
    
    // 使用iconId计算一个颜色
    final colorIndex = iconId % defaultColors.length;
    final defaultColor = defaultColors[colorIndex];
    
    final defaultIcon = IconModel(
      id: iconId,
      name: '目标 $iconId',
      code: 'icon_$iconId',
      iconType: 'fontawesome',
      iconCode: 'fa-tag',
      colorCode: defaultColor,
      categoryId: 3, // 储蓄目标类别
      category: '储蓄',
      isCustom: false,
    );
    
    debugPrint('✅ 创建默认图标: ID=$iconId, 名称=${defaultIcon.name}, 颜色=${defaultIcon.colorCode}');
    return defaultIcon;
  }

  // 创建用户自定义图标
  Future<void> createUserIcon({
    required int iconId,
    required String customName,
    required String customColor,
    required int categoryId,
    BuildContext? context,
  }) async {
    debugPrint('🔄 准备创建自定义图标: iconId=$iconId, name=$customName, color=$customColor, categoryId=$categoryId');
    
    try {
      final response = await _apiService.post(
        path: '/api/v1/icons/add',
        data: {
          'icon_id': iconId,
          'custom_name': customName,
          'custom_color': customColor,
          'category_id': categoryId,
        },
        context: context,
      );
      
      debugPrint('📦 创建图标API响应: $response');
      
      if (response['code'] != 0) {
        debugPrint('❌ 创建图标失败: ${response['message']}');
        throw Exception('创建图标失败: ${response['message']}');
      }
      
      // 清除缓存，以便下次获取最新的图标
      debugPrint('🔄 清除图标缓存，下次将获取最新数据');
      _cachedIcons = [];
      _lastCacheRefresh = null;
    } catch (e) {
      debugPrint('❌ 创建图标API请求失败: $e');
      throw Exception('创建图标失败: $e');
    }
  }
} 