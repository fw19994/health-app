import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:life_app/models/plan/special_project_model.dart';
import 'package:life_app/models/plan/project_phase_model.dart';
import 'package:life_app/screens/plan/special_project_detail_screen.dart';
import 'package:life_app/services/special_project_service.dart';
import 'package:life_app/services/project_phase_service.dart';

// 创建Mock服务
class MockSpecialProjectService extends Mock implements SpecialProjectService {}
class MockProjectPhaseService extends Mock implements ProjectPhaseService {}

void main() {
  late MockSpecialProjectService mockProjectService;
  late MockProjectPhaseService mockPhaseService;
  
  setUp(() {
    mockProjectService = MockSpecialProjectService();
    mockPhaseService = MockProjectPhaseService();
  });
  
  testWidgets('Special project detail screen shows loading state', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SpecialProjectService>.value(value: mockProjectService),
          ChangeNotifierProvider<ProjectPhaseService>.value(value: mockPhaseService),
        ],
        child: MaterialApp(
          home: SpecialProjectDetailScreen(projectId: '1'),
        ),
      ),
    );
    
    // 验证显示加载状态
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  
  // 如果有更多的测试，可以在这里添加
} 