import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;

  // Initialize SharedPreferences
  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  // Save primitive data
  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) {
      return await sharedPreferences!.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences!.setInt(key, value);
    } else if (value is bool) {
      return await sharedPreferences!.setBool(key, value);
    } else if (value is double) {
      return await sharedPreferences!.setDouble(key, value);
    }
    return false;
  }

  // Save model as JSON
  static Future<bool> saveModel<T>({
    required String key,
    required T model,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final jsonMap = toJson(model);
    final jsonString = jsonEncode(jsonMap);
    return await sharedPreferences!.setString(key, jsonString);
  }

  // Get primitive data
  static String? getData({required String key}) {
    final value = sharedPreferences!.get(key);
    return value != null ? value.toString() : null;
  }

  // Get model from JSON
  static T? getModel<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final jsonString = sharedPreferences!.getString(key);
    if (jsonString == null) return null;
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      // Log the error and clear invalid cache
      log('Cache deserialization error for key $key: $e');
      sharedPreferences!.remove(key);
      return null;
    }
  }

  // Remove specific data
  static Future<bool> removeData({required String key}) async {
    return await sharedPreferences!.remove(key);
  }

  // Clear all data
  static Future<bool> clearAllData() async {
    return await sharedPreferences!.clear();
  }

  // Check if key exists
  static bool containsKey({required String key}) {
    return sharedPreferences!.containsKey(key);
  }
}