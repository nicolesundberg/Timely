import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/controllers/json_storage_controller.dart';

/// NOTE: Local storage doesn't support multi-level storage, only flat key/value
/// TODO: Manually serialize/update JSON using https://docs.flutter.dev/development/data-and-backend/json
class LocalStorageController extends JsonStorageController {
  @override
  Future<void> update(Map<String, Object?> data) async {
    return set(data);
  }

  @override
  Future<void> set(Map<String, Object?> data) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<Future> futures = <Future>[];
    for (MapEntry<String, Object?> entry in data.entries) {
      if (entry.value is List) {
        futures.add(sharedPreferences.setStringList(
            entry.key,
            (entry.value as List)
                .map((val) => val.toString())
                .toList()));
      } else {
        futures.add(setObject(sharedPreferences, entry.key, entry.value));
      }
    }
    await Future.wait(futures);
  }

  Future<Object> setObject(
      SharedPreferences sharedPreferences, String key, Object? value) {
    if (value == null) {
      return sharedPreferences.remove(key);
    } else if (value is bool) {
      return sharedPreferences.setBool(key, value);
    } else if (value is int) {
      return sharedPreferences.setInt(key, value);
    } else if (value is double) {
      return sharedPreferences.setDouble(key, value);
    } else if (value is String) {
      return sharedPreferences.setString(key, value);
    } else {
      return sharedPreferences.setString(key, value.toString());
    }
  }

  @override
  Future<Object?> get(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.get(key);
  }
}
