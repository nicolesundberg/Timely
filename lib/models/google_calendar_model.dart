import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart';
import 'package:timely/controllers/account_controller.dart';
import 'package:timely/event_models/EventModel.dart';
import 'package:timely/event_models/GoogleEvent.dart';
import 'package:timely/models/calendar_model.dart';

import '../helpers.dart';

class GoogleCalendarModel extends CalendarModel {
  //Color color = Color.fromARGB(255, 255, 255, 255);

  GoogleCalendarModel(super.id, super.account, {List<GoogleEvent>? events, String? editable, String? calColor}) {
    if (events != null) {
      this.events = events;
    }
    if (editable != null) {
      if(editable == "writer" || editable == "owner") {
        super.canEdit = true;
      }
      else {
        super.canEdit = false;
      }
    }
    if(calColor != null)
      {
        color = calColor;
      }
  }

  @override
  EventModel createEvent(
      DateTime start, DateTime end, String subject, bool isAllDay) {
    GoogleEvent event = GoogleEvent(
        startTime: start,
        endTime: end,
        subject: subject,
        isAllDay: isAllDay,
        calendar: this);
    return event;
  }

  /// Returns a map of events that were changed
  /// The keys of the map are 'added', 'deleted', and 'updated'
  @override
  Future<Map<String, List<EventModel>>> update() async {
    List<EventModel> oldEvents = events;
    events = <EventModel>[];

    Uri uri = Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/$id/events?maxResults=1000');
    Response response = await Client()
        .get(uri, headers: {'Authorization': 'Bearer ${account.token}'});
    //print(response.body);
    List<dynamic> returnedEvents = jsonDecode(response.body)["items"] ?? [];

    for (dynamic event in returnedEvents) {
      // print("event found");
      Event test = Event.fromJson(event);
      if (test.summary == null) continue;
      try {
        GoogleEvent newEvent = GoogleEvent.fromGoogle(test, this);
        // if (test.colorId == null) {
        //   ///todo: add calendar color if event has no color
        // }
        newEvent.color = getColorObject(color);
        //log(test.colorId?.toString()??"nullData",name:"color");
        events.add(newEvent);
      } catch(e) {
        log("name: ${test.summary} \t recurrenceRule: ${test.recurrence![0]}", name:"invalidEvent");
      }
    }
    log(oldEvents.length.toString(), name: "oldEvents");
    log(events.length.toString(), name: "events");

    Map<String, List<EventModel>> changeLists = <String, List<EventModel>>{};
    changeLists['added'] = <EventModel>[];
    changeLists['deleted'] = <EventModel>[];
    changeLists['updated'] = <EventModel>[];
    int compareEvents(EventModel m1, EventModel m2) =>
        m1.id.toString().compareTo(m2.id.toString());
    oldEvents.sort(compareEvents);
    // for each new event
    for (EventModel event in events) {
      GoogleEvent gEvent = event as GoogleEvent;
      EventModel? match;
      // find the corresponding old event(binary search)
      int start = 0;
      int end = oldEvents.length - 1;
      int index = ((end + start) / 2).toInt();
      while (start <= end) {
        if (gEvent.id.toString().compareTo(oldEvents[index].id.toString()) == 0) {
          match = oldEvents[index];
          break;
        } else if (gEvent.id.toString().compareTo(oldEvents[index].id.toString()) < 0) {
          end = index - 1;
          index = ((end + start) / 2).toInt();
        } else {
          start = index + 1;
          index = ((end + start) / 2).toInt();
        }
      }
      // if no matching event, then it is added
      if (match == null) {
        changeLists['added']!.add(event);
      } else {
        // otherwise remove its match from the old list and check if it was changed
        oldEvents.remove(match);
        gEvent.backendId = match.backendId;
        gEvent.estimateInMinutes = match.estimateInMinutes;
        gEvent.startLocation = match.startLocation;
        if (!gEvent.equals(match)) {
          changeLists['updated']!.add(event);
        }
      }
    }
    // then all remaining old events don't have a corresponding new event
    // so they were deleted
    for (EventModel deletedEvent in oldEvents) {
      changeLists['deleted']!.add(deletedEvent);
    }
    return changeLists;
  }

  @override
  Map toJson() {
    List<Map> events = this.events.map((i) => i.toJson()).toList();
    return {'id': id, 'events': events, 'canEdit' : canEdit,
      // 'color' : jsonEncode(color)
      'color' : color,
    };
  }

  factory GoogleCalendarModel.fromJson(dynamic json, Account account) {
    String id = json['id'];
    List<GoogleEvent>? events;
    GoogleCalendarModel cal = GoogleCalendarModel(id, account);
    if (json['events'] != null) {
      var eventsObjsJson = json['events'] as List;
      events = eventsObjsJson
          .map((eventJson) => GoogleEvent.fromJson(eventJson, cal))
          .toList();
      cal.events = events;
    }
    cal.canEdit = json['canEdit'] ?? false;

    // cal.color = jsonDecode(json['color']) ?? const Color(0x0078d4);
    // if(json['color'] != null) {
    //   Color c = jsonDecode(json['color']);
    //   cal.color = c;
    // }
    cal.color =json['color'] ?? "0078d4";

    return cal;
  }
}
