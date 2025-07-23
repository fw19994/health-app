import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/routes.dart';
import '../../models/plan/special_project_model.dart';
import '../../models/plan/project_task_model.dart';
import '../../models/plan/project_phase_model.dart';
import '../../services/special_project_service.dart';
import '../../services/project_phase_service.dart';
import '../../widgets/common/date_picker_modal.dart';
import 'widgets/special_project_header.dart';
import 'widgets/special_project_summary.dart';
import 'widgets/special_project_timeline.dart';
import 'widgets/special_project_phase.dart';
import 'widgets/project_phases_list.dart';
import 'widgets/add_task_button.dart';
import '../../widgets/plan/custom_time_picker.dart';
import 'package:intl/intl.dart'; // Added for DateFormat

// 添加按钮控制器 - 用于管理所有添加按钮的状态
class AddButtonController extends ChangeNotifier {
  String? _activePhaseId;
  String? _activeTaskId;
  
  String? get activePhaseId => _activePhaseId;
  String? get activeTaskId => _activeTaskId;
  
  void setActivePhase(String? phaseId) {
    if (_activePhaseId != phaseId) {
      _activePhaseId = phaseId;
      // 当激活新阶段时，清除任务激活状态
      _activeTaskId = null;
      notifyListeners();
    }
  }
  
  void setActiveTask(String? taskId) {
    if (_activeTaskId != taskId) {
      _activeTaskId = taskId;
      // 当激活新任务时，清除阶段激活状态
      _activePhaseId = null;
      notifyListeners();
    }
  }
  
  void clearAll() {
    _activePhaseId = null;
    _activeTaskId = null;
    notifyListeners();
  }
  
  // 检查是否有任何按钮处于激活状态
  bool get hasActiveButton => _activePhaseId != null || _activeTaskId != null;
}

class SpecialProjectDetailScreen extends StatefulWidget {
  final String projectId;
  
  const SpecialProjectDetailScreen({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  State<SpecialProjectDetailScreen> createState() => _SpecialProjectDetailScreenState();
}

class _SpecialProjectDetailScreenState extends State<SpecialProjectDetailScreen> {
  SpecialProject? _project;
  final AddButtonController _addButtonController = AddButtonController();
  
  // 默认阶段和自定义阶段
  final List<String> _defaultPhases = [
    '设计阶段',
    '采购阶段',
    '施工阶段',
    '验收阶段',
  ];
  
  // 状态变量
  bool _isLoading = true;
  bool _isProcessing = false; // 用于标记是否正在处理操作（如删除、编辑等）
  List<String> _phases = []; // 用于存储后端返回的阶段名称
  
  // 服务实例
  late SpecialProjectService _projectService;
  late ProjectPhaseService _phaseService;
  
  @override
  void initState() {
    super.initState();
    
    // 延迟初始化，确保上下文已准备好
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initServices();
    });
  }
  
  // 初始化服务
  void _initServices() {
    if (!mounted) return;
    
    _projectService = Provider.of<SpecialProjectService>(context, listen: false);
    _phaseService = Provider.of<ProjectPhaseService>(context, listen: false);
    
    // 设置服务上下文
    _projectService.setContext(context);
    _phaseService.setContext(context);
    
    // 加载项目数据
    _loadProject();
  }
  
