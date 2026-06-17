/// 笔记数据模型
///
/// 在 Flutter 里，我们一般会先把页面要展示的数据抽象成一个类。
/// 比如首页的一张笔记卡片，需要：
///
/// 标题
/// 图片
/// 作者
/// 点赞数
/// 所属频道
///
/// 这些字段组合起来，就是一条 Note 数据。
class Note {
  /// 笔记唯一 ID
  final int id;

  /// 笔记标题
  final String title;

  /// 笔记封面图片地址
  final String coverImage;

  /// 作者昵称
  final String author;

  /// 作者头像地址
  final String avatar;

  /// 点赞数量
  final int likeCount;

  /// 评论数量
  final int commentCount;

  /// 收藏数量
  final int favoriteCount;

  /// 图片显示高度
  final double imageHeight;

  /// 所属频道Id
  final int categoryId;

  /// 所属频道
  final String category;

  /// 笔记内容
  final String content;

  /// 笔记发布时间
  final String publishTime;

  /// 笔记多张轮播图
  final List<String> images;

  /// 笔记标签
  final List<String> tags;

  /// 构造方法
  const Note({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.author,
    required this.avatar,
    required this.likeCount,
    required this.imageHeight,
    required this.categoryId,
    required this.category,
    required this.content,
    required this.publishTime,
    required this.images,
    required this.tags,
    required this.commentCount,
    required this.favoriteCount,
  });

  /// 把服务端返回的 JSON 转成 Note 对象。
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      coverImage: json['coverImage'] as String? ?? '',
      author: json['author'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      likeCount: json['likeCount'] as int? ?? 0,
      imageHeight: (json['imageHeight'] as num? ?? 180).toDouble(),
      categoryId: json['categoryId'] as int? ?? 0,
      category: json['category'] as String? ?? '推荐',
      content: json['content'] as String? ?? '',
      publishTime: json['publishTime'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      commentCount: json['commentCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
    );
  }

  /// 把 Note 对象转成 JSON。
  ///
  /// 目前主要备用。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverImage': coverImage,
      'author': author,
      'avatar': avatar,
      'likeCount': likeCount,
      'imageHeight': imageHeight,
      'category': category,
      'categoryId': categoryId,
      'content': content,
      'publishTime': publishTime,
      'images': images,
      'tags': tags,
      'commentCount': commentCount,
      'favoriteCount': favoriteCount,
    };
  }
}
