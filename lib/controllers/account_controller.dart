import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:event/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/backend_models/event_data.dart';

import '../controllers/firestore_controller.dart';
import '../event_models/EventModel.dart';
import '../models/calendar_model.dart';

//TODO: Move Account into the models folder
class Account {
  GoogleSignIn googleSignIn = GoogleSignIn();

  String get uid => _uid;
  String _uid;

  String get provider => _provider;
  String _provider;

  String get token => _token;
  String _token;

  int get idToken => _idToken;
  int _idToken;

  String get syncToken => _syncToken;
  String _syncToken = '';

  List<CalendarModel> get calendars => _calendars;
  List<CalendarModel> _calendars;

  Account({
    required String uid,
    required String provider,
    required String token,
    required int idToken,
    required List<CalendarModel> calendars,
  })  : _calendars = calendars,
        _idToken = idToken,
        _token = token,
        _provider = provider,
        _uid = uid;

  /// This method is used to create an Account object from a UserCredential object
  static Future<Account> fromUserCredential(
      UserCredential userCredential, FirebaseAuth auth) async {
    if (userCredential.credential!.accessToken!.isNotEmpty) {
      final String uid = userCredential.user!.uid;
      final int? token = userCredential.credential!.token;
      final String? accessToken = userCredential.credential!.accessToken;
      final String provider = userCredential.credential!.providerId;
      Account ret = Account(
        uid: uid,
        provider: provider,
        token: accessToken!,
        idToken: token!,
        calendars: [],
      );
      // Unnecessary to update calendars here
      // await ret.updateAvailableCalendars(auth);
      return ret;
    } else {
      throw ArgumentError("Access Token was empty in User Credential");
    }
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    Account account = Account(
        uid: json['uid'] as String,
        provider: json['provider'] as String,
        token: json['token'] as String,
        idToken: json['idToken'] as int,
        calendars: []);
    account._setCalendarsFromJson(
        json['calendars'], json['provider'] as String);
    return account;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': _uid,
      'provider': _provider,
      'token': _token,
      'idToken': _idToken,
      'calendars': _calendarsToJson(_calendars, _provider),
    };
  }

  static Future<Account?> signUp(
    FirebaseAuth firebaseAuth,
    String provider,
  ) async {
    try {
      UserCredential userCredential;
      if (provider == 'google.com') {
        final credential = await getGoogleCredential();
        userCredential = await _signInWithCredential(firebaseAuth, credential);
      } else {
        final authProvider = getAuthProvider(provider);
        userCredential = await _signInWithProvider(firebaseAuth, authProvider);
      }
      if (userCredential.additionalUserInfo!.isNewUser) {
        AccountController().firstTimeUser = true;
      }
      return await Account.fromUserCredential(userCredential, firebaseAuth);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
            'You already have an account linked to $provider, please sign in with that.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception(
            'Access to this account type has been disabled by your administrator.');
      } else if (e.code == 'invalid-credential') {
        throw Exception(
            'Access verification failed, please try again or contact support.');
      } else {
        throw Exception('There was an error, please try again.');
      }
    }
  }

  static Future<UserCredential> _signInWithCredential(
    FirebaseAuth firebaseAuth,
    AuthCredential credential,
  ) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser != null) {
      return await currentUser.linkWithCredential(credential);
    } else {
      return await firebaseAuth.signInWithCredential(credential);
    }
  }

  static Future<UserCredential> _signInWithProvider(
    FirebaseAuth firebaseAuth,
    AuthProvider authProvider,
  ) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser != null) {
      return await currentUser.linkWithProvider(authProvider);
    } else {
      return await firebaseAuth.signInWithProvider(authProvider);
    }
  }

  static AuthProvider getAuthProvider(String provider) {
    switch (provider) {
      case 'microsoft.com':
        return OAuthProvider('microsoft.com')
            .addScope('openid')
            .addScope('https://graph.microsoft.com/Calendars.ReadWrite');
      case 'apple.com':
        return OAuthProvider('apple.com').addScope('openid').addScope('email');
      default:
        throw ArgumentError('Invalid provider value');
    }
  }

  void _setCalendarsFromJson(Map<String, dynamic> json, String provider) {
    switch (provider) {
      case 'microsoft.com':
        final List<CalendarModel> calendars = <CalendarModel>[];
        for (var calendar in json.values) {
          calendars.add(MicrosoftCalendarModel.fromJson(calendar, this));
        }
        _calendars = calendars;
        break;
      case 'google.com':
        final List<CalendarModel> calendars = <CalendarModel>[];
        for (var calendar in json.values) {
          calendars.add(GoogleCalendarModel.fromJson(calendar, this));
        }
        _calendars = calendars;
        break;
      default:
        throw ArgumentError('Invalid provider value');
    }
  }

  static Map<String, dynamic> _calendarsToJson(
      List<CalendarModel> calendars, String provider) {
    final Map<String, dynamic> json = <String, dynamic>{};
    if (provider == 'microsoft.com') {
      for (var calendar in calendars) {
        json[calendar.id] = (calendar as MicrosoftCalendarModel).toJson();
      }
    } else if (provider == 'google.com') {
      for (var calendar in calendars) {
        json[calendar.id] = (calendar as GoogleCalendarModel).toJson();
      }
    } else {
      throw ArgumentError('Invalid provider value');
    }
    return json;
  }

  Future<void> updateAvailableCalendars(FirebaseAuth auth) async {
    Response response = Response('', 400);
    switch (provider) {
      //TODO: Break out into separate sub-classes
      case 'microsoft.com':
        Uri uri = Uri.parse('https://graph.microsoft.com/v1.0/me/calendars');
        response = await Client().get(uri, headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json'
        });
        if (response.statusCode == 200) {
          final List<dynamic> providerCalendars =
              jsonDecode(response.body)['value'];
          _calendars.sort((a, b) => a.id.compareTo(b.id));
          //Add all calendars that aren't already in the List
          _calendars.addAll(providerCalendars
              .where((calendar) =>
                  _calendars.binarySearch(
                      MicrosoftCalendarModel(calendar['id'], this,
                          editable: calendar['canEdit']),
                      (p0, p1) => p0.id.compareTo(p1.id)) ==
                  -1)
              .map((calendar) => MicrosoftCalendarModel(calendar['id'], this,
                  editable: calendar['canEdit'])));
        } else if (response.statusCode == 401) {
          await reAuthenticate(auth);
        } else {
          log('Unable to get calendar IDs for $provider',
              name: 'AccountController', error: response.body);
        }
        break;
      case 'google.com':
        Uri uri = Uri.parse(
            'https://www.googleapis.com/calendar/v3/users/me/calendarList?syncToken=$_syncToken');
        response = await Client().get(uri, headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json'
        });
        if (response.statusCode == 200) {
          _syncToken = jsonDecode(response.body)['nextSyncToken'];
          final List<dynamic> providerCalendars =
              jsonDecode(response.body)['items'];
          _calendars.sort((a, b) => a.id.compareTo(b.id));
          //Add all calendars that aren't already in the List
          _calendars.addAll(
            providerCalendars
                .where((calendar) =>
                    _calendars.binarySearch(
                        GoogleCalendarModel(
                          calendar['id'],
                          this,
                          editable: calendar['accessRole'],
                          calColor: calendar['backgroundColor'],
                        ),
                        (p0, p1) => p0.id.compareTo(p1.id)) ==
                    -1)
                .map(
                  (calendar) => GoogleCalendarModel(
                    calendar['id'],
                    this,
                    editable: calendar['accessRole'],
                    calColor: calendar['backgroundColor'],
                  ),
                ),
          );
        } else if (response.statusCode == 401) {
          await reAuthenticate(auth);
        } else if (response.statusCode == 410) {
          _syncToken = '';
          await updateAvailableCalendars(auth);
        } else {
          log('Unable to get calendar IDs for $provider',
              name: 'AccountController', error: response.body);
        }
        break;
      default:
        log('Unable to get calendar IDs for $provider',
            name: 'AccountController', error: response.body);
    }
    log(_calendars.length.toString(), name: "CalLength");
  }

  Future<Map<String, List<EventModel>>> updateCalendars() async {
    List<Future<Map<String, List<EventModel>>>> futures = [];
    for (var calendar in _calendars) {
      futures.add(calendar.update());
    }
    final List<Map<String, List<EventModel>>> results =
        await Future.wait(futures);
    final Map<String, List<EventModel>> events = <String, List<EventModel>>{};
    for (var result in results) {
      if (events.isEmpty) {
        events.addAll(result);
      } else {
        for (String key in result.keys) {
          events[key]!.addAll(result[key]!);
        }
      }
    }
    return events;
  }

  Future<void> reAuthenticate(FirebaseAuth firebaseAuth) async {
    UserCredential userCredential;
    try {
      if (provider == 'google.com') {
        OAuthCredential credential = await getGoogleCredential();
        userCredential = await firebaseAuth.signInWithCredential(credential);
      } else {
        userCredential =
            await firebaseAuth.signInWithProvider(getAuthProvider(provider));
      }
      _token = userCredential.credential!.accessToken!;
    } on FirebaseAuthException catch (e) {
      log('Unable to reauthenticate',
          name: 'AccountController', error: e.message);
      await AccountController().signOut();
    } catch (e) {
      log('Unable to reauthenticate', name: 'AccountController', error: e);
    }
  }

  static Future<OAuthCredential> getGoogleCredential() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn()
          .signInSilently(reAuthenticate: true, suppressErrors: true);
      googleUser ??= await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      return GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    } catch (e) {
      log('Unable to get Google credential', name: 'AccountController');
      rethrow;
    }
  }
}

