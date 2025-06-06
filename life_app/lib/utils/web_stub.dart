// 用于在Web环境中提供dart:io替代实现的存根文件
// 不要从dart:io导出类型，因为在web上不可用

// HttpClient和SecurityContext的模拟实现
class HttpClient {
  Duration? connectionTimeout;
  int? maxConnectionsPerHost;
  
  bool Function(X509Certificate, String, int)? badCertificateCallback;
  String Function(Uri)? findProxy;
  
  Future<HttpClientRequest> getUrl(Uri url) async {
    return HttpClientRequest();
  }
  
  Future<HttpClientRequest> postUrl(Uri url) async {
    return HttpClientRequest();
  }
}

class SecurityContext {
  SecurityContext();
  static SecurityContext defaultContext() => SecurityContext();
}

class X509Certificate {
  final String subject = 'Web Stub Certificate';
}

// 自定义HttpOverrides类，完全在web环境中模拟
class HttpOverrides {
  static HttpOverrides? global;
  
  HttpClient createHttpClient(SecurityContext? context) {
    return HttpClient();
  }
  
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    return 'DIRECT';
  }
}

enum InternetAddressType {
  IPv4,
  IPv6,
  unix,
  any
}

class InternetAddress {
  final String address;
  final InternetAddressType type;

  InternetAddress(this.address, {this.type = InternetAddressType.IPv4});

  static Future<List<InternetAddress>> lookup(String host) async {
    return [InternetAddress('127.0.0.1')];
  }

  @override
  String toString() => 'InternetAddress($address)';
}

class NetworkInterface {
  final String name;
  final List<InternetAddress> addresses;

  NetworkInterface(this.name, this.addresses);

  static Future<List<NetworkInterface>> list() async {
    return [
      NetworkInterface('web_interface', [
        InternetAddress('127.0.0.1'),
      ]),
    ];
  }
}

class Socket {
  static Future<Socket> connect(dynamic host, int port, {Duration? timeout}) async {
    return Socket();
  }

  Future close() async {
    return;
  }
}

class Process {
  static Future<ProcessResult> run(String executable, List<String> arguments) async {
    return ProcessResult(0, 0, 'Web stub', '');
  }
}

class ProcessResult {
  final int pid;
  final int exitCode;
  final dynamic stdout;
  final dynamic stderr;

  ProcessResult(this.pid, this.exitCode, this.stdout, this.stderr);
}

// HTTP相关类
class HttpClientRequest {
  Future<HttpClientResponse> close() async {
    return HttpClientResponse();
  }
  
  void write(Object? obj) {}
  void add(List<int> data) {}
}

class HttpClientResponse {
  int statusCode = 200;
  List<int> get readBytes => [];
  
  Future<String> transform(dynamic transformer) async {
    return '{"web_stub": true}';
  }
}

// Platform类模拟
class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isFuchsia => false;
  static bool get isWeb => true;
  
  static String get operatingSystem => 'web';
  static String get operatingSystemVersion => '1.0.0';
} 