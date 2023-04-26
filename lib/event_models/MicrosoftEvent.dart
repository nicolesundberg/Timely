import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:timely/event_models/EventModel.dart';
import 'package:timely/event_models/recurring_event_data.dart';

import '../backend_models/estimate_data.dart';
import '../backend_models/event_data.dart';
import '../helpers.dart';
import '../models/microsoft_calendar_model.dart';

class MicrosoftEvent extends EventModel {
  /**
   * MicrosoftEvent Class Constructor method (extends EventModel):
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
   * For further documentation about Microsoft Events see:
   *    https://learn.microsoft.com/en-us/graph/api/resources/event?view=graph-rest-1.0
   */
  MicrosoftEvent(
      {required super.endTime,
      required super.startTime,
      required super.subject,
      required super.isAllDay,
      required super.calendar,
      super.id,
      super.startTimeZone,
      super.endTimeZone,
      super.location,
      super.notes,
      super.color,
      super.recurrenceRule,
      super.recurrenceExceptionDates});

  // bool allowNewTimeProposals = true;
  ///Attendee attendees;
  ///ItemBody body;
  // String bodyPreview = "";
  ///String collection categories
  ///String changeKey
  ///DateTimeOffset createdDateTime
  ///DateTimeZone end
  ///bool hasAttachments
  ///bool hideAttendees
  ///String iCalUid
  ///String id
  ///String importance
  ///bool isCancelled
  ///bool isDraft
  ///bool isOnlineMeeting
  ///bool isOrganizer
  ///bool isReminderOn
  ///DateTimeOffset lastModifiedDateTime
  ///Location location
  ///Location collection locations
  ///OnlineMeetingInfo onlineMeeting
  ///onlineMeetingProviderType onlineMeetingProvider
  ///String onlineMeetingUrl
  ///Recipient organizer
  ///String originalEndTimeZone
  ///DateTimeOffset originalStart
  ///String originalStartTimeZone
  ///PatternedRecurrence recurrence
  ///Int32 reminderMinutesBeforeStart
  ///bool responseRequested
  ///ResponseStatus responseStatus
  ///String sensitivity
  ///String seriesMasterId
  ///String showAs
  ///DateTimeTimeZone start
  ///String subject
  ///String transactionId
  ///String type
  ///String webLink
  //String? summary; google summary -> event subject
  //String? description; google description -> event notes

  ///have json of changes to keep track of what needs to be updated for sending to outlook
  /**
   * Create MicrosoftEvent object from json map
   */
  MicrosoftEvent.fromJson(Map<String, dynamic> json, MicrosoftCalendarModel cal)
      : super(
            endTime: DateTime.now(),
            startTime: DateTime.now(),
            subject: " ",
            isAllDay: false,
            calendar: cal) {
    startTime = DateTime.parse(json["startTime"]);
    startTimeZone = json["startTimeZone"];
    endTime = DateTime.parse(json["endTime"]);
    endTimeZone = json["endTimeZone"];
    isAllDay = json["isAllDay"];
    subject = json["subject"];
    id = json["id"];
    if (json["location"] != null) location = json["location"];

    /// note that color is taken from string format
    if (json["color"] != null) {
      color = stringToColor(json["color"]);
    }
    if (json["backendId"] != null) {
      backendId = json["backendId"];
    }
    // if(json["calendarId"] != null)
    //   {
    //     calendar = json["calendarId"];
    //   }
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

    if (!isValid()) {
      throw Exception("Invalid JSON to create MicrosoftEvent from");
    }
  }