class AccountController extends ChangeNotifier {
  final Event<Value<Map<String, List<EventModel>>>> eventModelChanges =
      Event<Value<Map<String, List<EventModel>>>>();

  //TODO: make these variables private
  FirebaseAuth auth = FirebaseAuth.instance;
  FirestoreController firestoreController = FirestoreController();
  Map<String, Account> accounts = <String, Account>{};

  bool firstTimeUser = true;

  //TODO: Have this be a list
  //TODO: is this a problem that all the accounts will have the same email
  bool _updating = false;

  bool get updating => _updating;

  AccountController._internal() {
    eventModelChanges.subscribe(postEvents);
  }

  static final AccountController _instance = AccountController._internal();

  factory AccountController() {
    return _instance;
  }

  @override
  void dispose() {
    super.dispose();
    eventModelChanges.unsubscribe(postEvents);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    for (var account in accounts.values) {
      json[account.provider] = account.toJson();
    }
    return json;
  }

  Future<void> signUpOrLinkAccount(String providerID) async {
    Account? account = await Account.signUp(auth, providerID);
    if (account == null) return;

    accounts[account.provider] = account;
    await loadFromFirestore();
    update();
  }

  Future<void> removeAccount(String email) async {
    try {
      await auth.currentUser!.unlink(accounts[email]!.provider);
      accounts.remove(email);
      await saveToFirestore();
      if (accounts.isEmpty) await signOut();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      log('Unable to remove account for $email',
          name: 'AccountController', error: e.message);
    }
  }

