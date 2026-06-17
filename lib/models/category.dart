/// 笔记数据类型
class Category {
  /// ID
  final int id;

  /// name
  final String name;

  /// 构造方法
  const Category({required this.id, required this.name});

  /// 把服务端返回的 JSON 转成 category 对象。
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  /// 把 category 对象转成 JSON。
  ///
  /// 目前主要备用。
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
