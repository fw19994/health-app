import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../models/family_model.dart';
import '../services/family_service.dart';
import '../themes/app_theme.dart';
import 'finance/family_finance/family_finance_screen.dart';
import '../screens/expense_tracking_screen.dart'; // 导入记账页面

class FamilyManagementScreen extends StatefulWidget {
  const FamilyManagementScreen({super.key});

  @override
  State<FamilyManagementScreen> createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  final FamilyService _familyService = FamilyService();
  
  List<Family> _families = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _activeFilter = '全部'; // 添加过滤状态
  
  @override
  void initState() {
    super.initState();
    _loadFamilies();
  }
  
  // 加载家庭列表
  Future<void> _loadFamilies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final response = await _familyService.getFamilies(context: context);
      
      if (response.success) {
        setState(() {
          _families = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '加载家庭列表失败: $e';
        _isLoading = false;
      });
    }
  }
  
  // 创建新家庭
  Future<void> _createFamily() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // 内容容器
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              margin: const EdgeInsets.only(top: 45),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  const Text(
                    '创建新家庭',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '创建一个新的家庭，邀请家人加入并开始管理家庭财务',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 家庭名称输入框
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '家庭名称',
                      hintText: '例如: 幸福之家',
                      prefixIcon: const Icon(FontAwesomeIcons.house, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 家庭描述输入框
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: '家庭描述 (选填)',
                      hintText: '简单描述您的家庭...',
                      prefixIcon: const Icon(FontAwesomeIcons.noteSticky, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),

                  // 按钮区域
                  Row(
                    children: [
                      // 取消按钮
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
                            ),
                          ),
                          child: Text(
                            '取消',
                            style: TextStyle(
                              color: AppTheme.primaryColor.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 创建按钮
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '创建',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 顶部装饰图标
            Positioned(
              top: 0,
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 45,
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 40,
                  child: Icon(
                    FontAwesomeIcons.houseChimneyUser,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
    if (result == true && nameController.text.isNotEmpty) {
      try {
        final response = await _familyService.createFamily(
          context: context,
          name: nameController.text,
          description: descriptionController.text,
        );
        
        if (response.success && response.data != null) {
          // 刷新列表
          _loadFamilies();
        } else {
          // 保持静默，不显示错误提示
        }
      } catch (e) {
        // 保持静默，不显示错误提示
      }
    }
  }
  
  // 切换家庭状态
  Future<void> _toggleFamilyStatus(Family family) async {
    final bool newStatus = !family.isActive;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(newStatus ? '激活家庭' : '停用家庭'),
        content: Text(
          newStatus 
            ? '确定要激活"${family.name}"吗？激活后，该家庭将恢复正常使用。'
            : '确定要停用"${family.name}"吗？停用后，该家庭将无法进行财务记录等操作。'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? AppTheme.primaryColor : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: Text(newStatus ? '确定激活' : '确定停用'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        final response = await _familyService.setFamilyStatus(
          context: context,
          familyId: family.id,
          isActive: newStatus,
        );
        
        if (response.success) {
          // 刷新列表
          _loadFamilies();
        } else {
          // 保持静默，不显示错误提示
        }
      } catch (e) {
        // 保持静默，不显示错误提示
      }
    }
  }
  
  // 删除家庭
  Future<void> _deleteFamily(Family family) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('删除家庭', style: TextStyle(color: Colors.red)),
        content: Text(
          '确定要删除"${family.name}"吗？此操作将删除所有相关的家庭成员、财务记录等信息，且无法恢复！'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确定删除'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        final response = await _familyService.deleteFamily(
          context: context,
          familyId: family.id,
        );
        
        if (response.success) {
          // 刷新列表
          _loadFamilies();
        } else {
          // 保持静默，不显示错误提示
        }
      } catch (e) {
        // 保持静默，不显示错误提示
      }
    }
  }
  
  // 编辑家庭
  Future<void> _editFamily(Family family) async {
    final TextEditingController nameController = TextEditingController(text: family.name);
    final TextEditingController descriptionController = TextEditingController(text: family.description);
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // 内容容器
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              margin: const EdgeInsets.only(top: 45),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  const Text(
                    '编辑家庭',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '修改家庭信息',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 家庭名称输入框
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '家庭名称',
                      hintText: '例如: 幸福之家',
                      prefixIcon: const Icon(FontAwesomeIcons.house, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 家庭描述输入框
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: '家庭描述 (选填)',
                      hintText: '简单描述您的家庭...',
                      prefixIcon: const Icon(FontAwesomeIcons.noteSticky, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),

                  // 按钮区域
                  Row(
                    children: [
                      // 取消按钮
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
                            ),
                          ),
                          child: Text(
                            '取消',
                            style: TextStyle(
                              color: AppTheme.primaryColor.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 保存按钮
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '保存',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 顶部装饰图标
            Positioned(
              top: 0,
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 45,
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 40,
                  child: Icon(
                    FontAwesomeIcons.penToSquare,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
    if (result == true && nameController.text.isNotEmpty) {
      try {
        final response = await _familyService.updateFamily(
          context: context,
          familyId: family.id,
          name: nameController.text,
          description: descriptionController.text,
        );
        
        if (response.success) {
          // 刷新列表
          _loadFamilies();
        }
      } catch (e) {
        // 保持静默，不显示错误提示
      }
    }
  }
  
  // 通过邀请码加入家庭
  Future<void> _joinFamilyByCode() async {
    final TextEditingController codeController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('加入家庭'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入家庭邀请码以加入已有家庭'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: '邀请码',
                hintText: '请输入邀请码',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('加入'),
          ),
        ],
      ),
    );
    
    if (result == true && codeController.text.isNotEmpty) {
      try {
        final response = await _familyService.joinFamilyByCode(
          context: context,
          code: codeController.text,
        );
        
        if (response.success && response.data != null) {
          // 刷新列表
          _loadFamilies();
        } else {
          // 保持静默，不显示错误提示
        }
      } catch (e) {
        // 保持静默，不显示错误提示
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // 移除AppBar，使用自定义头部
      body: Column(
        children: [
          // 自定义美观的头部
          _buildCustomHeader(context, statusBarHeight),
          // 内容区域
          Expanded(
            child: _isLoading
                ? _buildLoadingView()
                : _errorMessage.isNotEmpty && _families.isEmpty
                    ? _buildErrorView()
                    : _buildFamiliesListView(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }
  
  // 浮动按钮组
  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 通过邀请码加入家庭按钮
        FloatingActionButton(
          heroTag: 'join_family',
          onPressed: _joinFamilyByCode,
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
          mini: true,
          child: const Icon(Icons.qr_code),
        ),
        const SizedBox(height: 16),
        // 创建新家庭按钮
        FloatingActionButton(
          heroTag: 'create_family',
          onPressed: _createFamily,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
  
  // 自定义美观的头部
  Widget _buildCustomHeader(BuildContext context, double statusBarHeight) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 6, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40635BFF),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              // 返回按钮
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 标题
              const Text(
                '家庭管理',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 合并家庭数量统计和描述到一行
          Row(
            children: [
              Text(
                '${_filteredFamilies.length} 个家庭',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '管理您的家庭，查看财务状况',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 快速过滤栏
          Row(
            children: [
              _buildFilterChip('全部', _activeFilter == '全部'),
              const SizedBox(width: 8),
              _buildFilterChip('活跃', _activeFilter == '活跃'),
              const SizedBox(width: 8),
              _buildFilterChip('已停用', _activeFilter == '已停用'),
            ],
          ),
        ],
      ),
    );
  }
  
  // 获取过滤后的家庭列表
  List<Family> get _filteredFamilies {
    if (_activeFilter == '全部') {
      return _families;
    } else if (_activeFilter == '活跃') {
      return _families.where((family) => family.isActive).toList();
    } else {
      return _families.where((family) => !family.isActive).toList();
    }
  }
  
  // 过滤选项芯片
  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white 
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  // 加载中视图
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('加载家庭列表...'),
        ],
      ),
    );
  }
  
  // 错误视图
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadFamilies,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  // 家庭列表视图
  Widget _buildFamiliesListView() {
    return RefreshIndicator(
      onRefresh: _loadFamilies,
      child: _filteredFamilies.isEmpty
          ? _buildEmptyListView()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredFamilies.length,
              itemBuilder: (context, index) {
                final family = _filteredFamilies[index];
                return _buildFamilyCard(family);
              },
            ),
    );
  }
  
  // 空列表视图
  Widget _buildEmptyListView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.house,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _activeFilter != '全部' 
              ? '没有${_activeFilter}的家庭' 
              : '您还没有创建或加入任何家庭',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _activeFilter != '全部' 
            ? Text(
                '尝试切换到"全部"查看所有家庭',
                style: TextStyle(color: Colors.grey[600]),
              )
            : Text(
                '点击下方按钮创建您的第一个家庭',
                style: TextStyle(color: Colors.grey[600]),
              ),
          const SizedBox(height: 24),
          if (_activeFilter == '全部')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _createFamily,
                  icon: const Icon(Icons.add),
                  label: const Text('创建家庭'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _joinFamilyByCode,
                  icon: const Icon(Icons.qr_code),
                  label: const Text('加入家庭'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  // 家庭卡片
  Widget _buildFamilyCard(Family family) {
    // 生成随机颜色作为家庭卡片的渐变背景色
    final List<List<Color>> gradients = [
      [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)], // 蓝色渐变
      [const Color(0xFF10B981), const Color(0xFF047857)], // 绿色渐变
      [const Color(0xFFF59E0B), const Color(0xFFB45309)], // 橙色渐变
      [const Color(0xFF6366F1), const Color(0xFF4338CA)], // 靛蓝渐变
      [const Color(0xFFEC4899), const Color(0xFFBE185D)], // 粉色渐变
    ];
    
    // 根据家庭ID选择渐变色，确保同一个家庭总是显示相同的渐变色
    final gradientIndex = family.id % gradients.length;
    final gradient = gradients[gradientIndex];
    
    return GestureDetector(
      onTap: () {
        // 导航到家庭财务页面
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FamilyFinanceScreen(familyId: family.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 家庭卡片头部 - 渐变色背景
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 家庭图标
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FontAwesomeIcons.house,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 家庭名称和创建日期
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            family.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '创建于 ${family.formattedCreatedDate}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 家庭状态标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: family.isActive
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        family.isActive ? '活跃' : '已停用',
                        style: TextStyle(
                          color: family.isActive ? Colors.white : Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 家庭卡片底部 - 信息部分
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 成员数量
                      _buildInfoItem(
                        icon: FontAwesomeIcons.userGroup,
                        label: '成员数量',
                        value: '${family.memberCount}人',
                      ),
                      // 家庭管理员
                      _buildInfoItem(
                        icon: FontAwesomeIcons.userShield,
                        label: '管理员',
                        value: family.ownerName,
                      ),
                    ],
                  ),
                ),
                // 操作按钮区域
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 切换状态按钮
                      IconButton(
                        onPressed: () => _toggleFamilyStatus(family),
                        icon: Icon(
                          family.isActive 
                            ? Icons.toggle_on_outlined 
                            : Icons.toggle_off_outlined,
                          size: 24,
                          color: family.isActive 
                            ? Colors.green 
                            : Colors.grey,
                        ),
                        tooltip: family.isActive ? '停用家庭' : '激活家庭',
                      ),
                      // 编辑家庭按钮
                      IconButton(
                        onPressed: () => _editFamily(family),
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.blue,
                        ),
                        tooltip: '编辑家庭',
                      ),
                      // 删除家庭按钮
                      IconButton(
                        onPressed: () => _deleteFamily(family),
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        tooltip: '删除家庭',
                      ),
                      // 记一笔按钮
                      ElevatedButton.icon(
                        onPressed: family.isActive ? () {
                          // 导航到记账页面
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpenseTrackingScreen(
                                familyId: family.id,
                                isFamilyExpense: true,
                              ),
                            ),
                          );
                        } : null, // 如果家庭未激活，则禁用按钮
                        icon: const Icon(FontAwesomeIcons.moneyBillWave, size: 14),
                        label: const Text('记一笔'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      // 进入家庭按钮
                      ElevatedButton.icon(
                        onPressed: () {
                          // 导航到家庭财务页面
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FamilyFinanceScreen(familyId: family.id)),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('进入家庭'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 家庭信息项
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
} 