  Future<void> update() async {
    if (_updating) {
      return;
    }

    _updating = true;

    log("Starting update", name: "AccountController.update");
    List<Future<Map<String, List<EventModel>>>> futures = [];

    for (Account account in accounts.values) {
      futures.add(account
          .updateAvailableCalendars(auth)
          .then((_) => account.updateCalendars()));
    }
    final eventChanges = await Future.wait(futures).then(
        (List<Map<String, List<EventModel>>> maps) =>
            _combineEventModelMaps(maps));
    eventModelChanges.broadcast(Value(eventChanges));
    notifyListeners();
    log("Finished updating", name: "AccountController.update");
    _updating = false;
  }

  Future<void> saveToFirestore() async {
    if (accounts.isEmpty) {
      log('Accounts is empty, nothing to save', name: 'AccountController');
      return;
    }
    try {
      final accounts = await firestoreController.get('accounts');
      if (accounts == null) {
        await firestoreController.set(<String, dynamic>{'accounts': toJson()});
      } else {
        await firestoreController
            .update(<String, dynamic>{'accounts': toJson()});
      }
      log('Saved accounts to Firestore', name: 'AccountController');
    } on FirebaseException catch (e) {
      log('Unable to save accounts to Firestore',
          name: 'AccountController', error: e.message);
    }
  }

