import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../widgets/login/animated_background.dart';
import '../../widgets/login/login_card.dart';
import '../../widgets/login/feature_preview.dart';
import '../../widgets/login/custom_toast.dart';
import '../../widgets/login/error_dialog.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../utils/validators.dart';
import '../network_diagnostics_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool isLoginMode = true;
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  bool rememberMe = false;
  bool isCodeSent = false;
  int countdownSeconds = 60;
  Timer? countdownTimer;
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode codeFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // 错误信息状态
  String? phoneError;
  String? codeError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // 延迟聚焦到手机号输入框
    Future.delayed(const Duration(milliseconds: 800), () {
      phoneFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    phoneFocusNode.dispose();
    codeFocusNode.dispose();
    countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      isLoginMode = !isLoginMode;
      _animationController.reset();
      _animationController.forward();
      // 清除错误信息
      phoneError = null;
      codeError = null;
    });
  }

  Future<void> startCountdown() async {
    // 验证手机号
    final errorMsg = Validators.getPhoneNumberErrorMessage(phoneController.text);
    
    if (errorMsg != null) {
      setState(() {
        phoneError = errorMsg;
      });
      showCustomToast(context, errorMsg + ' 📱', ToastType.warning);
      return;
    }
    
    // 清除手机号错误提示
    setState(() {
      phoneError = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final response = await authService.sendSMSCode(phoneController.text);

    if (response.success) {
      setState(() {
        isCodeSent = true;
        countdownSeconds = 60;
      });

      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (countdownSeconds > 0) {
            countdownSeconds--;
          } else {
            isCodeSent = false;
            timer.cancel();
          }
        });
      });

      showCustomToast(context, '验证码已发送 ✅', ToastType.success);
    } else {
      showCustomToast(context, '验证码发送失败: ${response.error ?? response.message}', ToastType.error);
    }
  }

  Future<void> submitForm() async {
    // 验证表单
    bool hasError = false;
    
    // 验证手机号
    final phoneErrorMsg = Validators.getPhoneNumberErrorMessage(phoneController.text);
    if (phoneErrorMsg != null) {
      setState(() {
        phoneError = phoneErrorMsg;
        hasError = true;
      });
    } else {
      setState(() {
        phoneError = null;
      });
    }
    
    // 验证验证码
    if (codeController.text.isEmpty) {
      setState(() {
        codeError = '请输入验证码';
        hasError = true;
      });
    } else if (codeController.text.length < 4) {
      setState(() {
        codeError = '验证码长度不足';
        hasError = true;
      });
    } else {
      setState(() {
        codeError = null;
      });
    }
    
    if (hasError) {
      showCustomToast(context, '请修正表单错误后再提交 ℹ️', ToastType.info);
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    ApiResponse<void> response;

    // 显示加载状态
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      if (isLoginMode) {
        // 登录
        response = await authService.loginWithSMS(
          phoneController.text,
          codeController.text,
        );

        // 关闭加载对话框
        Navigator.pop(context);

        if (response.success) {
          showCustomToast(context, '登录成功，欢迎回来！🎉', ToastType.success);
          // 导航到主页
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pushReplacementNamed(context, '/main');
          });
        } else {
          // 使用对话框显示错误提示，替代Toast
          showErrorDialog(
            context,
            response.message, // 直接使用服务层返回的统一错误提示
          );
          
          // 仍然调用Toast作为备用，不过不依赖它显示
          showCustomToast(
            context,
            response.message,
            ToastType.error,
          );
        }
      } else {
        // 注册 - 使用手机号的后4位作为默认昵称
        String nickname = '用户${phoneController.text.substring(phoneController.text.length - 4)}';
        
        response = await authService.register(
          phoneController.text,
          codeController.text,
          nickname,
        );

        // 关闭加载对话框
        Navigator.pop(context);

        if (response.success) {
          showCustomToast(context, '注册成功，欢迎加入悦管家！🎊', ToastType.success);
          // 导航到主页
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pushReplacementNamed(context, '/main');
          });
        } else {
          // 使用对话框显示错误提示，替代Toast
          showErrorDialog(
            context,
            response.message, // 直接使用服务层返回的统一错误提示
          );
          
          // 仍然调用Toast作为备用，不过不依赖它显示
          showCustomToast(
            context,
            response.message,
            ToastType.error,
          );
        }
      }
    } catch (e) {
      // 关闭加载对话框
      Navigator.pop(context);
      // 错误信息统一为系统繁忙
      showErrorDialog(
        context,
        '系统繁忙，请稍后再试'
      );
      
      // 仍然调用Toast作为备用，不过不依赖它显示
      showCustomToast(context, '系统繁忙，请稍后再试', ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // 背景动画 - 将其扩展到安全区域外
            const AnimatedBackground(),
            
            // 主内容区域
            // 使用Positioned.fill而非SafeArea来确保内容尺寸正确
            Positioned.fill(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    24.0, 
                    MediaQuery.of(context).padding.top + 20.0, // 顶部添加状态栏高度加padding
                    24.0, 
                    24.0
                  ),
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    children: [
                      
                      // 登录卡片
                      LoginCard(
                        isLoginMode: isLoginMode,
                        phoneController: phoneController,
                        codeController: codeController,
                        phoneFocusNode: phoneFocusNode,
                        codeFocusNode: codeFocusNode,
                        phoneError: phoneError,
                        codeError: codeError,
                        rememberMe: rememberMe,
                        isCodeSent: isCodeSent,
                        countdownSeconds: countdownSeconds,
                        onRememberMeChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                        onToggleMode: toggleMode,
                        onSendCode: startCountdown,
                        onSubmit: submitForm,
                        animation: _animation,
                        onNetworkDiagnostics: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NetworkDiagnosticsScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // 功能预览模块 - 添加水平内边距，增加视觉空间
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FeaturePreview(),
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
