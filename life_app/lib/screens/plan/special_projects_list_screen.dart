import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/routes.dart';
import '../../models/plan/special_project_model.dart';
import '../../services/special_project_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/plan/add_special_project_modal.dart';
import 'widgets/special_project_card.dart';
import 'package:provider/provider.dart';

class SpecialProjectsListScreen extends StatefulWidget {
  const SpecialProjectsListScreen({Key? key}) : super(key: key);

  @override
  State<SpecialProjectsListScreen> createState() => _SpecialProjectsListScreenState();
}

class _SpecialProjectsListScreenState extends State<SpecialProjectsListScreen> {
  String _currentFilter = '全部';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialProjectService>(
      builder: (context, projectService, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Expanded(
                child: _buildProjectList(projectService),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // 使用新的弹窗组件替代导航
              AddSpecialProjectModal.show(context, onCreated: (project) {
                // 可以在这里添加创建成功后的逻辑
                setState(() {}); // 刷新列表
              });
            },
            backgroundColor: const Color(0xFF4F46E5),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  // 构建头部
  Widget _buildHeader(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight, bottom: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF5D4CE6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题和菜单
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // 添加返回按钮
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                const Text(
                  '专项计划',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // 显示更多选项
                    _showMoreOptions(context);
                  },
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6A5AEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜索专项计划',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        // 关键是这里，确保背景透明
                        fillColor: Colors.transparent,
                        filled: true,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      cursorColor: Colors.white,
                      cursorWidth: 1.0,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 分类标签
          Container(
            height: 32,
            margin: const EdgeInsets.fromLTRB(0, 16, 0, 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterChip('全部'),
                _buildFilterChip('进行中'),
                _buildFilterChip('已完成'),
                _buildFilterChip('未开始'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建过滤标签
  Widget _buildFilterChip(String label) {
    final bool isActive = _currentFilter == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive 
              ? Colors.white
              : const Color(0xFF6A5AEE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF5D4CE6) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 构建项目列表
  Widget _buildProjectList(SpecialProjectService projectService) {
    // 根据过滤条件和搜索关键词筛选项目
    final List<SpecialProject> filteredProjects = projectService.projects
        .where((project) {
          // 搜索过滤
          if (_searchController.text.isNotEmpty) {
            return project.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );
          }
          return true;
        })
        .where((project) {
          // 状态过滤
          switch (_currentFilter) {
            case '进行中':
              return project.status == ProjectStatus.active;
            case '已完成':
              return project.status == ProjectStatus.completed;
            case '未开始':
              return project.status == ProjectStatus.planned;
            default:
              return true;
          }
        })
        .toList();

    if (filteredProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无专项计划',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        final project = filteredProjects[index];
        return SpecialProjectCard(project: project);
      },
    );
  }

  // 显示更多选项
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('排序方式'),
                onTap: () {
                  Navigator.pop(context);
                  // 显示排序选项
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('管理类别'),
                onTap: () {
                  Navigator.pop(context);
                  // 导航到类别管理页面
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('设置'),
                onTap: () {
                  Navigator.pop(context);
                  // 导航到设置页面
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 