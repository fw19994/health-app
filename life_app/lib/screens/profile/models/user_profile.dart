import 'package:flutter/material.dart';
import '../../../models/family_member_model.dart';

enum ActivityLevel {
  sedentary('久坐'),
  lightlyActive('轻度活动'),
  moderatelyActive('中度活动'),
  veryActive('高度活动');
  
  final String label;
  const ActivityLevel(this.label);
}

enum DietPreference {
  balanced('均衡饮食'),
  lowFat('低脂'),
  lowCarb('低碳水'),
  highProtein('高蛋白'),
  vegetarian('素食');
  
  final String label;
  const DietPreference(this.label);
}

enum FitnessGoal {
  weightLoss('减肥'),
  maintenance('保持体形'),
  muscleGain('增肌'),
  endurance('提高耐力');
  
  final String label;
  const FitnessGoal(this.label);
}

class HealthInfo {
  final double height; // 身高（厘米）
  final double weight; // 体重（千克）
  final String bloodType; // 血型
  
  HealthInfo({
    required this.height,
    required this.weight,
    required this.bloodType,
  });
  
  // 计算BMI
  double get bmi => weight / ((height / 100) * (height / 100));
  
  // 获取BMI健康状态
  String get bmiStatus {
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '健康';
    if (bmi < 28) return '超重';
    return '肥胖';
  }
  
  // BMI状态对应的颜色
  Color get bmiStatusColor {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 24) return Colors.green;
    if (bmi < 28) return Colors.orange;
    return Colors.red;
  }
  
  // 格式化BMI显示
  String get formattedBmi => bmi.toStringAsFixed(1);
}

class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final int age;
  final String gender;
  final String phone;
  final String bio; // 个人简介
  final HealthInfo healthInfo;
  final ActivityLevel activityLevel;
  final List<DietPreference> dietPreferences;
  final FitnessGoal fitnessGoal;
  final List<FamilyMember> familyMembers;
  
  UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.age,
    required this.gender,
    required this.phone,
    this.bio = '', // 默认为空字符串
    required this.healthInfo,
    required this.activityLevel,
    required this.dietPreferences,
    required this.fitnessGoal,
    required this.familyMembers,
  });
  
  // 支持部分更新用户资料的方法
  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? age,
    String? gender,
    String? phone,
    String? bio,
    HealthInfo? healthInfo,
    ActivityLevel? activityLevel,
    List<DietPreference>? dietPreferences,
    FitnessGoal? fitnessGoal,
    List<FamilyMember>? familyMembers,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      healthInfo: healthInfo ?? this.healthInfo,
      activityLevel: activityLevel ?? this.activityLevel,
      dietPreferences: dietPreferences ?? this.dietPreferences,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      familyMembers: familyMembers ?? this.familyMembers,
    );
  }
  
  // 创建模拟用户数据
  static UserProfile getMockProfile() {
    return UserProfile(
      name: '李明',
      email: 'liming@example.com',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=256&q=80',
      age: 32,
      gender: '男',
      phone: '138****5678',
      bio: '热爱健身和户外运动，追求健康生活方式。工作是软件工程师，闲暇时喜欢阅读和旅行。',
      healthInfo: HealthInfo(
        height: 178,
        weight: 72,
        bloodType: 'O型',
      ),
      activityLevel: ActivityLevel.moderatelyActive,
      dietPreferences: [
        DietPreference.balanced,
        DietPreference.highProtein,
      ],
      fitnessGoal: FitnessGoal.muscleGain,
      familyMembers: [],
    );
  }
}
