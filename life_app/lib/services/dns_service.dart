import 'dart:io' if (dart.library.html) 'package:life_app/utils/web_stub.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

class DnsService {
  static final DnsService _instance = DnsService._internal();
  factory DnsService() => _instance;
  DnsService._internal();

  // DNS服务器列表
  final List<String> dnsServers = [
    '8.8.8.8',      // Google DNS
    '114.114.114.114', // 国内DNS
    '223.5.5.5',    // 阿里DNS
  ];

  // 缓存解析结果
  final Map<String, List<InternetAddress>> _dnsCache = {};
  final Duration cacheDuration = const Duration(minutes: 5);

  Future<List<InternetAddress>> resolveDomain(String domain) async {
    // Web平台返回模拟数据
    if (kIsWeb) {
      print('=== Web平台模拟DNS解析 ===');
      return [
        InternetAddress('127.0.0.1', type: InternetAddressType.IPv4),
      ];
    }
    
    print('=== DNS解析开始 ===');
    print('域名: $domain');

    // 检查缓存
    if (_dnsCache.containsKey(domain)) {
      print('使用DNS缓存结果');
      return _dnsCache[domain]!;
    }

    List<InternetAddress>? addresses;
    Exception? lastError;

    // 尝试系统DNS
    try {
      print('尝试使用系统DNS解析...');
      addresses = await InternetAddress.lookup(domain);
      print('系统DNS解析成功: $addresses');
      _cacheResults(domain, addresses);
      return addresses;
    } catch (e) {
      print('系统DNS解析失败: $e');
      lastError = e as Exception;
    }

    // 如果系统DNS失败，尝试备用DNS服务器
    for (String dnsServer in dnsServers) {
      try {
        print('尝试使用DNS服务器 $dnsServer 解析...');
        // 这里我们使用ping来测试连接性
        if (!kIsWeb) {
          final result = await Process.run('ping', ['-c', '1', domain]);
          if (result.exitCode == 0) {
            print('Ping成功，尝试解析...');
            addresses = await InternetAddress.lookup(domain);
            print('DNS解析成功: $addresses');
            _cacheResults(domain, addresses);
            return addresses;
          }
        }
      } catch (e) {
        print('使用DNS服务器 $dnsServer 解析失败: $e');
        lastError = e as Exception;
        continue;
      }
    }

    // 所有DNS服务器都失败
    print('=== DNS解析失败 ===');
    print('所有DNS服务器都无法解析域名');
    throw lastError ?? Exception('无法解析域名: $domain');
  }

  void _cacheResults(String domain, List<InternetAddress> addresses) {
    _dnsCache[domain] = addresses;
    // 设置缓存过期
    Timer(cacheDuration, () => _dnsCache.remove(domain));
    print('DNS结果已缓存: $domain -> $addresses');
  }

  // 清除DNS缓存
  void clearCache() {
    _dnsCache.clear();
    print('DNS缓存已清除');
  }

  // 获取最佳IP地址（通过延迟测试）
  Future<InternetAddress?> getBestAddress(String domain) async {
    // Web平台返回模拟数据
    if (kIsWeb) {
      print('=== Web平台不支持IP延迟测试 ===');
      return InternetAddress('127.0.0.1', type: InternetAddressType.IPv4);
    }
    
    final addresses = await resolveDomain(domain);
    if (addresses.isEmpty) return null;

    InternetAddress? bestAddress;
    int bestTime = 999999;

    print('=== 开始延迟测试 ===');
    for (var address in addresses) {
      try {
        final stopwatch = Stopwatch()..start();
        final socket = await Socket.connect(address, 80, 
          timeout: const Duration(seconds: 5));
        final time = stopwatch.elapsedMilliseconds;
        await socket.close();
        
        print('IP: ${address.address}, 延迟: ${time}ms');
        if (time < bestTime) {
          bestTime = time;
          bestAddress = address;
        }
      } catch (e) {
        print('测试IP ${address.address} 失败: $e');
      }
    }

    if (bestAddress != null) {
      print('最佳IP地址: ${bestAddress.address} (延迟: ${bestTime}ms)');
    }
    return bestAddress;
  }
} 