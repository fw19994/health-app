import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/family_member_service.dart';
import '../../models/family_member_model.dart';
import '../../widgets/login/custom_toast.dart';
import 'models/user_profile.dart';
import 'widgets/profile_header.dart';
import 'widgets/info_card.dart';
import 'widgets/preference_card.dart';
import 'widgets/family_members_card.dart';
import 'widgets/account_actions.dart';
import 'edit_basic_info_screen.dart';
import '../family_members_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _userProfile;
  late UserService _userService;
  late FamilyMemberService _familyMemberService;
  bool _isLoading = true;
  List<FamilyMember> _familyMembers = [];
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里初始化服务，确保能访问到context
    _userService = UserService(context: context);
    _familyMemberService = FamilyMemberService(context: context);
  }

  @override
  void initState() {
    super.initState();
    // 初始化完成后加载用户数据
    // 使用WidgetsBinding确保在UI渲染完成后加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
      _loadFamilyMembers();
    });
  }
  
  // 加载家庭成员列表
  Future<void> _loadFamilyMembers() async {
    try {
      final response = await _familyMemberService.getFamilyMembers();
      if (response.success) {
        setState(() {
          _familyMembers = response.data ?? [];
        });
      } else {
        showCustomToast(context, '加载家庭成员失败: ${response.message}', ToastType.error);
      }
    } catch (e) {
      showCustomToast(context, '加载家庭成员失败: $e', ToastType.error);
    }
  }
  
  // 从服务器加载用户资料
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await _userService.getUserProfile();
      if (response.isSuccess && response.data != null) {
        // 使用后端数据创建用户资料
        setState(() {
          // 基于模拟数据初始化一个结构，但会用API返回的数据覆盖
          UserProfile baseProfile = UserProfile.getMockProfile();
          
          // 从响应中获取各字段并替换模拟数据
          Map<String, dynamic> userData = response.data;
          
          // 获取头像 URL，优先使用avatar字段（后端实际返回的字段名）
          String? avatarUrl = userData['avatar'] ?? userData['avatar_url'] ?? baseProfile.avatarUrl;
          
          if (kDebugMode) {
            print('用户资料API响应数据: $userData');
            print('解析到的头像地址: $avatarUrl');
          }
          
          // 根据生日计算年龄
          int age = baseProfile.age;
          if (userData['age'] != null) {
            age = int.tryParse(userData['age'].toString()) ?? age;
          } else if (userData['birthday'] != null && userData['birthday'].toString().isNotEmpty) {
            try {
              final birthDate = DateTime.parse(userData['birthday']);
              final now = DateTime.now();
              age = now.year - birthDate.year;
              // 如果生日还没过，年龄减1
              if (now.month < birthDate.month || 
                  (now.month == birthDate.month && now.day < birthDate.day)) {
                age--;
              }
            } catch (e) {
              if (kDebugMode) {
                print('生日解析错误: $e');
              }
            }
          }
          
          // 解析性别，将后端的male/female转换为中文的男/女
          String gender = baseProfile.gender;
          if (userData['gender'] != null) {
            switch (userData['gender']) {
              case 'male':
                gender = '男';
                break;
              case 'female':
                gender = '女';
                break;
              default:
                gender = userData['gender'] == null || userData['gender'].toString().isEmpty ? '男' : userData['gender'];
            }
          }
          
          // 解析健康信息
          HealthInfo healthInfo = baseProfile.healthInfo;
          if (userData['height'] != null || userData['weight'] != null || userData['blood_type'] != null) {
            double height = userData['height'] != null ? 
                double.tryParse(userData['height'].toString()) ?? healthInfo.height : healthInfo.height;
            double weight = userData['weight'] != null ? 
                double.tryParse(userData['weight'].toString()) ?? healthInfo.weight : healthInfo.weight;
            String bloodType = userData['blood_type'] ?? healthInfo.bloodType;
            
            healthInfo = HealthInfo(
              height: height,
              weight: weight,
              bloodType: bloodType,
            );
          }
          
          _userProfile = baseProfile.copyWith(
            name: userData['nickname'] ?? baseProfile.name,
            avatarUrl: avatarUrl,
            age: age,
            gender: gender,
            phone: userData['phone'] ?? baseProfile.phone,
            email: userData['email'] ?? baseProfile.email,
            healthInfo: healthInfo,
          );
          
          if (kDebugMode) {
            print('加载的用户头像: ${_userProfile.avatarUrl}');
            print('年龄: ${_userProfile.age}');
            print('性别: ${_userProfile.gender}');
            print('电话: ${_userProfile.phone}');
            print('身高: ${_userProfile.healthInfo.height}');
            print('体重: ${_userProfile.healthInfo.weight}');
          }
        });
      } else {
        // 如果加载失败，使用模拟数据
        setState(() {
          _userProfile = UserProfile.getMockProfile();
        });
        showCustomToast(context, '加载用户数据失败: ${response.message}', ToastType.error);
      }
    } catch (e) {
      // 如果发生错误，使用模拟数据
      setState(() {
        _userProfile = UserProfile.getMockProfile();
      });
      showCustomToast(context, '加载用户数据失败: $e', ToastType.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onEditAvatar() {
    // 实现编辑头像功能
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
            ),
            child: const Text(
              '个人资料编辑',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // 选项
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF4F46E5)),
            title: const Text('修改昵称'),
            onTap: () {
              Navigator.pop(context);
              _showEditNicknameDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera, color: Color(0xFF4F46E5)),
            title: const Text('修改头像'),
            onTap: () {
              Navigator.pop(context);
              _showUploadAvatarOptions();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // 显示编辑昵称的对话框
  void _showEditNicknameDialog() {
    final TextEditingController _nameController = TextEditingController(text: _userProfile.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '昵称',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateNickname(_nameController.text.trim());
            },
            child: const Text('保存', style: TextStyle(color: Color(0xFF4F46E5))),
          ),
        ],
      ),
    );
  }
  
  // 显示上传头像的选项
  void _showUploadAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
            ),
            child: const Text(
              '选择头像来源',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xFF4F46E5)),
            title: const Text('从相册选择'),
            onTap: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFF4F46E5)),
            title: const Text('拍照'),
            onTap: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  // 更新昵称
  void _updateNickname(String newName) async {
    if (newName.isEmpty) {
      showCustomToast(context, '昵称不能为空', ToastType.error);
      return;
    }
    
    // 显示加载状态
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 调用API服务更新昵称
      final response = await _userService.updateNickname(newName);
      
      if (response.isSuccess) {
        // 更新成功，修改本地用户对象
        setState(() {
          _userProfile = _userProfile.copyWith(name: newName);
        });
        
        showCustomToast(context, '昵称修改成功', ToastType.success);
      } else {
        showCustomToast(context, '昵称修改失败: ${response.message}', ToastType.error);
      }
    } catch (e) {
      showCustomToast(context, '昵称修改失败: $e', ToastType.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 从相册选择图片
  void _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85, // 压缩质量，减小文件大小
      );
      
      if (image != null) {
        // 直接传递XFile对象，由UserService处理平台差异
        _uploadAvatar(image);
      }
    } catch (e) {
      showCustomToast(context, '选择图片失败: $e', ToastType.error);
    }
  }
  
  // 使用相机拍照
  void _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85, // 压缩质量，减小文件大小
      );
      
      if (photo != null) {
        // 直接传递XFile对象，由UserService处理平台差异
        _uploadAvatar(photo);
      }
    } catch (e) {
      showCustomToast(context, '拍照失败: $e', ToastType.error);
    }
  }
  
  // 上传头像到服务器
  void _uploadAvatar(dynamic imageFile) async {
    // 显示加载状态
    showCustomToast(context, '正在上传头像...', ToastType.info);
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 调用API服务上传头像
      final response = await _userService.uploadAvatar(imageFile);
      
      if (response.isSuccess && response.data != null) {
        // 提取头像 URL
        final String avatarUrl = response.data['avatar_url'] ?? '';
        if (avatarUrl.isNotEmpty) {
          _onAvatarUploadSuccess(avatarUrl);
        } else {
          showCustomToast(context, '头像返回地址为空', ToastType.error);
        }
      } else {
        showCustomToast(context, '头像上传失败: ${response.message}', ToastType.error);
      }
    } catch (e) {
      showCustomToast(context, '头像上传失败: $e', ToastType.error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 头像上传成功后的回调
  void _onAvatarUploadSuccess(String newAvatarUrl) {
    setState(() {
      _userProfile = _userProfile.copyWith(avatarUrl: newAvatarUrl);
    });
    
    showCustomToast(context, '头像修改成功', ToastType.success);
  }
  
  void _onEditBasicInfo() async {
    // 导航到编辑基本信息页面
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditBasicInfoScreen()),
    );
    
    // 如果返回结果为true，表示信息已更新，需要重新加载个人资料
    if (result == true) {
      _loadUserProfile();
    }
  }

  void _onEditHealthInfo() {
    // TODO: 实现编辑健康信息功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('此功能暂未实现')),
    );
  }

  void _onEditPreferences() {
    // TODO: 实现编辑偏好设置功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('此功能暂未实现')),
    );
  }

  void _onAddFamilyMember() {
    // 导航到家庭成员管理页面，并在返回时刷新数据
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FamilyMembersScreen()),
    ).then((_) => _loadFamilyMembers());
  }

  void _onFamilyMemberTap(FamilyMember member) {
    // 导航到家庭成员管理页面，并在返回时刷新数据
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FamilyMembersScreen()),
    ).then((_) => _loadFamilyMembers());
  }

  void _navigateToSettings() {
    // TODO: 导航到设置页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导航到设置页面')),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // 获取AuthService并调用logout方法
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              
              // 显示成功提示
              showCustomToast(context, '已成功退出登录', ToastType.success);
              
              // 跳转到登录页面
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // 顶部个人头像和信息
              ProfileHeader(
                profile: _userProfile,
                onEditAvatar: _onEditAvatar,
              ),
          
              // 内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 基本信息卡片
                      InfoCard(
                        title: '基本信息',
                        rows: [
                          InfoRow(label: '姓名', value: _userProfile.name),
                          InfoRow(label: '年龄', value: '${_userProfile.age}岁'),
                          InfoRow(label: '性别', value: _userProfile.gender),
                          InfoRow(label: '电话', value: _userProfile.phone),
                        ],
                        onEdit: _onEditBasicInfo,
                      ),
                      
                      // 家庭成员卡片
                      FamilyMembersCard(
                        members: _familyMembers,
                        onAddMember: _onAddFamilyMember,
                        onMemberTap: _onFamilyMemberTap,
                      ),
                      
                      // 账户操作
                      AccountActions(
                        actions: [
                          AccountActionItem(
                            title: '设置',
                            icon: Icons.settings,
                            iconBackgroundColor: Colors.grey[100]!,
                            iconColor: Colors.grey[700]!,
                            onTap: _navigateToSettings,
                          ),
                          AccountActionItem(
                            title: '退出登录',
                            icon: Icons.logout,
                            iconBackgroundColor: const Color(0xFFFFE4E6),
                            iconColor: const Color(0xFFEF4444),
                            isWarning: true,
                            onTap: _showLogoutConfirmation,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