  Future<void> loadFromFirestore() async {
    if (auth.currentUser == null) {
      log('User is not signed in, no accounts to load',
          name: 'AccountController');
      return;
    }
    try {
      final documentSnapshot =
          await firestoreController.get('accounts') as Map<String, dynamic>?;
      if (documentSnapshot != null) {
        firstTimeUser = false;
        for (var account in documentSnapshot.values) {
          accounts[account['provider']] = Account.fromJson(account);
        }
        log('Loaded accounts from Firestore', name: 'AccountController');
      } else {
        log("No accounts found in Firestore", name: "AccountController");
        saveToFirestore();
      }
    } on FirebaseException catch (e) {
      log('Unable to load accounts from Firestore',
          name: 'AccountController', error: e.message);
    } on TypeError catch (e) {
      log('Unable to load accounts from Firestore, account data not in correct form',
          name: 'AccountController', error: e);
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
      _instance.accounts.clear();
      await SharedPreferences.getInstance().then((prefs) => prefs.clear());
      await GoogleSignIn().signOut();

      log('Signed out', name: 'AccountController');
    } on FirebaseAuthException catch (e) {
      log('Unable to sign out', name: 'AccountController', error: e.message);
    } catch (e) {
      log('Unable to sign out', name: 'AccountController', error: e.toString());
    }
  }

  List<EventModel> getAllEvents() {
    return accounts.values
        .expand<CalendarModel>((Account account) => account.calendars)
        .expand<EventModel>((CalendarModel calendar) => calendar.events)
        .toList();
  }

  Future<void> removeFromFirestore() async {
    try {
      FirebaseFirestore fire = FirebaseFirestore.instance;
      await fire.collection('users').doc(auth.currentUser!.uid).delete();
      log('Removed accounts from Firestore', name: 'AccountController');
    } on FirebaseException catch (e) {
      log('Unable to remove accounts from Firestore',
          name: 'AccountController', error: e.message);
    }
  }

  String getUserId() {
    return auth.currentUser!.uid;
  }
}

Map<String, List<EventModel>> _combineEventModelMaps(
    List<Map<String, List<EventModel>>> maps) {
  Map<String, List<EventModel>> ret = {};
  ret['added'] = <EventModel>[];
  ret['deleted'] = <EventModel>[];
  ret['updated'] = <EventModel>[];
  for (Map<String, List<EventModel>> map in maps) {
    if (map.containsKey('added')) {
      ret['added']!.addAll(map['added']!);
      log(ret['added']!.length.toString(), name: 'AddedLength');
    }
    if (map.containsKey('deleted')) {
      ret['deleted']!.addAll(map['deleted']!);
      log(ret['deleted']!.length.toString(), name: 'DeletedLength');
    }
    if (map.containsKey('updated')) {
      ret['updated']!.addAll(map['updated']!);
      log(ret['updated']!.length.toString(), name: 'UpdatedLength');
    }
  }
  return ret;
}

void postEvents(Value<Map<String, List<EventModel>>>? events) async {
  if (events == null) {
    log('events map was null', name: 'NullValueError');
  }
  // Gets updated/added/deleted events map
  Map<String, List<EventModel>> mapped_events = events!.value;
  // Verifies the proper keys exist
  if (!(mapped_events.keys.contains('added') &&
      mapped_events.keys.contains('deleted') &&
      mapped_events.keys.contains('updated'))) {
    log('Only found ${mapped_events.keys.toList()}', name: 'MissingKeysError');
  }

  if (mapped_events['added'] != null) {
    for (EventModel event in mapped_events['added']!) {
      EventData data = await EventData.fromEventModel(event);
      // Don't post if 'added' and an id already exists (in case if issue with hot reload)
      event.backendId ??= int.parse(await data.postData());
    }
  }
  if (mapped_events['deleted'] != null) {
    for (EventModel event in mapped_events['deleted']!) {
      event.backendId = null;
    }
  }
  if (mapped_events['updated'] != null) {
    for (EventModel event in mapped_events['updated']!) {
      EventData data = await EventData.fromEventModel(event);
      event.backendId = int.parse(await data.postData());
    }
  }
  AccountController().saveToFirestore();
}
