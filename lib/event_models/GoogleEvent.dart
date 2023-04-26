import 'dart:convert';
import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'package:http/http.dart';
import 'package:timely/event_models/EventModel.dart';
import 'package:timely/event_models/recurring_event_data.dart';

import '../backend_models/estimate_data.dart';
import '../backend_models/event_data.dart';
import '../models/google_calendar_model.dart';

class GoogleEvent extends EventModel {
  /**
   * GoogleEvent Class Constructor method (extends EventModel):
   *
   * note that the required fields for this class and all subclasses include:
   *    startTime (DateTime Object)
   *    endTime (DateTime Object)
   *    subject (String)
   *    isAllDay (boolean)
   *    calendarId (String)
   *
   * fields that can be accessed but are not required at the time of construction include:
   *    color (Color Object)
   *    id (Object? -> we give our events a String ID from the Calendar after creation)
   *    location (String?)
   *    notes (String?)
   *    recurrenceExceptionDates (for calendar view usage)
   *    recurrenceId (for calendar view usage)
   *    recurrenceRule (for calendar view usage)
   *      the three previous variables are for keeping track of repeat events
   *      here for documentation: https://www.syncfusion.com/kb/3719/what-is-recurrencerule-in-the-schedule-control
   *    startTimeZone (String?)
   *    endTimeZone (String?)
   *
   * other fields in this class are for Google API Purposes only (not necessary for our use)
   *    https://developers.google.com/calendar/api/v3/reference/events
   */
  GoogleEvent(
      {this.kind,
      this.etag,
      this.status,
      this.htmlLink,
      this.created,
      this.updated,
      super.notes,
      super.location,
      this.creator,
      this.organizer,
      this.start,
      this.end,
      this.endTimeUnspecified,
      this.transparency,
      this.visibility,
      this.iCalUid,
      this.sequence,
      this.attendees,
      this.guestsCanInviteOthers,
      this.privateCopy,
      this.reminders,
      this.source,
      this.eventType,
      this.recurrence,
      super.recurrenceRule,
      super.color,
      required super.startTime,
      required super.endTime,
      required super.subject,
      required super.isAllDay,
      required super.calendar,
      super.startTimeZone,
      super.endTimeZone,
      super.recurrenceExceptionDates,
      super.id}) {
    if (!isValid()) {
      throw Exception("Invalid GoogleEvent JSON");
    }
  }

  // googleAPI.Even

  String? kind;
  String? etag;
  String? status;
  String? htmlLink;
  DateTime? created;
  DateTime? updated;
  //String? summary; google summary -> event subject
  //String? description; google description -> event notes
  googleAPI.EventCreator? creator;
  googleAPI.EventOrganizer? organizer;
  googleAPI.EventDateTime? start;
  googleAPI.EventDateTime? end;
  bool? endTimeUnspecified;
  String? transparency;
  String? visibility;
  String? iCalUid;
  int? sequence;
  List<googleAPI.EventAttendee>? attendees;
  bool? guestsCanInviteOthers;
  bool? privateCopy;
  googleAPI.EventReminders? reminders;
  googleAPI.EventSource? source;
  String? eventType;
  List<String>? recurrence;
  //todo - add calendar class reference, for now we'll just add a String calendarID
  //String calendarID = "primary"; //must change this after creating a google event

