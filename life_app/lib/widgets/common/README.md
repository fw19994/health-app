# 统一提示对话框使用指南

## AppAlertDialog

`AppAlertDialog` 是为LifeApp项目设计的统一提示对话框组件，用于替换默认的 `AlertDialog` 和 `SnackBar`，确保整个应用的提示风格一致。

## 基本使用

### 导入

```dart
import '../../widgets/common/app_alert_dialog.dart';
```

### 显示基础提示

```dart
AppAlertDialog.show(
  context: context,
  message: '请输入必要信息',
);
```

### 显示成功提示

```dart
AppAlertDialog.showSuccess(
  context: context,
  message: '操作成功完成',
);
```

### 显示错误提示

```dart
AppAlertDialog.showError(
  context: context,
  message: '操作失败: $errorMessage',
);
```

### 显示确认对话框

```dart
final confirmed = await AppAlertDialog.showConfirmation(
  context: context,
  title: '删除确认',
  message: '确定要删除这个项目吗？该操作不可恢复',
  primaryButtonText: '删除',
  secondaryButtonText: '取消',
  accentColor: Colors.red,  // 可选，设置主色调
);

if (confirmed == true) {
  // 用户点击了确认按钮
  deleteItem();
}
```

## 替换SnackBar

将现有的SnackBar替换为AppAlertDialog：

### 旧代码
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('操作成功')),
);
```

### 新代码
```dart
AppAlertDialog.showSuccess(
  context: context,
  message: '操作成功',
);
```

对于错误提示：

### 旧代码
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('操作失败'),
    backgroundColor: Colors.red,
  ),
);
```

### 新代码
```dart
AppAlertDialog.showError(
  context: context,
  message: '操作失败',
);
```

## 替换AlertDialog

替换现有的AlertDialog：

### 旧代码
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('提示'),
    content: const Text('确定继续操作吗？'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('取消'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('确定'),
      ),
    ],
  ),
);
```

### 新代码
```dart
AppAlertDialog.showConfirmation(
  context: context,
  title: '提示',
  message: '确定继续操作吗？',
  primaryButtonText: '确定',
  secondaryButtonText: '取消',
);
```

## 自定义选项

`AppAlertDialog.show` 方法提供了多个可选参数，用于自定义对话框：

- `title`: 对话框标题
- `primaryButtonText`: 主按钮文本
- `secondaryButtonText`: 次要按钮文本
- `onPrimaryButtonPressed`: 点击主按钮的回调
- `onSecondaryButtonPressed`: 点击次要按钮的回调
- `barrierDismissible`: 是否允许点击背景关闭对话框
- `icon`: 自定义图标
- `accentColor`: 自定义强调色

## 最佳实践

1. 使用`.showSuccess()`、`.showError()`和`.showConfirmation()`方法，而不是每次都自定义`.show()`方法
2. 保持消息简洁明了
3. 对用户操作提供即时反馈
4. 错误提示需要明确指出问题和可能的解决方案 