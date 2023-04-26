import 'dart:convert';

import 'package:http/http.dart' as http;

import 'location_data.dart';

class ArrivalData {
  int event_id = 0;
  int? user_reported_minutes_early_to_event;
  DateTime? when_user_received_notification;
  TravelMode? user_travel_mode;
  DateTime? when_user_began_navigation;
  DateTime? when_user_departed;
  DateTime? when_user_arrived_at_parking_lot;
  DateTime? when_user_parked;
  DateTime? when_user_began_navigation_from_parking_lot;
  DateTime? when_user_arrived_at_event;
  LocationData? parking_location;

  ArrivalData.params(
      {required int backendId,
      int? minutesEarly,
      DateTime? notificationReceived,
      TravelMode? travelMode,
      DateTime? navigationBegins,
      DateTime? userDeparts,
      DateTime? userArrivesAtLot,
      DateTime? userParks,
      DateTime? parkingNavigationBegins,
      DateTime? userArrivesAtEvent,
      LocationData? parkingLocation}) {
    when_user_arrived_at_event = userArrivesAtEvent;
    when_user_arrived_at_parking_lot = userArrivesAtLot;
    when_user_began_navigation = navigationBegins;
    when_user_began_navigation_from_parking_lot = parkingNavigationBegins;
    when_user_departed = userDeparts;
    when_user_parked = userParks;
    when_user_received_notification = notificationReceived;
    parking_location = parkingLocation;
    user_reported_minutes_early_to_event = minutesEarly;
    user_travel_mode = travelMode;
    event_id = backendId;
  }

  ArrivalData(
      this.event_id,
      this.user_reported_minutes_early_to_event,
      this.when_user_received_notification,
      this.user_travel_mode,
      this.when_user_began_navigation,
      this.when_user_departed,
      this.when_user_arrived_at_parking_lot,
      this.when_user_parked,
      this.when_user_began_navigation_from_parking_lot,
      this.when_user_arrived_at_event,
      this.parking_location);

  Future<String> postData() async {
    final response = await http.post(
      Uri.parse('http://dursteler.me:8000/api/arrival_data/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(toJson()),
    );
    return response.body;
  }

  Map<String, dynamic> toJson() => {
        'event': event_id,
        'user_reported_minutes_early_to_event':
            user_reported_minutes_early_to_event.toString(),
        'when_user_received_notification':
            when_user_received_notification?.toIso8601String(),
        'user_travel_mode': user_travel_mode?.name ?? "driving",
        'when_user_began_navigation':
            when_user_began_navigation?.toIso8601String(),
        'when_user_departed': when_user_departed?.toIso8601String(),
        'when_user_arrived_at_parking_lot':
            when_user_arrived_at_parking_lot?.toIso8601String(),
        'when_user_parked': when_user_parked?.toIso8601String(),
        'when_user_began_navigation_from_parking_lot':
            when_user_began_navigation_from_parking_lot?.toIso8601String(),
        'when_user_arrived_at_event':
            when_user_arrived_at_event?.toIso8601String(),
        'parking_location': null
      };

  factory ArrivalData.fromJson(Map<String, dynamic> json) => ArrivalData(
      int.parse(json["event"]),
      int.tryParse(json["user_reported_minutes_early_to_event"] ?? ""),
      DateTime.tryParse(json["when_user_received_notification"] ?? ""),
      TravelMode.values.firstWhere((e) => e.name == json["user_travel_mode"]),
      DateTime.tryParse(json["when_user_began_navigation"] ?? ""),
      DateTime.tryParse(json["when_user_departed"] ?? ""),
      DateTime.tryParse(json["when_user_arrived_at_parking_lot"] ?? ""),
      DateTime.tryParse(json["when_user_parked"] ?? ""),
      DateTime.tryParse(
          json["when_user_began_navigation_from_parking_lot"] ?? ""),
      DateTime.tryParse(json["when_user_arrived_at_event"] ?? ""),
      null //TODO: Add location data for parking_location if we ever implement that
      );
}
