import 'package:timely/owm/owm_current_weather.dart';
import 'package:timely/owm/owm_dependencies.dart';
import 'package:timely/owm/owm_forecast_weather.dart';

import 'double_precision.dart';

/// Represents the Weather data as expected by the backend API
///
/// Can be created from an OWMCurrentWeather object
/// Easily translated to a JSON representation for posting to backend
class Weather {
  List<WeatherData> current_data_set = <WeatherData>[];
  List<WeatherData> forecast_data_set = <WeatherData>[];

  Weather(this.current_data_set, this.forecast_data_set);

  Weather.fromOWMCurrent(OWMCurrentWeather current) {
    WeatherData weather = WeatherData.fromOWMCurrent(current);
    current_data_set.add(weather);
  }

  Weather.fromOWMForecast(OWMForecastWeather forecast) {
    List<WeatherData> weather_list = WeatherData.fromOWMForecast(forecast);
    for(WeatherData weather in weather_list) {
      forecast_data_set.add(weather);
    }
  }

  void addFromOWMCurrent(OWMCurrentWeather current) {
    WeatherData weather = WeatherData.fromOWMCurrent(current);
    current_data_set.add(weather);
  }

  void addFromOWMForecast(OWMForecastWeather forecast) {
    List<WeatherData> weather_list = WeatherData.fromOWMForecast(forecast);
    for(WeatherData weather in weather_list) {
      forecast_data_set.add(weather);
    }
  }

  Map toJson() {
    List<Map>? weather_data_set = this.current_data_set.map((i) => i.toJson()).toList();
    List<Map>? temp_set = this.forecast_data_set.map((i) => i.toJson()).toList();
    for(Map map in temp_set) {
      weather_data_set.add(map);
    }
    return {
      'weather_data_set': weather_data_set
    };
  }
}

enum WeatherProvider {
  OWM,  // Open Weather Maps
  APP,  // Apple
  UNKN  // Unknown
}

enum WeatherDataType {
  OWM200, // Thunderstorm with light rain
  OWM201, // Thunderstorm with rain
  OWM202, // Thunderstorm with heavy rain
  OWM210, // Light thunderstorm
  OWM211, // Thunderstorm
  OWM212, // Heavy thunderstorm
  OWM221, // Ragged thunderstorm
  OWM230, // Thunderstorm with light drizzle
  OWM231, // Thunderstorm with drizzle
  OWM232, // Thunderstorm with heavy drizzle

  OWM300, // Light intensity drizzle
  OWM301, // Drizzle
  OWM302, // Heavy intensity drizzle
  OWM310, // Light intensity drizzle rain
  OWM311, // Drizzle rain
  OWM312, // Heavy intensity drizzle rain
  OWM313, // Shower rain and drizzle
  OWM314, // Heavy shower rain and drizzle
  OWM321, // Shower drizzle

  OWM500, // Light rain
  OWM501, // Moderate rain
  OWM502, // Heavy intensity rain
  OWM503, // Very heavy rain
  OWM504, // Extreme rain
  OWM511, // Freezing rain
  OWM520, // Light intensity shower rain
  OWM521, // Shower rain
  OWM522, // Heavy intensity shower rain
  OWM531, // Ragged shower rain

  OWM600, // Light snow
  OWM601, // Snow
  OWM602, // Heavy snow
  OWM611, // Sleet
  OWM612, // Light shower sleet
  OWM613, // Shower sleet
  OWM615, // Light rain and snow
  OWM616, // Rain and snow
  OWM620, // Light shower snow
  OWM621, // Shower snow
  OWM622, // Heavy shower snow

  OWM701, // Mist
  OWM711, // Smoke
  OWM721, // Haze
  OWM731, // Sand/dust whirls
  OWM741, // Fog
  OWM751, // Sand
  OWM761, // Dust
  OWM762, // Volcanic Ash
  OWM771, // Squalls
  OWM781, // Tornado

  OWM800, // Clear sky
  OWM801, // Few clouds: 11-25%
  OWM802, // Scattered clouds: 25-50%
  OWM803, // Broken clouds: 51-84%
  OWM804  // Overcast clouds: 85-100%
}

