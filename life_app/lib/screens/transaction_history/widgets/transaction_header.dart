import 'package:flutter/material.dart';
import '../../../models/family_member_model.dart';
import '../../../services/family_member_service.dart';

class TransactionHeader extends StatefulWidget {
  final Function(FamilyMember?)? onMemberSelected;
  final FamilyMember? selectedMember;

  const TransactionHeader({
    Key? key, 
    this.onMemberSelected,
    this.selectedMember
  }) : super(key: key);

  @override
  State<TransactionHeader> createState() => _TransactionHeaderState();
}

class _TransactionHeaderState extends State<TransactionHeader> {
  List<FamilyMember> _familyMembers = [];
  bool _isLoadingMembers = false;
  FamilyMember? _selectedMember;
  
  @override
  void initState() {
    super.initState();
    _selectedMember = widget.selectedMember;
    print('【TransactionHeader】初始化 - 接收到的selectedMember: ${widget.selectedMember?.name}, ID: ${widget.selectedMember?.id}');
    _loadFamilyMembers();
  }
  
  @override
  void didUpdateWidget(TransactionHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当selectedMember属性变化时更新内部状态
    if (widget.selectedMember != oldWidget.selectedMember) {
      print('【TransactionHeader】属性更新 - 新的selectedMember: ${widget.selectedMember?.name}, ID: ${widget.selectedMember?.id}');
      setState(() {
        _selectedMember = widget.selectedMember;
      });
    }
  }
  
  // 加载家庭成员
  Future<void> _loadFamilyMembers() async {
    if (mounted) {
      setState(() {
        _isLoadingMembers = true;
      });
    }

    try {
      final familyMemberService = FamilyMemberService(context: context);
      final response = await familyMemberService.getFamilyMembers();
      
      if (response.success && mounted) {
        // 获取预选成员ID
        final String? preSelectedMemberId = widget.selectedMember?.id.toString();
        print('【TransactionHeader】家庭成员加载成功 - 预选成员ID: $preSelectedMemberId');
        
        setState(() {
          // 确保response.data不为空，否则使用空列表
          _familyMembers = response.data ?? [];
          
          // 如果有预选成员ID，尝试在加载的成员列表中找到匹配成员
          if (preSelectedMemberId != null && preSelectedMemberId.isNotEmpty) {
            final matchingMembers = _familyMembers.where(
              (m) => m.id.toString() == preSelectedMemberId
            ).toList();
            
            if (matchingMembers.isNotEmpty) {
              _selectedMember = matchingMembers.first;
              print('【TransactionHeader】找到匹配的预选成员: ${_selectedMember?.name}, ID: ${_selectedMember?.id}');
            } else {
              print('【TransactionHeader】未找到匹配的预选成员，ID: $preSelectedMemberId');
            }
          } else if (_selectedMember == null && _familyMembers.isNotEmpty) {
            // 如果没有预选成员，则选择全部（显示为null）
            _selectedMember = null;
            print('【TransactionHeader】没有预选成员，使用"全部成员"');
            if (widget.onMemberSelected != null) {
              widget.onMemberSelected!(null);
            }
          }
        });
        
        print('【TransactionHeader】成功加载 ${_familyMembers.length} 个家庭成员');
        print('【TransactionHeader】当前选中成员: ${_selectedMember?.name ?? "全部成员"}, ID: ${_selectedMember?.id}');
        for (var member in _familyMembers) {
          print('【TransactionHeader】成员列表项: ${member.name}, ID: ${member.id}, 角色: ${member.role}');
        }
      }
    } catch (e) {
      print('【TransactionHeader】加载家庭成员失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
        });
      }
    }
  }
  
  // 显示成员选择器
  void _showMemberPicker() {
    if (_isLoadingMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在加载成员数据，请稍候...')),
      );
      return;
    }
    
    if (_familyMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无家庭成员数据')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // 顶部指示条
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '选择成员',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              
              // 全部选项
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMember = null;
                    });
                    if (widget.onMemberSelected != null) {
                      widget.onMemberSelected!(null);
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      color: _selectedMember == null ? Colors.green.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.people,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            "全部成员",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (_selectedMember == null) 
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              Divider(height: 16, color: Colors.grey[200]),
                
              // 家庭成员列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _familyMembers.length,
                  itemBuilder: (context, index) {
                    final member = _familyMembers[index];
                    final isSelected = _selectedMember?.id == member.id;
                    
                    // 确保显示名称优先使用昵称
                    final displayName = member.nickname.isNotEmpty 
                        ? member.nickname 
                        : member.name;
                    
                    // 确保显示角色
                    final roleName = member.getRoleName();

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMember = member;
                        });
                        if (widget.onMemberSelected != null) {
                          widget.onMemberSelected!(member);
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            _buildMemberAvatar(member, size: 36),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    roleName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected) 
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 构建成员头像
  Widget _buildMemberAvatar(FamilyMember member, {double size = 30}) {
    final bool isCurrentUser = member.isCurrentUser;
    final double radius = size / 2;
    final double indicatorSize = size * 0.4;
    
    if (member.avatarUrl.isNotEmpty) {
      return Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(member.avatarUrl),
            backgroundColor: Colors.grey[200],
          ),
          if (isCurrentUser)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // 如果没有头像，使用占位符
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: Text(
          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部导航栏
          Row(
            children: [
              // 返回按钮
                  GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
              const SizedBox(width: 12),
              // 页面标题
                  const Text(
                    '交易记录',
                    style: TextStyle(
                  fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
          
          const SizedBox(height: 4),
          
          // 成员选择行 - 优化后的布局
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 页面描述
              Opacity(
                opacity: 0.8,
                child: const Text(
                  '查看所有收支明细',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // 成员选择按钮 - 减小高度
              GestureDetector(
                onTap: _showMemberPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedMember != null && _selectedMember!.avatarUrl.isNotEmpty)
                    Container(
                          width: 16,
                          height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(_selectedMember!.avatarUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
          Container(
                          width: 16,
                          height: 16,
            decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                            size: 10,
                      ),
                    ),
                      const SizedBox(width: 3),
                  Text(
                    _selectedMember != null 
                        ? (_selectedMember!.nickname.isNotEmpty 
                            ? _selectedMember!.nickname 
                            : _selectedMember!.name)
                        : '全部成员',
                    style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                    ),
                  ),
                      const SizedBox(width: 1),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                        size: 14,
                    ),
                  ],
                ),
            ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
