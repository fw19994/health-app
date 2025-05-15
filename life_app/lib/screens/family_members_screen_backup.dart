import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/family_member_model.dart';
import '../services/family_member_service.dart';
import '../services/auth_service.dart';
import '../themes/app_theme.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/family_member_card.dart';
import 'add_family_member_screen.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  // 家庭成员数据
  List<FamilyMember> _members = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late int _currentUserId;
  
  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  // 加载家庭成员列表
  Future<void> _loadFamilyMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    print('开始重新加载家庭成员列表，设置loading状态为true');

    try {
      print('开始加载家庭成员列表...');
      // 获取当前用户ID - 用于空间显示判断当前用户
      final authService = Provider.of<AuthService>(context, listen: false);
      _currentUserId = authService.currentUser?.id ?? 0;
      print('当前用户ID: $_currentUserId');

      if (_currentUserId == 0) {
        setState(() {
          _isLoading = false;
          _errorMessage = '未找到当前用户信息';
        });
        print('错误: 未找到当前用户信息');
        return;
      }

      // 获取家庭成员列表 - 不需要传递ownerId，后端会自动查询
      final familyService = FamilyMemberService(context: context);
      print('调用家庭成员服务...');
      final response = await familyService.getFamilyMembers();
      
      print('响应状态: ${response.success ? "成功" : "失败"}');
      print('响应消息: ${response.message}');
      print('响应数据类型: ${response.data?.runtimeType}');
      print('响应数据长度: ${response.data?.length ?? 0}');
      
      if (response.success) {
        print('成功获取家庭成员数据: ${response.data?.length ?? 0} 个成员');
        setState(() {
          _members = response.data ?? [];
          _isLoading = false;
          // 清除任何错误消息
          _errorMessage = '';
        });
        print('已更新状态: 加载${_members.length}个家庭成员，关闭加载状态');
        
        // 记录成员信息供调试
        if (_members.isNotEmpty) {
          for (var member in _members) {
            print('家庭成员: ${member.name}, 角色: ${member.role}, ID: ${member.id}');
          }
        } else {
          print('警告: 家庭成员列表为空');
        }
      } else {
        print('获取家庭成员失败: ${response.message}');
        setState(() {
          _isLoading = false;
          _errorMessage = '获取家庭成员失败: ${response.message}';
        });
        print('已更新状态: 设置错误消息，关闭加载状态');
      }
    } catch (e) {
      print('加载家庭成员时发生异常: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '加载家庭成员失败: ${e.toString()}';
      });
      print('已更新状态: 设置异常错误消息，关闭加载状态');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('构建家庭成员页面: 成员数量=${_members.length}, 正在加载=$_isLoading, 错误消息="$_errorMessage"');
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadFamilyMembers,
                child: _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _errorMessage.isNotEmpty
                      ? _buildErrorView()
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAddMemberButton(),
                                  const SizedBox(height: 20),
                                  _members.isEmpty ? _buildEmptyState() : _buildMembersList(),
                                ],
                              ),
                            ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 头部绿色渐变区域
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF10B981)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40059669),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和返回按钮
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  print('点击了返回按钮，准备返回');
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '家庭成员管理',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '管理您的家庭成员和财务权限',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // 家庭信息卡片
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前家庭人数: ${_members.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                        _members.isEmpty
                            ? '暂无成员'
                            : '主要成员: ${_members.take(3).map((m) => m.isCurrentUser ? "${m.name} (我)" : m.name).join(", ")}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 添加成员按钮
  Widget _buildAddMemberButton() {
    return InkWell(
      onTap: () {
        // 保存当前的上下文引用
        final currentContext = context;
        
        // 使用对话框而不是页面导航
        showDialog(
          context: currentContext,
          barrierDismissible: false, // 防止点击外部关闭对话框
          builder: (BuildContext dialogContext) {
            return Dialog(
              insetPadding: const EdgeInsets.all(0), // 消除默认边距
              backgroundColor: Colors.transparent, // 透明背景
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: AddFamilyMemberScreen(
                  onMemberAdded: () {
                    print('成员添加完成，准备更新列表并返回');
                    // 先刷新列表，确保数据已更新
                    _loadFamilyMembers();
                    
                    // 使用正确的上下文关闭对话框
                    try {
                      // 确保仅关闭当前对话框
                      if (Navigator.canPop(dialogContext)) {
                        print('正在关闭添加对话框');
                        Navigator.of(dialogContext).pop();
                        print('已关闭添加对话框');
                      }
                    } catch (e) {
                      print('关闭对话框出错: $e');
                    }
                  },
                ),
              ),
            );
          },
        ).then((_) {
          print('添加对话框已关闭');
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              '添加新成员',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 成员列表
  Widget _buildMembersList() {
    print('构建家庭成员列表, 成员数量: ${_members.length}');
    
    // 家庭成员信息表格
    if (_members.isEmpty) {
      print('家庭成员列表为空，显示提示信息');
      return _buildEmptyState();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '家庭成员列表',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _members.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final member = _members[index];
            print('渲染成员卡片 #$index: ${member.name}, 角色: ${member.role}, ID: ${member.id}');
            return _buildMemberCard(member);
          },
        ),
      ],
    );
  }

  // 成员卡片样式
  Widget _buildMemberCard(FamilyMember member) {
    // 不同角色对应不同的颜色
    final Color roleColor = _getRoleColor(member.role);
    final bool isCurrentUser = member.userId == _currentUserId;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              Container(
                width: 64,
                height: 64,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3F4F6),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                ),
                child: member.avatarUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.network(
                          member.avatarUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person,
                            size: 32,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 32,
                        color: Color(0xFF9CA3AF),
                      ),
              ),
              
              // 成员信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCurrentUser ? '${member.name} (我)' : member.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (member.description.isNotEmpty)
                              Text(
                                member.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                          ],
                        ),
                        
                        // 角色标签
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            member.getRoleName(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 成员详细信息
                    _buildInfoRow('电话:', member.phone.isEmpty ? '未设置' : member.phone),
                    const SizedBox(height: 4),
                    _buildInfoRow('加入时间:', member.joinTime),
                    const SizedBox(height: 4),
                    // _buildInfoRow('权限:', _getPermissionText(member.permission)),
                    if (member.userId != null && member.userId! > 0)
                      ...[
                        const SizedBox(height: 4),
                        _buildInfoRow('用户ID:', member.userId.toString()),
                      ],
                    if (member.ownerId > 0)
                      ...[
                        const SizedBox(height: 4),
                        _buildInfoRow('家主ID:', member.ownerId.toString()),
                      ],
                  ],
                ),
              ),
            ],
          ),
          
          // 操作按钮
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 不允许删除自己以及家主角色的成员
                if (!isCurrentUser && member.role != '家庭主账户')
                  TextButton.icon(
                    onPressed: () => _confirmRemoveMember(member),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('移除'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editMember(member),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('编辑'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 获取角色对应的颜色
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'head':
      case '家庭主账户':
        return const Color(0xFF4F46E5); // 蓝色
      case 'spouse':
      case '配偶':
        return const Color(0xFFEC4899); // 粉色
      case 'child':
      case '子女':
        return const Color(0xFF0EA5E9); // 青色
      default:
        return const Color(0xFFA855F7); // 紫色
    }
  }
  
  // 获取权限文本描述
  String _getPermissionText(String permission) {
    switch (permission.toLowerCase()) {
      case 'all':
      case '全部':
        return '完全访问权限';
      case 'edit':
      case '编辑':
      case '编辑者':
        return '管理自己的支出和共享账单';
      case 'view':
      case '查看':
      case '查看者':
        return '记录个人支出';
      default:
        return permission;
    }
  }
  
  // 信息行 UI
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF9CA3AF),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  // 空状态视图
  Widget _buildEmptyState() {
    print('显示空状态视图');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            color: Color(0xFF10B981),
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            '没有家庭成员',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '点击上方按钮添加您的第一个家庭成员',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  // 错误显示
  Widget _buildErrorView() {
    print('显示错误视图: $_errorMessage');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.orange,
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            '加载失败',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadFamilyMembers,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xFF10B981)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )),
            ),
          ),
        ],
      ),
    );
  }
  
  // 编辑成员
  void _editMember(FamilyMember member) {
    print('编辑成员: ${member.name}, ID: ${member.id}');
    
    // 保存当前的上下文引用
    final currentContext = context;
    
    showDialog(
      context: currentContext,
      barrierDismissible: false, // 防止点击外部关闭对话框
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(0), // 消除默认边距
          backgroundColor: Colors.transparent, // 透明背景
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: AddFamilyMemberScreen(
              onMemberAdded: () {
                print('成员编辑完成，准备更新列表并返回');
                // 先刷新列表，确保数据已更新
                _loadFamilyMembers();
                
                // 使用正确的上下文关闭对话框
                try {
                  // 确保仅关闭当前对话框
                  if (Navigator.canPop(dialogContext)) {
                    print('正在关闭编辑对话框');
                    Navigator.of(dialogContext).pop();
                    print('已关闭编辑对话框');
                  }
                } catch (e) {
                  print('关闭对话框出错: $e');
                }
              },
              isEditing: true,
              memberToEdit: member,
            ),
          ),
        );
      },
    ).then((_) {
      print('编辑对话框已关闭');
    });
  }

  // 确认移除成员
  void _confirmRemoveMember(FamilyMember member) {
    print('显示成员移除确认对话框: ${member.name}, ID: ${member.id}');
    showDialog(
      context: context,
      barrierDismissible: false, // 防止点击外部关闭
      builder: (context) => AlertDialog(
        title: const Text('确认移除'),
        content: Text('确定要移除家庭成员 ${member.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              _removeMember(member);
            },
            child: const Text('确定'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  // 移除成员
  Future<void> _removeMember(FamilyMember member) async {
    print('开始移除成员: ${member.name}, ID: ${member.id}');
    setState(() {
      _isLoading = true;
    });

    try {
      final familyService = FamilyMemberService(context: context);
      // 直接调用删除接口，不再依赖owner_id参数
      final response = await familyService.removeFamilyMember(member.id);

      if (response.success) {
        print('成员移除成功: ${member.name}');
        // 重新加载成员列表
        await _loadFamilyMembers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('成员 ${member.name} 已成功移除')),
          );
        }
      } else {
        print('成员移除失败: ${response.message}');
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('移除失败: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('移除成员时发生异常: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('移除失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
