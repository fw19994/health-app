// Web平台存根文件，用于模拟dart:io中的类

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

// HTTP相关的模拟类
class HttpOverrides {
  static HttpOverrides? global;
  
  HttpClient createHttpClient(SecurityContext? context) {
    return HttpClient();
  }
}

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

class SecurityContext {
  SecurityContext.defaultContext();
}

class X509Certificate {
  final String subject = 'Web Stub Certificate';
}

// Platform类模拟
class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isFuchsia => false;
  
  static String get operatingSystem => 'web';
  static String get operatingSystemVersion => '1.0.0';
} 