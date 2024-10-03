import 'package:shared_preferences/shared_preferences.dart';

// const String IpAddress = "http://127.0.0.1:8000";
const String IpAddress = "http://192.168.10.131:30003";

class SharedPrefs {
  static Future<SharedPreferences> getInstance() async {
    return SharedPreferences.getInstance();
  }

  static Future<String?> getCusId() async {
    SharedPreferences prefs = await getInstance();
    return prefs.getString('cusid');
  }

  static Future<String?> getEmail() async {
    SharedPreferences prefs = await getInstance();
    return prefs.getString('email');
  }

  static Future<String?> getRole() async {
    SharedPreferences prefs = await getInstance();
    return prefs.getString('role');
  }

  static Future<void> saveCusId(String cusid) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('cusid', cusid);
  }

  static Future<void> saveEmail(String email) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('email', email);
  }

  static Future<void> saveRole(String role) async {
    SharedPreferences prefs = await getInstance();
    await prefs.setString('role', role);
  }

  static Future<void> clearAll() async {
    SharedPreferences prefs = await getInstance();
    await prefs.remove('cusid');
    await prefs.remove('email');
    await prefs.remove('role');
  }
}
