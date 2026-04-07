import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:io' if (dart.library.html) 'package:life_app/utils/web_stub.dart';
import 'dns_service.dart';

class NetworkDiagnostics {
  static final NetworkDiagnostics _instance = NetworkDiagnostics._internal();
  factory NetworkDiagnostics() => _instance;
  NetworkDiagnostics._internal();
  
  final DnsService _dnsService = DnsService();
  
  // 测试站点列表
  final List<Map<String, String>> testSites = [
    {'name': '百度', 'url': 'https://www.baidu.com'},
    {'name': '腾讯', 'url': 'https://www.qq.com'},
    {'name': '阿里巴巴', 'url': 'https://www.aliyun.com'},
    {'name': '网易', 'url': 'https://www.163.com'},
    {'name': '新浪', 'url': 'https://www.sina.com.cn'},
    {'name': 'API站点', 'url': 'https://api.example.com'},
  ];
  
  // 测试所有站点
  Future<List<Map<String, dynamic>>> testAllSites() async {
    // Web平台返回模拟数据
    if (kIsWeb) {
      return _getWebMockSiteResults();
    }
    
    List<Map<String, dynamic>> results = [];
    
    for (var site in testSites) {
      try {
        final result = await testSite(site['name']!, site['url']!);
        results.add(result);
      } catch (e) {
        print('测试站点 ${site['name']} 失败: $e');
        results.add({
          'name': site['name'],
          'url': site['url'],
          'success': false,
          'message': '测试过程出错: $e',
          'time': -1,
        });
      }
    }
    
    return results;
  }
  
  // Web平台模拟站点测试结果
  List<Map<String, dynamic>> _getWebMockSiteResults() {
    return testSites.map((site) => {
      'name': site['name'],
      'url': site['url'],
      'success': false,
      'message': 'Web平台网络检测不可用',
      'time': -1,
      'dns_success': false,
      'dns_error': 'Web平台不支持DNS检测',
      'http_error': 'Web平台不支持网络诊断',
    }).toList();
  }
  
  // 测试单个站点
  Future<Map<String, dynamic>> testSite(String name, String url) async {
    // Web平台返回模拟数据
    if (kIsWeb) {
      return {
        'name': name,
        'url': url,
        'success': false,
        'message': 'Web平台网络检测不可用',
        'time': -1,
        'dns_success': false,
        'dns_error': 'Web平台不支持DNS检测',
      };
    }
    
    print('开始测试站点: $name ($url)');
    final result = <String, dynamic>{
      'name': name,
      'url': url,
      'success': false,
      'message': '',
      'time': -1,
    };
    
    try {
      // 1. DNS测试
      final uri = Uri.parse(url);
      print('正在解析域名: ${uri.host}');
      
      final stopwatch = Stopwatch()..start();
      List<InternetAddress> addresses = [];
      
      try {
        addresses = await _dnsService.resolveDomain(uri.host);
        result['dns_success'] = true;
        result['dns_result'] = addresses.map((a) => a.address).toList();
        result['dns_time'] = stopwatch.elapsedMilliseconds;
        print('DNS解析成功: $addresses, 用时: ${stopwatch.elapsedMilliseconds}ms');
      } catch (e) {
        result['dns_success'] = false;
        result['dns_error'] = e.toString();
        print('DNS解析失败: $e');
        return result;
      }
      
      // 2. 连接测试
      stopwatch.reset();
      stopwatch.start();
      
      try {
        final response = await http.get(uri).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('请求超时'),
        );
        
        final time = stopwatch.elapsedMilliseconds;
        result['success'] = true;
        result['status_code'] = response.statusCode;
        result['time'] = time;
        result['message'] = '连接成功，响应码: ${response.statusCode}, 用时: ${time}ms';
        
        if (response.body.length < 1000) {
          result['response'] = response.body;
        } else {
          result['response'] = '${response.body.substring(0, 500)}...（已截断）';
        }
        
        print('HTTP请求成功: ${response.statusCode}, 用时: ${time}ms');
      } catch (e) {
        result['http_error'] = e.toString();
        result['message'] = '连接失败: $e';
        print('HTTP请求失败: $e');
      }
    } catch (e) {
      result['message'] = '测试过程出错: $e';
      print('测试站点 $name 出错: $e');
    }
    
    return result;
  }
  
  // 测试当前网络状态
  Future<Map<String, dynamic>> checkNetworkStatus() async {
    // Web平台返回模拟数据
    if (kIsWeb) {
      return {
        'connected': false,
        'wifi': false,
        'mobile': false,
        'error': 'Web平台不支持网络状态检测',
        'details': {
          'web_platform': true,
          'web_message': '网络诊断在Web平台上不可用'
        },
      };
    }
    
    final result = <String, dynamic>{
      'connected': false,
      'wifi': false,
      'mobile': false,
      'details': <String, dynamic>{},
    };
    
    try {
      // 检查是否有网络连接
      try {
        final connectivityResult = await InternetAddress.lookup('www.baidu.com');
        result['connected'] = connectivityResult.isNotEmpty;
      } catch (e) {
        result['connected'] = false;
        result['error'] = e.toString();
      }
      
      // 获取网络接口信息
      try {
        final interfaces = await NetworkInterface.list();
        final List<Map<String, dynamic>> interfaceDetails = [];
        
        for (var interface in interfaces) {
          final details = <String, dynamic>{
            'name': interface.name,
            'addresses': interface.addresses.map((addr) => {
              'address': addr.address,
              'type': addr.type.toString(),
            }).toList(),
          };
          interfaceDetails.add(details);
          
          // 根据接口名称判断Wifi或移动数据
          if (interface.name.toLowerCase().contains('wlan') || 
              interface.name.toLowerCase().contains('wifi')) {
            result['wifi'] = true;
          } else if (interface.name.toLowerCase().contains('rmnet') || 
                    interface.name.toLowerCase().contains('pdp')) {
            result['mobile'] = true;
          }
        }
        
        result['details']['interfaces'] = interfaceDetails;
      } catch (e) {
        result['details']['interfaces_error'] = e.toString();
      }
    } catch (e) {
      result['error'] = e.toString();
    }
    
    return result;
  }
} 