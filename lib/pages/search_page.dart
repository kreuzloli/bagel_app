import 'package:bagel_app/common/constants/local_key_constants.dart';
import 'package:bagel_app/models/note.dart';
import 'package:bagel_app/pages/note_detail_page.dart';
import 'package:bagel_app/service/api/note_api_service.dart';
import 'package:bagel_app/service/api/system_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 搜索页
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// 搜索框控制器
  ///
  /// 用来获取输入框内容，也可以主动修改输入框内容。
  final TextEditingController _searchController = TextEditingController();

  /// 笔记 API 服务
  ///
  /// 用来调用搜索笔记接口。
  final NoteApiService _noteApiService = NoteApiService();

  /// 系统 API 服务
  ///
  /// 用来获取热门搜索关键词。
  final SystemApiService _systemApiService = SystemApiService();

  /// 热门搜索关键词
  ///
  /// 从后端 API 获取。
  List<String> _hotKeywords = <String>[];

  /// 搜索历史
  ///
  /// 从本地 shared_preferences 读取。
  List<String> _historyKeywords = <String>[];

  /// 搜索结果列表
  List<Note> _searchRes = <Note>[];

  /// 当前正在搜索的关键词
  String _currentKeyword = '';

  /// 当前是否正在搜索
  bool _isLoading = false;

  /// 是否已经搜索过
  ///
  /// 用它区分：
  /// 1. 刚进入页面，还没搜过
  /// 2. 已经搜过，但是没有结果
  bool _hasSearched = false;

  /// 错误信息
  String? _err;

  @override
  void initState() {
    super.initState();

    /// 页面初始化时，加载热门搜索关键词
    _loadHotKeywords();

    /// 页面初始化时，加载本地搜索历史
    _loadSearchHistory();
  }

  @override
  void dispose() {
    /// 页面销毁时释放输入框控制器
    _searchController.dispose();

    super.dispose();
  }

  /// 获取热门搜索关键词
  Future<void> _loadHotKeywords() async {
    try {
      final List<String> res = await _systemApiService.fetchHotkeywords();

      if (!mounted) {
        return;
      }

      setState(() {
        _hotKeywords = res;
      });
    } catch (e) {
      /// 热门搜索失败不影响主流程
      ///
      /// 这里不弹错误，避免用户刚进页面就看到错误提示。
      if (!mounted) {
        return;
      }

      setState(() {
        _hotKeywords = <String>[];
      });
    }
  }

  /// 从本地读取搜索历史
  Future<void> _loadSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> history =
        prefs.getStringList(LocalKeyConstants.searchHistory) ?? <String>[];

    if (!mounted) {
      return;
    }

    setState(() {
      _historyKeywords = history;
    });
  }

  /// 保存搜索历史到本地
  Future<void> _saveSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      LocalKeyConstants.searchHistory,
      _historyKeywords,
    );
  }

  /// 执行搜索
  Future<void> _search(String keyword) async {
    final String trimmedKeyword = keyword.trim();

    if (trimmedKeyword.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _err = null;
      _currentKeyword = trimmedKeyword;
    });

    try {
      final List<Note> res = await _noteApiService.searchNotes(
        keyword: trimmedKeyword,
        page: 1,
        pageSize: 20,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _searchRes = res;
      });

      await _addSearchHistory(trimmedKeyword);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _searchRes = <Note>[];
        _err = '搜索失败，请稍后重试';
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 添加搜索历史
  Future<void> _addSearchHistory(String keyword) async {
    setState(() {
      /// 如果历史里已经有这个关键词，先删掉。
      ///
      /// 这样可以把最新搜索的关键词放到最前面。
      _historyKeywords.remove(keyword);

      /// 把最新搜索的关键词放到最前面
      _historyKeywords.insert(0, keyword);

      /// 最多只保留 10 条
      if (_historyKeywords.length > 10) {
        _historyKeywords.removeLast();
      }
    });

    /// 保存到本地
    await _saveSearchHistory();
  }

  /// 点击关键词
  ///
  /// 热门搜索和搜索历史都会调用这个方法。
  void _onKeywordTap(String keyword) {
    _searchController.text = keyword;
    _search(keyword);
  }

  /// 清空历史
  Future<void> _clearHistory() async {
    setState(() {
      _historyKeywords.clear();
    });

    /// 清空之后，也要同步保存到本地
    await _saveSearchHistory();
  }

  /// 清空搜索框
  void _clearSearchInput() {
    setState(() {
      _searchController.clear();
      _searchRes = <Note>[];
      _hasSearched = false;
      _currentKeyword = '';
      _err = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildSearchHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  /// 顶部搜索区域
  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(21),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.search, size: 22, color: Colors.grey),

                  const SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      controller: _searchController,

                      /// 点击键盘上的搜索按钮时触发
                      onSubmitted: _search,

                      /// 键盘右下角显示“搜索”
                      textInputAction: TextInputAction.search,

                      decoration: const InputDecoration(
                        hintText: '搜索笔记',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),

                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearchInput,
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: () {
              _search(_searchController.text);
            },
            child: const Text(
              '搜索',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 页面主体内容
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_err != null) {
      return Center(
        child: Text(
          _err!,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    if (_hasSearched) {
      return _buildSearchResultList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHotSearchSection(),

          const SizedBox(height: 28),

          _buildHistorySection(),
        ],
      ),
    );
  }

  /// 热门搜索区域
  Widget _buildHotSearchSection() {
    if (_hotKeywords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '热门搜索',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _hotKeywords.map((String kw) {
            return _buildKeywordChip(
              text: kw,
              onTap: () {
                _onKeywordTap(kw);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 搜索历史区域
  Widget _buildHistorySection() {
    if (_historyKeywords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              '搜索历史',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            GestureDetector(
              onTap: _clearHistory,
              child: const Icon(
                Icons.delete_outline,
                size: 22,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _historyKeywords.map((String kw) {
            return _buildKeywordChip(
              text: kw,
              onTap: () {
                _onKeywordTap(kw);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 关键词小标签
  Widget _buildKeywordChip({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    );
  }

  /// 搜索结果列表
  Widget _buildSearchResultList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(
            '“$_currentKeyword”的搜索结果',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        Expanded(
          child: _searchRes.isEmpty
              ? _buildEmptyResult()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  itemCount: _searchRes.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 12);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final Note note = _searchRes[index];

                    return _buildResultItem(note);
                  },
                ),
        ),
      ],
    );
  }

  /// 没有搜索结果时显示
  Widget _buildEmptyResult() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(Icons.search_off, size: 38, color: Colors.grey),
          ),

          const SizedBox(height: 14),

          Text(
            '没有找到和“$_currentKeyword”相关的笔记',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            '换个关键词试试吧',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 单条搜索结果
  Widget _buildResultItem(Note note) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return NoteDetailPage(note: note);
            },
          ),
        );
      },
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                note.coverImage,
                width: 92,
                height: 92,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Container(
                        width: 92,
                        height: 92,
                        color: const Color(0xFFEFEFEF),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                        ),
                      );
                    },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    note.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const Spacer(),

                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(note.avatar),
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          note.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.favorite_border,
                              size: 14,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 3),

                            Text(
                              '${note.likeCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
    );
  }
}