enum WeatherDataPredictionType {
  MP, // Minutely Prediction
  HP, // Hourly Prediction
  DP, // Daily Prediction
  MH, // Minutely Historical
  HH, // Hourly Historical
  DH, // Daily Historical
  C   // Current
}

class WeatherData {
  static const ONE_HR_IN_SECONDS = 60 * 60;
  static const THREE_HR_IN_SECONDS = 60 * 60;

  DateTime recorded_at;
  WeatherProvider provider;

  WeatherDataType? weather_type;

  WeatherDataPredictionType prediction_type;
  DateTime prediction_time_for;

  double latitude;
  double longitude;

  double temperature_min_celsius;
  double temperature_max_celsius;

  double? wind_speed;
  double? wind_direction_in_degrees;
  double? wind_speed_gusts;

  int? visibility_in_meters;
  double? cloudiness_in_percentage;
  double? humidity_in_percentage;
  double? atmospheric_pressure_hPa;

  double? percent_chance_of_rain;
  double? percent_chance_of_snow;

  List<PrecipitationData> precipitation_volume_set;

  WeatherData(this.recorded_at, this.provider, this.weather_type,
      this.prediction_type, this.prediction_time_for, this.latitude,
      this.longitude, this.temperature_min_celsius, this.temperature_max_celsius,
      this.wind_speed, this.wind_direction_in_degrees, this.wind_speed_gusts,
      this.visibility_in_meters, this.cloudiness_in_percentage,
      this.humidity_in_percentage, this.atmospheric_pressure_hPa,
      this.percent_chance_of_rain, this.percent_chance_of_snow,
      this.precipitation_volume_set);

  static WeatherData fromOWMCurrent(OWMCurrentWeather current) {
    DateTime recorded_at = current.recorded_at;
    WeatherProvider provider = WeatherProvider.OWM;
    WeatherDataType? weather_type;
    if (current.weather != null) {
      if (current.weather!.isNotEmpty) {
        weather_type = WeatherDataType.values.firstWhere((element) => element.name.contains(provider.name + current.weather![0].id.toString()));
      }
    }
    double latitude = current.coord.lat;
    double longitude = current.coord.lon;
    double temperature_min_celsius = current.main.temp;
    if (current.main.temp_min != null) {
      temperature_min_celsius = current.main.temp_min!;
    }
    double temperature_max_celsius = current.main.temp;
    if (current.main.temp_max != null) {
      temperature_max_celsius = current.main.temp_max!;
    }
    double? wind_speed;
    double? wind_direction_in_degrees;
    double? wind_speed_gusts;
    if (current.wind != null) {
      if (current.wind!.speed != null) {
        wind_speed = current.wind!.speed;
      }
      if (current.wind!.deg != null) {
        wind_direction_in_degrees = current.wind!.deg;
      }
      if (current.wind!.gust != null) {
        wind_speed_gusts = current.wind!.gust;
      }
    }
    int? visibility_in_meters = current.visibility;
    double? cloudiness_in_percentage;
    if (current.clouds != null) {
      cloudiness_in_percentage = current.clouds!.all;
    }
    double? humidity_in_percentage = current.main.humidity;
    double? atmospheric_pressure_hPa = current.main.pressure;
    double? percent_chance_of_rain;
    double? percent_chance_of_snow;
    List<PrecipitationData> precipitation_volume_set = <PrecipitationData>[];
    if (current.rain != null) {
      if (current.rain!.oneHr != null) {
        precipitation_volume_set.add(PrecipitationData(PrecipitationDataType.R, current.rain!.oneHr!, ONE_HR_IN_SECONDS));
      }
      if (current.rain!.threeHr != null) {
        precipitation_volume_set.add(PrecipitationData(PrecipitationDataType.R, current.rain!.threeHr!, THREE_HR_IN_SECONDS));
      }
    }
    if (current.snow != null) {
      if (current.snow!.oneHr != null) {
        precipitation_volume_set.add(PrecipitationData(PrecipitationDataType.S, current.snow!.oneHr!, ONE_HR_IN_SECONDS));
      }
      if (current.snow!.threeHr != null) {
        precipitation_volume_set.add(PrecipitationData(PrecipitationDataType.S, current.snow!.threeHr!, THREE_HR_IN_SECONDS));
      }
    }

    return WeatherData(recorded_at, provider, weather_type, WeatherDataPredictionType.C, recorded_at, latitude, longitude,
        temperature_min_celsius, temperature_max_celsius, wind_speed, wind_direction_in_degrees,
        wind_speed_gusts, visibility_in_meters, cloudiness_in_percentage, humidity_in_percentage,
        atmospheric_pressure_hPa, percent_chance_of_rain, percent_chance_of_snow,
        precipitation_volume_set);
  }

