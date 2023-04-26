

import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timely/event_models/recurring_event_data.dart';

import '../backend_models/arrival_data.dart';
import '../backend_models/estimate_data.dart';
import '../backend_models/event_data.dart';
import '../backend_models/location_data.dart' as loc;
import '../backend_models/location_data.dart';
import '../models/calendar_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../shared/maps.dart';

abstract class EventModel extends Appointment{
  int? backendId;

  int? eventsInDay;
  int? thisEventNumber;
  String? startLocation;
  double? estimateInMinutes;


  /**
   * EventModel Abstract Class Constructor method:
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
   */
  EventModel({required super.startTime, required super.endTime,
    required super.subject, required super.isAllDay, required this.calendar,
     super.color,  super.location,  super.notes,
     super.recurrenceRule,  super.id="",  super.recurrenceExceptionDates,
     super.startTimeZone,  super.endTimeZone});


  //inherited fields
  /*
    appoihtmentType (changedOccurence, normal, occurence, pattern)
    Color color
    Datetime endTime
    String? endTimeZone
    int hashCode
    Object? id
    bool isAllDay
    String? location
    String? notes
    List<DateTime>? recurrenceExceptinoDates
    Object? reccurenceId
    String? recurrenceRule
    List<Object>? resourceIds
    Type runtimeType
    DateTime startTime
    String? startTimeZone
    String subjecte

   */

/*
REQUIRED -- appointmentType, color, endTime, isAllDay, startTime, subject
 */

//TODO: add reference to CalendarClass (abstract)
  //calendarId must be set here or EventModel gets upset about calendarId
  // not being initialized, even though it's required
  CalendarModel calendar;

  //Recurring Event Data (nullable, only used if recurrence rule is not null)
  Map<String, RecurringEventData>? recurringData;

  /**
   * Validates new datetimes, name, and location then saves new event data
   */
  Future<void> update({String name, DateTime newStart, DateTime newEnd, String newLocation});

  /**
   * Add or update event based on if event id exists
   */
  Future<void> save();

  /**
   * Delete event from online and local calendar
   */
  Future<void> delete();

  Future<List<ArrivalData>> getArrivalDataFromBackend() async {
    if (backendId == null) {
      return <ArrivalData>[];
    }
    final response = await http.get(
      Uri.parse('http://dursteler.me:8000/api/get_arrival_data_by_event_id/$backendId/'),
    );
    return jsonDecode(response.body)
        .map((element) => ArrivalData.fromJson(element))
        .toList<ArrivalData>();
  }

  /**
   * Get time Estimate data if it exists, update it otherwise
   */
  Future<void> getTimeEstimate({required String startAdd, required LocationData? startLoc, DateTime? recurrenceDate,
                    int? totalEvents, int? thisEvent})
  async {

    if(recurrenceDate != null && recurringData != null && recurringData![recurrenceDate.toString()]?.estimateInMinutes != null) {
      //update totalEvents and this Event
      if(thisEvent != null) {
        recurringData![recurrenceDate.toString()]?.thisEventNumber = thisEvent;
      }
      if(totalEvents != null) {
        recurringData![recurrenceDate.toString()]?.eventsInDay = totalEvents;
      }
      return;
    }
    if(recurrenceDate == null && estimateInMinutes != null) {
      if(thisEvent != null) {
        thisEventNumber = thisEvent;
      }
      if(totalEvents != null) {
        eventsInDay = totalEvents;
      }
      return;
    }

    //otherwise grab the stuff

    await updateTimeEstimate(startAdd: startAdd, startLoc: startLoc, recurrenceDate: recurrenceDate,
        totalEvents: totalEvents, thisEvent: thisEvent);
  }


  /**
   * Set time Estimate data
   */

