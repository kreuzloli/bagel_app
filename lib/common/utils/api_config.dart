class ApiConfig {
  /// API 服务基础地址。
  ///
  /// 注意：
  /// 如果 Flutter 跑在 iPhone 模拟器上，可以访问你 Mac 本机的 localhost。
  ///
  /// 例如你的服务端运行在：
  /// http://localhost:8080
  ///
  /// 如果是Android 模拟器 就要写:
  /// http://10.0.2.2:8080
  static const String baseUrl = 'http://localhost:8080';
}
