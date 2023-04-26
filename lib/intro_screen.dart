import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:timely/agenda.dart';

import 'controllers/account_controller.dart';
import 'controllers/settings_controller.dart';
import 'helpers.dart';
import 'dart:developer' as dev;


class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<ContentConfig> listContentConfig = [];
  late SettingsController settings;
  TextEditingController homeController = TextEditingController();
  var homeAddress = SettingsController().settingsModel.homeAddress;

  bool validHomeAddress = false;

  @override
  void initState() {
    super.initState();
    //add slides
    homeController.addListener(() {
      if (homeController.text != homeAddress) {
        homeAddress = homeController.text;
        SettingsController().settingsModel.homeAddress = homeAddress;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    homeController.dispose();
  }

  void onTabChangeCompleted(int index) {
    dev.log("Tab change completed");

    print("UPDATE HERE");
  }

  void addAllPages() {
    //welcome
    listContentConfig.add(
      const ContentConfig(
        title: "Welcome to Timely",
        description:
            "The all-in-one scheduling app that can help you be on time for life's most important events",
        pathImage: "assets/timely.png",
        backgroundColor: Color(0xff292929),
      ),
    );

    //CALENDAR FUNCTIONALITY

    Widget title1 = makeTitleWidget(Icons.calendar_month, text: "Calendar");
    String calendarText =
        "Timely allows you to sync all of your calendars to see all of your"
        " events in one place.  With a variety of views combined with our travel estimation algorithm, "
        "you can be sure that you know when and where you're going for all of your appointments.";
    Widget body1 = makeBodyWidget(calendarText);

    addIntroPage(listContentConfig, title1, body1);

    //USERS

    Widget botWidget2 = Row(children: const [
      Spacer(),
      Icon(FontAwesome.google, color: Colors.red, size: 32),
      Spacer(),
      Icon(FontAwesome.apple, color: Colors.grey, size: 32),
      Spacer(),
      Icon(FontAwesome.microsoft, color: Colors.cyan, size: 32),
      Spacer()
    ]);

    Widget title2 = makeTitleWidget(Icons.person, botWidget: botWidget2);
    String userText =
        "Timely allows you to connect all of your calendars from different accounts, allowing for all"
        " of your events to be stored in one place. Calendars are color coded as you assigned them in"
        " your other applications for easy viewing. To link another account, go to the settings menu "
        "in the top right and link another account type.";
    Widget body2 = makeBodyWidget(userText);

    addIntroPage(listContentConfig, title2, body2);

    //EVENT DETAILS

    Widget title3 = makeTitleWidget(Icons.event_note, text: "Event Details");
    String eventText =
        "In any calendar view, click on an event to view its details. Here, you can see its title,"
        " start time, end time, and calculate your estimated notification time based on currently available data.";
    Widget body3 = makeBodyWidget(eventText);

    addIntroPage(listContentConfig, title3, body3);

    //ADD EVENT

    Widget title5 = makeTitleWidget(Icons.add, text: "Add Events");
    String addText =
        "Timely also allows you to add new events. You can add a new event and sync it to your calendars"
        " by clicking on the plus icon in the bottom right corner of the screen when looking at your calendar.";
    Widget body5 = makeBodyWidget(addText);

    addIntroPage(listContentConfig, title5, body5);

    //EDIT EVENT

    Widget title4 = makeTitleWidget(Icons.edit, text: "Edit Events");
    String editText =
        "To edit an event, after clicking to view its event details click the pencil icon. This will take"
        " you to another menu where you can edit existing event data, which will then be synced across your"
        " accounts and calendars.";
    Widget body4 = makeBodyWidget(editText);

    addIntroPage(listContentConfig, title4, body4);

    //NOTIFICATIONS

    Widget title6 =
        makeTitleWidget(Icons.notifications_active, text: "Notifications");
    String notifsText =
        "Timely ensures you can arrive on time by notifying you when you need to start heading out for"
        " your next appointment. Timely accounts for a variety of factors including weather, traffic, and"
        " user history to allow for enough time to get out of the house and to your event.";
    Widget body6 = makeBodyWidget(notifsText);

    addIntroPage(listContentConfig, title6, body6);

    //LOCATION SERVICES
    Widget title7 =
        makeTitleWidget(Icons.location_on, text: "Location Services");
    String locText =
        "Timely uses location services to check when you need to leave for your appointment as well as"
        " to see what time you arrived at your appointment. This allows our algorithm to notice trends"
        " of tardiness to notify you earlier if needed.";
    Widget body7 = makeBodyWidget(locText);

    addIntroPage(listContentConfig, title7, body7);

    //Home Address

    Widget title8 = makeTitleWidget(Icons.home, text: "Home Address");
    String homeText =
        "Timely uses your home address to properly estimate the time it will"
        " take for you to get to your appointments. Add your home address below"
        " to continue using Timely";

    Widget body8 = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        makeBodyWidget(homeText),
        SizedBox(height: MediaQuery.of(context).size.height / 25),
        TextField(
            showCursor: false,
            maxLines: 1,
            controller: homeController,
            onTap: () {
              getLocationUsingPlacesAutocomplete(context)
                  .then((value) => {
                setState(() {
                  homeAddress = value;
                  // SettingsController().settingsModel.homeAddress =
                  //     homeAddress;
                  homeController.text = homeAddress ?? 'N/A';
                  value != null
                  ? validHomeAddress = true
                      : validHomeAddress = false;

                }),
              })
                  .catchError((error) => {
                        setState(() {
                          homeController.text = '';
                        }),
                      });
              //setState(() {});
            },
            decoration: InputDecoration(
              suffixIcon: homeController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          homeController.clear();
                        });
                      },
                      icon: const Icon(Icons.cancel),
                    )
                  : null,
              contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.blueAccent.shade100, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              hintStyle: TextStyle(color: Theme.of(context).hintColor),
              hintText: "123 Main Street, City, State, 12345",
            )),
      ],
    );

    addIntroPage(listContentConfig, title8, body8);
  }

  void addIntroPage(
      List<ContentConfig> contentConfigList, Widget title, Widget body) {
    listContentConfig.add(ContentConfig(
        widgetTitle: title,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        widgetDescription: body));
  }

  Widget makeBodyWidget(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget makeTitleWidget(IconData iconType, {Widget? botWidget, String? text}) {
    Color grad = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[1],
            gradient: LinearGradient(
              colors: [grad.withOpacity(.9), grad.withOpacity(.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            iconType,
            size: 80,
            color: (SettingsController().settingsModel.darkTheme
                ? const Color(0xffc9c9c9)
                : const Color(0xff292929)),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Divider(
            height: 20,
            thickness: 5,
            indent: 80,
            endIndent: 80,
            color: Theme.of(context).dividerColor),
        const SizedBox(
          height: 20,
        ),
        if (text != null)
          Text(
            text,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        if (botWidget != null) botWidget,
      ],
    );
  }

  void onDonePress() {
    if (homeAddress != null && homeAddress != "" && homeAddress != 'N/A') {
      SettingsController().settingsModel.homeAddress = homeAddress;
    }
    AccountController().firstTimeUser = false;

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AgendaWidget(view: 8)));
  }

  @override
  Widget build(BuildContext context) {
    addAllPages();
    late Function goToTab;
    int currentIndex = 0;

    if (SettingsController().settingsModel.homeAddress != null) {
      validHomeAddress = true;
    }

    return IntroSlider(
        listContentConfig: listContentConfig,
        onDonePress: onDonePress,
        indicatorConfig: IndicatorConfig(
          colorActiveIndicator: Theme.of(context).colorScheme.onSurface,
          colorIndicator: Theme.of(context).disabledColor,
        ),
        refFuncGoToTab: (refFunc) {
          goToTab = refFunc;
        },
        onTabChangeCompleted: (int index) {
          currentIndex = index;
        },
        renderSkipBtn: OutlinedButton(
          onPressed: !validHomeAddress
              ? null
              : () {
                  goToTab(8);
                  // goToTab
                },
          child: const Text('SKIP'),
        ),
        renderPrevBtn: OutlinedButton(
          onPressed:() {
            goToTab(currentIndex-1);
          },
          child: const Text('PREV'),
        ),
        renderDoneBtn: OutlinedButton(
          onPressed: () {

            if(!validHomeAddress)
              {
                Fluttertoast.showToast(
                    msg: "Please enter a valid home address",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM);
              }
            else
              {
                onDonePress();
              }
          },
          child: const Text('DONE'),
        ),
        onSkipPress: () {},
        renderNextBtn: OutlinedButton(
          onPressed: () {
            goToTab(currentIndex + 1);
          },
          child: const Text('NEXT'),
        ),
      isShowPrevBtn: true,
      isShowSkipBtn: false,

    );
  }
}
