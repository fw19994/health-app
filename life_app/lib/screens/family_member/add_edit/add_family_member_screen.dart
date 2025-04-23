import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/family_member_model.dart';
import '../../../services/family_member_service.dart';
import '../../../services/user_service.dart';
import '../../../services/upload_service.dart';
import 'find_user_form.dart';
import 'create_virtual_form.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  final VoidCallback onMemberAdded;
  final bool isEditing;
  final FamilyMember? memberToEdit;

  const AddFamilyMemberScreen({
    Key? key,
    required this.onMemberAdded,
    this.isEditing = false,
    this.memberToEdit,
  }) : super(key: key);

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  // 当前标签：0 - 查找已有用户, 1 - 创建虚拟成员
  int _currentTab = 0;
  
  // 控制器
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nicknameController = TextEditingController();
  
  // 新成员角色和性别
  String _selectedRole = '';
  String _selectedGender = '';
  
  // 家庭关系
  String _selectedRelation = '';
  
  // 权限选项
  final List<bool> _permissions = [true, true, false, false];
  
  // 是否在搜索
  bool _isSearching = false;
  
  // 是否找到用户
  bool? _userFound = null;
  
  // 搜索到的用户数据
  Map<String, dynamic>? _foundUserData;
  
  // 服务实例
  late final UserService _userService;
  late final FamilyMemberService _familyMemberService;
  
  // 头像相关
  XFile? _selectedAvatar;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;
  
  @override
  void initState() {
    super.initState();
    _userService = UserService(context: context);
    _familyMemberService = FamilyMemberService(context: context);
    
    // 如果是编辑模式，则填充表单
    if (widget.isEditing && widget.memberToEdit != null) {
      final member = widget.memberToEdit!;
      // 设置为虚拟成员模式，因为我们要编辑成员信息
      _currentTab = 1;
      
      // 填充表单数据
      _nameController.text = member.name;
      _nicknameController.text = member.nickname;
      _descriptionController.text = member.description;
      _phoneController.text = member.phone;
      _selectedRole = member.role;
      _selectedGender = member.gender;
      _selectedRelation = member.role;
      
      // 设置头像URL
      if (member.avatarUrl.isNotEmpty) {
        _avatarUrl = member.avatarUrl;
      }
      
      // 设置权限（假设权限存储在字符串中）
      switch (member.permission.toLowerCase()) {
        case '管理员':
          _permissions[0] = true;
          _permissions[1] = false;
          _permissions[2] = false;
          break;
        case '编辑者':
          _permissions[0] = false;
          _permissions[1] = true;
          _permissions[2] = false;
          break;
        case '查看者':
          _permissions[0] = false;
          _permissions[1] = false;
          _permissions[2] = true;
          break;
        default:
          _permissions[0] = true; // 默认为管理员
      }
    }
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      body: Center(
        child: _buildModal(),
      ),
    );
  }
  
  // 构建模态对话框
  Widget _buildModal() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildTabSelector(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _currentTab == 0 && !widget.isEditing 
                  ? _buildFindUserForm() 
                  : _buildCreateVirtualForm(),
            ),
          ),
        ],
      ),
    );
  }
  
  // 对话框头部
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isEditing ? '编辑家庭成员' : '添加家庭成员',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          IconButton(
            onPressed: () {
              print('点击了关闭按钮');
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
              print('正在关闭对话框');
            },
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }
  
  // 标签选择器
  Widget _buildTabSelector() {
    // 编辑模式下不显示标签选择器
    if (widget.isEditing) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTab == 0 
                    ? const Color(0xFF059669) 
                    : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '查找已有用户',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _currentTab == 0 
                      ? Colors.white 
                      : const Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTab == 1 
                    ? const Color(0xFF059669) 
                    : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '创建虚拟成员',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _currentTab == 1 
                      ? Colors.white 
                      : const Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 查找用户表单
  Widget _buildFindUserForm() {
    return FindUserForm(
      phoneController: _phoneController,
      nicknameController: _nicknameController,
      descriptionController: _descriptionController,
      selectedRelation: _selectedRelation,
      permissions: _permissions,
      isSearching: _isSearching,
      userFound: _userFound,
      foundUserData: _foundUserData,
      onRelationChanged: (value) {
        setState(() {
          _selectedRelation = value ?? '';
        });
      },
      onPermissionChanged: (index, value) {
        setState(() {
          if (value != null) {
            _permissions[index] = value;
          }
        });
      },
      onSearchUser: _searchUser,
      onAddUser: _addFoundUser,
    );
  }
  
  // 创建虚拟成员表单
  Widget _buildCreateVirtualForm() {
    return CreateVirtualForm(
      nameController: _nameController,
      phoneController: _phoneController,
      descriptionController: _descriptionController,
      nicknameController: _nicknameController,
      selectedRelation: _selectedRelation,
      selectedGender: _selectedGender,
      permissions: _permissions,
      selectedAvatar: _selectedAvatar,
      avatarUrl: _avatarUrl,
      isUploading: _isUploadingAvatar,
      isEditing: widget.isEditing,
      onRelationChanged: (value) {
        setState(() {
          _selectedRelation = value ?? '';
        });
      },
      onGenderChanged: (value) {
        setState(() {
          _selectedGender = value ?? '';
        });
      },
      onPermissionChanged: (index, value) {
        setState(() {
          if (value != null) {
            _permissions[index] = value;
          }
        });
      },
      onAvatarSelected: (avatar) {
        setState(() {
          _selectedAvatar = avatar;
        });
      },
      onAvatarUrlReceived: (url) {
        setState(() {
          _avatarUrl = url;
        });
      },
      onUploadingChanged: (value) {
        setState(() {
          _isUploadingAvatar = value;
        });
      },
      onSubmitForm: widget.isEditing ? _updateMember : _createVirtualMember,
      onCancel: () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
    );
  }
  
  // 搜索用户
  Future<void> _searchUser() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入手机号')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _userFound = null;
      _foundUserData = null;
    });

    try {
      final response = await _userService.getUserByPhone(_phoneController.text);
      
      if (response.code == 0 && response.data != null) {
        // 获取当前登录用户信息
        final authService = Provider.of<AuthService>(context, listen: false);
        final currentUser = authService.currentUser;
        
        // 检查查询到的用户是否是自己
        if (currentUser != null && response.data['id'] == currentUser.id) {
          setState(() {
            _userFound = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('您自己已经是家庭成员了')),
          );
          return;
        }
        
        setState(() {
          _userFound = true;
          _foundUserData = response.data;
          // 自动填充昵称
          _nicknameController.text = response.data['nickname'] ?? '';
        });
      } else {
        setState(() {
          _userFound = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? '未找到用户')),
        );
      }
    } catch (e) {
      setState(() {
        _userFound = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失败: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // 上传头像
  Future<void> _uploadAvatar() async {
    if (_selectedAvatar == null) return;
    
    setState(() {
      _isUploadingAvatar = true;
    });
    
    try {
      // 使用UploadService上传图片到family目录
      final uploadService = UploadService(context: context);
      final response = await uploadService.uploadImage(_selectedAvatar!, directory: 'family');
      
      if (response.code == 0 && response.data != null) {
        // 成功获取图片URL
        setState(() {
          _avatarUrl = response.data['url'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('头像上传失败: ${response.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('头像上传失败: $e')),
      );
    } finally {
      setState(() {
        _isUploadingAvatar = false;
      });
    }
  }
  
  // 添加找到的用户为家庭成员
  Future<void> _addFoundUser() async {
    if (_foundUserData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先搜索并找到有效用户')),
      );
      return;
    }
    
    if (_selectedRelation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择家庭关系')),
      );
      return;
    }
    
    setState(() {
      _isUploadingAvatar = true;
    });
    
    try {
      // 设置默认权限为"查看者"
      const String permission = "查看者";
      
      // 获取用户ID
      final int userId = _foundUserData!['id'];
      final String name = _foundUserData!['nickname'] ?? _foundUserData!['name'] ?? '';
      final String phone = _foundUserData!['phone'] ?? '';
      final String avatarUrl = _foundUserData!['avatar'] ?? '';
      
      // 创建成员
      final response = await _familyMemberService.addFamilyMember(
        userId: userId,
        name: name,
        nickname: _nicknameController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: phone,
        role: _selectedRelation,
        gender: _selectedGender,
        avatarUrl: avatarUrl,
        permission: permission,
      );
      
      if (response.success) {
        // 添加成功
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('成员添加成功')),
          );
          
          // 先调用回调函数刷新列表，确保数据已更新
          widget.onMemberAdded();
          
          // 不在这里执行导航，让回调函数处理
        }
      } else {
        // 添加失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加失败: ${response.message}')),
          );
        }
      }
    } catch (e) {
      // 异常
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isUploadingAvatar = false;
      });
    }
  }
  
  // 提交表单 - 创建虚拟成员
  Future<void> _createVirtualMember() async {
    // 表单验证
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入成员姓名')),
      );
      return;
    }
    
    if (_selectedRelation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择家庭关系')),
      );
      return;
    }
    
    setState(() {
      _isUploadingAvatar = true;
    });
    
    try {
      // 如果有选择头像，先上传头像
      if (_selectedAvatar != null && _avatarUrl == null) {
        await _uploadAvatar();
      }
      
      // 设置默认权限为"查看者"
      const String permission = "查看者";
      
      // 创建成员
      final response = await _familyMemberService.addFamilyMember(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRelation,
        gender: _selectedGender,
        avatarUrl: _avatarUrl,
        permission: permission,
      );
      
      if (response.success) {
        // 添加成功
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('成员添加成功')),
          );
          
          // 先调用回调函数刷新列表，确保数据已更新
          widget.onMemberAdded();
          
          // 注意：不要在这里关闭对话框，让onMemberAdded回调函数来处理导航
          // 回调函数中已经有关闭逻辑，这里不需要再次执行Navigator.pop
          // 避免多次导航导致返回到错误页面
        }
      } else {
        // 添加失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加失败: ${response.message}')),
          );
        }
      }
    } catch (e) {
      // 异常
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isUploadingAvatar = false;
      });
    }
  }
  
  // 更新成员
  Future<void> _updateMember() async {
    if (widget.memberToEdit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法获取成员信息')),
      );
      return;
    }
    
    // 验证必填字段
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入成员姓名')),
      );
      return;
    }
    
    // 设置默认权限为"查看者"
    const String permission = '查看者';
    
    try {
      // 如果有选择新头像，先上传头像
      if (_selectedAvatar != null) {
        await _uploadAvatar();
      }
      
      // 调用更新服务
      final response = await _familyMemberService.updateFamilyMember(
        memberId: widget.memberToEdit!.id,
        name: _nameController.text,
        nickname: _nicknameController.text,
        description: _descriptionController.text,
        role: _selectedRelation.isEmpty ? widget.memberToEdit!.role : _selectedRelation,
        gender: _selectedGender.isEmpty ? widget.memberToEdit!.gender : _selectedGender,
        avatarUrl: _avatarUrl ?? widget.memberToEdit!.avatarUrl,
        permission: permission,
      );
      
      if (response.success) {
        // 更新成功
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('成员信息已更新')),
          );
          
          // 先调用回调函数刷新列表，确保数据已更新
          widget.onMemberAdded();
          
          // 不在这里执行导航，让回调函数处理
        }
      } else {
        // 更新失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失败: ${response.message}')),
          );
        }
      }
    } catch (e) {
      // 异常
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新过程中发生错误: $e')),
        );
      }
    }
  }
}
