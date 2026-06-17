import 'package:bagel_app/models/category.dart';

import '../models/note.dart';

/// 模拟笔记数据
///
/// 真实项目里，这些数据通常来自服务器接口。
/// 现在我们还没有接后端，所以先写一组本地假数据，
/// 用来把首页、详情页、点赞、收藏、评论入口这些功能跑通。
const List<Note> mockNotes = [
  Note(
    id: 1,
    title: '今天的贝果早餐太治愈了',
    coverImage: 'https://picsum.photos/id/292/600/800',
    author: '小橘子',
    avatar: 'https://picsum.photos/id/64/100/100',
    likeCount: 128,
    imageHeight: 230,
    categoryId: 1,
    category: '美食',
    content: '今天早上做了一个芝士火腿贝果，外皮微脆，里面软软的。配上一杯冰拿铁，感觉整个人都被重新开机了。',
    publishTime: '2026-06-08 09:30',
    images: [
      'https://picsum.photos/id/292/600/800',
      'https://picsum.photos/id/312/600/800',
      'https://picsum.photos/id/431/600/800',
    ],
    tags: ['早餐', '贝果', '生活感'],
    commentCount: 24,
    favoriteCount: 36,
  ),

  Note(
    id: 2,
    title: '周末穿搭分享',
    coverImage: 'https://picsum.photos/id/325/600/900',
    author: '月亮汽水',
    avatar: 'https://picsum.photos/id/65/100/100',
    likeCount: 86,
    imageHeight: 280,
    categoryId: 2,
    category: '穿搭',
    content: '浅色衬衫搭配牛仔裤，简单但是很舒服。最近越来越喜欢这种不费力的穿搭，出门不用纠结太久。',
    publishTime: '2026-06-08 13:20',
    images: [
      'https://picsum.photos/id/325/600/900',
      'https://picsum.photos/id/342/600/850',
    ],
    tags: ['穿搭', '周末', '日常'],
    commentCount: 12,
    favoriteCount: 18,
  ),

  Note(
    id: 3,
    title: '旅行路上的小咖啡馆',
    coverImage: 'https://picsum.photos/id/431/600/850',
    author: '风从海上来',
    avatar: 'https://picsum.photos/id/91/100/100',
    likeCount: 203,
    imageHeight: 260,
    categoryId: 3,
    category: '旅行',
    content: '在街角发现一家很安静的小咖啡馆，窗边的位置刚好能看到落日。旅行中最开心的就是这种意外发现。',
    publishTime: '2026-06-07 18:45',
    images: [
      'https://picsum.photos/id/431/600/850',
      'https://picsum.photos/id/42/600/800',
      'https://picsum.photos/id/1060/600/800',
    ],
    tags: ['旅行', '咖啡', '城市漫游'],
    commentCount: 41,
    favoriteCount: 67,
  ),

  Note(
    id: 4,
    title: '学习 Flutter 的第八天',
    coverImage: 'https://picsum.photos/id/180/600/780',
    author: '代码小面包',
    avatar: 'https://picsum.photos/id/1005/100/100',
    likeCount: 64,
    imageHeight: 220,
    categoryId: 4,
    category: '学习',
    content: '今天做了点赞、收藏和评论入口。状态变化用 setState 就能完成，感觉 Flutter 的数据驱动开始有点意思了。',
    publishTime: '2026-06-09 08:10',
    images: [
      'https://picsum.photos/id/180/600/780',
      'https://picsum.photos/id/0/600/800',
    ],
    tags: ['Flutter', '学习', 'App开发'],
    commentCount: 9,
    favoriteCount: 21,
  ),

  Note(
    id: 5,
    title: '数码桌面改造计划',
    coverImage: 'https://picsum.photos/id/201/600/820',
    author: '键盘不会睡',
    avatar: 'https://picsum.photos/id/1011/100/100',
    likeCount: 156,
    imageHeight: 250,
    categoryId: 5,
    category: '数码',
    content: '把桌面重新整理了一下，显示器、键盘、鼠标和小台灯终于不再互相打架了。桌面干净之后，写代码都像开了低噪模式。',
    publishTime: '2026-06-06 21:15',
    images: [
      'https://picsum.photos/id/201/600/820',
      'https://picsum.photos/id/119/600/800',
      'https://picsum.photos/id/160/600/780',
    ],
    tags: ['数码', '桌面改造', '效率'],
    commentCount: 33,
    favoriteCount: 58,
  ),

  Note(
    id: 6,
    title: '适合新手的 Flutter 学习路线',
    coverImage: 'https://picsum.photos/id/366/600/760',
    author: '一只会敲代码的贝果',
    avatar: 'https://picsum.photos/id/1027/100/100',
    likeCount: 312,
    imageHeight: 240,
    categoryId: 4,
    category: '学习',
    content: '刚开始学 Flutter 不要急着背所有组件。先把页面结构、布局、状态变化和页面跳转搞懂，再慢慢补动画、网络请求和状态管理。',
    publishTime: '2026-06-05 10:00',
    images: [
      'https://picsum.photos/id/366/600/760',
      'https://picsum.photos/id/48/600/760',
    ],
    tags: ['Flutter', '新手教程', '学习路线'],
    commentCount: 52,
    favoriteCount: 104,
  ),

  Note(
    id: 7,
    title: '晚饭随手拍',
    coverImage: 'https://picsum.photos/id/493/600/830',
    author: '番茄炒蛋选手',
    avatar: 'https://picsum.photos/id/1025/100/100',
    likeCount: 74,
    imageHeight: 270,
    categoryId: 1,
    category: '美食',
    content: '今天晚饭做了番茄炒蛋和清炒时蔬，虽然普通，但是热乎。普通人的快乐有时候就是一碗刚出锅的饭。',
    publishTime: '2026-06-04 19:40',
    images: [
      'https://picsum.photos/id/493/600/830',
      'https://picsum.photos/id/488/600/780',
    ],
    tags: ['晚饭', '家常菜', '治愈'],
    commentCount: 15,
    favoriteCount: 20,
  ),

  Note(
    id: 8,
    title: '城市散步记录',
    coverImage: 'https://picsum.photos/id/1015/600/880',
    author: '路过一阵风',
    avatar: 'https://picsum.photos/id/1035/100/100',
    likeCount: 189,
    imageHeight: 300,
    categoryId: 3,
    category: '旅行',
    content: '今天没有安排特别的目的地，只是沿着街道慢慢走。路边的树影、便利店的灯、还有突然出现的小巷，都很适合被记录下来。',
    publishTime: '2026-06-03 16:25',
    images: [
      'https://picsum.photos/id/1015/600/880',
      'https://picsum.photos/id/1043/600/850',
      'https://picsum.photos/id/1050/600/820',
    ],
    tags: ['城市', '散步', '记录生活'],
    commentCount: 28,
    favoriteCount: 49,
  ),
];

const List<Category> mockCategories = [
  // Category(id: 1, name: "推荐"),
  // Category(id: 2, name: "关注"),
  Category(id: 1, name: "美食"),
  Category(id: 2, name: "穿搭"),
  Category(id: 3, name: "旅行"),
  Category(id: 4, name: "学习"),
  Category(id: 5, name: "数码"),
];

/// 热门搜索
const List<String> mockHotKeywords = <String>[
  '美食',
  '旅行',
  '穿搭',
  '学习',
  '数码',
  '咖啡',
  '拍照',
  '周末去哪',
];
