import 'dart:convert';

import 'package:http/http.dart' as http;

import 'location_data.dart';

// TODO: Implement Parking Data in Beta
// Not originally planned until end of beta
class ParkingData {
  String polygon;
  LocationData? parking_lot_location;
  String? name;

  ParkingData(this.polygon, this.parking_lot_location, this.name);

  Future<String> postData() async {
    final response = await http.post(
      Uri.parse('http://dursteler.me:8000/api/parking_lot/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(this),
    );
    return response.body;
  }

  Map toJson() => {
    'polygon': polygon,
    'parking_lot_location': parking_lot_location,
    'name': name
  };
}