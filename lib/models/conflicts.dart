// import "package:timely/shared/event_model_classes/event_model.dart";


import '../event_models/EventModel.dart';

class Conflicts {
  final List<EventModel> events;
  List<EventModel> conflicts;
  DateTime lastUpdate;

  Conflicts(this.events)
      : conflicts = <EventModel>[],
        lastUpdate = DateTime.now() {
    updateConflicts();
  }

  bool _isEventUseful(EventModel e) {
    return e.startTime != null
        && e.endTime != null
        && e.endTime.isAfter(DateTime.now());
  }

  void updateConflicts() {
    print(events.where(_isEventUseful).map((e) => e.startTime));
    List<EventModel> futureEvents= events.where(_isEventUseful).toList();
    //TODO: Replace this with a.start.dateTime.compareTo(b.start.dateTime) once
    //      we make it so that start and dateTime aren't nullable.
    futureEvents.sort((a, b) => a.startTime!.compareTo(b.startTime!));
  }
}