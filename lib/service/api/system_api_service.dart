import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bagel_app/common/utils/api_config.dart';
import 'package:bagel_app/data/mock_notes.dart';
import 'package:bagel_app/models/category.dart';
import 'package:http/http.dart' as http;

class SystemApiService {
  /// 获取首页笔记categor列表
  ///
  /// 对应服务端：
  ///
  /// GET /categories
  Future<List<Category>> fetchCategories() async {
    String httpUrl = '${ApiConfig.baseUrl}/categories';
    final Uri url = Uri.parse(httpUrl);
    late final http.Response response;
    try {
      response = await http.get(url);
    } catch (_) {
      developer.log('$httpUrl call Api fail!', name: 'SystemApiSevice');
      return mockCategories;
    }

    if (response.statusCode == 404) {
      return mockCategories;
    }

    if (response.statusCode != 200) {
      throw Exception('获取Category失败，状态码：${response.statusCode}');
    }
    final dynamic jsonData = jsonDecode(response.body);
    if (jsonData is! List) {
      throw Exception('接口返回格式错误，期望返回 List');
    }
    return jsonData.map((item) {
      return Category.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  /// 获取热门搜索关键字
  ///
  /// 对应服务端：
  ///
  /// GET /hot/keywords
  Future<List<String>> fetchHotkeywords() async {
    String httpUrl = '${ApiConfig.baseUrl}/hot/keywords';
    final Uri url = Uri.parse(httpUrl);
    late final http.Response response;
    try {
      response = await http.get(url);
    } catch (_) {
      developer.log('$httpUrl call Api fail!', name: 'SystemApiSevice');
      return mockHotKeywords;
    }

    if (response.statusCode == 404) {
      return mockHotKeywords;
    }

    if (response.statusCode != 200) {
      throw Exception('获取Category失败，状态码：${response.statusCode}');
    }
    final dynamic jsonData = jsonDecode(response.body);
    if (jsonData is! List) {
      throw Exception('接口返回格式错误，期望返回 List');
    }
    return jsonData.map((item) {
      return item as String;
    }).toList();
  }
}