  Future<void> updateTimeEstimate({required String startAdd, required LocationData? startLoc, DateTime? recurrenceDate,
    int? totalEvents, int? thisEvent})
  async {

    if(startLoc == null) {
      throw Exception("invalid start location for appointment $subject");
    }

    loc.LocationData? endLoc = await AppleMaps.fetchGeocode(location ?? "");
    //if this isn't a valid location, just return false
    if(endLoc == null) {
      print("invalid location data");
      return;
    }
    int bID = 0;
    RecurringEventData? appointmentData;
    if(recurrenceDate != null)
    {
      //Map<DateTime, RecurringEventData>? recurringData
      recurringData ??= {};
      printRecurrences();
      print("adding recurrence: ${recurrenceDate.toString()}");
      if(recurringData![recurrenceDate.toString()] == null ||
          recurringData![recurrenceDate.toString()]?.backendId == null)
      {
        DateTime d = recurrenceDate;
        appointmentData =
            RecurringEventData(date: recurrenceDate, start: startAdd,
                totalEvents: totalEvents, thisEvent: thisEvent);
        recurringData![d.toString()] = appointmentData;
        EventData data = await EventData.fromEventModel(this);
        appointmentData.backendId = int.parse(await data.postData());
        print(appointmentData.backendId ?? "no id exists");
        bID = appointmentData.backendId ?? 0;
      }
      else
      {
        appointmentData = recurringData![recurrenceDate.toString()];
        bID = recurringData![recurrenceDate.toString()]?.backendId ?? 0;
      }
    }
    else
    {
      //we're not dealing with a recurrence appointment, can save all data here
      eventsInDay = totalEvents;
      thisEventNumber = thisEvent;
      startLocation = startAdd;
      EventData data = await EventData.fromEventModel(this);
      backendId ??= int.parse(await data.postData());
      bID = backendId ?? 0;
    }
    log("backendId = ${bID}", name:"setDayEventInfo->EventModel");

    EstimateData estimateData = await EstimateData.fromEventId(bID, current_location:startLoc!,
      nthEvent: thisEvent, totalEvents: eventsInDay);

    loc.DistanceData dist = loc.DistanceData(Geolocator.distanceBetween(
      startLoc!.latitude,
      startLoc!.longitude,
      endLoc!.latitude,
      endLoc!.longitude,
    )/1000  //turn m into km
    );

    final result = await AppleMaps().fetchETA(
        currentPos: loc.LocationData.fromCoordinates(startLoc?.latitude ?? 0, startLoc?.longitude ?? 0),
        destination: location??"");

    final travelTime = result!['etas'][0]['expectedTravelTimeSeconds'].toString();
    final convertedTime = int.parse(travelTime);

    loc.RouteData route = loc.RouteData(double.parse(result!['etas'][0]['distanceMeters'].toString())/1000,
        convertedTime, loc.TravelTimeProvider.AN, null, loc.TravelMode.D);

    dist.routes.add(route);
    estimateData.distance_from_current_location_to_parking_lot = dist;

    String estimateResponse = await estimateData.postData();
    log("estimateResponse = ${estimateResponse}", name:"setDayEventInfo->EventModel");
    double estimatedTime = double.parse(estimateResponse)/60;
    log("estimatedTime = ${estimatedTime}", name:"setDayEventInfo->EventModel");

    if(appointmentData != null)
    {
      appointmentData.startLocation = startAdd;
      appointmentData.estimateInMinutes = estimatedTime;
    }
    else
    {
      log("set estimatedTime = ${estimatedTime}", name:"setDayEventInfo->EventModel");
      estimateInMinutes = estimatedTime;
      startLocation = startAdd;
    }
    return;
  }



  void printRecurrences()
  {
    if(recurringData == null || (recurringData?.values?.isEmpty ?? true))
      {
       print("no data in recurringData");
      }
    recurringData?.forEach((key, value) {
      print("$key \t\t ${value.toJson().toString()}");
    });
  }


// EventModel.fromJson(Map<String, dynamic> json) : calendarId=null, super(endTime: DateTime.now(), startTime: DateTime.now(),
//     subject: " ", isAllDay: false);

  Map<String, dynamic> toJson();

  bool isValid() {

    return _isValidTimeZone(startTimeZone)
        && _isValidTimeZone(endTimeZone)
        && isValidRecurrenceRule(recurrenceRule);
  }

  static bool _isValidTimeZone(String? zone) {
    if (zone == null) {
      return true;
    }
    return validTimeZone.contains(zone);
  }

  static bool isValidRecurrenceRule(String? recurrenceRule) {
    if (recurrenceRule == null || recurrenceRule == "") {
      return true;
    }
    //https://www.rfc-editor.org/rfc/rfc5545#section-3.8.5
    //BUT BETTER:
    //https://www.syncfusion.com/kb/3719/what-is-recurrencerule-in-the-schedule-control

    //now check all fields are correct
    recurrenceRule = recurrenceRule.replaceAll(' ', '');
    if(recurrenceRule.startsWith('RRULE:'))
      {
        recurrenceRule = recurrenceRule.replaceAll('RRULE:', '');
      }
    try {
      Map<String, List<String>> data = _tokenizeRecurrence(recurrenceRule);
      return validateRecurrenceFields(data);
    } catch(e) {
      return false;
    }
  }

