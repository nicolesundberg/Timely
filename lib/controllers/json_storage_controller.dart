abstract class JsonStorageController {
  /// For update, you can use `.` in the key name to get to nested fields.
  /// This is a map of keys to values.
  Future<void> update(Map<String, Object?> data);

  Future<void> set(Map<String, Object?> data);

  /// Return will be Map<String, Object?> for JSON
  Future<Object?> get(String key);
}