  GoogleEvent.fromJson(Map<String, dynamic> json, GoogleCalendarModel calID)
      : super(
            endTime: DateTime.now(),
            startTime: DateTime.now(),
            subject: " ",
            isAllDay: false,
            calendar: calID) {
    startTime = DateTime.parse(json["startTime"]);
    startTimeZone = json["startTimeZone"];
    endTime = DateTime.parse(json["endTime"]);
    endTimeZone = json["endTimeZone"];
    isAllDay = json["isAllDay"];
    subject = json["subject"];
    id = json["id"];
    if (json["location"] != null) location = json["location"];

    if (json["color"] != null) {
      color = Color(int.parse(json["color"]));
    }
    if (json["backendId"] != null) {
      backendId = json["backendId"];
    }
    /// note that color is taken from string format
    // if (json["color"] != null) {
    //   //https://stackoverflow.com/questions/49835146/how-to-convert-flutter-color-to-string-and-back-to-a-color
    //
    //   String valueString =
    //       json["color"].split('(0x')[1].split(')')[0]; // kind of hacky..
    //   int value = int.parse(valueString, radix: 16);
    //   color = new Color(value);
    // }
    // if(json["calendarId"] != null)
    // {
    //   calendar = json["calendarId"];
    // }
    if (json["notes"] != null) {
      notes = json["notes"];
    }
    if (json["recurrenceRule"] != null) {
      recurrenceRule = json["recurrenceRule"];
    }
    if (json["recurrenceExceptionDates"] != null) {
      notes = jsonDecode(json["recurrenceExceptionDates"]);
    }
    if (json["recurringEventData"] != null) {
      Map<String, dynamic> tempMap = jsonDecode(json["recurringEventData"]);
      recurringData = {};
      tempMap.forEach((key, value) {
        recurringData![key] = RecurringEventData.fromJson(value);
      });
    }
    if (!isValid()) {
      throw Exception("Invalid GoogleEvent JSON");
    }

    if(json["eventsInDay"] != null) {
      eventsInDay = json["eventsInDay"];
    }
    if(json["thisEventNumber"] != null) {
      thisEventNumber = json["thisEventNumber"];
    }
    if(json["startLocation"] != null) {
      startLocation = json["startLocation"];
    }
    if(json["estimateInMinutes"] != null) {
      estimateInMinutes = json["estimateInMinutes"];
    }

  }

  GoogleEvent.fromGoogle(googleAPI.Event event, GoogleCalendarModel cal)
      : super(
            endTime: DateTime.now(),
            startTime: DateTime.now(),
            subject: '',
            isAllDay: false,
            calendar: cal) {
    id = event.id;

    kind = event.kind;
    etag = event.etag;
    status = event.status;
    htmlLink = event.htmlLink;
    created = event.created;
    updated = event.updated;
    subject = event.summary!;
    notes = event.description;
    location = event.location;
    creator = event.creator;
    organizer = event.organizer;

    if (event.start == null || event.end == null)
      throw Exception("invalid event, no start/end given");
    if (event.start?.date == null && event.start?.dateTime == null)
      throw Exception("invalid event, start given");
    if (event.end?.date == null && event.end?.dateTime == null)
      throw Exception("invalid event, no end data given");

    /// so these are custom google event start and end fields, should we keep and update these? or
    /// kill them and make them again when we need to revert back to a google event type?
    endTimeUnspecified = event.endTimeUnspecified;
    transparency = event.transparency;
    visibility = event.visibility;
    iCalUid = event.iCalUID;
    sequence = event.sequence;
    attendees = event.attendees;
    guestsCanInviteOthers = event.guestsCanInviteOthers;
    privateCopy = event.privateCopy;
    reminders = event.reminders;
    source = event.source;
    eventType = event.eventType;
    recurrence = event.recurrence;

    recurrenceRule = recurrence?[0] ?? "";
    // recurrenceExceptionDates = recurrence?[1] ?? "";

    ///code for finding and setting color
    // var hexString = event.colorId;
    // final buffer = StringBuffer();
    // if (hexString?.length == 6 || hexString?.length == 7) buffer.write('ff');
    // buffer.write(hexString?.replaceFirst('#', ''));
    // color = Color(int.parse(buffer.toString(), radix: 16));

    isAllDay = event.start?.date != null;

    start = event.start;
    end = event.end;

    ///code for start and end time

    DateTime endTemp = end?.date ?? end?.dateTime?.toLocal() ?? DateTime.now();
    DateTime startTemp =
        start?.date ?? start?.dateTime?.toLocal() ?? DateTime.now();
    if (isAllDay) {
      endTime = endTemp.subtract(const Duration(days: 1));
      startTime = startTemp;
    } else {
      endTime = endTemp;
      startTime = startTemp;
    }
    //TODO: Remove these two lines. This is a bad fix
    startTimeZone = 'America/Denver';
    endTimeZone = 'America/Denver';

    if (!isValid()) {
      throw Exception("Invalid GoogleEvent");
    }
  }

