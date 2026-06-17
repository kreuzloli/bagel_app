import 'package:bagel_app/models/note.dart';
import 'package:flutter/material.dart';

/// NoteCard 表示首页里的单个笔记卡片。
///
/// 它只负责一件事：
/// 把一条 Note 数据，显示成一个好看的卡片。
///
/// 这样做的好处是：
/// HomePage 不需要关心卡片内部怎么画，
/// 只需要把 Note 数据传进来就行。
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onTap});

  /// 当前卡片要展示的笔记数据
  final Note note;

  /// 点击卡片时执行的方法
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      /// Container 可以理解成一个盒子。
      ///
      /// 我们用它来设置：
      /// 背景色、圆角、阴影、外边距。
      child: Container(
        /// 卡片外边距
        margin: const EdgeInsets.only(bottom: 12), // 卡片之间的间距
        /// BoxDecoration 可以控制背景色、圆角、阴影等。
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14), // 圆角
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), // 阴影颜色
              blurRadius: 10, // 模糊程度
              offset: const Offset(0, 4), // 阴影偏移
            ),
          ],
        ),

        /// ClipRRect 用来裁剪圆角
        ///
        /// 如果只给 Container 设置圆角，里面的图片可能还是直角。
        /// 用 ClipRRect 包住后，图片也会跟着圆角裁剪。
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.network(
                note.coverImage,
                width: double.infinity, // 宽度占满卡片
                height: note.imageHeight, // 每张图片使用自己的高度
                fit: BoxFit.cover, // cover 表示图片铺满区域，多余部分裁掉
                /// 图片加载时显示一个浅色占位
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Container(
                        height: note.imageHeight,
                        color: const Color(0xFFF2F2F2),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Container(
                        height: note.imageHeight,
                        color: const Color(0xFFF2F2F2),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                        ),
                      );
                    },
              ),

              /// 标题区域
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Text(
                  note.title,
                  maxLines: 2, // 最多显示两行
                  overflow: TextOverflow.ellipsis, // 超出部分显示省略号
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: Color(0xFF222222),
                  ),
                ),
              ),

              /// 作者 + 点赞区域
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  children: <Widget>[
                    // 头像
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(note.avatar),
                    ),
                    const SizedBox(width: 6),

                    /// 作者名字
                    ///
                    /// Expanded 表示占据剩余空间。
                    /// 这样右边点赞数就不会被挤出去。
                    Expanded(
                      child: Text(
                        note.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.favorite_border,
                      size: 15,
                      color: Color(0xFF777777),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${note.likeCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                    // const SizedBox(height: 6),
                    // Text(
                    //   note.channel,
                    //   style: const TextStyle(
                    //     fontSize: 11,
                    //     color: Colors.pinkAccent,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
