import '../utils/shared_preference.dart';

class UserStore {
  // Use SharedPreferenceService for persistent storage
  static Future<void> saveUser(String username, String email, String password) {
    return SharedPreferenceService.saveUser(username, email, password);
  }

  static Future<List<Map<String, String>>> getUsers() {
    return SharedPreferenceService.getUsers();
  }

  static Future<bool> userExists(String email) {
    return SharedPreferenceService.userExists(email);
  }

  static Future<Map<String, String>?> findUserByEmail(String email) {
    return SharedPreferenceService.findUserByEmail(email);
  }
}


