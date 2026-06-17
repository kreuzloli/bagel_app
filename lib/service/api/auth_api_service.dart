// ignore_for_file: unintended_html_in_doc_comment

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bagel_app/common/utils/api_config.dart';
import 'package:bagel_app/models/api_result.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  /// 登陆api
  Future<ApiResult<String>> login({
    required String account,
    required String password,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/login');
    final Map<String, dynamic> requestBody = {
      'account': account,
      'password': password,
    };
    developer.log(
      'call login body=$requestBody',
      name: 'AuthApiService',
    );
    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('登陆失败，状态码：${response.statusCode}');
    }

    final dynamic jsonData = jsonDecode(response.body);

    if (jsonData is! Map<String, dynamic>) {
      throw Exception('接口返回格式错误');
    }

    return ApiResult<String>.fromJson(
      jsonData,
      fromData: (Object? data) => data as String?,
    );
  }

  /// 注册
  ///
  /// 对应服务端接口示例：
  ///
  /// POST /auth/register
  ///
  /// 请求参数：
  /// nickname 昵称
  /// account 手机号 / 邮箱
  /// password 密码
  ///
  /// 返回值：
  /// ApiResult<String>
  /// data 一般是 token
  Future<ApiResult<String>> register({
    required String nickname,
    required String account,
    required String password,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    final Map<String, dynamic> requestBody = {
      'nickname': nickname,
      'account': account,
      'password': password,
    };
    developer.log('call register body=$requestBody', name: 'AuthApiService');
    final http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
    final Map<String, dynamic> jsonMap = jsonDecode(response.body);
    return ApiResult<String>.fromJson(
      jsonMap,
      fromData: (dynamic data) => data?.toString() ?? '',
    );
  }
}
