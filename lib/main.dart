import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis/cloudsearch/v1.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timely/backend_models/estimate_data.dart';
import 'package:timely/backend_models/location_data.dart';
import 'package:timely/controllers/firestore_controller.dart';
import 'package:timely/models/SyncFusionModelSource.dart';
import 'package:timely/models/settings_model.dart';
import 'package:timely/models/theme_model.dart';
import 'package:timely/providers/user.dart';
import 'package:timely/shared/dispatcher_methods.dart';
import 'package:timely/shared/maps.dart';
import 'package:workmanager/workmanager.dart';

import 'event_models/recurring_event_data.dart';
import 'intro_screen.dart';
import 'agenda.dart';
import 'backend_models/arrival_data.dart';
import 'controllers/account_controller.dart';
import 'controllers/settings_controller.dart';
import 'event_models/EventModel.dart';
import 'login.dart';
import 'settings.dart';
import 'notifications.dart';
import 'shared/firebase_options.dart';

/// Main initializes things like firebase and other objects that firebase depends on
/// then takes user to the agenda or login page depending on if they are logged in
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //TODO: Remove
  await dotenv.load(fileName: 'assets/.env');

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await Workmanager().cancelAll();
  runApp(const Timely());
}

class Timely extends StatefulWidget {
  const Timely({super.key});

  @override
  State<Timely> createState() => _TimelyState();
}

class _TimelyState extends State<Timely> {
  AccountController accountController = AccountController();
  SettingsProvider settings = SettingsProvider();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirestoreController firestoreController = FirestoreController();

  @override
  void initState() {
    super.initState();
    getUserTheme();
  }

  void getUserTheme() async {
    if (auth.currentUser == null) return;
    settings.darkTheme = await settings.darkThemePreference.getTheme();
    await accountController.loadFromFirestore();
    accountController.update();
    await Workmanager().registerOneOffTask("Send info to backend", "daily",
        initialDelay: const Duration(seconds: 30));
    await Workmanager().registerPeriodicTask(
        "Checking when to send notification", "periodic",
        initialDelay: const Duration(minutes: 1));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AccountController()),
      ChangeNotifierProvider(create: (_) => SettingsController()),
      //If this ChangeNotifierProxyProvider is confusing, see
      // https://stackoverflow.com/questions/57765994/how-to-use-a-provider-inside-of-another-provider-in-flutter
      ChangeNotifierProxyProvider<SettingsController, SettingsProvider>(
          create: (context) => SettingsController().settingsModel,
          update: (context, settingsController, previousSettingsProvider) =>
              settingsController.settingsModel),
      ChangeNotifierProvider(create: (_) => DarkThemeProvider()),
      ProxyProvider2(
        update: (context, SettingsProvider settings, DarkThemeProvider theme,
            previous) {
          return UserProvider(settings: settings, theme: theme);
        },
      ),
    ], builder: (context, args) => _buildMaterialApp(context));

  }

  Widget _buildMaterialApp(BuildContext context) {
    return MaterialApp(
        title: 'Timely',
        debugShowCheckedModeBanner: false,
        themeAnimationCurve: Curves.easeInOut,
        themeAnimationDuration: const Duration(milliseconds: 500),
        theme: Provider.of<SettingsProvider>(context).darkTheme
            ? ThemeData.dark(useMaterial3: true)
            : ThemeData.light(useMaterial3: true),
        home: auth.currentUser == null
            ? const Login()
            : const AgendaWidget(view: 8));
  }
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    //Initialize all required objects (Account Controller, Plugins, Firebase)
    WidgetsFlutterBinding.ensureInitialized();
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    DartPluginRegistrant.ensureInitialized();
    await dotenv.load(fileName: 'assets/.env');
    FirebaseAuth auth = FirebaseAuth.instance;
    final FirestoreController firestoreController = FirestoreController();
    final AccountController accountController = AccountController();
    await accountController.loadFromFirestore();
    await accountController.update();
    final SettingsController settingsController = SettingsController();
    await settingsController.load();

    //Create Flutter Local Notification object to be passed and grab all Events with Account Controller

    List<EventModel> events = AccountController().getAllEvents();

    SyncFusionModelSource eventData = SyncFusionModelSource(events: events);
    switch (task) {
      //Task that runs once a day that sets the estimate data for all events for the day
      case "daily":
        await calculateAllDailyEstimates(accountController, eventData);
        return true;

      default:
        return await upcomingEventPlanner(eventData);
    }
  });
}
