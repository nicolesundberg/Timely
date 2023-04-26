/**
 * Class to hold all relevant information concerning recurring events
 *
 * backendId -- holds backend ID for this recurrence
 * startLocation -- string of where we expect the user to start traveling from (this is used in UI so it has to be good)
 * estimateInMinutes -- double estimate in minutes from expected start location for the reminder to occur
 * date -- date of the occurence this event is for (startTime)
 * eventsInDay -- how many events are in that day
 * thisEventNumber -- which number event this is in the day
 */
class RecurringEventData {
  int? backendId;
  String? startLocation;
  double? estimateInMinutes;
  DateTime? date;
  int? eventsInDay;
  int? thisEventNumber;

  RecurringEventData({this.backendId, String? start, this.estimateInMinutes, required this.date,
              int? totalEvents, int? thisEvent})
  {
    eventsInDay ??= totalEvents;
    thisEventNumber ??= thisEvent;
    startLocation ??= start;

  }

  Map<String,dynamic> toJson() {
    return {
      "backendId":backendId,
      "startLocation":startLocation,
      "estimateInMinutes":estimateInMinutes,
      "date":date?.toIso8601String(),
      "eventsInDay":eventsInDay,
      "thisEventNumber":thisEventNumber,
    };
  }

  RecurringEventData.fromJson(Map<String,dynamic> json)
  {
    backendId = json["backendId"];
    startLocation = json["startLocation"];
    estimateInMinutes = json["estimateInMinutes"];
    date = DateTime.parse(json["date"]);
    eventsInDay = json["eventsInDay"];
    thisEventNumber = json["thisEventNumber"];
  }


}