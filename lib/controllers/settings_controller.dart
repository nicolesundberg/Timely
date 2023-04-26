import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:timely/controllers/firestore_controller.dart';
import 'package:timely/controllers/json_storage_controller.dart';
import 'package:timely/models/settings_model.dart';

/// This class handles loading/saving the SettingsModel so you don't need to
/// concern yourself with such things. It notifies of changes whenever the underlying
/// SettingsModel object changes, but not when a field of the SettingsModel changes.
/// SettingsModel changing occurs, for example, after Firebase has been loaded.
class SettingsController with ChangeNotifier {
  ///The SettingsModel object that this controller provides/manages.
  SettingsProvider _settingsModel = SettingsProvider();

  SettingsProvider get settingsModel => _settingsModel;

  ///Returns the Singleton instance of the SettingsController
  factory SettingsController() {
    return _instance;
  }

  Future<void> save() {
    //TODO: Add localStorage
    return _saveToJsonStorageController(FirestoreController());
  }

  Future<void> load() async {
    //TODO: Use local storage too
    SettingsProvider? settingsModel =
        await _loadFromJsonStorageController(FirestoreController());
    if (settingsModel != null) {
      _settingsModel = settingsModel;
      notifyListeners();
    } else {
      save();
    }
  }

  Future<void> _saveToJsonStorageController(
      JsonStorageController jsonStorageController) {
    return jsonStorageController
        .set(<String, dynamic>{'settings': settingsModel.toJson()}).onError(
            (Object? error, StackTrace stackTrace) {
      log("$error $stackTrace", name: 'SettingsController:saveToFirestore');
    });
  }

  Future<SettingsProvider?> _loadFromJsonStorageController(
      JsonStorageController jsonStorageController) async {
    final Object? data = await jsonStorageController.get('settings');
    if (data == null) {
      return null;
    }
    if (data is Map<String, dynamic>) {
      return SettingsProvider.fromJson(data as Map<String, dynamic>);
    } else {
      log("Data isn't in JSON form for Settings",
          name: 'SettingsController._loadFromJsonStorageController');
      return null;
    }
  }

  static final SettingsController _instance = SettingsController._internal();

  SettingsController._internal() {
    addListener(_registerSettingsModelUpdateCallbacks);
    addListener(save);
    load(); //TODO: Handle the case for a new user
  }

  void _registerSettingsModelUpdateCallbacks() {
    _settingsModel.addListener(save);
  }
}
