import 'dart:developer' as developer;

import 'package:bagel_app/common/constants/local_key_constants.dart';
import 'package:bagel_app/models/api_result.dart';
import 'package:bagel_app/pages/register_page.dart';
import 'package:bagel_app/service/api/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 登录页面
///
/// 第 14 课目标：
///
/// 1. 输入手机号 / 邮箱
/// 2. 输入密码
/// 3. 点击登录按钮
/// 4. 有注册入口
///
/// 这一课先做页面和基础交互，暂时不接真实后端。
class LoginPage extends StatefulWidget {
  // 构造方法
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// LoginPage 对应的状态类

class _LoginPageState extends State<LoginPage> {
  /// 安全存储工具
  ///
  /// flutter_secure_storage 会把数据保存到系统提供的安全区域里。
  /// iOS：Keychain
  /// Android：EncryptedSharedPreferences / Keystore
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// 表单 key
  ///
  /// 用来统一校验 TextFormField。
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// 账号输入框控制器
  final TextEditingController _accountController = TextEditingController();

  /// 密码输入框控制器
  final TextEditingController _passwordController = TextEditingController();

  /// 认证 API 服务
  final AuthApiService _authApiService = AuthApiService();

  /// 是否隐藏密码
  bool _obscurePassword = true;

  /// 是否正在登录
  bool _isLoading = false;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 点击登录按钮
  Future<void> _handleLogin() async {
    developer.log('开始登陆逻辑');

    /// 如果手机号 / 邮箱为空，或者密码为空，就不继续执行。
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    developer.log('登陆校验通过');

    /// 收起键盘
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    try {
      final String account = _accountController.text.trim();
      final String password = _passwordController.text.trim();
      final ApiResult<String> apiRes = await _authApiService.login(
        account: account,
        password: password,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      if (apiRes.code != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败, 状态码:${apiRes.code}, ${apiRes.msg}')),
        );
        return;
      }

      /// apiRes.data 这里一般就是后端返回的 token
      final String? token = apiRes.data;
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('登录失败：服务端没有返回 token')));
        return;
      }

      /// 安全保存 token 到本地
      ///
      /// 这样 App 关闭后再打开，token 依然还在。
      /// 相比 shared_preferences，它更适合保存登录 token。
      await _secureStorage.write(
        key: LocalKeyConstants.accountToken,
        value: token,
      );
      developer.log('登录成功，token: $token');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('登录成功')));

      /// 登录成功后返回上一页
      Navigator.pop(context);
    } catch (error, stackTrace) {
      developer.log('登录接口请求失败', error: error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('登录失败，请检查网络或稍后重试')));
    } finally {
      // 不管成功、失败、接口报错，都要关闭 loading。
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 点击注册入口
  void _goToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 0  没阴影，比较扁平, 2  轻微阴影, 8 阴影明显，更像浮起来
        centerTitle: true,
        title: const Text(
          '登录',
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
                // 顶部欢迎文案
                const Text(
                  '欢迎回来',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '登录后可以发布笔记、点赞收藏和查看消息',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                // 账号输入框
                TextFormField(
                  controller: _accountController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '手机号 / 邮箱',
                    hintText: '请输入手机号或邮箱',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (String? value) {
                    final String account = value ?? '';
                    return account.isEmpty ? '请输入手机号或邮箱' : null;
                  },
                ),
                const SizedBox(height: 18),
                // 密码输入框
                TextFormField(
                  controller: _passwordController,
                  // obscureText 为 true 时，密码会显示成小黑点
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '请输入密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    // 右侧眼睛按钮
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  // 校验密码
                  validator: (String? value) {
                    final String password = value ?? '';
                    if (password.isEmpty) {
                      return '请输入密码';
                    }
                    if (password.length < 6) {
                      return '密码至少 6 位';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                // 登录按钮
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            '登录',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // 注册入口
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('还没有账号？', style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: _goToRegisterPage,
                      child: const Text(
                        ' 去注册',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // 小提示区域
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '提示：这一课先完成登录页面和基础校验，真实登录接口、token 保存、自动登录会放到后面的课程。',
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
