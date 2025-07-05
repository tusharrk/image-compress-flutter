import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked_annotations.dart';

class StorageService implements InitializableDependency {
  late SharedPreferences _prefs;

  // Remove the constructor parameter since we'll initialize in init()
  StorageService();

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Read value
  T? read<T>(String key) {
    return _readValue<T>(key);
  }

  // Private method to handle actual reading
  T? _readValue<T>(String key) {
    try {
      if (T == String) {
        return _prefs.getString(key) as T?;
      } else if (T == int) {
        return _prefs.getInt(key) as T?;
      } else if (T == bool) {
        return _prefs.getBool(key) as T?;
      } else if (T == double) {
        return _prefs.getDouble(key) as T?;
      } else if (T == List<String>) {
        return _prefs.getStringList(key) as T?;
      } else {
        // For complex objects, try to deserialize from JSON
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          try {
            final decoded = json.decode(jsonString);
            return decoded as T;
          } catch (e) {
            print('Error decoding JSON for key $key: $e');
            return null;
          }
        }
        return null;
      }
    } catch (e) {
      print('Error reading value for key $key: $e');
      return null;
    }
  }

  // Write value
  Future<void> write(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      } else {
        // For complex objects, serialize to JSON
        final jsonString = json.encode(value);
        await _prefs.setString(key, jsonString);
      }
    } catch (e) {
      print('Error writing value for key $key: $e');
      throw Exception('Failed to write value for key $key: $e');
    }
  }

  // Remove a key
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      print('Error removing key $key: $e');
      throw Exception('Failed to remove key $key: $e');
    }
  }

  // Clear all data
  Future<void> erase() async {
    try {
      await _prefs.clear();
    } catch (e) {
      print('Error clearing storage: $e');
      throw Exception('Failed to clear storage: $e');
    }
  }

  // Check if key exists
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}