  /**
   * Creates a MicrosoftEvent object from the Microsoft given json from http calls
   */
  MicrosoftEvent.fromMicrosoftJson(
      Map<String, dynamic> json, MicrosoftCalendarModel cal)
      : super(
            endTime: DateTime.now(),
            startTime: DateTime.now(),
            subject: " ",
            isAllDay: false,
            calendar: cal) {
    startTime = DateTime.parse(json["start"]["dateTime"]);
    startTimeZone = json["start"]["timeZone"];
    endTime = DateTime.parse(json["end"]["dateTime"]);
    endTimeZone = json["end"]["timeZone"];
    isAllDay = json["isAllDay"];
    subject = json["subject"];
    id = json["id"];
    if (json["location"] != null && json["location"]["address"] != null) {
      Map<String, dynamic> loc = json["location"]["address"];
      if (loc.isEmpty) {
        location = json["location"]["displayName"];
      } else {
        location = loc["street"] +
            " " +
            loc["city"] +
            ", " +
            loc["state"] +
            " " +
            loc["postalCode"];
      }
    }

    ///"recurrence":{"pattern":{"type":"absoluteMonthly","interval":1,"month":0,"dayOfMonth":26,
    ///"firstDayOfWeek":"sunday","index":"first"},"range":{"type":"endDate","startDate":"2023-02-26",
    ///"endDate":"2024-02-26","recurrenceTimeZone":"Mountain Standard Time","numberOfOccurrences":0}},"
    String frequency = "";
    String interval = "";
    String count = "";
    String until = "";
    String byday = "";
    String bymonthday = "";
    String bymonth = "";
    String bysetpos = "";
    if (json["recurrence"] != null) {
      switch (json["recurrence"]["pattern"]["type"]) {
        case "absoluteMonthly":
          {
            frequency = "FREQ=MONTHLY";
            interval = "INTERVAL=" +
                json["recurrence"]["pattern"]["interval"].toString();
            bymonthday = "BYMONTHDAY=" +
                json["recurrence"]["pattern"]["dayOfMonth"].toString();
          }
          break;

        case "daily":
          {
            frequency = "FREQ=DAILY";
            interval = "INTERVAL=" +
                json["recurrence"]["pattern"]["interval"].toString();
          }
          break;

        case "weekly":
          {
            frequency = "FREQ=WEEKLY";
            interval = "INTERVAL=" +
                json["recurrence"]["pattern"]["interval"].toString();
            byday = _getDaysFromMicrosoftInfo(
                json["recurrence"]["pattern"]["daysOfWeek"]);
          }
          break;
        case "relativeMonthly":
          {
            frequency = "FREQ=MONTHLY";
            interval = "INTERVAL=" +
                json["recurrence"]["pattern"]["interval"].toString();
            byday = _getDaysFromMicrosoftInfo(
                json["recurrence"]["pattern"]["daysOfWeek"]);
          }
          break;

        case "absoluteYearly":
          {
            frequency = "FREQ=YEARLY";
            interval = "INTERVAL=${json["recurrence"]["pattern"]["interval"]}";
            bymonthday =
                "BYMONTHDAY=${json["recurrence"]["pattern"]["dayOfMonth"]}";
            bymonth = "BYMONTH=${json["recurrence"]["pattern"]["month"]}";
          }
          break;
        case "relativeYearly":
          {
            frequency = "FREQ=MONTHLY";
            interval = "INTERVAL=${json["recurrence"]["pattern"]["interval"]}";
            bymonth = "BYMONTH=${json["recurrence"]["pattern"]["month"]}";
            int counter = 0;
            String byday = _getDaysFromMicrosoftInfo(
                json["recurrence"]["pattern"]["daysOfWeek"]);
          }
          break;
      }
      String until = "";
      switch (json["recurrence"]["range"]["type"]) {
        case "endDate":
          {
            DateTime endOfRecurrence =
                DateTime.parse(json["recurrence"]["range"]["endDate"]);
            until = "UNTIL=${endOfRecurrence.toIso8601String()}";
          }
          break;
        case "noEnd":
          {}
          break;
        case "numbered":
          {}
          break;
      }
      recurrenceRule = "";
      List<String> parts = [];

      if (frequency != "") {
        parts.add(frequency);
      }
      if (interval != "") {
        parts.add(interval);
      }
      if (count != "") {
        parts.add(count);
      }
      if (until != "") {
        parts.add(until);
      }
      if (byday != "") {
        parts.add(byday);
      }
      if (bymonthday != "") {
        parts.add(bymonthday);
      }
      if (bymonth != "") {
        parts.add(bymonth);
      }
      if (bysetpos != "") {
        parts.add(bysetpos);
      }

      int counter = 0;
      for (String part in parts) {
        if (counter != 0) {
          recurrenceRule = (recurrenceRule ?? "") + ";" + part;
        } else {
          recurrenceRule = (recurrenceRule ?? "") + part;
        }
        counter++;
      }
    }
    if (json["bodyPreview"] != null) {
      notes = json["bodyPreview"];
    }

    // recurrenceRule = "RRULE:"+"FREQ="+json["recurrence"]["recurrencePattern"]["type"]
    //     +";UNTIL=" + json["recurrence"]["recurrenceRange"] +";BYDAY=";

    ///TODO -- check if we should chek if any of these are null in case of bad data
    ///(would cause an exception / crash the program)

    if (!isValid()) {
      throw Exception(
          "Invalid MicrosoftEventJson to create into MicrosoftEvent");
    }
  }

