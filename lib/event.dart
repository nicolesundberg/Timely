class GenericEvent {
  late String summary;
  late String location;
  late String description;
  late String timeZone;
  late String startTime;
  late String endTime;

  late int priority; //1-3 scale

  int _endHour = 0;
  int _endMinute = 0;
  bool _endAm = false;
  int _endDay = 0;
  int _endMonth = 0;
  int _endYear = 0;

  int _startHour = 0;
  int _startMinute = 0;
  bool _startAm = false;
  int _startDay = 0;
  int _startMonth = 0;
  int _startYear = 0;

  int _timeZone = 0;

  GenericEvent() {
    summary = "";
    location = "";
    description = "";
    timeZone = "";
    startTime = "";
    endTime = "";
    priority = 0;
  }

  void setPriority(int prio) {
    priority = prio;
  }

  int getPriority() {
    return priority;
  }

  void setEndTime(int hour, int minute, bool am, int month, int day, int year,
      int timeZone) {
    _endHour = hour;
    _endMinute = minute;
    _endAm = am;
    _endDay = day;
    _endMonth = month;
    _endYear = year;
    _timeZone = timeZone;
//$ date -u '+%Y-%m-%dT%H:%M:%SZ'
    endTime = "$year-$month-${day}T$hour:$minute:$timeZone";
  }

  String getEndTime() {
    return "$_endHour:$_endMinute";
  }

  String getEndDate() {
    return "$_endMonth/$_endDay/$_endYear";
  }

  void setStartTime(int hour, int minute, bool am, int month, int day, int year,
      int timeZone) {
    _startHour = hour;
    _startMinute = minute;
    _startAm = am;
    _startDay = day;
    _startMonth = month;
    _startYear = year;
    _timeZone = timeZone;
//$ date -u '+%Y-%m-%dT%H:%M:%SZ'
    startTime = "$year-$month-${day}T$hour:$minute:$timeZone";
  }

  String getStartTime() {
    return "$_startHour:$_startMinute";
  }

  String getStartDate() {
    return "$_startMonth/$_startDay/$_startYear";
  }
}
