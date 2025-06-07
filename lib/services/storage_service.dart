import 'package:get_storage/get_storage.dart';

class StorageService {
  static bool _initialized = false;
  late final GetStorage _box;

  // Constructor that initializes GetStorage
  StorageService() {
    _initializeAsync();
  }

  // Private async initialization method
  Future<void> _initializeAsync() async {
    if (!_initialized) {
      await GetStorage.init();
      _initialized = true;
    }
    _box = GetStorage();
  }

  // Read value (synchronous)
  T? read<T>(String key) {
    // Make sure storage is initialized before reading
    if (!_initialized) {
      print('Warning: Attempting to read before storage is initialized');
      return null;
    }
    return _box.read<T>(key);
  }

  // Write value
  Future<void> write(String key, dynamic value) async {
    // Ensure initialization is complete before writing
    if (!_initialized) {
      await _initializeAsync();
    }
    return _box.write(key, value);
  }

  // Remove a key
  Future<void> remove(String key) async {
    if (!_initialized) {
      await _initializeAsync();
    }
    return _box.remove(key);
  }

  // Clear all data
  Future<void> erase() async {
    if (!_initialized) {
      await _initializeAsync();
    }
    return _box.erase();
  }
}
