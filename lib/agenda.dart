import 'dart:convert';
import 'dart:developer';

import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_webservice/places.dart' as gmw;
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'package:http/http.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:timely/controllers/local_storage_controller.dart';
import 'package:timely/event_models/GoogleEvent.dart';
import 'package:timely/helpers.dart';
import 'package:timely/models/settings_model.dart';
import 'package:timely/settings.dart';

import '../event_models/EventModel.dart';
import 'controllers/account_controller.dart';
import 'controllers/settings_controller.dart';
import 'event_models/MicrosoftEvent.dart';
import 'login.dart';
import 'models/SyncFusionModelSource.dart';
import 'models/calendar_model.dart';
import 'stats.dart';

class AgendaWidget extends StatefulWidget {
  final int view;

  const AgendaWidget({super.key, required this.view});

  @override
  State<AgendaWidget> createState() => AgendaWidgetState();
}

/// Bulk of our Agenda widget, creating all the buttons/displays necessary
/// As well as using our connection to firebase.
/// Check Comments below to see where each thing gets made/used
class AgendaWidgetState extends State<AgendaWidget> {
  // ignore: constant_identifier_names
  static const String localViewKey = "view";
  late AccountController accountController;
  late String name;
  late ImageProvider image;
  late SyncFusionModelSource eventData;
  late List<EventModel> events;
  late ThemeData theme;
  bool backgroundIsEventColor = false;
  bool updating = false;

  final _formKey = GlobalKey<FormState>();

  DateTime startTime = DateTime.now();
  late DateTime endTime;
  String subject = "";
  String eventDescription = "";
  String location = "";
  String notes = "";
  String eta = "";
  String gEta = "";
  late String startsIn;
  LocalStorageController localStorage = LocalStorageController();
  final CalendarController _calController = CalendarController();
  final TextEditingController _titleController = TextEditingController();
  late SettingsProvider settings;

  @override
  void initState() {
    super.initState();
    endTime = startTime.add(const Duration(hours: 1));
    _calController.view = CalendarView.values[widget.view];
    _titleController.text =
        _calController.view.toString().split('.').last.capitalize!;

    image = NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? "");
    startsIn = startTime.relative(levelOfPrecision: 1);