  static List<WeatherData> fromOWMForecast(OWMForecastWeather forecast) {
    List<WeatherData> forecasts = <WeatherData>[];
    DateTime recorded_at = forecast.recorded_at;
    WeatherProvider provider = WeatherProvider.OWM;
    double latitude = forecast.city.coord.lat;
    double longitude = forecast.city.coord.lon;
    for (int i = 0; i < forecast.cnt; i++) {
      ForecastData current = forecast.weather![i];
      WeatherDataType? weather_type;
      if (current.weather != null) {
        if (current.weather!.isNotEmpty) {
          weather_type = WeatherDataType.values.firstWhere((element) => element.name.contains(provider.name + current.weather![0].id.toString()));
        }
      }
      double temperature_min_celsius = current.main.temp;
      if (current.main.temp_min != null) {
        temperature_min_celsius = current.main.temp_min!;
      }
      double temperature_max_celsius = current.main.temp;
      if (current.main.temp_max != null) {
        temperature_max_celsius = current.main.temp_max!;
      }
      double? wind_speed;
      double? wind_direction_in_degrees;
      double? wind_speed_gusts;
      if (current.wind != null) {
        wind_speed = current.wind!.speed;
        wind_direction_in_degrees = current.wind!.deg;
        wind_speed_gusts = current.wind!.gust;
      }
      int? visibility_in_meters = current.visibility;
      double? cloudiness_in_percentage;
      if (current.clouds != null) {
        cloudiness_in_percentage = current.clouds!.all;
      }
      double? humidity_in_percentage = current.main.humidity;
      double? atmospheric_pressure_hPa = current.main.pressure;
      double? percent_chance_of_rain = 0;
      double? percent_chance_of_snow = 0;
      List<PrecipitationData> precipitation_volume_set = <PrecipitationData>[];
      if (current.rain != null) {
        if (current.pop != null) {
          percent_chance_of_rain = current.pop! * 100;
        }
        if (current.rain!.oneHr != null) {
          precipitation_volume_set.add(
              PrecipitationData(PrecipitationDataType.R, current.rain!.oneHr!, ONE_HR_IN_SECONDS));
        }
        if (current.rain!.threeHr != null) {
          precipitation_volume_set.add(PrecipitationData(
              PrecipitationDataType.R, current.rain!.threeHr!, THREE_HR_IN_SECONDS));
        }
      }
      if (current.snow != null) {
        if (current.pop != null) {
          percent_chance_of_snow = current.pop! * 100;
        }
        if (current.snow!.oneHr != null) {
          precipitation_volume_set.add(
              PrecipitationData(PrecipitationDataType.S, current.snow!.oneHr!, ONE_HR_IN_SECONDS));
        }
        if (current.snow!.threeHr != null) {
          precipitation_volume_set.add(PrecipitationData(
              PrecipitationDataType.S, current.snow!.threeHr!, THREE_HR_IN_SECONDS));
        }
      }
      forecasts.add(WeatherData(recorded_at, provider, weather_type, WeatherDataPredictionType.HP,
          DateTime.fromMillisecondsSinceEpoch(current.dt * 1000), latitude,
          longitude, temperature_min_celsius, temperature_max_celsius, wind_speed,
          wind_direction_in_degrees, wind_speed_gusts, visibility_in_meters,
          cloudiness_in_percentage, humidity_in_percentage, atmospheric_pressure_hPa,
          percent_chance_of_rain, percent_chance_of_snow, precipitation_volume_set));
    }
    return forecasts;
  }

