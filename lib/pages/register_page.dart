import 'dart:developer' as developer;

import 'package:bagel_app/common/constants/local_key_constants.dart';
import 'package:bagel_app/common/utils/validator_utils.dart';
import 'package:bagel_app/models/api_result.dart';
import 'package:bagel_app/service/api/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 注册页面
///
/// 第 15 课目标：
///
/// 1. 输入昵称
/// 2. 输入手机号 / 邮箱
/// 3. 输入密码
/// 4. 输入确认密码
/// 5. 点击注册按钮
/// 6. 注册成功后保存 token
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  /// 用来保存注册成功后服务端返回的 token。
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// 表单key 用来统一校验昵称、账号、密码、确认密码。
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// 输入框控制器
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// API 认证服务
  final AuthApiService _authApiService = AuthApiService();

  /// 是否隐藏密码
  bool _obscurePassword = true;

  /// 是否隐藏确认密码
  bool _obscureConfirmPassword = true;

  /// 是否正在注册
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 点击注册按钮
  Future<void> _handleRegister() async {
    developer.log('开始注册逻辑');
    // 表单校验。
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    developer.log('注册校验通过');
    // 收起键盘
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    try {
      final String nickname = _nicknameController.text.trim();
      final String account = _accountController.text.trim();
      final String password = _passwordController.text.trim();
      final ApiResult<String> apiRes = await _authApiService.register(
        nickname: nickname,
        account: account,
        password: password,
      );
      if (!mounted) {
        return;
      }
      if (apiRes.code != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('注册失败，状态码：${apiRes.code}，${apiRes.msg}')),
        );
        return;
      }
      final String? token = apiRes.data;
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('注册成功，请返回登录')));
        Navigator.pop(context);
        return;
      }
      // 保存 token 到本地
      await _secureStorage.write(
        key: LocalKeyConstants.accountToken,
        value: token,
      );
      developer.log('注册成功，token: $token');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('注册成功')));
      // 注册成功后关闭注册页，回到上一页。
      Navigator.pop(context);
    } catch (error, stackTrace) {
      developer.log('注册接口请求失败', error: error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('注册失败，请检查网络或稍后重试')));
    } finally {
      // 不管成功、失败、接口报错，都要关闭 loading。
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 返回登录页
  void _goBack2LoginPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '注册',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '创建账号',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '注册后就可以发布笔记、点赞收藏和查看消息啦',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nicknameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: '昵称',
                    hintText: '请输入昵称',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (String? value) =>
                      ValidatorUtils.validatorNickname(value),
                ),
                const SizedBox(height: 18),
                // 手机号 / 邮箱输入框
                TextFormField(
                  controller: _accountController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '手机号 / 邮箱',
                    hintText: '请输入手机号或邮箱',
                    prefixIcon: const Icon(Icons.percent_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (String? value) =>
                      ValidatorUtils.validatorAccount(value),
                ),
                const SizedBox(height: 18),
                // 密码输入框
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '请输入密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.vibration_outlined,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (String? value) =>
                      ValidatorUtils.validatorPassword(value),
                ),
                const SizedBox(height: 18),
                // 确认密码输入框
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    hintText: '请再次输入密码',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.vibration_outlined,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (String? value) {
                    final String confirmPassword = value ?? '';
                    final String password = _passwordController.text;
                    if (confirmPassword.isEmpty) {
                      return '请确认密码';
                    }
                    return confirmPassword != password ? '两次输入的密码不一致' : null;
                  },
                ),
                const SizedBox(height: 28),
                // 注册按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '注册',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // 返回登录入口
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('已有账号？', style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: _goBack2LoginPage,
                      child: const Text(
                        ' 去登录',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '提示：注册成功后，如果服务端返回 token，就直接保存 token；如果没有返回 token，就提示用户回到登录页登录。',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF8A5A00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
