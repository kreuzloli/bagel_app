import 'package:bagel_app/models/note.dart';
import 'package:flutter/material.dart';

class NoteDetailPage extends StatefulWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  /// 当前正在展示第几张图片
  ///
  /// PageView 滑动时会更新这个值。
  /// 比如图片一共有三张，当前是第一张时，这个值是 0。
  int currentImageIndex = 0;

  /// 当前点赞数量
  ///
  /// 不能直接改 widget.note.likeCount，
  /// 因为 Note 是数据模型，字段通常是 final，不建议直接修改。
  /// 所以这里单独创建一个页面内部状态。
  late int currentLikeCount;

  /// 当前收藏数量
  ///
  /// 和点赞数量一样，先从 note.favoriteCount 拿初始值，
  /// 后面点击收藏按钮时，只修改这个页面内部状态。
  late int currentFavoriteCount;

  /// 当前是否已经点赞
  ///
  /// false 表示还没点赞。
  /// true 表示已经点赞。
  bool isLiked = false;

  /// 当前是否已经收藏
  ///
  /// false 表示还没收藏。
  /// true 表示已经收藏。
  bool isFavorited = false;

  /// 评论输入框控制器
  ///
  /// TextEditingController 可以拿到输入框里的文字，
  /// 也可以用它清空输入框。
  final TextEditingController commentController = TextEditingController();

  /// 页面初始化
  @override
  void initState() {
    super.initState();
    currentLikeCount = widget.note.likeCount;
    currentFavoriteCount = widget.note.favoriteCount;
  }

  /// 页面销毁时，把输入框控制器也销毁掉。
  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  /// 切换点赞状态
  void toggleLike() {
    setState(() {
      if (isLiked) {
        isLiked = false;
        currentLikeCount--;
      } else {
        isLiked = true;
        currentLikeCount++;
      }
    });
  }

  /// 切换收藏状态
  void toggleFavorite() {
    setState(() {
      if (isFavorited) {
        isFavorited = false;
        currentFavoriteCount--;
      } else {
        isFavorited = true;
        currentFavoriteCount++;
      }
    });
  }

  /// 发送评论
  void sendComment() {
    final String commentText = commentController.text.trim();
    if (commentText.isEmpty) {
      return;
    }
    commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('评论已输入: $commentText'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Note note = widget.note;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildImageSwiper(note),
                    const SizedBox(height: 16),
                    buildAuthorInfo(note),
                    const SizedBox(height: 16),
                    buildTitle(note),
                    const SizedBox(height: 12),
                    buildContent(note),
                    const SizedBox(height: 16),
                    buildTags(note),
                    const SizedBox(height: 16),
                    buildPublishTime(note),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            /// 底部点赞、评论、收藏、输入框区域。
            buildBottomActionBar(note),
          ],
        ),
      ),
    );
  }

  Widget buildImageSwiper(Note note) {
    return Stack(
      children: [
        SizedBox(
          height: 360,
          width: double.infinity,
          child: PageView.builder(
            itemCount: note.images.length,
            onPageChanged: (int index) {
              setState(() {
                currentImageIndex = index;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return Image.network(note.images[index], fit: BoxFit.cover);
            },
          ),
        ),
        Positioned(left: 12, top: 12, child: buildBackButton()),
        Positioned(right: 16, bottom: 16, child: buildImageCounter(note)),
      ],
    );
  }

  Widget buildBackButton() {
    // GestureDetector 手势监听器
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(35),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget buildImageCounter(Note note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${currentImageIndex + 1}/${note.images.length}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget buildAuthorInfo(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              note.avatar,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.author,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              '关注',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitle(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        note.title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.35,
        ),
      ),
    );
  }

  Widget buildContent(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        note.content,
        style: const TextStyle(
          fontSize: 15,
          height: 1.7,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget buildTags(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: note.tags.map((String tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '# $tag',
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildPublishTime(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '发布于 ${note.publishTime}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
    );
  }

  /// 构建底部操作栏
  ///
  /// 包含：
  /// 评论输入框
  /// 点赞按钮和点赞数量
  /// 评论入口和评论数量
  /// 收藏按钮和收藏数量
  Widget buildBottomActionBar(Note note) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: commentController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '说点什么...',
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                onSubmitted: (_) {
                  sendComment();
                },
              ),
            ),
          ),
          const SizedBox(width: 10),

          /// 点赞按钮
          buildActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            text: currentLikeCount.toString(),
            color: isLiked ? Colors.redAccent : Colors.black87,
            onTapFun: toggleLike,
          ),

          /// 评论入口
          buildActionButton(
            icon: Icons.chat_bubble_outline,
            text: note.commentCount.toString(),
            color: Colors.black87,
            onTapFun: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),

          /// 收藏按钮
          buildActionButton(
            icon: isFavorited ? Icons.star : Icons.star_border,
            text: currentFavoriteCount.toString(),
            color: isFavorited ? Colors.orange : Colors.black87,
            onTapFun: toggleFavorite,
          ),
        ],
      ),
    );
  }

  /// 构建底部单个操作按钮
  Widget buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTapFun,
  }) {
    return GestureDetector(
      onTap: onTapFun,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: 38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(text, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