  Map toJson() {
    List<Map> precipitation_volume_set = this.precipitation_volume_set.map((i) => i.toJson()).toList();
    String? weather_type;
    if (this.weather_type != null) {
      weather_type = this.weather_type!.name;
    }
    String recorded_at = this.recorded_at.toIso8601String();
    String prediction_time_for = this.prediction_time_for.toIso8601String();
    double? wind_speed;
    if (this.wind_speed != null) {
      wind_speed = doublePrecision(this.wind_speed!, 5, 2);
    }
    double? wind_direction_in_degrees;
    if (this.wind_direction_in_degrees != null) {
      wind_direction_in_degrees = doublePrecision(this.wind_direction_in_degrees!, 5, 2);
    }
    double? wind_speed_gusts;
    if (this.wind_speed_gusts != null) {
      wind_speed_gusts = doublePrecision(this.wind_speed_gusts!, 5, 2);
    }
    double? cloudiness_in_percentage;
    if (this.cloudiness_in_percentage != null) {
      this.cloudiness_in_percentage = (this.cloudiness_in_percentage!/100.0);
      cloudiness_in_percentage = doublePrecision(this.cloudiness_in_percentage!, 3, 2);
    }
    double? humidity_in_percentage;
    if (this.humidity_in_percentage != null) {
      this.humidity_in_percentage = this.humidity_in_percentage!/100.0;
      humidity_in_percentage = doublePrecision(this.humidity_in_percentage!, 3, 2);
    }
    double? atmospheric_pressure_hPa;
    if (this.atmospheric_pressure_hPa != null) {
      atmospheric_pressure_hPa = doublePrecision(this.atmospheric_pressure_hPa!, 7, 3);
    }
    double? percent_chance_of_rain;
    if (this.percent_chance_of_rain != null) {
      this.percent_chance_of_rain = this.percent_chance_of_rain!/100.0;
      percent_chance_of_rain = doublePrecision(this.percent_chance_of_rain!, 3, 2);
    }
    double? percent_chance_of_snow;
    if (this.percent_chance_of_snow != null) {
      this.percent_chance_of_snow = this.percent_chance_of_snow!/100.0;
      percent_chance_of_snow = doublePrecision(this.percent_chance_of_snow!, 3, 2);
    }

    return {
      'recorded_at': recorded_at,
      'provider': provider.name,
      'weather_type': weather_type,
      'prediction_type': prediction_type.name,
      'prediction_time_for': prediction_time_for,
      'latitude': doublePrecision(latitude, 9, 6),
      'longitude': doublePrecision(longitude, 9, 6),
      'temperature_min_celsius': doublePrecision(temperature_min_celsius, 4, 1),
      'temperature_max_celsius': doublePrecision(temperature_max_celsius, 4, 1),
      'wind_speed': wind_speed,
      'wind_direction_in_degrees': wind_direction_in_degrees,
      'wind_speed_gusts': wind_speed_gusts,
      'visibility_in_meters': visibility_in_meters,
      'cloudiness_in_percentage': cloudiness_in_percentage,
      'humidity_in_percentage': humidity_in_percentage,
      'atmospheric_pressure_hPa': atmospheric_pressure_hPa,
      'percent_chance_of_rain': percent_chance_of_rain,
      'percent_chance_of_snow': percent_chance_of_snow,
      'precipitation_volume_set': precipitation_volume_set
    };
  }
}

enum PrecipitationDataType {
  S,  // Snow
  R   // Rain
}

class PrecipitationData {
  PrecipitationDataType type;
  double volume_in_mm;
  int recording_duration_in_seconds;

  PrecipitationData(this.type, this.volume_in_mm, this.recording_duration_in_seconds);

  Map toJson() => {
    'type': type.name,
    'volume_in_mm': doublePrecision(volume_in_mm, 6, 2),
    'recording_duration_in_seconds': recording_duration_in_seconds
  };
}