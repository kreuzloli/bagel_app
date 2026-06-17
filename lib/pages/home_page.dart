import 'package:bagel_app/models/category.dart';
import 'package:bagel_app/models/note.dart';
import 'package:bagel_app/pages/note_detail_page.dart';
import 'package:bagel_app/service/api/note_api_service.dart';
import 'package:bagel_app/service/api/system_api_service.dart';
import 'package:bagel_app/widgets/note_card.dart';
import 'package:flutter/material.dart';

/// 首页页面
///
/// 第 5 课新增重点：
///
/// 顶部频道栏
/// 点击频道切换
/// 根据频道过滤笔记列表
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

/// 首页状态类
///
/// 这里没有用 _HomePageState，而是用 HomePageState。
/// 原因：如果 main.dart 里后面要用 GlobalKey<HomePageState>
/// 调用首页的刷新方法，私有类 _HomePageState 在别的文件里访问不到。
class HomePageState extends State<HomePage> {
  /// 系统接口服务。
  ///
  /// 目前用来获取分类列表。
  final SystemApiService _systemApiSerice = SystemApiService();

  /// 笔记接口服务。
  ///
  /// 目前用来获取笔记列表。
  final NoteApiService _noteApiService = NoteApiService();

  /// 首页滚动控制器。
  ///
  /// 用来监听用户有没有滑到底部。
  /// 滑到底部时，触发上拉加载更多。
  final ScrollController _scrollController = ScrollController();

  /// 当前选中的频道名称。
  ///
  /// 它主要用于 UI 展示和判断“推荐 / 关注”这种特殊频道。
  String selectedChannel = '推荐';

  /// 当前选中的分类 id。
  ///
  /// 普通分类请求接口时用它。
  /// 推荐 / 关注这种特殊频道可以用 -1。
  int selectedCategoryId = -1;

  /// 当前页面展示的笔记列表。
  ///
  /// 注意：
  /// 这里的 notes 已经是服务端按 categoryId / recommend / attention 返回的数据。
  /// 所以前端不需要再 where 过滤。
  List<Note> notes = <Note>[];

  /// 分类列表。
  ///
  /// 接口只返回普通分类，比如：美食、穿搭、旅行。
  /// 推荐、关注是前端手动加进去的特殊频道。
  List<Category> categories = <Category>[];

  /// 首次进入页面 / 切换频道时是否正在加载。
  bool isLoading = false;

  /// 是否正在下拉刷新。
  bool isRefreshing = false;

  /// 是否正在上拉加载更多。
  bool isLoadingMore = false;

  /// 是否还有更多数据。
  bool hasMore = true;

  /// 当前页码。
  int page = 1;

  /// 每页数量。
  final int pageSize = 10;

  /// 错误信息。
  String? err;

  /// 是否处于推荐页面。
  bool recommend = true;

  /// 是否处于关注页面。
  bool attention = false;

