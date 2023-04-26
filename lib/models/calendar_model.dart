import 'dart:ui';

import 'package:timely/event_models/EventModel.dart';

import '../controllers/account_controller.dart';

export 'apple_calendar_model.dart';
export 'google_calendar_model.dart';
export 'microsoft_calendar_model.dart';

abstract class CalendarModel {
  final String id;
  final Account account;
  List<EventModel> events = <EventModel>[];
  String color = "0078d4";
  bool canEdit = false;
  CalendarModel(this.id, this.account);
  // All classes also implement Class.fromJson(Map<String, dynamic> json, Account account)

  void addEvents(List<EventModel> events) {
    for (EventModel event in events) {
      this.events.add(event);
    }
  }

  Future<Map<String, List<EventModel>>> update();
  EventModel createEvent(DateTime start, DateTime end, String subject, bool isAllDay);

  Map toJson();
}
