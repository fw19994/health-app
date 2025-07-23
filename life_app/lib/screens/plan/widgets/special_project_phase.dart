import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../special_project_detail_screen.dart';
import 'action_buttons.dart';
import 'special_project_timeline.dart'; // 添加导入

class SpecialProjectPhase extends StatefulWidget {
  final String id;
  final String title;
  final List<Widget> children;
  final VoidCallback onEdit;
  final VoidCallback? onAddPhaseBefore;
  final VoidCallback? onDeletePhase;
  
  const SpecialProjectPhase({
    Key? key,
    required this.id,
    required this.title,
    required this.children,
    required this.onEdit,
    this.onAddPhaseBefore,
    this.onDeletePhase,
  }) : super(key: key);

  @override
  State<SpecialProjectPhase> createState() => _SpecialProjectPhaseState();
}

class _SpecialProjectPhaseState extends State<SpecialProjectPhase> {
  // 控制阶段内容是否展开
  bool _isExpanded = false;  // 默认折叠状态
  
  // 预定义的颜色方案列表
  static const List<Map<String, Color>> colorSchemes = [
    {
      'primary': Color(0xFF4F46E5),      // 紫色
      'lighter': Color(0xFFF5F3FF),
      'darker': Color(0xFF4338CA),
      'gradient1': Color(0xFFF5F3FF),
      'gradient2': Color(0xFFEEF2FF),
    },
    {
      'primary': Color(0xFF0EA5E9),      // 蓝色
      'lighter': Color(0xFFE0F2FE),
      'darker': Color(0xFF0369A1),
      'gradient1': Color(0xFFE0F7FF),
      'gradient2': Color(0xFFE0F2FE),
    },
    {
      'primary': Color(0xFF10B981),      // 绿色
      'lighter': Color(0xFFECFDF5),
      'darker': Color(0xFF047857),
      'gradient1': Color(0xFFECFDF5),
      'gradient2': Color(0xFFD1FAE5),
    },
    {
      'primary': Color(0xFFEF4444),      // 红色
      'lighter': Color(0xFFFEE2E2),
      'darker': Color(0xFFB91C1C),
      'gradient1': Color(0xFFFEE2E2),
      'gradient2': Color(0xFFFECACA),
    },
    {
      'primary': Color(0xFFF59E0B),      // 黄色
      'lighter': Color(0xFFFEF3C7),
      'darker': Color(0xFFB45309),
      'gradient1': Color(0xFFFEF3C7),
      'gradient2': Color(0xFFFDE68A),
    },
    {
      'primary': Color(0xFF8B5CF6),      // 亮紫色
      'lighter': Color(0xFFF3E8FF),
      'darker': Color(0xFF6D28D9),
      'gradient1': Color(0xFFF3E8FF),
      'gradient2': Color(0xFFEDE9FE),
    },
    {
      'primary': Color(0xFFEC4899),      // 粉色
      'lighter': Color(0xFFFCE7F3),
      'darker': Color(0xFFBE185D),
      'gradient1': Color(0xFFFCE7F3),
      'gradient2': Color(0xFFFBCFE8),
    },
  ];

  // 获取阶段颜色
  Map<String, Color> _getPhaseColors() {
    // 使用ID的哈希值来确定颜色方案索引
    final colorIndex = widget.id.hashCode.abs() % colorSchemes.length;
    return colorSchemes[colorIndex];
  }
  
  // 切换展开/收起状态
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final addButtonController = Provider.of<AddButtonController>(context);
    final bool showAddButton = addButtonController.activePhaseId == widget.id;
    
    // 获取此阶段的颜色方案
    final colors = _getPhaseColors();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 阶段标题区域
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 6), // 增加间距
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 阶段标题容器
              GestureDetector(
                onTap: () {
                  // 点击时切换当前阶段的激活状态
                  if (addButtonController.activePhaseId == widget.id) {
                    addButtonController.clearAll();
                  } else {
                    addButtonController.setActivePhase(widget.id);
                  }
                },
                child: MouseRegion(
                  onEnter: (_) => addButtonController.setActivePhase(widget.id),
                  onExit: (_) => addButtonController.clearAll(),
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: double.infinity, // 确保容器占满整个宽度
                    padding: const EdgeInsets.fromLTRB(16, 16, 60, 16), // 增加内边距
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: showAddButton 
                              ? colors['primary']! // 使用主题色
                              : colors['primary']!,
                          width: showAddButton ? 5 : 4, // 加粗左侧边框
                        ),
                      ),
                      gradient: showAddButton 
                          ? LinearGradient( // 激活状态使用渐变色
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [colors['gradient1']!, colors['gradient2']!],
                            )
                          : null, // 未激活状态不使用渐变
                      color: showAddButton ? null : const Color(0xFFFAFAFA), // 仅未激活时使用纯色背景
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10), // 更大的圆角
                        bottomRight: Radius.circular(10),
                      ),
                      boxShadow: showAddButton 
                          ? [
                              BoxShadow(
                                color: colors['primary']!.withOpacity(0.15),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ] 
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        // 添加阶段图标
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: showAddButton 
                                ? colors['primary']!.withOpacity(0.15) 
                                : colors['primary']!.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.layers_outlined, // 使用层级图标表示阶段
                            size: 16,
                            color: showAddButton 
                                ? colors['darker']!
                                : colors['primary']!,
                          ),
                        ),
                        // 阶段标题
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: showAddButton 
                                  ? colors['darker']! // 激活状态使用更深的颜色
                                  : const Color(0xFF1F2937), // 更深的文字颜色
                              letterSpacing: 0.3, // 增加字间距
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 展开/收起按钮 - 调整位置和样式
              Positioned(
                right: 14,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _toggleExpanded,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34, // 增加按钮尺寸
                      height: 34,
                      decoration: BoxDecoration(
                        color: colors['primary']!.withOpacity(_isExpanded ? 0.12 : 0.08),  // 不管展开还是折叠都使用主题色背景
                        borderRadius: BorderRadius.circular(17), // 完全圆形
                        boxShadow: [
                          BoxShadow(
                            color: colors['primary']!.withOpacity(_isExpanded ? 0.2 : 0.1),  // 两种状态都使用主题色阴影
                            blurRadius: 4,  // 统一阴影模糊度
                            spreadRadius: _isExpanded ? 0 : -1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        border: Border.all(
                          color: colors['primary']!.withOpacity(_isExpanded ? 0.8 : 0.5),  // 两种状态都使用主题色边框，只是透明度不同
                          width: _isExpanded ? 1.5 : 1, // 激活时加粗边框
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: colors['darker'],  // 两种状态都使用主题的darker颜色
                          size: 22, // 增大图标
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 使用新的操作按钮组件
              PhaseActionButtons(
                isVisible: showAddButton,
                onAdd: widget.onAddPhaseBefore != null ? () {
                  widget.onAddPhaseBefore!();
                  addButtonController.clearAll();
                } : null,
                onEdit: () => widget.onEdit(),
                onDelete: widget.onDeletePhase,
              ),
            ],
          ),
        ),
        
        // 阶段内容 - 根据展开状态显示
        if (_isExpanded) 
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4), // 增加上下内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
      ],
    );
  }
} 