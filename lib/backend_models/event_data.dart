import 'dart:convert';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timely/backend_models/location_data.dart';
import 'package:http/http.dart' as http;
import 'package:timely/controllers/settings_controller.dart';
import 'package:timely/models/settings_model.dart';
import 'package:timely/shared/maps.dart';
import 'package:timely/event_models/EventModel.dart';
import 'package:timely/controllers/account_controller.dart';

class EventData {
  // Requires an EventModel that this EventData corresponds to
  EventModel? event;
  LocationData? event_location;
  String event_name;
  int priority;
  int how_early_to_appointment_desired_in_minutes;
  int how_early_to_be_notified_to_leave_in_minutes;
  String? tags;
  String? user_id;

  EventData._private_constructor(
      this.event,
      this.event_location,
      this.event_name,
      this.priority,
      this.how_early_to_appointment_desired_in_minutes,
      this.how_early_to_be_notified_to_leave_in_minutes,
      this.tags,
      this.user_id);

  static Future<EventData> fromEventModel(EventModel event) async {
    LocationData? event_location;
    if (event.location != null) {
      event_location = await AppleMaps.fetchGeocode(event.location!);
    }
    String event_name = event.subject;
    SettingsProvider settings = SettingsController().settingsModel;
    int priority = settings.priority.index;
    int how_early_to_appointment_desired_in_minutes = settings.arriveEarlyMinutes;
    int how_early_to_be_notified_to_leave_in_minutes = settings.getReadyMinutes;
    String? tags; // null for now, TODO: maybe cut this
    return EventData._private_constructor(
        event,
        event_location,
        event_name,
        priority,
        how_early_to_appointment_desired_in_minutes,
        how_early_to_be_notified_to_leave_in_minutes,
        tags,
        AccountController().getUserId());
  }

  Future<String> postData() async {
    final response = await http.post(
      Uri.parse('http://dursteler.me:8000/api/event/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(toJson()),
    );
    // Automatically saves the new backend id in the EventModel,
    // throws an exception if the response was invalid
    event?.backendId = int.parse(response.body);
    // await event.save(); ///TODO: SAVE TO FIREBASE
    return response.body;
  }

  Map toJson() {
    Map? event_location;
    if (this.event_location != null) {
      event_location = this.event_location!.toJson();
    }

    return {
      "event_location": event_location,
      "event_name": event_name,
      "priority": priority,
      "how_early_to_appointment_desired_in_minutes":
      how_early_to_appointment_desired_in_minutes,
      "how_early_to_be_notified_to_leave_in_minutes":
      how_early_to_be_notified_to_leave_in_minutes,
      "tags": tags,
      "user_id": user_id
    };
  }
}