  void _updateStartEnd() {
    if (start == null) start = googleAPI.EventDateTime();
    if (end == null) end = googleAPI.EventDateTime();

    if (!isAllDay) {
      end?.dateTime = endTime;
      start?.dateTime = startTime;
    } else {
      end?.date = endTime;
      start?.date = startTime;
    }
    start?.timeZone = startTimeZone;
    end?.timeZone = endTimeZone;
  }

  /**
   * Return a google Event type from the current event
   */
  googleAPI.Event toGoogleEvent() {
    googleAPI.Event newEvent = googleAPI.Event(
        kind: kind,
        etag: etag,
        status: status,
        htmlLink: htmlLink,
        created: created,
        updated: updated,
        location: location,
        summary: subject,
        description: notes,
        creator: creator,
        organizer: organizer,
        start: start,
        end: end,
        endTimeUnspecified: endTimeUnspecified,
        transparency: transparency,
        visibility: visibility,
        iCalUID: iCalUid,
        sequence: sequence,
        attendees: attendees,
        guestsCanInviteOthers: guestsCanInviteOthers,
        privateCopy: privateCopy,
        reminders: reminders,
        source: source,
        eventType: eventType,
        recurrence: recurrence);
    if (!isValid()) {
      throw Exception("Invalid Event to make into a Google Event");
    }
    return newEvent;
  }

  /**
   * verifies and saves updated information -- note that if given a new startTime, you must also give a new endTime
   */
  @override
  Future<void> update(
      {String? name,
      DateTime? newStart,
      DateTime? newEnd,
      String? newLocation}) async {
    ///only verification checking to be done here is to make sure end comes after start
    if (newEnd != null && newStart != null) {
      if (newEnd.isBefore(newStart!))
        throw Exception("end must come after start");
    }
    if (name != null) {
      subject = name;
    }
    if (newStart != null && newEnd != null) {
      startTime = newStart;
      endTime = newEnd;
    }
    if (newLocation != null) {
      location = newLocation;
    }

    await save();
    //subject = name;
  }

  /**
   * Add or update event based on if event id exists
   */
  @override
  Future<void> save() async {
    //edit start and end fields to match the startTime and endTime stuff
    _updateStartEnd();

    if (!isValid()) {
      throw Exception("Invalid Event to save");
    }

    String token = calendar.account.token;
    String calID = calendar.id;
    Uri uri;
    Response response;
    if (id != "" && id != null) {
      // print("ID EXISTS");
      //event exists
      uri = Uri.parse(
          'https://www.googleapis.com/calendar/v3/calendars/$calID/events/$id');

      Map<String, String> headers = {};
      headers['Authorization'] = 'Bearer ${token}';

      response =
          await Client().put(uri, headers: headers, body: toGoogleJson());

      if (response.statusCode != 200) {
        Fluttertoast.showToast(
            msg: "Error: ${response.body}", toastLength: Toast.LENGTH_LONG);
        return;
      } else {
        Fluttertoast.showToast(
            msg: "Event Updated", toastLength: Toast.LENGTH_LONG);
      }

      EventData eventData = await EventData.fromEventModel(this);
      String eventResponse = await eventData.postData();
      print("Post Event Data Response: $eventResponse");
      if (location != null) {
        int eventResponseID = int.parse(eventResponse);
        EstimateData estimateData =
            await EstimateData.fromEventId(eventResponseID);
        String estimateResponse = await estimateData.postData();
        print("Post Estimate Data Response: $estimateResponse");
      }

      ///TODO: fix the above code to work with future versions of event model stuff

      // googleAPI.Event insertedEvent = await calendarApi.events.update(googleEvent, calendarId, id.toString());
      //   print("UPDATED  ${insertedEvent.status}");
    } else {
      ///TODO: fix the above code to work with future versions of event model
      //event DOES NOT exist
      uri = Uri.parse(
          'https://www.googleapis.com/calendar/v3/calendars/$calID/events');
      Map<String, String> headers = {};
      headers['Authorization'] = 'Bearer ${token}';

      response = await Client()
          .post(uri, headers: headers, body: jsonEncode(toGoogleEvent()));

      if (response.statusCode != 200) {
        Fluttertoast.showToast(
            msg: "Error: ${response.body}", toastLength: Toast.LENGTH_LONG);
        return;
      } else {
        Fluttertoast.showToast(
            msg: "Event Saved", toastLength: Toast.LENGTH_LONG);
      }
      // googleAPI.Event insertedEvent = await calendarApi.events.insert(googleEvent, calendarId);
      //   print("ADDED  ${insertedEvent.status}");
      //   // if(value.status == )
      //   id = insertedEvent.id; //CHECK IF WE WANT TO WAIT TO IMPORT THIS DIRECTLY SINCE WE GET THE FULL EVENT OR JUST CHANGE THE ID HERE
      id = jsonDecode(response.body)["id"];

      EventData eventData = await EventData.fromEventModel(this);
      String eventResponse = await eventData.postData();
      print("Post Event Data Response: $eventResponse");
      if (location != null) {
        int eventResponseID = int.parse(eventResponse);
        EstimateData estimateData =
            await EstimateData.fromEventId(eventResponseID);
        String estimateResponse = await estimateData.postData();
        print("Post Estimate Data Response: $estimateResponse");
      }
    }
    return;
  }

