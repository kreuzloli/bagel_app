class LocalKeyConstants {
  /// 搜索历史保存到本地时使用的 key
  static const String searchHistory = 'search_history_keywords';

  /// token 保存 key
  static const String accountToken = 'bagel_token';

  /// 当前登录账号保存 key
  ///
  /// 这里保存的是用户输入的手机号 / 邮箱。
  /// 后面如果服务端返回用户信息，比如 userId、nickname、avatar，
  /// 我们再继续加 key。
  static const String currentAccount = 'bagel_current_account';
}