  @override
  void dispose() {
    _addButtonController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProject() async {
    // 检查组件是否已被销毁
    if (!mounted) return;
    
    // 如果正在处理其他操作，不重复加载
    if (_isProcessing) return;
    
    // 显示加载状态
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      // 从API获取项目详情
      final projectDetail = await _projectService.getSpecialProjectDetail(widget.projectId);
      
      // 再次检查组件是否已被销毁
      if (!mounted) return;
      
      if (projectDetail != null) {
        if (mounted) {
          setState(() {
            _project = projectDetail;
            _isLoading = false;
            
            // 如果有阶段数据，使用后端返回的阶段
            if (_project!.phases.isNotEmpty) {
              _phases = _project!.phases.map((phase) => phase.name).toList();
            }
          });
        }
    } else {
        // 加载失败，显示错误信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('获取专项计划详情失败')),
          );
          
          setState(() {
            _isLoading = false;
          });
          
      // 项目不存在，返回上一页
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
          });
        }
      }
    } catch (e) {
      print('加载专项计划详情时出错: $e');
      
      // 检查组件是否已被销毁
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('获取专项计划详情失败')),
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 初始加载状态
    if (_isLoading && _project == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // 加载失败状态
    if (_project == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('无法加载专项计划', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('返回'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProject,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    
    return ChangeNotifierProvider.value(
      value: _addButtonController,
      child: GestureDetector(
        onTap: () => _addButtonController.clearAll(), // 点击空白处清除所有激活状态
        child: Scaffold(
      body: Column(
        children: [
          // 头部
          SpecialProjectHeader(project: _project!),
          
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 项目摘要
                  SpecialProjectSummary(project: _project!),
                  
                      // 使用API数据显示阶段列表
                      ProjectPhasesList(
                        phases: _project!.phases,
                        onEditPhase: _showEditPhaseDialog,
                        onAddPhase: _showAddPhaseDialog,
                        onDeletePhase: _deletePhase,
                        onEditTask: _editTask,
                        onAddTask: _showAddTaskModal,
                        onAddTaskBefore: _showAddTaskBeforeModal,
                        onDeleteTask: _deleteTask,
                        onCompleteTask: _completeTask,
                  ),
                  
                  // 底部间距
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddPhaseDialog(null),
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
  
  // 获取设计阶段任务
  List<ProjectTask> _getDesignTasks() {
    // 这里应该从项目数据中获取设计阶段的任务
    // 暂时使用模拟数据
    return [
      ProjectTask(
        id: '1',
        title: '确定装修风格与预算',
        description: '初步确定现代简约风格，预算控制在15万内。',
        date: DateTime(2025, 4, 1),
        cost: 500.0,
        status: TaskStatus.completed,
        category: 'design',
      ),
      ProjectTask(
        id: '2',
        title: '找设计师咨询',
        description: '联系3家装修公司，对比方案与报价。',
        date: DateTime(2025, 4, 5),
        cost: 3000.0,
        status: TaskStatus.completed,
        category: 'design',
      ),
      ProjectTask(
        id: '3',
        title: '确定平面布局图',
        description: '厨房改为开放式，客厅扩大3平米。',
        date: DateTime(2025, 4, 10),
        cost: 2500.0,
        status: TaskStatus.completed,
        category: 'design',
      ),
      ProjectTask(
        id: '4',
        title: '确定装修材料清单',
        description: '地板选用强化木地板，墙面采用乳胶漆。',
        date: DateTime(2025, 4, 15),
        cost: 1200.0,
        status: TaskStatus.inProgress,
        category: 'design',
      ),
    ];
  }
  
  // 获取采购阶段任务
  List<ProjectTask> _getPurchaseTasks() {
    // 这里应该从项目数据中获取采购阶段的任务
    // 暂时使用模拟数据
    return [
      ProjectTask(
        id: '5',
        title: '采购主材',
        description: '地板、瓷砖、卫浴设备、灯具等。',
        date: DateTime(2025, 4, 20),
        cost: 50000.0,
        status: TaskStatus.notStarted,
        category: 'purchase',
      ),
      ProjectTask(
        id: '6',
        title: '采购家电',
        description: '冰箱、洗衣机、空调等大型家电。',
        date: DateTime(2025, 5, 1),
        cost: 30000.0,
        status: TaskStatus.notStarted,
        category: 'purchase',
      ),
    ];
  }
  
  // 获取施工阶段任务
  List<ProjectTask> _getConstructionTasks() {
    // 这里应该从项目数据中获取施工阶段的任务
    // 暂时使用模拟数据
    return [
      ProjectTask(
        id: '7',
        title: '水电改造',
        description: '所有房间的水电改造，包括隐蔽工程。',
        date: DateTime(2025, 5, 10),
        cost: 18000.0,
        status: TaskStatus.notStarted,
        category: 'construction',
      ),
      ProjectTask(
        id: '8',
        title: '泥瓦工程',
        description: '铺设地砖、墙砖，卫生间防水处理。',
        date: DateTime(2025, 5, 20),
        cost: 0.0,
        status: TaskStatus.notStarted,
        category: 'construction',
      ),
      ProjectTask(
        id: '9',
        title: '木工工程',
        description: '安装木门、橱柜、衣柜等。',
        date: DateTime(2025, 5, 30),
        cost: 0.0,
        status: TaskStatus.notStarted,
        category: 'construction',
      ),
    ];
  }
  
  // 获取验收阶段任务
  List<ProjectTask> _getInspectionTasks() {
    // 这里应该从项目数据中获取验收阶段的任务
    // 暂时使用模拟数据
    return [
      ProjectTask(
        id: '10',
        title: '完工验收',
        description: '检查所有施工项目的完成情况。',
        date: DateTime(2025, 6, 20),
        cost: 1000.0,
        status: TaskStatus.notStarted,
        category: 'inspection',
      ),
      ProjectTask(
        id: '11',
        title: '家具进场',
        description: '沙发、餐桌、床等大型家具的购买和安装。',
        date: DateTime(2025, 6, 25),
        cost: 45000.0,
        status: TaskStatus.notStarted,
        category: 'inspection',
      ),
      ProjectTask(
        id: '12',
        title: '入住准备',
        description: '清洁、消毒、室内装饰等。',
        date: DateTime(2025, 6, 30),
        cost: 3800.0,
        status: TaskStatus.notStarted,
        category: 'inspection',
      ),
    ];
  }
  
  // 显示添加任务模态框
  void _showAddTaskModal(String phaseId) {
    // 查找阶段名称
    String phaseName = '';
    for (var phase in _project!.phases) {
      if (phase.id == phaseId) {
        phaseName = phase.name;
        break;
      }
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return AddTaskModal(
          initialPhase: phaseName,
          phaseId: phaseId,  // 传递阶段ID
          onSave: (task, id) => _addTask(task, id),
        );
      },
    );
  }
  
  // 显示编辑任务模态框
  void _showEditTaskModal(ProjectTask task) {
    // 查找任务所属的阶段ID
    String phaseId = '';
    String phaseName = '';
    
    for (var phase in _project!.phases) {
      for (var existingTask in phase.tasks) {
        if (existingTask.id == task.id) {
          phaseId = phase.id;
          phaseName = phase.name;
          break;
        }
      }
      if (phaseId.isNotEmpty) break;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return AddTaskModal(
          initialPhase: phaseName,
          phaseId: phaseId,
          existingTask: task,
          onSave: (updatedTask, phaseId) => _updateTask(updatedTask, phaseId),
        );
      },
    );
  }
  
  // 从分类获取阶段名称
  String _getPhaseFromCategory(String category) {
    switch (category) {
      case 'design':
        return '设计阶段';
      case 'purchase':
        return '采购阶段';
      case 'construction':
        return '施工阶段';
      case 'inspection':
        return '验收阶段';
      default:
        if (category.startsWith('custom_')) {
          // 处理自定义阶段
          String phaseName = category.substring(7); // 去掉'custom_'前缀
          phaseName = phaseName.replaceAll('_', ' '); // 将下划线替换为空格
          // 将首字母大写
          return phaseName.split(' ').map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1);
          }).join(' ');
        }
        return '设计阶段'; // 默认值
    }
  }
  
  // 更新任务
  Future<void> _updateTask(ProjectTask updatedTask, String phaseId) async {
    if (_project == null) return;
    
    // 显示加载指示器
    setState(() {
      _isProcessing = true;
    });
    
    try {
    // 使用特殊项目服务更新任务
    final projectService = Provider.of<SpecialProjectService>(context, listen: false);
      
      // 调用API更新任务
      final result = await projectService.updateTaskInPhase(
        projectId: _project!.id,
        phaseId: phaseId,
        task: updatedTask
      );
      
      if (result) {
        // 更新成功，重新加载项目数据
        await _loadProject();
    
    // 显示成功提示
        if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('任务更新成功')),
          );
        }
      } else {
        // 更新失败，显示错误信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新任务失败: ${projectService.error ?? "未知错误"}')),
          );
        }
      }
    } catch (e) {
      print('更新任务时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新任务失败，请稍后重试')),
        );
      }
    } finally {
      // 隐藏加载指示器
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  // 显示编辑阶段对话框
  Future<void> _showEditPhaseDialog(String phaseId) async {
    if (_project == null || !mounted || _isProcessing) return;
    
    // 查找当前阶段
    ProjectPhase? phase;
    try {
      phase = _project!.phases.firstWhere(
        (p) => p.id == phaseId,
      );
    } catch (e) {
      // 找不到指定阶段
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('找不到指定的阶段')),
        );
      }
      return;
    }
    
    // 创建控制器
    final TextEditingController nameController = TextEditingController(text: phase.name);
    final TextEditingController descController = TextEditingController(text: phase.description);
    final formKey = GlobalKey<FormState>();
    
    try {
      // 显示对话框
      final result = await showDialog<Map<String, String>?>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
        barrierDismissible: false,  // 防止点击外部关闭对话框
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // 标题栏
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFEEEEEE),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4F46E5),
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '编辑阶段',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 表单内容
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '阶段名称',
                            style: TextStyle(
                          fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: '输入阶段名称',
                              hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入阶段名称';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '阶段描述',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: descController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: '输入阶段描述（可选）',
                              hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                        filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                    
                    // 按钮区域
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 取消按钮
                        TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(null),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                          ),
                          child: const Text(
                            '取消',
                            style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // 保存按钮
                        ElevatedButton(
                          onPressed: () {
                                  if (formKey.currentState?.validate() ?? false) {
                                    Navigator.of(dialogContext).pop({
                                      'name': nameController.text,
                                      'description': descController.text,
                                    });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            '保存',
                            style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
                  ),
                ],
            ),
          ),
        );
      },
      );
      
      // 处理对话框结果
      if (result != null && mounted) {
        await _updatePhase(
          phaseId: phaseId,
          name: result['name'] ?? '',
          description: result['description'] ?? '',
        );
      }
    } catch (e) {
      print('显示编辑对话框时出错: $e');
    } finally {
      // 确保控制器被释放
      nameController.dispose();
      descController.dispose();
    }
  }
  
  // 更新阶段
  Future<void> _updatePhase({
    required String phaseId,
    required String name,
    required String description,
  }) async {
    // 避免在异步操作完成前Widget被销毁
    if (!mounted) return;
    
    // 避免多个操作同时进行
    if (_isProcessing) return;
    
    // 设置处理状态
    if (mounted) {
      setState(() {
        _isProcessing = true;
      });
    }
    
    try {
      final success = await _phaseService.updatePhase(
        phaseId: phaseId,
        name: name,
        description: description,
      );
      
      // 再次检查组件是否已被销毁
      if (!mounted) return;
      
      if (success) {
        // 重置处理状态
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
        
        // 重新加载项目数据
        await _loadProject();
      } else {
        if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
              content: Text('更新阶段失败: ${_phaseService.error ?? "未知错误"}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
          
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      print('更新阶段时出错: $e');
      
      // 检查组件是否已被销毁
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('更新阶段失败，请稍后重试'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  // 添加任务
  Future<void> _addTask(ProjectTask task, String phaseId) async {
    if (_project == null) return;
    
    // 显示加载指示器
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // 使用特殊项目服务添加任务
      final projectService = Provider.of<SpecialProjectService>(context, listen: false);
      
      // 调用API添加任务
      final result = await projectService.addTaskToPhase(
        projectId: _project!.id,
        phaseId: phaseId,
        task: task
      );
      
      if (result) {
        // 添加成功，重新加载项目数据
        await _loadProject();
        
        // 显示成功提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('任务添加成功')),
          );
        }
      } else {
        // 添加失败，显示错误信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加任务失败: ${projectService.error ?? "未知错误"}')),
          );
        }
      }
    } catch (e) {
      print('添加任务时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加任务失败，请稍后重试')),
        );
      }
    } finally {
      // 隐藏加载指示器
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  // 显示添加阶段对话框
  void _showAddPhaseDialog(String? referencePhaseId) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    // 添加位置相关变量 - 只有"之前"和"之后"两个选项
    String selectedPosition = "after"; // 默认"之后"
    String? selectedPhaseId = referencePhaseId;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题栏
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFEEEEEE),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4F46E5),
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '添加阶段',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 表单内容
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 添加位置选择 (移到最前面)
                            const Text(
                              '添加位置',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedPosition,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  dropdownColor: Colors.white, // 确保下拉菜单背景为白色
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1F2937),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: "before",
                                      child: Text('之前'),
                                    ),
                                    DropdownMenuItem(
                                      value: "after",
                                      child: Text('之后'),
                                    ),
                                  ],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedPosition = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // 阶段名称
                            const Text(
                              '阶段名称',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: '输入阶段名称',
                                hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入阶段名称';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // 阶段描述
                            const Text(
                              '阶段描述',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: descController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: '输入阶段描述（可选）',
                                hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // 按钮区域
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 取消按钮
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    '取消',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // 添加按钮
                                ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      Navigator.of(context).pop();
                                      
                                      _addPhase(
                                        name: nameController.text,
                                        description: descController.text,
                                        beforePhaseId: selectedPhaseId,
                                        position: selectedPosition,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    '添加',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
  
  // 添加阶段方法
  Future<void> _addPhase({
    required String name, 
    required String description, 
    String? beforePhaseId,
    String? position,
  }) async {
    // 如果项目ID为空，则无法添加阶段
    if (_project == null || _project!.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法添加阶段：项目ID无效')),
      );
      return;
    }
    
    // 验证项目ID是否为有效整数
    try {
      int.parse(_project!.id);
    } catch (e) {
      print('项目ID不是有效整数: ${_project!.id}');
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法添加阶段：项目ID格式错误')),
      );
      return;
    }
    
    // 避免在异步操作完成前Widget被销毁
    if (!mounted) return;
    
    // 避免多个操作同时进行
    if (_isProcessing) return;
    
    // 设置处理状态
    if (mounted) {
      setState(() {
        _isProcessing = true;
      });
    }
    
    try {
      // 确定添加位置参数
      String? referencePhaseId = beforePhaseId;
      String? positionValue = position;
      
      final result = await _phaseService.createPhase(
        projectId: _project!.id,
        name: name,
        description: description,
        referencePhaseId: referencePhaseId,
        position: positionValue,
      );
      
      // 再次检查组件是否已被销毁
      if (!mounted) return;
      
      if (result != null) {
        // 重置处理状态
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
        
        // 重新加载项目数据
        await _loadProject();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加阶段失败：${_phaseService.error ?? "未知错误"}')),
          );
          
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      print('添加阶段时出错: $e');
      
      // 检查组件是否已被销毁
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加阶段失败，请稍后重试')),
      );
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  // 在特定任务之前添加任务
  void _showAddTaskBeforeModal(String referenceTaskId, String phaseId) {
    // 查找阶段名称
    String phaseName = '';
    for (var phase in _project!.phases) {
      if (phase.id == phaseId) {
        phaseName = phase.name;
        break;
      }
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return AddTaskModal(
          initialPhase: phaseName,
          phaseId: phaseId,  // 传递阶段ID
          onSave: (task, id) => _addTaskBefore(referenceTaskId, task, id),
        );
      },
    );
  }
  
  // 添加任务到指定任务之前
  Future<void> _addTaskBefore(String referenceTaskId, ProjectTask task, String phaseId) async {
    if (_project == null) return;
    
    // 显示加载指示器
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // 使用特殊项目服务添加任务
    final projectService = Provider.of<SpecialProjectService>(context, listen: false);
      
      // 调用API添加任务
      final result = await projectService.addTaskToPhaseWithPosition(
        projectId: _project!.id,
        phaseId: phaseId,
        task: task,
        referenceTaskId: referenceTaskId,
        position: 'before'
      );
      
      if (result) {
        // 添加成功，重新加载项目数据
        await _loadProject();
    
    // 显示成功提示
        if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('任务添加成功')),
          );
        }
      } else {
        // 添加失败，显示错误信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加任务失败: ${projectService.error ?? "未知错误"}')),
          );
        }
      }
    } catch (e) {
      print('添加任务时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加任务失败，请稍后重试')),
        );
      }
    } finally {
      // 隐藏加载指示器
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  // 删除阶段
  Future<void> _deletePhase(String phaseId) async {
    if (_project == null) return;
    
    // 避免多个操作同时进行
    if (_isProcessing) return;
    
    // 显示确认对话框
    bool? confirm;
    try {
      confirm = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFEEEEEE),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '确认删除',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 内容
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '删除阶段将会同时删除该阶段下的所有任务，此操作无法撤销。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 按钮区域
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 取消按钮
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // 删除按钮
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              '删除',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('显示确认对话框时出错: $e');
      return;
    }
    
    if (confirm != true) return;
    
    // 检查组件是否已被销毁
    if (!mounted) return;
    
    // 设置处理状态
    if (mounted) {
      setState(() {
        _isProcessing = true;
      });
    }
    
    try {
      // 使用阶段服务删除阶段
      final success = await _phaseService.deletePhase(phaseId);
      
      // 再次检查组件是否已被销毁
      if (!mounted) return;
      
      if (success) {
        // 重置处理状态
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
        
        // 重新加载项目数据
        await _loadProject();
      } else {
        if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
              content: Text('删除阶段失败: ${_phaseService.error ?? "未知错误"}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      print('删除阶段时出错: $e');
      
      // 检查组件是否已被销毁
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('删除阶段失败，请稍后重试'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  // 删除任务
  Future<void> _deleteTask(String taskId) async {
    if (_project == null) return;
    
    // 查找任务所属的阶段ID
    String phaseId = '';
    for (var phase in _project!.phases) {
      for (var existingTask in phase.tasks) {
        if (existingTask.id == taskId) {
          phaseId = phase.id;
          break;
        }
      }
      if (phaseId.isNotEmpty) break;
    }
    
    if (phaseId.isEmpty) {
      // 未找到对应任务
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未找到对应任务')),
        );
      }
      return;
    }
    
    // 显示确认对话框
    bool? confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFEEEEEE),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '确认删除',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 内容
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '确定要删除此任务吗？此操作无法撤销。',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 按钮区域
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 取消按钮
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            '取消',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // 删除按钮
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            '删除',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    if (confirm != true) return;
    
    // 显示加载指示器
    setState(() {
      _isProcessing = true;
    });
    
    try {
    // 使用特殊项目服务删除任务
    final projectService = Provider.of<SpecialProjectService>(context, listen: false);
      
      // 调用API删除任务
      final result = await projectService.deleteTaskFromPhase(
        projectId: _project!.id,
        phaseId: phaseId,
        taskId: taskId
      );
      
      if (result) {
        // 删除成功，重新加载项目数据
        await _loadProject();
    
    // 显示成功提示
        if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('任务删除成功')),
          );
        }
      } else {
        // 删除失败，显示错误信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除任务失败: ${projectService.error ?? "未知错误"}')),
          );
        }
      }
    } catch (e) {
      print('删除任务时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除任务失败，请稍后重试')),
        );
      }
    } finally {
      // 隐藏加载指示器
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // 完成任务
  Future<void> _completeTask(ProjectTask task) async {
    if (!mounted) return;
    
    // 避免多个操作同时进行
    if (_isProcessing) return;
    
    // 设置处理状态
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // 调用服务方法，直接使用任务的日期
      final result = await _projectService.markTaskAsCompleted(
        task.id, 
        context: context,
        date: task.date,
      );
      
      if (result) {
        // 成功完成任务
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('任务已标记为完成')),
          );
        }
      } else {
        // 完成失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('标记任务完成失败: ${_projectService.error ?? "未知错误"}')),
          );
        }
      }
    } catch (e) {
      // 捕获异常
      print('标记任务完成时出错: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('标记任务完成失败，请稍后重试')),
        );
      }
    } finally {
      // 隐藏加载指示器并重新加载项目
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        await _loadProject(); // 重新加载项目数据以更新UI
      }
    }
  }

  // 编辑任务
  void _editTask(String phaseId, ProjectTask task) {
    // 调用现有的编辑任务对话框
    _showEditTaskModal(task);
  }
}

