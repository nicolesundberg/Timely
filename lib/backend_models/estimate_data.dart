import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:timely/backend_models/weather.dart';
import 'package:timely/owm/owm_requester.dart';

import 'package:timely/controllers/location_controller.dart';
import 'location_data.dart';
import 'package:timely/event_models/EventModel.dart';
import 'event_data.dart';

class EstimateData {
  Weather? weather;
  int event_id;
  int nth_event_today;
  int number_events_today;
  LocationData? current_location;
  // int? parking_lot_id;
  DistanceData? distance_from_current_location_to_parking_lot;
  DistanceData? distance_from_parking_lot_to_event;

  EstimateData._private_constructor(this.weather, this.event_id, this.nth_event_today, this.number_events_today,
      this.current_location, this.distance_from_current_location_to_parking_lot,
      this.distance_from_parking_lot_to_event);

  static Future<EstimateData> fromEventId(int event_id, {LocationData? current_location, int? nthEvent, int? totalEvents}) async {
    OWMRequester requester = OWMRequester();
    LocationController locator = LocationController();

    // Maybe add weather data for event location too?
    current_location ??= await locator.currentLocation();
    Weather? weather = Weather.fromOWMCurrent(await requester.currentWeather(current_location.latitude, current_location.longitude));
    weather.addFromOWMForecast(await requester.forecastWeather(current_location.latitude, current_location.longitude));

    int nth_event_today = nthEvent ?? 0; // 1 for now, TODO: update based on calendar info
    int number_events_today = totalEvents ?? 0; // 1 for now, TODO: update based on calendar info
    // ParkingData? parking_lot = null; // null for now, TODO: maybe cut this
    DistanceData? distance_from_current_location_to_parking_lot = null; // null for now, TODO: maybe cut this
    DistanceData? distance_from_parking_lot_to_event = null;  // null for now, TODO: maybe cut this
    return EstimateData._private_constructor(weather, event_id, nth_event_today, number_events_today,
    current_location, distance_from_current_location_to_parking_lot, distance_from_parking_lot_to_event);
  }

  static Future<EstimateData> fromEventIdNewLocation(int event_id, LocationData current_location) async {
    OWMRequester requester = OWMRequester();

    // Maybe add weather data for event location too?
    Weather? weather = Weather.fromOWMCurrent(await requester.currentWeather(current_location.latitude, current_location.longitude));
    weather.addFromOWMForecast(await requester.forecastWeather(current_location.latitude, current_location.longitude));

    int nth_event_today = 1; // 1 for now, TODO: update based on calendar info
    int number_events_today = 1; // 1 for now, TODO: update based on calendar info
    // ParkingData? parking_lot = null; // null for now, TODO: maybe cut this
    DistanceData? distance_from_current_location_to_parking_lot = null; // null for now, TODO: maybe cut this
    DistanceData? distance_from_parking_lot_to_event = null;  // null for now, TODO: maybe cut this
    return EstimateData._private_constructor(weather, event_id, nth_event_today, number_events_today,
        current_location, distance_from_current_location_to_parking_lot, distance_from_parking_lot_to_event);
  }

  Future<String> postData() async {
    final response = await http.post(
      Uri.parse('http://dursteler.me:8000/api/get_estimate/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(this),
    );
    return response.body;
  }

  Map toJson() {
    Map? weather;
    if (this.weather != null) {
      weather = this.weather!.toJson();
    }
    Map? current_location;
    if (this.current_location != null) {
      current_location = this.current_location!.toJson();
    }
    Map? distance_from_current_location_to_parking_lot;
    if (this.distance_from_current_location_to_parking_lot != null) {
      distance_from_current_location_to_parking_lot = this.distance_from_current_location_to_parking_lot!.toJson();
    }
    Map? distance_from_parking_lot_to_event;
    if (this.distance_from_parking_lot_to_event != null) {
      distance_from_parking_lot_to_event = this.distance_from_parking_lot_to_event!.toJson();
    }
    return {
      'weather': weather,
      'event': event_id,
      'nth_event_today': nth_event_today,
      'number_events_today': number_events_today,
      'parking_lot' : null,
      'current_location': current_location,
      'distance_from_current_location_to_parking_lot': distance_from_current_location_to_parking_lot,
      'distance_from_parking_lot_to_event': distance_from_parking_lot_to_event
    };
  }

  void printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((RegExpMatch match) =>   print(match.group(0)));
  }
}