  static Map<String, List<String>> _tokenizeRecurrence(String recurrenceRule)
  {
    //TODO: Fails on an empty string ("")
    List<String> parts = recurrenceRule.split(';');

    //add all portions into a recurrence map for parsing
    Map<String, List<String>> recurrence = {};
    for(String part in parts)
    {
      List<String> data = part.split("=");
      if(data[0] == "TZID")
        {
          continue;
        }
      if(data.length != 2) {
        if(data.length == 1 && data[0] == "EXDATE")
          {
            continue;
          }
        throw const FormatException('invalid token in recurrenceRule');
      }
      recurrence[data[0]] = data[1].split(',');
    }
    return recurrence;
  }

  static bool validateRecurrenceFields(Map<String, List<String>> data)
  {
    for(String key in data.keys)
    {
      switch(key) {
        case "FREQ": {
          if(data[key]?.length != 1)
          {
            print("INVALID FREQ");
            return false;
          }
          String val = data[key]![0];
          if(val != "DAILY" && val != "WEEKLY" && val != "MONTHLY" && val != "YEARLY")
          {
            print("INVALID FREQ");
            return false;
          }
          if(val == "WEEKLY" && data["BYDAY"] == null)
            {
              return false;
            }
        }
        break;
        case "INTERVAL": {
          if(!validateStringToPosInt(data[key] ?? []))
          {
            print("INVALID INTERVAL");
            return false;
          }
        }
        break;
        case "COUNT": {
          if(!validateStringToPosInt(data[key] ?? []))
          {
            print("INVALID COUNT");
            return false;
          }
        }
        break;
        case "UNTIL": {
          List<String> fieldData = data[key] ?? [];
          for(String date in fieldData)
            {
              if(!validateRecurrenceDate(date))
                {
                  return false;
                }
            }

        }
        break;
        case "BYDAY": {
          List<String> fieldData = data[key] ?? [];
          for(String day in fieldData)
          {
            if(!validateWeekDay(day))
            {
              return false;
            }
          }
        }
        break;
        case "BYMONTHDAY": {
          if(!validateStringToPosInt(data[key] ?? []))
            {
              return false;
            }
          //now we know that it can be parsed correctly
          int day = int.parse(data[key]![0]);
          if(day < 1 || day > 31)
          {
            return false;
          }
        }
        break;
        case "BYMONTH": {
          if(!validateStringToPosInt(data[key] ?? []))
          {
            return false;
          }
          //now we know that it can be parsed correctly
          int month = int.parse(data[key]![0]);
          if(month < 1 || month > 12)
            {
              return false;
            }
        }
        break;
        case "BYSETPOS": {
          if(!validateStringToPosInt(data[key] ?? []))
          {
            return false;
          }
        }
        break;
        case "WKST": {
          if(data[key]!.length != 1)
            {
              return false;
            }
          if(!validateWeekDay(data[key]![0] ?? ""))
            {
              return false;
            }
        }
        break;
        case "EXDATE": {
          List<String> fieldData = data[key] ?? [];
          for(String date in fieldData)
          {
            if(!validateRecurrenceDate(date))
            {
              return false;
            }
          }
        }
        break;
        case "RECUREDITID": {
          if(!validateStringToPosInt(data[key] ?? []))
            {
              return false;
            }
        }
        break;
        default: { ///INVALID DATA FIELD IN RECURRENCE STRING
          return false;
        }

      }
    }
    return true;
  }


  static bool validateWeekDay(String day)
  {
    if(day != "MO" && day != "TU" && day != "WE" && day != "TH"
        && day != "FR" && day != "SA" && day != "SU")
      {
        return false;
      }
    return true;
  }

  /**
   * Takes in a list of Strings, validates that only one string is in the list and the string can be parsed to a positive number
   */
  static bool validateStringToPosInt(List<String> nums)
  {
    ///ENSURE LENGTH OF LIST IS 1 --> ONLY ONE STRING AVAILABLE
    if(nums.length != 1)
    {
      return false;
    }

    ///ENSURE STRING AVAILABLE IS A POSITIVE NUMBER
    String num = nums[0];
    int dataAsInt = int.tryParse(num) ?? -1;
    if(dataAsInt > 0)
    {
      return true;
    }
    else
    {
      return false;
    }
  }