// 添加任务模态框
class AddTaskModal extends StatefulWidget {
  final String? initialPhase;
  final Function(ProjectTask, String) onSave;  // 修改为接收任务和阶段ID
  final ProjectTask? existingTask;
  final String phaseId;  // 阶段ID
  
  const AddTaskModal({
    Key? key,
    this.initialPhase,
    required this.onSave,
    this.existingTask,
    required this.phaseId,
  }) : super(key: key);

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _formKey = GlobalKey<FormState>();
  late String _phase;
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late final TextEditingController _costController;
  
  // 默认阶段列表，用于获取分类
  final List<String> _defaultPhases = ['设计阶段', '采购阶段', '施工阶段', '验收阶段'];
  
  @override
  void initState() {
    super.initState();
    
    // 初始化控制器和值，使用现有任务的值（如果有）
    if (widget.existingTask != null) {
      _titleController = TextEditingController(text: widget.existingTask!.title);
      _descController = TextEditingController(text: widget.existingTask!.description);
      _date = widget.existingTask!.date;
      _startTime = widget.existingTask!.startTime ?? TimeOfDay.now();
      _endTime = widget.existingTask!.endTime ?? TimeOfDay(
        hour: (_startTime.hour + 1) % 24,
        minute: _startTime.minute
      );
      _costController = TextEditingController(
        text: widget.existingTask!.cost > 0 ? widget.existingTask!.cost.toString() : ''
      );
      
      // 从分类中获取阶段名称
      final phase = _getCategoryPhase(widget.existingTask!.category);
      if (phase.isNotEmpty) {
        _phase = phase;
      } else {
        _phase = widget.initialPhase ?? '设计阶段';
      }
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _date = DateTime.now();
      _costController = TextEditingController();
      
      // 初始化开始和结束时间，默认为当前时间和当前时间后1小时
      final now = TimeOfDay.now();
      _startTime = now;
      _endTime = TimeOfDay(
        hour: (now.hour + 1) % 24,
        minute: now.minute
      );
    
      // 使用初始阶段
      _phase = widget.initialPhase ?? '设计阶段';
    }
  }
  
