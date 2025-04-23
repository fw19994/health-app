import 'package:flutter/material.dart';
import '../services/family_member_service.dart';

class FindUserForm extends StatefulWidget {
  final int ownerId;
  final Function(bool) onUserFound;
  final Function(Map<String, dynamic>) onUserSelected;

  const FindUserForm({
    super.key,
    required this.ownerId,
    required this.onUserFound,
    required this.onUserSelected,
  });

  @override
  State<FindUserForm> createState() => _FindUserFormState();
}

class _FindUserFormState extends State<FindUserForm> {
  final _phoneController = TextEditingController();
  final _nicknameController = TextEditingController();
  
  String _selectedRole = '家庭成员';
  String _selectedPermission = '查看者';
  
  bool _isSearching = false;
  Map<String, dynamic>? _foundUser;
  
  @override
  void dispose() {
    _phoneController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '手机号码',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      hintText: '输入手机号查找用户',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Color(0xFFA0AEC0),
                        fontSize: 14,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ),
              IconButton(
                onPressed: _searchUser,
                icon: _isSearching 
                    ? const SizedBox(
                        width: 20, 
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                        ),
                      )
                    : const Icon(
                        Icons.search,
                        color: Color(0xFF059669),
                        size: 20,
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // 家庭关系
        const Text(
          '家庭关系',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        _buildRoleDropdown(),
        const SizedBox(height: 16),
        
        // 家庭称呼
        const Text(
          '家庭称呼',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                hintText: '如"小美"、"老公"等亲切称呼',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFFA0AEC0),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 权限设置
        const Text(
          '权限设置',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        _buildPermissionDropdown(),
        const SizedBox(height: 16),
        
        // 搜索结果
        if (_foundUser != null) _buildUserFoundState(),
      ],
    );
  }
  
  // 角色下拉菜单
  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(value: '家庭成员', child: Text('家庭成员')),
            DropdownMenuItem(value: '配偶', child: Text('配偶')),
            DropdownMenuItem(value: '子女', child: Text('子女')),
            DropdownMenuItem(value: '其他', child: Text('其他')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedRole = value!;
            });
          },
        ),
      ),
    );
  }
  
  // 权限下拉菜单
  Widget _buildPermissionDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPermission,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(value: '查看者', child: Text('查看者 (仅查看)')),
            DropdownMenuItem(value: '编辑者', child: Text('编辑者 (查看和编辑)')),
            DropdownMenuItem(value: '管理员', child: Text('管理员 (完全权限)')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPermission = value!;
            });
          },
        ),
      ),
    );
  }
  
  // 搜索用户
  Future<void> _searchUser() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入手机号')),
      );
      return;
    }
    
    setState(() {
      _isSearching = true;
      _foundUser = null;
    });
    
    try {
      final familyService = FamilyMemberService(context: context);
      final response = await familyService.findUserByPhone(phone);
      
      if (response.success && response.data != null) {
        setState(() {
          _foundUser = response.data;
          _isSearching = false;
        });
        widget.onUserFound(true);
      } else {
        setState(() {
          _foundUser = null;
          _isSearching = false;
        });
        widget.onUserFound(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _foundUser = null;
      });
      widget.onUserFound(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('查找用户失败: ${e.toString()}')),
      );
    }
  }
  
  // 用户找到状态
  Widget _buildUserFoundState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF059669),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '已找到用户: ${_foundUser!['name']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildUserInfoRow('手机:', _foundUser!['phone'] ?? ''),
          const SizedBox(height: 4),
          _buildUserInfoRow('昵称:', _foundUser!['nickname'] ?? ''),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addFoundUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('添加为家庭成员'),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建用户信息行
  Widget _buildUserInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  // 添加找到的用户
  void _addFoundUser() {
    if (_foundUser == null) return;
    
    // 准备成员数据
    final userData = {
      'user_id': _foundUser!['id'],
      'owner_id': widget.ownerId,
      'name': _foundUser!['name'] ?? '',
      'nickname': _nicknameController.text.trim(),
      'phone': _foundUser!['phone'] ?? '',
      'role': _selectedRole,
      'permission': _selectedPermission,
      'avatar_url': _foundUser!['avatar'] ?? '',
    };
    
    widget.onUserSelected(userData);
  }
}