  /**
      Takes in dates in recurrence format (month/day/year) and determines if they're valid
   */
  static bool validateRecurrenceDate(String date)
  {
    DateTime? attempt1 = DateTime.tryParse(date);
    if(attempt1 != null)
      {
        return true;
      }
    List<String> dateParts = date.split('/');
    if(dateParts.length != 3)
      {
        return false;
      }
    int month = int.tryParse(dateParts[0]) ?? -1;
    int day = int.tryParse(dateParts[1]) ?? -1;
    int year = int.tryParse(dateParts[2]) ?? -1;
    ///Throw exception in case of parse issues
    if(month == -1)
    {
      return false;
    }
    else if(day == -1)
    {
      return false;
    }
    else if(year == -1)
    {
      return false;
    }

    ///build new string
    String newDateFormat = "";
    newDateFormat += year.toString();
    if(month < 10)
    {
      newDateFormat += "-0$month";
    }
    else
    {
      newDateFormat += "-$month";
    }
    if(day < 10)
    {
      newDateFormat += "-0$day";
    }
    else
    {
      newDateFormat += "-$day";
    }
    DateTime? testDate = DateTime.tryParse(newDateFormat);
    if(testDate == null)
      {
        return false;
      }
    else
      {
        return true;
      }

  }

  static final List<String> validTimeZone = ["Samoa Standard Time", "Pacific/Apia", "UTC - 13:00", "Dateline Standard Time", "Etc/GMT+12", "UTC - 12:00", "UTC-11", "Pacific/Midway", "UTC - 11:00", "Hawaiian Standard Time", "Pacific/Honolulu", "UTC - 10:00", "Alaskan Standard Time", "America/Anchorage", "UTC - 09:00", "Pacific Standard Time", "America/Los_Angeles", "UTC - 08:00", "Pacific Standard Time (Mexico)", "America/Santa_Isabel", "UTC - 08:00", "Mountain Standard Time", "America/Denver", "UTC - 07:00", "Mountain Standard Time (Mexico)", "America/Chihuahua", "UTC - 07:00", "US Mountain Standard Time", "America/Phoenix", "UTC - 07:00", "Canada Central Standard Time", "America/Regina", "UTC - 06:00", "Central America Standard Time", "America/Guatemala", "UTC - 06:00", "Central Standard Time", "America/Chicago", "UTC - 06:00", "Eastern Standard Time", "America/New_York", "UTC - 05:00", "SA Pacific Standard Time", "America/Bogota", "UTC - 05:00", "US Eastern Standard Time", "America/Indianapolis", "UTC - 05:00", "Venezuela Standard Time", "America/Caracas", "UTC - 04:30", "Atlantic Standard Time", "America/Halifax", "UTC - 04:00", "Central Brazilian Standard Time", "America/Cuiaba", "UTC - 04:00", "Pacific SA Standard Time", "America/Santiago", "UTC - 04:00", "Paraguay Standard Time", "America/Asuncion", "UTC - 04:00", "SA Western Standard Time", "America/La_Paz", "UTC - 04:00", "Newfoundland Standard Time", "America/St_Johns", "UTC - 03:30", "Bahia Standard Time", "America/Bahia", "UTC - 03:00", "Argentina Standard Time", "America/Buenos_Aires", "UTC - 03:00", "E. South America Standard Time", "America/Sao_Paulo", "UTC - 03:00", "Greenland Standard Time", "America/Godthab", "UTC - 03:00", "Montevideo Standard Time", "America/Montevideo", "UTC - 03:00", "SA Eastern Standard Time", "America/Cayenne", "UTC - 03:00", "UTC-02", "America/Noronha", "UTC - 02:00", "Azores Standard Time", "Atlantic/Azores", "UTC - 01:00", "Cape Verde Standard Time", "Atlantic/Cape_Verde", "UTC - 01:00", "GMT Standard Time", "Europe/London", "UTC", "Greenwich Standard Time", "Atlantic/Reykjavik", "UTC", "Morocco Standard Time", "Africa/Casablanca", "UTC", "UTC", "America/Danmarkshavn", "UTC", "Central Europe Standard Time", "Europe/Budapest", "UTC + 01:00", "Central European Standard Time", "Europe/Warsaw", "UTC + 01:00", "Namibia Standard Time", "Africa/Windhoek", "UTC + 01:00", "Romance Standard Time", "Europe/Paris", "UTC + 01:00", "W. Central Africa Standard Time", "Africa/Lagos", "UTC + 01:00", "W. Europe Standard Time", "Europe/Berlin", "UTC + 01:00", "Egypt Standard Time", "Africa/Cairo", "UTC + 02:00", "FLE Standard Time", "Europe/Kiev", "UTC + 02:00", "GTB Standard Time", "Europe/Bucharest", "UTC + 02:00", "Israel Standard Time", "Asia/Jerusalem", "UTC + 02:00", "Libya Standard Time", "Africa/Tripoli", "UTC + 02:00", "Middle East Standard Time", "Asia/Beirut", "UTC + 02:00", "South Africa Standard Time", "Africa/Johannesburg", "UTC + 02:00", "Syria Standard Time", "Asia/Damascus", "UTC + 02:00", "Turkey Standard Time", "Europe/Istanbul", "UTC + 02:00", "Arab Standard Time", "Asia/Riyadh", "UTC + 03:00", "Arabic Standard Time", "Asia/Baghdad", "UTC + 03:00", "Belarus Standard Time", "Europe/Minsk", "UTC + 03:00", "E. Africa Standard Time", "Africa/Nairobi", "UTC + 03:00", "Jordan Standard Time", "Asia/Amman", "UTC + 03:00", "Kaliningrad Standard Time", "Europe/Kaliningrad", "UTC + 03:00", "Iran Standard Time", "Asia/Tehran", "UTC + 03:30", "Arabian Standard Time", "Etc/GMT-4", "UTC + 04:00", "Azerbaijan Standard Time", "Asia/Baku", "UTC + 04:00", "Caucasus Standard Time", "Asia/Yerevan", "UTC + 04:00", "Georgian Standard Time", "Asia/Tbilisi", "UTC + 04:00", "Mauritius Standard Time", "Indian/Mauritius", "UTC + 04:00", "Russia Time Zone 3", "Europe/Samara", "UTC + 04:00", "Russian Standard Time", "Europe/Moscow", "UTC + 04:00", "Afghanistan Standard Time", "Asia/Kabul", "UTC + 04:30", "Pakistan Standard Time", "Asia/Karachi", "UTC + 05:00", "West Asia Standard Time", "Asia/Tashkent", "UTC + 05:00", "India Standard Time", "Asia/Calcutta", "UTC + 05:30", "Sri Lanka Standard Time", "Asia/Colombo", "UTC + 05:30", "Nepal Standard Time", "Asia/Kathmandu", "UTC + 05:45", "Bangladesh Standard Time", "Asia/Dhaka", "UTC + 06:00", "Central Asia Standard Time", "Asia/Almaty", "UTC + 06:00", "Ekaterinburg Standard Time", "Asia/Yekaterinburg", "UTC + 06:00", "Myanmar Standard Time", "Asia/Rangoon", "UTC + 06:30", "SE Asia Standard Time", "Asia/Bangkok", "UTC + 07:00", "N. Central Asia Standard Time", "Asia/Novosibirsk", "UTC + 07:00", "China Standard Time", "Asia/Shanghai", "UTC + 08:00", "North Asia Standard Time", "Asia/Krasnoyarsk", "UTC + 08:00", "Singapore Standard Time", "Asia/Singapore", "UTC + 08:00", "Taipei Standard Time", "Asia/Taipei", "UTC + 08:00", "Ulaanbaatar Standard Time", "Asia/Ulaanbaatar", "UTC + 08:00", "W. Australia Standard Time", "Australia/Perth", "UTC + 08:00", "Korea Standard Time", "Asia/Seoul", "UTC + 09:00", "North Asia East Standard Time", "Asia/Irkutsk", "UTC + 09:00", "Tokyo Standard Time", "Asia/Tokyo", "UTC + 09:00", "AUS Central Standard Time", "Australia/Darwin", "UTC + 09:30", "Cen. Australia Standard Time", "Australia/Adelaide", "UTC + 09:30", "AUS Eastern Standard Time", "Australia/Sydney", "UTC + 10:00", "E. Australia Standard Time", "Australia/Brisbane", "UTC + 10:00", "Tasmania Standard Time", "Australia/Hobart", "UTC + 10:00", "West Pacific Standard Time", "Pacific/Port Moresby", "UTC + 10:00", "Yakutsk Standard Time", "Asia/Yakutsk", "UTC + 10:00", "Central Pacific Standard Time", "Pacific/Guadalcanal", "UTC + 11:00", "Russia Time Zone 10", "Asia/Srednekolymsk", "UTC + 11:00", "Vladivostok Standard Time", "Asia/Vladivostok", "UTC + 11:00", "Fiji Standard Time", "Pacific/Fiji", "UTC + 12:00", "Magadan Standard Time", "Asia/Magadan", "UTC + 12:00", "New Zealand Standard Time", "Pacific/Auckland", "UTC + 12:00", "Russia Time Zone 11", "Asia/Kamchatka", "UTC + 12:00", "UTC+12", "Pacific/Tarawa", "UTC + 12:00", "Tonga Standard Time", "Pacific/Tongatapu", "UTC + 13:00", "Line Islands Standard Time", "Pacific/Kiritimati", "UTC + 14:00"];
}