class ValidatorUtils {
  ValidatorUtils._();

  static String? validatorAccount(String? value) {
    final String account = value?.trim() ?? '';
    if (account.isEmpty) {
      return '请输入手机号或邮箱';
    }
    if (account.contains('@')) {
      final bool isEmail = RegExp(
        r'^[\w\.-]+@[\w\.-]+\.\w+$',
      ).hasMatch(account);
      if (!isEmail) {
        return '请输入正确的邮箱格式';
      }
    } else {
      final bool isPhone = RegExp(r'^1[3-9]\d{9}$').hasMatch(account);
      if (!isPhone) {
        return '请输入正确的手机号';
      }
    }
    return null;
  }

  static String? validatorNickname(String? value) {
    final String nickname = value?.trim() ?? '';
    if (nickname.isEmpty) {
      return '请输入昵称';
    }
    if (nickname.length < 2) {
      return '昵称至少 2 个字符';
    }
    if (nickname.length > 20) {
      return '昵称不能超过 20 个字符';
    }
    return null;
  }

  static String? validatorPassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return '请输入密码';
    }
    if (password.length < 6) {
      return '密码至少 6 位';
    }
    if (password.length > 20) {
      return '密码不能超过 20 位';
    }
    return null;
  }
}
