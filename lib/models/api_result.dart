class ApiResult<T> {
  final int code;
  final String msg;
  final T? data;

  /// 构造方法
  const ApiResult({required this.code, required this.msg, required this.data});

  /// 把服务端返回的 JSON 转成 ApiResult 对象。
  factory ApiResult.fromJson(
    Map<String, dynamic> json, {
    T? Function(Object? data)? fromData,
  }) {
    final Object? rawData = json['data'];
    return ApiResult<T>(
      code: json['code'] as int? ?? 0,
      msg: json['msg'] as String? ?? '',
      data: fromData == null ? rawData as T? : fromData(rawData),
    );
  }

  /// 把 ApiResult 对象转成 JSON。
  ///
  /// 目前主要备用。
  Map<String, dynamic> toJson() {
    return {'code': code, 'msg': msg, 'data': data};
  }
}