  String _getDaysFromMicrosoftInfo(List<dynamic> days) {
    int counter = 0;
    String byday = "";
    for (String day in days) {
      if (counter != 0) {
        byday += ",";
      } else {
        byday = "BYDAY=";
      }
      switch (day) {
        case "monday":
          {
            byday += "MO";
          }
          break;
        case "tuesday":
          {
            byday += "TU";
          }
          break;
        case "wednesday":
          {
            byday += "WE";
          }
          break;
        case "thursday":
          {
            byday += "TH";
          }
          break;
        case "friday":
          {
            byday += "FR";
          }
          break;
        case "saturday":
          {
            byday += "SA";
          }
          break;
        case "sunday":
          {
            byday += "SU";
          }
          break;
      }
      counter++;
    }
    return byday;
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
    //TODO: NExt two lines seem like a hack. We shouldn't overwrite their time zone
    // startTimeZone=getTimeZoneName();
    // endTimeZone=getTimeZoneName();
    // String endTimePartialZone = endTime.timeZoneOffset.toString();
    // if(endTime.timeZoneOffset.inHours < 10)
    // {
    //   endTimeZone = "UTC ${endTimePartialZone.substring(0,1)} 0${endTimePartialZone.substring(1,5)}";
    //   startTimeZone = "UTC ${endTimePartialZone.substring(0,1)} 0${endTimePartialZone.substring(1,5)}";
    // }
    // else
    // {
    //   endTimeZone = "UTC ${endTimePartialZone.substring(0,1)} ${endTimePartialZone.substring(1,6)}";      endTimeZone = "UTC ${endTimePartialZone.substring(0,1)} 0${endTimePartialZone.substring(1,5)}";
    //   startTimeZone = "UTC ${endTimePartialZone.substring(0,1)} 0${endTimePartialZone.substring(1,5)}";
    //
    // }

    // if (!isValid()) {
    //   throw Exception("Invalid Event to save");
    // }
    String tempTimeZone = startTimeZone ?? "";
    startTimeZone = "America/Denver";
    endTimeZone = "America/Denver";

    String token = calendar.account.token;
    String calID = calendar.id;
    Map<String, dynamic> microsoftJson = toMicrosoftJson();
    Response response;
    if (id != "" && id != null) {
      /// id != null => update event
      Uri uri = Uri.parse(
          'https://graph.microsoft.com/v1.0/me/calendars/$calID/events/${id}');
      response = await Client().patch(uri,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json'
          },
          body: json.encode(microsoftJson));

      if (response.statusCode != 200) {
        Fluttertoast.showToast(
          msg: "Error ${response.body}",
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Updated event",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } else {
      //remove id from json
      microsoftJson.remove("id");
      Uri uri = Uri.parse(
          'https://graph.microsoft.com/v1.0/me/calendars/$calID/events');

      response = await Client().post(uri,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json'
          },
          body: json.encode(microsoftJson));

      if (response.statusCode != 201) {
        Fluttertoast.showToast(
          msg: "Error ${response.body}",
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Created event",
          toastLength: Toast.LENGTH_LONG,
        );
      }
      id = jsonDecode(response.body)["id"];
    }
    //print(response.body);
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
    startTimeZone = tempTimeZone;
    endTimeZone = tempTimeZone;
  }

  /**
   * Delete event from online and local calendar
   */
  Future<void> delete() async {
    String token = calendar.account.token;
    String calID = calendar.id;

    Uri uri = Uri.parse('https://graph.microsoft.com/v1.0/me/events/${id}');
    Response response = await Client().delete(uri, headers: {
      'Authorization': 'Bearer ${token}',
      'Content-Type': 'application/json'
    });

    if (response.statusCode != 204) {
      Fluttertoast.showToast(
        msg: "Error ${response.body}",
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Deleted event",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  /**
   * To Json from MicrosoftEvent
   *
   * note that color is turned into a string for conversion
   */
  @override
  Map<String, dynamic> toJson() {
    if (!isValid()) {
      throw Exception("Invalid Event to make into JSON");
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
      "color": color.toString(),
      "notes": notes,
      "recurrenceRule": recurrenceRule,
      "recurrenceExceptionDates": jsonEncode(recurrenceExceptionDates),

      "recurringEventData:": jsonEncode(tempMap),

      "eventsInDay":eventsInDay,
      "thisEventNumber":thisEventNumber,
      "startLocation":startLocation,
      "estimateInMinutes":estimateInMinutes,

      "backendId": backendId,
      /// TODO: Check this
    };
  }

  Map<String, dynamic> toMicrosoftJson() {
    if (!isValid()) {
      throw Exception("Invalid MicrosoftEvent to make into MicrosoftJson");
    }
    return {
      "start": {
        "dateTime": startTime.toIso8601String(),
        "timeZone": startTimeZone
      },
      "end": {"dateTime": endTime.toIso8601String(), "timeZone": endTimeZone},
      "subject": subject,
      "isAllDay": isAllDay,
      "id": id.toString(),
      // "location" : location, ///TODO: FIX LOCATION EDITING
      /// WHAT OTHER THINGS DO WE WANT TO BE EDITABLE?
      /// - -> THIS IS SPECIFICALLY USED FOR UPDATING
    };
  }

  bool equals(EventModel other) {
    if (other is MicrosoftEvent) {
      MicrosoftEvent event = other;

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
          recurrenceExceptionDates.toString() == event.recurrenceExceptionDates.toString() &&
          backendId == event.backendId) {
        return true;
      }
    }
    return false;
  }
}