  // 从分类获取阶段名称
  String _getCategoryPhase(String category) {
    switch (category) {
      case 'design':
        return '设计阶段';
      case 'purchase':
        return '采购阶段';
      case 'construction':
        return '施工阶段';
      case 'inspection':
        return '验收阶段';
      default:
        if (category.startsWith('custom_')) {
          // 处理自定义阶段
          String phaseName = category.substring(7); // 去掉'custom_'前缀
          phaseName = phaseName.replaceAll('_', ' '); // 将下划线替换为空格
          // 将首字母大写
          return phaseName.split(' ').map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1);
          }).join(' ');
        }
        return '';
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _costController.dispose();
    super.dispose();
  }
  
  // 构建表单组
  Widget _buildFormGroup({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
                child: Text(
              label,
                  style: const TextStyle(
                        fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 确定是添加还是编辑模式
    final bool isEditMode = widget.existingTask != null;
    final Color _selectedColor = const Color(0xFF4F46E5); // 使用固定的主题色
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
        child: Column(
          children: [
          // 弹窗标题栏
            Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                  onPressed: () => Navigator.pop(context),
                ),
                            Text(
                  isEditMode ? '编辑任务' : '添加任务',
                  style: TextStyle(
                    color: _selectedColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 40), // 占位，保持标题居中
              ],
            ),
          ),
          
          // 表单内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 移除阶段选择下拉框
                    
                    // 任务标题
                    _buildFormGroup(
                      label: '任务标题',
                      child: TextFormField(
                        controller: _titleController,
                      decoration: InputDecoration(
                          hintText: '输入任务标题',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _selectedColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入任务标题';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    // 时间段选择
                    _buildFormGroup(
                      label: '时间段',
                      child: CustomTimePicker(
                        startTime: _startTime,
                        endTime: _endTime,
                        onStartTimeChanged: (newTime) {
                          setState(() {
                            _startTime = newTime;
                          });
                        },
                        onEndTimeChanged: (newTime) {
                          setState(() {
                            _endTime = newTime;
                          });
                        },
                      ),
                    ),
                    
                    // 日期选择
                    _buildFormGroup(
                      label: '日期',
                      child: GestureDetector(
                  onTap: () async {
                        // 使用自定义日期选择器
                        final date = await DatePickerModal.show(
                      context: context,
                      initialDate: _date,
                          recentDates: null, // 可以传入最近使用的日期
                    );
                    if (date != null) {
                      setState(() {
                        _date = date;
                      });
                    }
                  },
                  child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFD1D5DB)),
                            borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                                DateFormat('yyyy年MM月dd日').format(_date),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today, size: 20, color: Color(0xFF6B7280)),
                      ],
                    ),
                  ),
                ),
                    ),
                    
                    // 预计花费
                    _buildFormGroup(
                      label: '预计花费',
                      child: TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '￥0.00',
                          prefixIcon: const Icon(Icons.monetization_on_outlined, color: Color(0xFF6B7280)),
                    border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _selectedColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    // 任务描述
                    _buildFormGroup(
                      label: '描述（可选）',
                      child: TextFormField(
                  controller: _descController,
                      maxLines: 3,
                  decoration: InputDecoration(
                          hintText: '添加任务描述...',
                    border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _selectedColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    // 操作按钮
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Row(
                  children: [
                          // 取消按钮
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                      style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFF3F4F6),
                            shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                            ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(
                                  color: Color(0xFF374151),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                          // 保存按钮
                          Expanded(
                            child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedColor,
                            shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                            ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                          child: Text(
                            isEditMode ? '更新' : '保存',
                            style: const TextStyle(
                                  color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                                ),
                            ),
                          ),
                    ),
                  ],
                      ),
                ),
              ],
                ),
            ),
          ),
            ),
          ],
      ),
    );
  }
  
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // 设置开始和结束时间
      final taskDateTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
        _startTime.hour,
        _startTime.minute,
      );
      
      final ProjectTask task;
      
      if (widget.existingTask != null) {
        // 更新现有任务
        task = widget.existingTask!.copyWith(
          title: _titleController.text,
          description: _descController.text,
          date: taskDateTime,
          startTime: _startTime,
          endTime: _endTime,
          cost: double.tryParse(_costController.text) ?? 0.0,
          category: _getCategoryFromPhase(_phase),
        );
      } else {
        // 创建新任务
        task = ProjectTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descController.text,
          date: taskDateTime,
          startTime: _startTime,
          endTime: _endTime,
        cost: double.tryParse(_costController.text) ?? 0.0,
        status: TaskStatus.notStarted,
        category: _getCategoryFromPhase(_phase),
          isAllDay: false,
      );
      }
      
      widget.onSave(task, widget.phaseId);  // 传递任务和阶段ID
      Navigator.pop(context);
    }
  }
  
  String _getCategoryFromPhase(String phase) {
    switch (phase) {
      case '设计阶段':
        return 'design';
      case '采购阶段':
        return 'purchase';
      case '施工阶段':
        return 'construction';
      case '验收阶段':
        return 'inspection';
      default:
        // 自定义阶段使用custom_前缀+阶段名称转小写
        return 'custom_${phase.toLowerCase().replaceAll(' ', '_')}';
    }
  }
} 