import 'package:timely/event_models/EventModel.dart';
import 'package:timely/models/calendar_model.dart';

class AppleCalendarModel extends CalendarModel {
  AppleCalendarModel(super.id, super.account);

  @override
  EventModel createEvent(DateTime start, DateTime end, String subject, bool isAllDay) {
    // TODO: implement createEvent
    throw UnimplementedError();
  }

  @override
  Future<Map<String, List<EventModel>>> update() async{
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Map toJson() {
    // List<Map> events = this.events.map((i) => i.toJson()).toList(); TODO: uncomment once EventModel has toJson method
    return {
      'id': id,
      'events': events
    };
  }

}