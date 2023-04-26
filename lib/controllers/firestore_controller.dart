import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timely/controllers/json_storage_controller.dart';
import 'package:timely/shared/firebase_options.dart';

/// This class is a wrapper around Firestore based on the user that is logged in
class FirestoreController extends JsonStorageController {
  static final Future<void> _initializeFirestoreFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Updates firestore with a map of fields
  @override
  Future<void> update(Map<String, Object?> data) async {
    await _initializeFirestoreFuture;
    if(_auth.currentUser == null) return;
    return _db.collection('users')
        .doc(_auth.currentUser!.uid)
        .update(data);
  }

  /// Sets the firestore instance to be data, merging data
  @override
  Future<void> set(Map<String, Object?> data) async {
    await _initializeFirestoreFuture;
    if(_auth.currentUser == null) return;
    return _db.collection('users')
        .doc(_auth.currentUser!.uid)
        .set(data, SetOptions(merge: true));
  }

  /// Returns the object stored at a key, which could be another map
  @override
  Future<Object?> get(String key) async {
    await _initializeFirestoreFuture;
    if (_auth.currentUser == null) return null;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _db.collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    if (snapshot.exists) {
      //Loop over the key to return just the data requested
      dynamic cursor = snapshot.data()!;
      for (String subkey in key.split('.')) {
        if(cursor is Map<String, dynamic>) {
          if (cursor.containsKey(subkey)) {
            cursor = cursor[subkey];
          }
          else {
            return null;
          }
        }
        else {
          return null;
        }
      }
      return cursor;
    }
    else {
      return null;
    }
  }

  static final FirestoreController _instance = FirestoreController._internal();

  FirestoreController._internal();

  factory FirestoreController() {
    return _instance;
  }
}
