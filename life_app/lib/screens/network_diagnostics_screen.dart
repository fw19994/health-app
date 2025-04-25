import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/network_diagnostics.dart';
import '../themes/app_theme.dart';

class NetworkDiagnosticsScreen extends StatefulWidget {
  const NetworkDiagnosticsScreen({Key? key}) : super(key: key);

  @override
  State<NetworkDiagnosticsScreen> createState() => _NetworkDiagnosticsScreenState();
}

class _NetworkDiagnosticsScreenState extends State<NetworkDiagnosticsScreen> {
  final NetworkDiagnostics _diagnostics = NetworkDiagnostics();
  bool _isLoading = false;
  Map<String, dynamic>? _networkStatus;
  List<Map<String, dynamic>>? _siteTestResults;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 1. 检查网络状态
      final networkStatus = await _diagnostics.checkNetworkStatus();
      setState(() {
        _networkStatus = networkStatus;
      });

      // 2. 测试各个站点
      final results = await _diagnostics.testAllSites();
      setState(() {
        _siteTestResults = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '诊断过程出错: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Web平台特定UI
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('网络诊断'),
        ),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Web平台提示',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '网络诊断功能在Web平台上不可用。\n'
                    '如果您遇到登录问题，请尝试使用移动应用程序，\n'
                    '或确保您的网络连接正常。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 移动平台UI（原有实现）
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络诊断'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runDiagnostics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDiagnosticsResults(),
    );
  }

  Widget _buildDiagnosticsResults() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '诊断失败',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _runDiagnostics,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _runDiagnostics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNetworkStatusCard(),
          const SizedBox(height: 16),
          _buildSiteTestResultsCard(),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '网络状态',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
            const Divider(),
            if (_networkStatus == null)
              const Text('网络状态未知')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow(
                    '网络连接',
                    _networkStatus!['connected'] ? '已连接' : '未连接',
                    _networkStatus!['connected'],
                  ),
                  _buildStatusRow(
                    'WiFi',
                    _networkStatus!['wifi'] ? '已连接' : '未连接',
                    _networkStatus!['wifi'],
                  ),
                  _buildStatusRow(
                    '移动数据',
                    _networkStatus!['mobile'] ? '已连接' : '未连接',
                    _networkStatus!['mobile'],
                  ),
                  if (_networkStatus!['error'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '错误: ${_networkStatus!['error']}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.cancel,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSiteTestResultsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '站点测试结果',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
            const Divider(),
            if (_siteTestResults == null)
              const Text('尚未进行站点测试')
            else if (_siteTestResults!.isEmpty)
              const Text('没有测试结果')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _siteTestResults!.length,
                itemBuilder: (context, index) {
                  final result = _siteTestResults![index];
                  return _buildSiteTestResultItem(result);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteTestResultItem(Map<String, dynamic> result) {
    final bool isSuccess = result['success'] == true;
    final bool isDnsSuccess = result['dns_success'] == true;

    return ExpansionTile(
      leading: Icon(
        isSuccess ? Icons.check_circle : Icons.cancel,
        color: isSuccess ? Colors.green : Colors.red,
      ),
      title: Text(
        result['name'] ?? '未知站点',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(result['url'] ?? ''),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusRow('DNS解析', isDnsSuccess ? '成功' : '失败', isDnsSuccess),
              if (isDnsSuccess) ...[
                const SizedBox(height: 4),
                Text('DNS解析时间: ${result['dns_time']}ms'),
                const SizedBox(height: 4),
                Text('DNS结果: ${(result['dns_result'] as List?)?.join(', ') ?? '无'}'),
              ],
              if (!isDnsSuccess && result['dns_error'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'DNS错误: ${result['dns_error']}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const Divider(),
              if (isSuccess) ...[
                Text('响应码: ${result['status_code']}'),
                const SizedBox(height: 4),
                Text('请求时间: ${result['time']}ms'),
                if (result['response'] != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    '响应内容:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    width: double.infinity,
                    child: Text(
                      result['response'] ?? '',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ] else if (result['http_error'] != null) ...[
                Text(
                  '连接错误: ${result['http_error']}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
} 