    localStorage.get(localViewKey).then((value) {
      if (value is int) {
        _calController.view = CalendarView.values[value];
        _titleController.text =
            _calController.view.toString().split('.').last.capitalize!;
      } else {
        localStorage.set({localViewKey: widget.view});
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _calController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    settings = Provider.of<SettingsProvider>(context);
    accountController = Provider.of<AccountController>(context);
    theme = Theme.of(context);
    events = accountController.getAllEvents();
    eventData = SyncFusionModelSource(events: events);

    if (events.isEmpty) {
      return _makeLoadingCircle();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(_titleController.text),
          automaticallyImplyLeading: true,
          actions: [
            IconButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Settings()));
                },
                icon: const Icon(Icons.settings)),
          ],
        ),
        body: _makeBody(eventData),
        drawer: _navigationDrawer(context),
        floatingActionButton: _buildButtons(context, eventData),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }
  }

  Widget _buildPopupDialog(
      {required BuildContext context, String? popTitle, EventModel? details}) {
    googleAPI.CalendarListEntry tempC = googleAPI.CalendarListEntry();
    tempC.summary = "primary";
    DateTime startTime;
    DateTime endTime;
    String eventTitle;
    String? location;
    if (details == null) {
      startTime = DateTime.now().toLocal();
      endTime = startTime.add(const Duration(hours: 1)).toLocal();
      eventTitle = "";
      location = null;
    } else {
      startTime = details.startTime;
      endTime = details.endTime;
      eventTitle = details.subject;
      if (details.location == "" || details.location == null) {
        location = null;
      } else {
        location = details.location;
      }
    }

    googleAPI.CalendarListEntry dropdownValue = tempC;
    List<googleAPI.CalendarListEntry> calendarOptions = [];
    calendarOptions.add(dropdownValue);

    return StatefulBuilder(
      builder: (context, setState) {
        bool enabled = true;

        return AlertDialog(
          actionsPadding: const EdgeInsets.all(16.0),
          contentPadding: const EdgeInsets.all(16.0),
          buttonPadding: const EdgeInsets.all(16.0),
          insetPadding: const EdgeInsets.all(32.0),
          icon: const Icon(FontAwesome.calendar),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 1,
          scrollable: true,
          clipBehavior: Clip.antiAlias,
          //Create Event Edit Event
          title: Text(popTitle ?? ""),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Title:',
                        ),
                        const Text(
                          '*',
                          style: TextStyle(color: Colors.red),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: eventTitle,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Required',
                                contentPadding:
                                    const EdgeInsets.only(left: 30.0),
                                hintStyle: TextStyle(
                                    color: Colors.red.withOpacity(0.8),
                                    fontSize: 14.0,
                                    fontStyle: FontStyle.italic)),
                            onChanged: (value) {
                              setState(() {
                                eventTitle = value;
                              });
                            },
                            onSaved: (value) {
                              setState(
                                () {
                                  eventTitle = value ?? "";
                                },
                              );
                            },

                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                        ),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Start Time:'),
                      const Spacer(),
                      TextButton(
                        onPressed: enabled
                            ? () {
                          DatePicker.showDatePicker(context,
                              currentTime: startTime,
                              showTitleActions: true, onChanged: (date) {
                                setState(
                                      () {
                                    startTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);

                                    // startTime = date;
                                  },
                                );
                              }, onConfirm: (date) {
                                setState(
                                      () {
                                    // startTime = date;
                                    startTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
                                    endTime =
                                        date.add(const Duration(hours: 1));
                                  },
                                );
                              });
                        }
                            : null,
                        child: Text(startTime.format('M dS, Y')),
                      ),
                      TextButton(
                        onPressed: enabled
                            ? () {
                          DatePicker.showTime12hPicker(context,
                              currentTime: startTime,
                              showTitleActions: true, onChanged: (date) {
                                setState(
                                      () {
                                        startTime = DateTime(startTime.year, startTime.month, startTime.day, date.hour, date.minute);
                                        // startTime = date;
                                  },
                                );
                              }, onConfirm: (date) {
                                setState(
                                      () {
                                    // startTime = date;
                                    startTime = DateTime(startTime.year, startTime.month, startTime.day, date.hour, date.minute);
                                    endTime =
                                        date.add(const Duration(hours: 1));
                                  },
                                );
                              });
                        }
                            : null,
                        child: Text(startTime.format('h:i A')),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('End Time:'),
                      const Spacer(),
                      TextButton(
                        onPressed: enabled
                            ? () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              currentTime: endTime, onChanged: (date) {
                                setState(
                                      () {
                                        endTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
                                  },
                                );
                              }, onConfirm: (date) {
                                setState(
                                      () {
                                        endTime = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
                                  },
                                );
                              }, locale: LocaleType.en);
                        }
                            : null,
                        child: Text(endTime.format('M dS, Y')),
                      ),
                      TextButton(
                        onPressed: enabled
                            ? () {
                          DatePicker.showTime12hPicker(context,
                              showTitleActions: true,
                              currentTime: endTime, onChanged: (date) {
                                setState(
                                      () {
                                      endTime = DateTime(endTime.year, endTime.month, endTime.day, date.hour, date.minute);

                                  },
                                );
                              }, onConfirm: (date) {
                                setState(
                                      () {
                                      endTime = DateTime(endTime.year, endTime.month, endTime.day, date.hour, date.minute);
                                      },
                                );
                              }, locale: LocaleType.en);
                        }
                            : null,
                        child: Text(endTime.format('h:i A')),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Location:',
                        overflow: TextOverflow.ellipsis,
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 5,
                        child: TextButton(
                          onPressed: enabled
                              ? () async {
                                  String address = await _setEventLocation();
                                  setState(
                                    () {
                                      location = address;
                                    },
                                  );
                                }
                              : null,
                          child: Text(
                            location ?? 'Add a Location',
                            textAlign: TextAlign.right,
                            softWrap: true,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 3,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Approve'),
              onPressed: () async {
                //Create the Event
                if (details == null) {
                  if (_formKey.currentState!.validate()) {
                    AccountController accController = AccountController();
                    Iterable<Account> allAccounts =
                        accController.accounts.values;

                    CalendarModel cal = allAccounts.first.calendars.first;
                    //get first calendar that is editable
                    for (CalendarModel c in allAccounts.first.calendars) {
                      if (c.canEdit) {
                        cal = c;
                      }
                    }

                    EventModel newEvent;

                    if (allAccounts.first.provider.startsWith("google")) {
                      newEvent = GoogleEvent(
                          endTime: endTime,
                          startTime: startTime,
                          subject: eventTitle,
                          location: location,
                          isAllDay: false,
                          calendar: cal);
                      newEvent.save();
                    } else if (allAccounts.first.provider
                        .startsWith("microsoft")) {
                      cal = allAccounts.first.calendars.elementAt(1);
                      newEvent = MicrosoftEvent(
                          endTime: endTime,
                          startTime: startTime,
                          subject: eventTitle,
                          location: location,
                          isAllDay: false,
                          calendar: cal);
                      newEvent.save();
                    } else {
                      Fluttertoast.showToast(
                          msg: "Sorry we cannot add this event to the calendar",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM);
                    }

                    Navigator.of(context).pop();

                    AccountController().update();
                  }
                }
                //Case for EDIT EVENT
                else {
                  Navigator.of(context).pop();
                  await (details as EventModel).update(
                      name: eventTitle,
                      newStart: startTime,
                      newEnd: endTime,
                      newLocation: location ?? "");

                  AccountController().update();
                }
                accountController.update();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _makeCalendarView(CalendarView view, dynamic event) {
    Duration duration = event.endTime.difference(event.startTime);
    if (_calController.view == CalendarView.day ||
        _calController.view == CalendarView.week) {
      if (event.isAllDay) {
        return defaultAllDayEvent(event);
      } else {
        // Default events for week view.
        return defaultDayAndWeekEvent(event);
      }
    } else {
      return ListTile(
        visualDensity: VisualDensity.compact,
        isThreeLine: true,
        dense: true,
        leading: Icon(Icons.event,
            color: backgroundIsEventColor ? Colors.white70 : event.color,
            size: 20),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: backgroundIsEventColor
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              event.location ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: backgroundIsEventColor
                      ? Colors.white.withOpacity(0.9)
                      : theme.colorScheme.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.normal),
            ),
            Row(
              children: [
                const Icon(
                  FontAwesome.bell,
                  color: Colors.amber,
                  size: 11,
                ),
                const SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Text(
                    DateTimeFormat.format(
                        event.startTime.subtract(Duration(
                            minutes:
                                eventData.getTimeEstimate(event)?.toInt() ??
                                    settings.getReadyMinutes)),
                        format: 'g:i a'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: backgroundIsEventColor
                            ? Colors.white.withOpacity(0.9)
                            : theme.colorScheme.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          ],
        ),
        title: Text(
          event.isAllDay
              ? event.startTime.day == DateTime.now().day
                  ? 'Today'
                  : 'All Day'
              : "${DateTimeFormat.format(event.startTime, format: 'g:i A')} to ${DateTimeFormat.format(event.endTime, format: 'g:i A')}",
          style: TextStyle(
              color: backgroundIsEventColor
                  ? Colors.white
                  : theme.colorScheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.normal),
        ),
        trailing: event.isAllDay
            ? Text(
                event.startTime.day == DateTime.now().day
                    ? 'Today'
                    : DateTimeFormat.relative(
                        event.startTime,
                        abbr: true,
                        format: 'd',
                        levelOfPrecision: 0,
                      ),
                style: TextStyle(
                  color: event.startTime.isBefore(DateTime.now())
                      ? theme.disabledColor
                      : backgroundIsEventColor
                          ? theme.disabledColor
                          : Colors.green,
                  fontSize: 10,
                ),
              )
            : Text(
                DateTimeFormat.relative(
                  event.startTime.subtract(
                      Duration(minutes: SettingsProvider().getReadyMinutes)),
                  abbr: true,
                  levelOfPrecision: 1,
                  appendIfAfter: "ago",
                  prependIfBefore: "in",
                ),
                style: TextStyle(
                  color: event.startTime.isBefore(DateTime.now())
                      ? theme.disabledColor
                      : backgroundIsEventColor
                          ? Colors.white70
                          : Colors.green,
                  fontSize: 10,
                ),
              ),
      );
    }
  }

  SfCalendar _makeSfCalendar(SyncFusionModelSource eventData) {
    return SfCalendar(
      showDatePickerButton: true,
      initialDisplayDate: DateTime.now(),
      initialSelectedDate: DateTime.now(),
      onTap: (tap) {
        if (tap.targetElement == CalendarElement.appointment) {
          var details = tap.appointments![0];

          _showEventDetails(details, eventData);
        }
      },
      onLongPress: (longPress) {
        if (longPress.targetElement == CalendarElement.appointment) {
          var details = longPress.appointments![0];
          //_showArrivalData(details, eventData);
        }
      },
      headerDateFormat: 'MMMM y',
      scheduleViewSettings: ScheduleViewSettings(
        appointmentItemHeight: 80,
        monthHeaderSettings: MonthHeaderSettings(
            monthTextStyle: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: theme.colorScheme.secondaryContainer),
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
        minimumAppointmentDuration: Duration(minutes: 30),
        timeInterval: Duration(minutes: 30),
        timeFormat: "h:mm",
      ),
      selectionDecoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueAccent.shade100,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      timeZone: "America/Denver",
      monthViewSettings: const MonthViewSettings(
        showAgenda: true,
        numberOfWeeksInView: 4,
        agendaItemHeight: 100,
      ),
      view: _calController.view!,
      viewNavigationMode: ViewNavigationMode.snap,
      controller: _calController,
      showCurrentTimeIndicator: true,
      appointmentBuilder:
          (BuildContext context, CalendarAppointmentDetails app) {
        var event = app.appointments.first;
        if (event is EventModel) {
          event = app.appointments.first as EventModel;
        }
        return AnimatedContainer(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          key: ValueKey(event.id),
          height: app.bounds.height > 0 ? app.bounds.height : 50,
          width: app.bounds.width > 0 ? app.bounds.width : 20,
          curve: Curves.easeInOut,
          alignment: Alignment.topLeft,
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: backgroundIsEventColor
                ? kElevationToShadow[3]
                : kElevationToShadow[2],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: backgroundIsEventColor
                  ? [
                      event.color.withOpacity(0.8),
                      event.color.withOpacity(0.6),
                    ]
                  : [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface,
                    ],
            ),
          ),
          child: _makeCalendarView(_calController.view!, event),
        );
      },
      dataSource: eventData,
    );
  }

  void _showEventDetails(details, SyncFusionModelSource eventData) {
    showDialog(
      barrierDismissible: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        String timeEstimate = "";
        int? etaMinutes = eventData.getTimeEstimate(details)?.toInt();
        bool etaAvailable = (!details.isAllDay &&
                (details.location != null && details.location != "")) &&
            (details.startTime as DateTime).isAfter(DateTime.now());
        bool calculating = false;

        //"Calculate for time estimate.";
        String buttonText =
            etaAvailable ? "Calculate Estimate" : "Not Available";
        String startLocation = "";
        if (etaMinutes != null && etaMinutes > 0) {
          buttonText = "Update Starting Address";
          timeEstimate =
              "${etaMinutes.toString()} minutes before at ${startTime.subtract(Duration(minutes: etaMinutes)).format("g:i a")}";
          startLocation = eventData.getStartLocation(details) ?? "";
        }
        return StatefulBuilder(
          builder: (context, setState) {
            subject = details.subject as String;
            startTime = details.startTime as DateTime;
            endTime = details.endTime as DateTime;

            location = details.location ?? '';
            bool editable = false;
            try {
              editable = (details as EventModel).calendar.canEdit;
            } catch (e) {
              log("not an eventmodel");
            }
            return AlertDialog(
                iconPadding: const EdgeInsets.symmetric(vertical: 24.0),
                iconColor: details.color,
                actionsPadding: const EdgeInsets.all(16.0),
                contentPadding: const EdgeInsets.all(16.0),
                buttonPadding: const EdgeInsets.all(16.0),
                insetPadding: const EdgeInsets.all(32.0),
                icon: const Icon(Icons.event, size: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                elevation: 5,
                scrollable: true,
                actions: [
                  IconButton(
                    onPressed: () async {
                      if (details.calendar.canEdit) {
                        bool eventDeleted = false;
                        Navigator.of(context).pop();
                        eventDeleted = await _deleteMenu(context, details);
                        if (eventDeleted) {
                          await details.delete();
                          accountController.update();

                          Fluttertoast.showToast(
                              msg: "Event Deleted",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "You can't delete this event",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM);
                      }
                    },
                    icon: Icon(
                      editable ? Icons.delete : null,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (editable) {
                        Navigator.of(context).pop();
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => _buildPopupDialog(
                              context: context,
                              popTitle: "Edit Event",
                              details: details),
                        );
                      } else {
                        Fluttertoast.showToast(
                            msg: "You can't edit this event",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM);
                      }
                    },
                    icon: editable
                        ? const Icon(
                            Icons.edit,
                          )
                        : Icon(
                            Icons.lock_outline,
                            color: theme.disabledColor,
                          ),
                  ),
                  IconButton(
                    icon: const Icon(FontAwesome.x),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Event Details",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(startsIn,
                          style: startTime.isBefore(DateTime.now())
                              ? theme.textTheme.bodyText2!
                                  .copyWith(color: theme.errorColor)
                              : theme.textTheme.bodyText2!
                                  .copyWith(color: Colors.greenAccent.shade100),
                          textAlign: TextAlign.center),
                    ],
                    //style: theme.textTheme.bodyText2,
                  ),
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("Title:",
                              style: TextStyle(color: theme.disabledColor)),
                          subtitle: Text(subject),
                        ),
                        ListTile(
                          title: Text("Location",
                              style: TextStyle(color: theme.disabledColor)),
                          subtitle: Text(
                            location,
                          ),
                        ),
                        ListTile(
                          title: Text("When:",
                              style: TextStyle(color: theme.disabledColor)),
                          subtitle: details.isAllDay
                              ? Row(children: [
                                  Text(
                                    startTime.format("M d"),
                                  ),
                                  startTime.day == endTime.day
                                      ? Text("")
                                      : Text(' - ${endTime.format("M d")}'),
                                ])
                              : Row(children: [
                                  Text(
                                    "${startTime.format("M dS, g:i")} – ",
                                  ),
                                  startTime.day == endTime.day
                                      ? Text(endTime.format("g:i A"))
                                      : Text(endTime.format("M dS, g:i A")),
                                ]),
                        ),
                        ListTile(
                          title: Text("Predicted Notification Time",
                              style: TextStyle(color: theme.disabledColor)),
                          subtitle: Text(timeEstimate),
                        ),
                        ListTile(
                          title: Text(
                            "Based on Starting Location",
                            style: TextStyle(color: theme.disabledColor),
                          ),
                          subtitle: Text(
                            startLocation.endsWith(", USA")
                                ? startLocation.substring(
                                    0, startLocation.length - 5)
                                : startLocation,
                            softWrap: true,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 25,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(2.0),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                          onPressed: (!etaAvailable || startLocation == " ")
                              ? null
                              : () async {

                                  if(SettingsController().settingsModel.homeAddress == null ||
                                  SettingsController().settingsModel.homeAddress == "")
                                    {
                                      Fluttertoast.showToast(
                                          msg: 'Enter a home address to get a time estimate',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM);
                                      return;
                                    }

                                  if (startLocation == "") {
                                    setState(() {
                                      startLocation = " ";
                                      calculating = true;
                                    });
                                    await eventData
                                        .setDayEventInfo(details.startTime);
                                  } else {
                                    String? newLocation =
                                        await getLocationUsingPlacesAutocomplete(
                                            context);
                                    if (newLocation == null) {
                                      Fluttertoast.showToast(
                                          msg: 'A valid location is required',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM);
                                    } else {
                                      setState(() {
                                        calculating = true;
                                        timeEstimate = "";
                                        startLocation = newLocation;

                                        buttonText = "changing...";
                                      });
                                      await eventData.changeEventInfo(
                                          details, newLocation);
                                    }
                                  }
                                  setState(() {
                                    calculating = false;
                                    var temp = eventData
                                        .getTimeEstimate(details)
                                        ?.toInt();
                                    if (temp != null) {
                                      timeEstimate =
                                          "$temp minutes before event at ${startTime.subtract(Duration(minutes: temp)).format("g:i A")}";
                                    } else {
                                      timeEstimate = "No estimate available";
                                    }

                                    startLocation = {
                                      eventData.getStartLocation(details)
                                    }.join(',');
                                    buttonText = "Update Starting Location";
                                  });
                                },
                          child: calculating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(buttonText),
                        ),
                      ],
                    ),
                  ),
                ));
          },
        );
      },
    );
  }

  Widget _makeBody(SyncFusionModelSource eventData) {
    return Stack(
      children: [
        updating
            ? _makeLoadingCircle()
            : SfCalendarTheme(
                data: SfCalendarThemeData(
                  brightness: theme.brightness,
                ),
                child: _makeSfCalendar(eventData),
              ),
      ],
    );
  }

  Widget _makeLoadingCircle() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Loading Events..."),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, SyncFusionModelSource eventData) {
    return
        //Creation of the Add Event button
        FloatingActionButton(
            heroTag: 'addEvent',
            backgroundColor: theme.colorScheme.secondaryContainer,
            onPressed: () {

              showDialog(
                  barrierDismissible: true,
                  useSafeArea: true,
                  context: context,
                  builder: (BuildContext context) {
                    return _buildPopupDialog(
                        context: context,
                        popTitle: "Add Event",
                        details: null);
                  });

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => _buildPopupDialog(
              //           context: context,
              //           popTitle: "Add Event",
              //           details: null)),
              // );
            },
            child: Icon(
              Icons.add,
              color: theme.colorScheme.onSecondaryContainer,
            ));
  }

  Widget _navigationDrawer(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    String name = user.displayName ?? '';
    String email = user.email!.split('@')[0];
    return Drawer(
      width: 200,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.all(6)),
                CircleAvatar(radius: 32, backgroundImage: image),
                const Padding(padding: EdgeInsets.all(12)),
                Text(
                  name.isNotEmpty ? name : email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(FontAwesome.table_list, size: 30),
            title: const Text('Schedule', style: TextStyle(fontSize: 18)),
            onTap: () {
              setState(() {
                _calController.view = CalendarView.schedule;
                _titleController.text = CalendarView.schedule.name.capitalize!;
                localStorage.set({localViewKey: CalendarView.schedule.index});
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(FontAwesome.calendar_day, size: 30),
            title: const Text('Day', style: TextStyle(fontSize: 18)),
            onTap: () {
              setState(() {
                _calController.view = CalendarView.day;
                _titleController.text = CalendarView.day.name.capitalize!;
                localStorage.set({localViewKey: CalendarView.day.index});
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(FontAwesome.calendar_week, size: 30),
            title: const Text('Week', style: TextStyle(fontSize: 18)),
            onTap: () {
              setState(() {
                _calController.view = CalendarView.week;
                _titleController.text = CalendarView.week.name.capitalize!;
                localStorage.set({localViewKey: CalendarView.week.index});
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(FontAwesome.calendar, size: 30),
            title: const Text('Month', style: TextStyle(fontSize: 18)),
            onTap: () {
              setState(() {
                _calController.view = CalendarView.month;
                _titleController.text = CalendarView.month.name.capitalize!;
                localStorage.set({localViewKey: CalendarView.month.index});
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart, size: 30),
            title: const Text('Statistics', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Stats(),
                  ));
            },
          ),
          const Divider(),
          ListTile(
            leading: AnimatedCrossFade(
              firstChild: Icon(
                Icons.palette,
                color: theme.colorScheme.onPrimaryContainer,
                size: 30,
              ),
              secondChild: const Icon(
                Icons.palette_outlined,
                size: 30,
              ),
              crossFadeState: backgroundIsEventColor
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 500),
            ),
            title: const Text('Color Mode', style: TextStyle(fontSize: 18)),
            onTap: () {
              setState(() {
                backgroundIsEventColor = !backgroundIsEventColor;
              });
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .15,
          ),
          ListTile(
            leading: const Icon(Icons.update, size: 30),
            title: const Text('Sync', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              accountController.update().then(
                    (_) => Fluttertoast.showToast(
                      msg: 'Synced',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    ),
                  );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, size: 30),
            title: const Text('Log Out', style: TextStyle(fontSize: 18)),
            onTap: () {
              Provider.of<AccountController>(context, listen: false).signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );

              Fluttertoast.showToast(
                  msg: "Logged Out",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
            },
          ),
          const Padding(padding: EdgeInsets.all(10))
        ],
      ),
    );
  }

  /// Utilizes the Google Places API to search and select a location
  Future<String> _setEventLocation() async {
    try {
      gmw.Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        onError: (error) {
          log(error.errorMessage.toString());
        },
        mode: Mode.overlay,
        hint: 'Search Location',
        language: 'en',
        types: [''],
        components: [gmw.Component(gmw.Component.country, 'us')],
        strictbounds: false,
      );

      if (p != null) {
        var location = await gmw.GoogleMapsPlaces(
                apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!)
            .getDetailsByPlaceId(p.placeId!);
        return location.result.formattedAddress!;
      } else {
        return '';
      }
    } catch (e) {
      log(e.toString());
    }
    return '';
  }

  Future<bool> _deleteMenu(BuildContext context, EventModel event) async {
    bool eventDeleted = false;
    await showDialog(
        barrierDismissible: true,
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Delete Event: ${event.subject}",
                  textAlign: TextAlign.center),
              content: const Text(
                  "Are you sure you want to delete this event?"
                  "\nDeleting events also deletes them from your online calendar.",
                  textAlign: TextAlign.center),
              actions: [
                TextButton(
                    child: const Text("Delete", textAlign: TextAlign.center),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      eventDeleted = true;
                    }),
                TextButton(
                    child: const Text("Cancel", textAlign: TextAlign.center),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
    return eventDeleted;
  }

  Widget _eventStatus(Appointment details) {
    return startTime.isBefore(DateTime.now())
        ? (endTime.isBefore(DateTime.now())
            ? const Text(
                'Ended',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.red),
              )
            : const Text(
                'Started',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.red),
              ))
        : Text(
            startsIn,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.green),
          );
  }

  Widget defaultAllDayEvent(event) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
          event.subject.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              color: backgroundIsEventColor ? Colors.white : event.color,
              fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ));
  }

  Widget defaultDayAndWeekEvent(event) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            flex: 2,
            child: Text(
              event.subject,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: backgroundIsEventColor ? Colors.white : event.color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Text(
              event.location ?? '',
              style: TextStyle(
                fontSize: 11,
                color: backgroundIsEventColor
                    ? Colors.white
                    : theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Flexible(
                child: Icon(
                  FontAwesome.bell,
                  color: backgroundIsEventColor ? Colors.amber : event.color,
                  size: 10,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                    DateTimeFormat.format(event.startTime!, format: 'g:i a'),
                    style: TextStyle(
                        fontSize: 10,
                        color: backgroundIsEventColor
                            ? Colors.white
                            : theme.colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> getArrivalDataByEvent(int eventId) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final response = await Client().get(
      Uri.parse(
          'http://dursteler.me:8000/api/get_arrival_data_by_event_id/${eventId.toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response.body;
  }

  void _showArrivalData(details, SyncFusionModelSource eventData) async {
    List<dynamic> arrivalData = [];
    FirebaseAuth auth = FirebaseAuth.instance;

    DateTime arrivalTime = DateTime(2021, 1, 1, 0, 0, 0);
    DateTime departureTime = DateTime(2021, 1, 1, 0, 0, 0);
    int minutesArrivedEarly = -1;

    if (details.startTime.isAfter(DateTime.now())) {
      Fluttertoast.showToast(
          msg: "Cannot show arrival data for an event that hasn't started yet",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    } else {
      Fluttertoast.showToast(
          msg: "Fetching arrival data...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return FutureBuilder(
                future: getArrivalDataByEvent(11020),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return AlertDialog(
                      content: const Text("Loading..."),
                    );
                  }

                  if (snapshot.hasData) {
                    arrivalData = jsonDecode(snapshot.data.toString());

                    return AlertDialog(
                      iconPadding: const EdgeInsets.symmetric(vertical: 24.0),
                      iconColor: details.color,
                      actionsPadding: const EdgeInsets.all(16.0),
                      contentPadding: const EdgeInsets.all(16.0),
                      buttonPadding: const EdgeInsets.all(16.0),
                      insetPadding: const EdgeInsets.all(32.0),
                      icon: const Icon(Icons.event, size: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      elevation: 5,
                      scrollable: true,
                      title: Text("Arrival Data for ${details.subject}"),
                      content: SingleChildScrollView(
                          child: Column(
                        children: [
                          ListTile(
                            title: const Text("Enter Arrival Time"),
                            onTap: () {
                              showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          DateTime.now()))
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    arrivalTime = DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        value.hour,
                                        value.minute);
                                  });
                                }
                              });
                            },
                            subtitle: arrivalTime !=
                                    DateTime(2021, 1, 1, 0, 0, 0)
                                ? Text(
                                    "Arrival Time: ${DateTimeFormat.format(arrivalTime, format: 'g:i a')}")
                                : const Text(""),
                          ),
                          ListTile(
                            title: const Text("Enter Departure Time"),
                            onTap: () {
                              showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          DateTime.now()))
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    departureTime = DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        value.hour,
                                        value.minute);
                                  });
                                }
                              });
                            },
                            subtitle: departureTime !=
                                    DateTime(2021, 1, 1, 0, 0, 0)
                                ? Text(
                                    "Departure Time: ${DateTimeFormat.format(departureTime, format: 'g:i a')}")
                                : const Text(""),
                          ),
                          ListTile(
                            title: const Text("Enter Minutes Arrived Early"),
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 300,
                                      child: Column(children: [
                                        for (int i = 0; i < 120; i += 5)
                                          ListTile(
                                            title: Text("${i.toString()}"),
                                            onTap: () {
                                              setState(() {
                                                minutesArrivedEarly = i;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          )
                                      ]),
                                    );
                                  });
                            },
                            subtitle: minutesArrivedEarly != -1
                                ? Text(
                                    "Minutes Arrived Early: ${minutesArrivedEarly.toString()}")
                                : const Text(""),
                          ),
                          TextButton(
                            child: const Text("Submit"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      )),
                    );
                  }
                  return const AlertDialog(
                    content: Text("There was an error loading arrival data."),
                  );
                });
          });
    }
  }
}
