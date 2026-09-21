import 'db_helper.dart';

class SessionManager {
  static String? _username;
  static DateTime? _loginTime;

  static bool get isLoggedIn => _username != null;
  static String get username => _username ?? 'Tamu';
  static DateTime? get loginTime => _loginTime;

  static Future<bool> login(String username, String password) async {
    final valid = await DBHelper.checkLogin(username, password);
    if (!valid) return false;
    _username = username.trim();
    _loginTime = DateTime.now();
    return true;
  }

  static void logout() {
    _username = null;
    _loginTime = null;
  }
}