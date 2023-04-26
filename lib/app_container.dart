import 'package:flutter/material.dart';

import 'agenda.dart';
import 'settings.dart';

/// The main app container. This is the root widget of the app.
/// It is responsible for:
/// - Creating the [FirebaseAuthentication] instance
/// - Creating the [BottomNavigationBar] and its items
class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => AppContainerState();
}

class AppContainerState extends State<AppContainer> {
  late int _selectedIndex;

  //TODO: Make this private. Tests should use AppContainer

  //TODO: There should be a global events holder

  @override
  void initState() {
    super.initState();
    _selectedIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    return buildMaterialApp(context);
  }

  get selectedIndex => _selectedIndex;

  Scaffold buildMaterialApp(BuildContext context) {
    return Scaffold(
      body: Center(
          child: AnimatedIndexedStack(
              index: _selectedIndex,
              duration: const Duration(milliseconds: 500),
              children: _widgetOptions)),

      //TODO: Factor out to be a TaskBar widget. The AppContainer should own the classes though.
    );
  }

  final List<Widget> _widgetOptions = <Widget>[
    const AgendaWidget(view: 8),
    const Settings(),
  ];
}

class AnimatedIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const AnimatedIndexedStack(
      {super.key,
      required this.index,
      required this.children,
      required this.duration});

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: index,
      children: children
          .asMap()
          .map((i, child) => MapEntry(
              i,
              AnimatedSwitcher(
                duration: duration,
                child: i == index ? child : const SizedBox.shrink(),
              )))
          .values
          .toList(),
    );
  }
}
