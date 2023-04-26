import 'package:timely/backend_models/double_precision.dart';
import 'package:units_converter/units_converter.dart';

enum LocationProvider {
  GMLA, // Google Maps Location API
  UNKN  // Unknown
}

class LocationData {
  LocationProvider provider;
  DateTime recorded_at;
  double latitude;
  double longitude;
  int? altitude_in_feet;
  String? street_number_long_name;
  String? street_number_short_name;
  String? street_long_name;
  String? street_short_name;
  String? city_long_name;
  String? city_short_name;
  String? county_long_name;
  String? county_short_name;
  String? state_long_name;
  String? state_short_name;
  String? country_long_name;
  String? country_short_name;
  String? zip_code_long_name;
  String? zip_code_short_name;

  LocationData(this.provider, this.recorded_at, this.latitude, this.longitude, this.altitude_in_feet,
      this.street_number_long_name, this.street_number_short_name, this.street_long_name, this.street_short_name,
      this.city_long_name, this.city_short_name, this.county_long_name, this.county_short_name, this.state_long_name,
      this.state_short_name, this.country_long_name, this.country_short_name, this.zip_code_long_name,
      this.zip_code_short_name);

  LocationData.fromCoordinates(this.latitude, this.longitude): recorded_at = DateTime.now(), provider = LocationProvider.UNKN;

  LocationData.fromProvider(this.provider, this.recorded_at, this.latitude, this.longitude);

  Map toJson() {
    String recorded_at = this.recorded_at.toIso8601String();
    String? street_number_long_name;
    if (this.street_number_long_name != null) {
      street_number_long_name = this.street_number_long_name!.substring(0, 30);
    }
    String? street_number_short_name;
    if (this.street_number_short_name != null) {
      street_number_short_name = this.street_number_short_name!.substring(0, 30);
    }
    String? street_long_name;
    if (this.street_long_name != null) {
      street_long_name = this.street_long_name!.substring(0, 50);
    }
    String? street_short_name;
    if (this.street_short_name != null) {
      street_short_name = this.street_short_name!.substring(0, 50);
    }
    String? city_long_name;
    if (this.city_long_name != null) {
      city_long_name = this.city_long_name!.substring(0, 50);
    }
    String? city_short_name;
    if (this.city_short_name != null) {
      city_short_name = this.city_short_name!.substring(0, 50);
    }
    String? county_long_name;
    if (this.county_long_name != null) {
      county_long_name = this.county_long_name!.substring(0, 50);
    }
    String? county_short_name;
    if (this.county_short_name != null) {
      county_short_name = this.county_short_name!.substring(0, 50);
    }
    String? state_long_name;
    if (this.state_long_name != null) {
      state_long_name = this.state_long_name!.substring(0, 30);
    }
    String? state_short_name;
    if (this.state_short_name != null) {
      state_short_name = this.state_short_name!.substring(0, 30);
    }
    String? country_long_name;
    if (this.country_long_name != null) {
      country_long_name = this.country_long_name!.substring(0, 30);
    }
    String? country_short_name;
    if (this.country_short_name != null) {
      country_short_name = this.country_short_name!.substring(0, 30);
    }
    String? zip_code_long_name;
    if (this.zip_code_long_name != null) {
      zip_code_long_name = this.zip_code_long_name!.substring(0, 20);
    }
    String? zip_code_short_name;
    if (this.zip_code_short_name != null) {
      zip_code_short_name = this.zip_code_short_name!.substring(0, 20);
    }
    return {
      "provider": provider.name,
      "recorded_at": recorded_at,
      "latitude": doublePrecision(latitude, 9, 6),
      "longitude": doublePrecision(longitude, 9, 6),
      "altitude_in_feet": altitude_in_feet,
      "street_number_long_name": street_number_long_name,
      "street_number_short_name": street_number_short_name,
      "street_long_name": street_long_name,
      "street_short_name": street_short_name,
      "city_long_name": city_long_name,
      "city_short_name": city_short_name,
      "county_long_name": county_long_name,
      "county_short_name": county_short_name,
      "state_long_name": state_long_name,
      "state_short_name": state_short_name,
      "country_long_name": country_long_name,
      "country_short_name": country_short_name,
      "zip_code_long_name": zip_code_long_name,
      "zip_code_short_name": zip_code_short_name
    };
  }
}

class DistanceData {
  double kilometers_as_bird_flies;
  List<RouteData> routes;

  DistanceData(this.kilometers_as_bird_flies): routes = <RouteData>[];

  Map toJson() {
    List<Map>? routes = this.routes.map((i) => i.toJson()).toList();
    return {
      "kilometers_as_bird_flies": doublePrecision(kilometers_as_bird_flies, 9, 4),
      "routes": routes
    };
  }
}

enum TravelMode {
  W,  // Walking
  T,  // Transit
  B,  // Biking
  D,  // Driving
  R,  // Ride-sharing
}

enum TravelTimeProvider {
  GM, // Google Maps
  AC, // Apple Maps with conditions
  AN, // Apple Maps without conditions
  UN  // Unknown
}

class RouteData {
  double? kilometers_based_on_route;
  int? travel_time_in_minutes;
  TravelTimeProvider travel_time_provider;
  DateTime travel_time_generated_at;
  DateTime? travel_time_generated_for;
  TravelMode? travel_time_travel_mode;

  RouteData(this.kilometers_based_on_route, this.travel_time_in_minutes, this.travel_time_provider,
      this.travel_time_generated_for, this.travel_time_travel_mode): travel_time_generated_at = DateTime.now();

  Map toJson() {
    double? kilometers_based_on_route;
    if (this.kilometers_based_on_route != null) {
      kilometers_based_on_route = doublePrecision(this.kilometers_based_on_route!, 9, 4);
    }
    String travel_time_generated_at = this.travel_time_generated_at.toIso8601String();
    String? travel_time_generated_for;
    if (this.travel_time_generated_for != null) {
      travel_time_generated_for = this.travel_time_generated_for!.toIso8601String();
    }
    String? travel_time_travel_mode;
    if (this.travel_time_travel_mode != null) {
      travel_time_travel_mode = this.travel_time_travel_mode!.name;
    }
    return {
      "kilometers_based_on_route": kilometers_based_on_route,
      "travel_time_in_seconds": travel_time_in_minutes,
      "travel_time_provider": travel_time_provider.name,
      "travel_time_generated_at": travel_time_generated_at,
      "travel_time_generated_for": travel_time_generated_for,
      "travel_time_travel_mode": travel_time_travel_mode
    };
  }
}
