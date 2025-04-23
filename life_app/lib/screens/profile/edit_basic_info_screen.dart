import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/login/custom_toast.dart' show showCustomToast, ToastType;
import 'models/user_profile.dart';

class EditBasicInfoScreen extends StatefulWidget {
  const EditBasicInfoScreen({super.key});

  @override
  State<EditBasicInfoScreen> createState() => _EditBasicInfoScreenState();
}

class _EditBasicInfoScreenState extends State<EditBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserService _userService;
  bool _isLoading = true;
  bool _isSaving = false;

  // 表单控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  // 性别选择
  String _selectedGender = '男';
  DateTime? _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userService = UserService(context: context);
    _loadUserData();
  }

  @override
  void dispose() {
    // 销毁控制器，避免内存泄漏
    _nameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // 加载用户数据并填充表单
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取用户信息
      final response = await _userService.getUserProfile();
      
      if (response.code == 0 && response.data != null) {
        // 填充表单字段
        final userData = response.data;
        
        setState(() {
          _nameController.text = userData['nickname'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          
          // 处理生日日期
          if (userData['birthday'] != null && userData['birthday'].toString().isNotEmpty) {
            try {
              _selectedDate = DateTime.parse(userData['birthday']);
              _birthdayController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
            } catch (e) {
              debugPrint('生日解析错误: $e');
              _birthdayController.text = '';
            }
          }
          
          // 将后端的gender值转换为前端显示的中文
          if (userData['gender'] != null) {
            switch (userData['gender']) {
              case 'male':
                _selectedGender = '男';
                break;
              case 'female':
                _selectedGender = '女';
                break;
              default:
                _selectedGender = '男';
            }
          } else {
            _selectedGender = '男';
          }
          
          _addressController.text = userData['address'] ?? '';
          _occupationController.text = userData['occupation'] ?? '';
          _bioController.text = userData['bio'] ?? '';
        });
      } else {
        // 显示错误消息
        if (mounted) {
          showCustomToast(
            context, 
            response.message ?? '加载用户信息失败',
            ToastType.error,
          );
        }
      }
    } catch (e) {
      debugPrint('加载用户数据错误: $e');
      if (mounted) {
        showCustomToast(
          context, 
          '加载用户数据出错: $e',
          ToastType.error,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 保存用户基本信息
  Future<void> _saveUserInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 准备提交的数据
      // 将中文性别转换为后端需要的格式
      String gender;
      switch (_selectedGender) {
        case '男': // 男
          gender = 'male';
          break;
        case '女': // 女
          gender = 'female';
          break;
        default:
          gender = 'other';
      }
      
      final Map<String, dynamic> userData = {
        'nickname': _nameController.text,
        'phone': _phoneController.text,
        'birthday': _selectedDate != null 
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!) 
            : null,
        'gender': gender,
        'address': _addressController.text,
        'occupation': _occupationController.text,
        'bio': _bioController.text,
      };

      // 调用API更新用户信息
      final response = await _userService.updateUserProfile(userData);

      if (response.code == 0) {
        if (mounted) {
          // 更新成功，显示成功消息
          showCustomToast(
            context, 
            '个人资料更新成功',
            ToastType.success,
          );
          
          // 更新AuthService中的用户信息
          final authService = Provider.of<AuthService>(context, listen: false);
          authService.updateUserInfo(nickname: _nameController.text);
          
          // 返回上一页
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          // 显示错误消息
          showCustomToast(
            context, 
            response.message ?? '更新失败',
            ToastType.error,
          );
        }
      }
    } catch (e) {
      debugPrint('保存用户数据错误: $e');
      if (mounted) {
        showCustomToast(
          context, 
          '保存用户数据出错: $e',
          ToastType.error,
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // 选择日期方法
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5), // 主题色与UI一致
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('编辑基本信息'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 姓名
                        _buildTextField(
                          controller: _nameController,
                          label: '姓名',
                          hintText: '请输入您的姓名',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入姓名';
                            }
                            return null;
                          },
                        ),
                        
                        // 性别选择
                        _buildLabel('性别'),
                        _buildGenderSelector(),
                        
                        // 生日
                        _buildDateField(
                          controller: _birthdayController,
                          label: '出生日期',
                          hintText: 'YYYY-MM-DD',
                          onTap: _selectDate,
                        ),
                        
                        // 联系电话
                        _buildTextField(
                          controller: _phoneController,
                          label: '联系电话',
                          hintText: '请输入您的联系电话',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        

                        
                        // 居住地址
                        _buildTextField(
                          controller: _addressController,
                          label: '居住地址',
                          hintText: '请输入您的居住地址',
                          icon: Icons.home,
                        ),
                        
                        // 职业
                        _buildTextField(
                          controller: _occupationController,
                          label: '职业',
                          hintText: '请输入您的职业',
                          icon: Icons.work,
                        ),
                        

                        
                        // 个人简介
                        _buildTextField(
                          controller: _bioController,
                          label: '个人简介',
                          hintText: '请简单介绍一下自己',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 保存按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _isSaving ? null : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: const Text('取消'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isSaving ? null : _saveUserInfo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('保存'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // 构建文本输入字段
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF4F46E5)),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 构建日期选择字段
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4F46E5)),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          readOnly: true,
          onTap: onTap,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 构建标签文本
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }

  // 构建性别选择器
  Widget _buildGenderSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildGenderOption('男'),
          const SizedBox(width: 16),
          _buildGenderOption('女'),
        ],
      ),
    );
  }

  // 构建性别选项
  Widget _buildGenderOption(String gender) {
    final isSelected = _selectedGender == gender;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              gender == '男' ? Icons.male : Icons.female,
              color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
