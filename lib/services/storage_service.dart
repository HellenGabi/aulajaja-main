import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  static Future<void> saveUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final cleanedUsername = username.trim().toLowerCase();
    await prefs.setString('user_$cleanedUsername', password);

    List<String> users = prefs.getStringList('users') ?? [];
    if (!users.contains(cleanedUsername)) {
      users.add(cleanedUsername);
      await prefs.setStringList('users', users);
    }
  }

  static Future<String?> getPassword(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanedUsername = username.trim().toLowerCase();
    return prefs.getString('user_$cleanedUsername');
  }

  static Future<List<String>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('users') ?? [];
  }
}