  @override
  void initState() {
    super.initState();
    // 监听滚动位置
    _scrollController.addListener(_onScroll);

    /// 初始化首页数据：
    /// 1. 先获取分类
    /// 2. 默认选中第一个分类
    /// 3. 再获取这个分类下的第一页笔记
    initHomeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 初始化首页数据
  ///
  /// 页面第一次进入时调用。
  /// 从服务端重新获取笔记列表。
  Future<void> initHomeData() async {
    setState(() {
      isLoading = true;
      err = null;
      page = 1;
      hasMore = true;
      selectedChannel = '推荐';
      selectedCategoryId = -1;
      recommend = true;
      attention = false;
    });

    try {
      /// 获取普通分类列表。
      final List<Category> categoryRes = await _systemApiSerice
          .fetchCategories();
      if (categoryRes.isEmpty) {
        throw Exception('分类列表为空');
      }

      /// 组装首页频道。
      ///
      /// 推荐、关注是特殊频道。
      /// 普通分类来自服务端。
      final List<Category> nextCategories = <Category>[
        const Category(id: -1, name: '推荐'),
        const Category(id: -2, name: '关注'),
        ...categoryRes,
      ];

      /// 请求推荐第一页。
      final List<Note> noteRes = await _noteApiService.fetchNotes(
        categoryId: -1,
        page: page,
        pageSize: pageSize,
        recommend: true,
        attention: false,
      );
      setState(() {
        categories = nextCategories;
        notes = noteRes;
        hasMore = noteRes.length >= pageSize;
      });
    } catch (e) {
      setState(() {
        err = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 监听滚动位置
  void _onScroll() {
    // 没有绑定滚动控制器时，不处理
    if (!_scrollController.hasClients) {
      return;
    }

    /// 正在加载时，不重复请求
    if (isLoading || isRefreshing || isLoadingMore) {
      return;
    }

    /// 没有更多数据时，不请求
    if (!hasMore) {
      return;
    }
    // 当前滚动位置
    final double currentPixels = _scrollController.position.pixels;
    // 最大可滚动距离
    final double maxPixels = _scrollController.position.maxScrollExtent;
    // 距离底部还有多少
    final double distance2Bottom = maxPixels - currentPixels;
    // 距离底部小鱼120时，提前加载下一页
    if (distance2Bottom < 120) {
      loadMoreNotes();
    }
  }

  Future<void> _loadFirstPage({
    required bool showFullLoading,
    required bool showRefreshLoading,
  }) async {
    final String channel = selectedChannel;
    final bool nextRecommend = channel == '推荐';
    final bool nextAttention = channel == '关注';
    setState(() {
      isLoading = showFullLoading;
      isRefreshing = showRefreshLoading;
      err = null;
      page = 1;
      hasMore = true;
      recommend = nextRecommend;
      attention = nextAttention;
    });
    try {
      final List<Note> res = await _noteApiService.fetchNotes(
        categoryId: selectedCategoryId,
        page: page,
        pageSize: pageSize,
        recommend: recommend,
        attention: attention,
      );
      setState(() {
        notes = res;
        hasMore = res.length >= pageSize;
      });
    } catch (e) {
      setState(() {
        err = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  /// 普通加载第一页。
  ///
  /// 用在：
  /// 1. 切换频道
  /// 2. 发布成功后首页刷新
  /// 3. 错误页面点击重新加载
  Future<void> fetchNotes() async {
    await _loadFirstPage(showFullLoading: true, showRefreshLoading: false);
  }

  /// 下拉刷新。
  ///
  /// 重新请求当前频道的第一页。
  Future<void> refreshNotes() async {
    await _loadFirstPage(showFullLoading: false, showRefreshLoading: true);
  }

  /// 上拉加载更多。
  ///
  /// 请求当前频道的下一页，然后追加到 notes 后面。
  Future<void> loadMoreNotes() async {
    if (isLoadingMore || !hasMore) {
      return;
    }
    setState(() {
      isLoadingMore = true;
      err = null;
    });
    try {
      final int nextPage = page + 1;
      final List<Note> res = await _noteApiService.fetchNotes(
        categoryId: selectedCategoryId,
        page: nextPage,
        pageSize: pageSize,
        recommend: recommend,
        attention: attention,
      );
      setState(() {
        page = nextPage;
        notes.addAll(res);
        hasMore = res.length >= pageSize;
      });
    } catch (e) {
      setState(() {
        err = e.toString();
      });
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  /// 点击频道。
  Future<void> changeChannel(Category category) async {
    /// 如果点的是当前频道，不重复请求。
    if (selectedCategoryId == category.id && selectedChannel == category.name) {
      return;
    }
    setState(() {
      selectedChannel = category.name;
      selectedCategoryId = category.id;
      notes = <Note>[];
      page = 1;
      hasMore = true;
      err = null;
    });
    await fetchNotes();
  }

  /// 跳转到详情页
  ///
  /// 这里传的是完整 Note 对象。
  /// 所以详情页可以直接展示 title、imageUrl、content、publishTime 等字段。
  void goDetailPage(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return NoteDetailPage(note: note);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Scaffold 是一个页面骨架。
    ///
    /// 它可以包含：
    /// appBar 顶部栏
    /// body 页面主体
    /// bottomNavigationBar 底部导航
    return Scaffold(
      /// 页面背景色。
      backgroundColor: const Color(0xFFF7F7F7),

      /// SingleChildScrollView 表示整个页面可以滚动。
      body: SafeArea(
        /// Row 表示左右排列。
        child: Column(
          children: <Widget>[
            /// 顶部频道切换栏
            _buildChannelBar(),

            /// 下方笔记列表。
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  /// 构建顶部频道栏

  Widget _buildChannelBar() {
    /// 分类还没加载出来时。
    if (categories.isEmpty) {
      return Container(
        height: 50,
        color: Colors.white,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Text(
          '频道加载中...',
          style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
        ),
      );
    }
    return Container(
      height: 50,
      color: Colors.white,

      /// 横向滚动列表, ListView.separated 可以很方便地给每个 item 中间加间距。
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 22);
        },
        // 1157
        itemBuilder: (BuildContext context, int index) {
          final Category channel = categories[index];
          // 判断当前频道是否是选中状态
          /// 判断当前频道是否是选中状态。
          final bool isSelected =
              channel.id == selectedCategoryId &&
              channel.name == selectedChannel;
          return GestureDetector(
            /// 点击频道时触发
            onTap: () {
              changeChannel(channel);
            },
            // center 让文字在 50 高度里垂直居中
            child: Center(
              child: AnimatedContainer(
                /// AnimatedContainer 会自动给样式变化加动画。
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFFFF2442)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: AnimatedDefaultTextStyle(
                  /// AnimatedDefaultTextStyle 可以让文字样式变化也带动画。
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    fontSize: isSelected ? 17 : 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF111111)
                        : const Color(0xFF777777),
                  ),
                  child: Text(channel.name),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建主体内容。
  Widget _buildBody() {
    // 首次进入页面 / 切换频道时加载中。
    if (isLoading && notes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // 接口报错，并且没有旧数据时，展示错误页。
    if (err != null && notes.isEmpty) {
      return _buildErrorView();
    }
    // 当前频道没有笔记。
    if (notes.isEmpty) {
      return RefreshIndicator(
        onRefresh: refreshNotes,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const <Widget>[
            SizedBox(height: 220),
            Center(
              child: Text(
                '这个频道还没有笔记，小贝果正在烤内容 🥯',
                style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
            ),
          ],
        ),
      );
    }
    // 有数据时，支持下拉刷新。
    return RefreshIndicator(
      onRefresh: refreshNotes,
      child: _buildWaterfallList(),
    );
  }

  /// 构建双列瀑布流列表。

  Widget _buildWaterfallList() {
    final List<Note> leftNotes = <Note>[];
    final List<Note> rightNotes = <Note>[];

    /// 把笔记分成左右两列。
    for (int index = 0; index < notes.length; index++) {
      final Note note = notes[index];
      if (index.isEven) {
        leftNotes.add(note);
      } else {
        rightNotes.add(note);
      }
    }
    return SingleChildScrollView(
      controller: _scrollController,
      // AlwaysScrollableScrollPhysics 让内容不够一屏时也能下拉刷新。
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 左列。
              Expanded(
                child: Column(
                  children: leftNotes.map((Note note) {
                    return NoteCard(
                      note: note,
                      onTap: () {
                        goDetailPage(note);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              // 右列。
              Expanded(
                child: Column(
                  children: rightNotes.map((Note note) {
                    return NoteCard(
                      note: note,
                      onTap: () {
                        goDetailPage(note);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          /// 底部加载更多状态。
          _buildLoadMoreView(),
        ],
      ),
    );
  }

  /// 构建底部加载更多状态。
  Widget _buildLoadMoreView() {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Text(
          '没有更多啦，贝果篮子空了 🧺',
          style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
        ),
      );
    }
    return const SizedBox(height: 18);
  }

  /// 错误页面。
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.wifi_off_outlined,
              size: 42,
              color: Color(0xFF999999),
            ),
            const SizedBox(height: 12),
            Text(
              err ?? '加载失败',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF777777)),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: initHomeData, child: const Text('重新加载')),
          ],
        ),
      ),
    );
  }
}
