import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bagel_app/common/constants/api_config.dart';
import 'package:bagel_app/data/mock_notes.dart';
import 'package:bagel_app/models/note.dart';
import 'package:http/http.dart' as http;

class NoteApiService {
  /// 获取首页笔记列表。
  ///
  /// 对应服务端：
  ///
  /// GET /notes
  /// categoryId = 分类ID
  /// page 当前页数
  /// pageSize 每页条数
  /// recommend 是否查询推荐的notes
  /// attention 是否查询关注对象的notes
  Future<List<Note>> fetchNotes({
    int? categoryId,
    int? page,
    int? pageSize,
    bool? recommend,
    bool? attention,
  }) async {
    String httpUrl =
        '${ApiConfig.baseUrl}/notes?categoryId=$categoryId&page=$page&pageSize=$pageSize&recommend=$recommend&attention=$attention';
    final Uri url = Uri.parse(httpUrl);
    late final http.Response response;
    try {
      response = await http.get(url);
    } catch (_) {
      developer.log('$httpUrl call Api fail!', name: 'NoteApiService');
      if (recommend != null && recommend) {
        return mockNotes;
      }
      if (attention != null && attention) {
        return mockNotes;
      }
      return mockNotes.where((note) => note.categoryId == categoryId).toList();
    }

    if (response.statusCode == 404) {
      if (recommend != null && recommend) {
        return mockNotes;
      }
      if (attention != null && attention) {
        return mockNotes;
      }
      return mockNotes.where((note) => note.categoryId == categoryId).toList();
    }

    if (response.statusCode != 200) {
      throw Exception('获取笔记失败，状态码：${response.statusCode}');
    }
    final dynamic jsonData = jsonDecode(response.body);
    if (jsonData is! List) {
      throw Exception('接口返回格式错误，期望返回 List');
    }
    return jsonData.map((item) {
      return Note.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<List<Note>> searchNotes({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    final String trimmedKeyword = keyword.trim();
    if (keyword.isEmpty) {
      return <Note>[];
    }
    final String encodedKeyword = Uri.encodeComponent(trimmedKeyword);
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}/notes/search'
      '?keyword=$encodedKeyword'
      '&page=$page'
      '&pageSize=$pageSize',
    );
    try {
      final http.Response response = await http.get(uri);

      if (response.statusCode == 404) {
        return mockNotes
            .where((note) => note.title.contains(trimmedKeyword))
            .toList();
      }
      if (response.statusCode != 200) {
        throw Exception('搜索笔记失败：${response.statusCode}');
      }

      final dynamic jsonData = jsonDecode(response.body);
      List<dynamic> list;

      if (jsonData is List) {
        list = jsonData;
      } else if (jsonData is Map<String, dynamic> && jsonData['data'] is List) {
        list = jsonData['data'];
      } else {
        throw Exception('搜索返回格式不正确');
      }
      return list.map((dynamic item) {
        return Note.fromJson(item as Map<String, dynamic>);
      }).toList();
    } catch (_) {
      developer.log('${uri.toString()} call Api fail!', name: 'NoteApiService');
      return mockNotes
          .where((note) => note.title.contains(trimmedKeyword))
          .toList();
    }
  }

  /// 发布笔记。
  ///
  /// 对应服务端：
  ///
  /// POST /notes
  ///
  /// 这一版先传图片路径 / 图片 URL。
  ///
  /// 注意：
  /// 现在不是正式上传图片文件。
  /// 真正上传图片，后面要改成 MultipartRequest。
  Future<Note> createNote({
    required String title,
    required String content,
    required int categoryId,
    required List<String> images,
    required List<String> tags,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/notes');
    final Map<String, dynamic> requestBody = {
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'images': images,
      'tags': tags,
    };
    developer.log(
      'call createNote params:$requestBody',
      name: 'NoteApiService',
    );
    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('发布笔记失败，状态码：${response.statusCode}');
    }

    final dynamic jsonData = jsonDecode(response.body);

    if (jsonData is! Map<String, dynamic>) {
      throw Exception('接口返回格式错误，期望返回 Note 对象');
    }

    return Note.fromJson(jsonData);
  }
}