  /**
   * Delete event from online and local calendar
   */
  Future<void> delete() async {
    String token = calendar.account.token;
    String calID = calendar.id;

    Uri uri = Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/$calID/events/$id');
    Map<String, String> headers = {};
    headers['Authorization'] = 'Bearer ${token}';

    Response response = await Client().delete(uri, headers: headers);

    if (response.statusCode != 204) {
      Fluttertoast.showToast(
          msg: "Error: ${response.body}", toastLength: Toast.LENGTH_LONG);
      return;
    } else {
      Fluttertoast.showToast(
          msg: "Event Deleted", toastLength: Toast.LENGTH_LONG);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    if (!isValid()) {
      throw Exception("Invalid event to save to JSON");
    }

    Map<String, dynamic> tempMap = {};
    recurringData?.forEach((key, value) {
      tempMap[key] = value.toJson();
    });


    return {
      "endTime": endTime.toIso8601String(),
      "startTime": startTime.toIso8601String(),
      "subject": subject,
      "isAllDay": isAllDay,
      "id": id.toString(),
      "location": location,
      "startTimeZone": startTimeZone,
      "endTimeZone": endTimeZone,
      "color": color.value.toString(),
      "notes": notes,
      "recurrenceRule": recurrenceRule,
      "backendId": backendId,
      "recurrenceExceptionDates": jsonEncode(recurrenceExceptionDates),

      "recurringEventData:": jsonEncode(tempMap),

      "eventsInDay":eventsInDay,
      "thisEventNumber":thisEventNumber,
      "startLocation":startLocation,
      "estimateInMinutes":estimateInMinutes,
      //TODO: Probably add in recurrenceExceptionDates, so that we don't lose them when we update?
      // "recurrenceExceptionDates" : jsonEncode(recurrenceExceptionDates.toString()), //Check this
    };
  }

  void _toLocal() {
    if (start?.date != null) start?.date?.toLocal();

    if (start?.dateTime != null) start?.dateTime?.toLocal();

    if (end?.date != null) end?.date?.toLocal();

    if (start?.dateTime != null) end?.dateTime?.toLocal();
  }

  String toGoogleJson() {
    _updateStartEnd();

    googleAPI.Event gEvent = toGoogleEvent();
    return jsonEncode(gEvent);
  }

  bool equals(EventModel other) {
    if (other is GoogleEvent) {
      GoogleEvent event = other;

      if (endTime.toIso8601String() == event.endTime.toIso8601String() &&
          startTime.toIso8601String() == event.startTime.toIso8601String() &&
          subject == event.subject &&
          isAllDay == event.isAllDay &&
          id.toString() == event.id.toString() &&
          location == event.location &&
          startTimeZone == event.startTimeZone &&
          endTimeZone == event.endTimeZone &&
          color.value.toString() == event.color.value.toString() &&
          notes == event.notes &&
          recurrenceRule == event.recurrenceRule &&
          backendId == event.backendId) {
        return true;
      }
    }
    return false;
  }
}
