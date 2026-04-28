import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/Item.dart';

class SharedPreferenceService {
  static const String _usersKey = 'registered_users';
  static const String _favoritesKey = 'favorite_items';

  // ── User Management ──────────────────────────────────────────────────────

  // Save a new user to SharedPreferences
  static Future<void> saveUser(
    String username,
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();

    users.add({
      'username': username,
      'email': email,
      'password': password,
    });

    await prefs.setString(_usersKey, jsonEncode(users));
  }

  // Retrieve all users from SharedPreferences
  static Future<List<Map<String, String>>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null || usersJson.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(usersJson);
    return decoded
        .map((user) => Map<String, String>.from(user as Map))
        .toList();
  }

  // Check if a user with a given email exists
  static Future<bool> userExists(String email) async {
    final users = await getUsers();
    return users.any((user) => user['email'] == email);
  }

  // Find a user by email
  static Future<Map<String, String>?> findUserByEmail(String email) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  // Clear all users (for testing/reset purposes)
  static Future<void> clearUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
  }

  // ── Favorites Management ─────────────────────────────────────────────────

  // Save a favorite article
  static Future<void> saveFavorite(Item item) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    // Check if item already exists
    if (!favorites.any((fav) => fav.id == item.id)) {
      favorites.add(item);
      final jsonList = favorites.map((item) => item.toJson()).toList();
      await prefs.setString(_favoritesKey, jsonEncode(jsonList));
    }
  }

  // Remove a favorite article
  static Future<void> removeFavorite(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    favorites.removeWhere((item) => item.id == itemId);
    final jsonList = favorites.map((item) => item.toJson()).toList();
    await prefs.setString(_favoritesKey, jsonEncode(jsonList));
  }

  // Get all favorite articles
  static Future<List<Item>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);

    if (favoritesJson == null || favoritesJson.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(favoritesJson);
    return decoded
        .map((item) => Item.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Check if an article is favorited
  static Future<bool> isFavorited(String itemId) async {
    final favorites = await getFavorites();
    return favorites.any((item) => item.id == itemId);
  }

  // Clear all favorites
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}

