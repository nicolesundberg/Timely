import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:timely/owm/owm_current_weather.dart';
import 'package:timely/owm/owm_forecast_weather.dart';
import 'package:timely/backend_models/weather.dart';

// Tests modeled after:
//    https://docs.flutter.dev/cookbook/testing/unit/introduction
//    https://docs.flutter.dev/cookbook/testing/unit/mocking
//    https://api.flutter.dev/flutter/package-matcher_matcher/TypeMatcher-class.html

void main() {
  test('Weather: Converting from OpenWeatherMaps API docs example response', () {
    var current = '{"coord": { "lon": 10.99, "lat": 44.34 }, "weather": [ { "id": 501, "main": "Rain", "description": "moderate rain", "icon": "10d" } ], "base": "stations", "main": { "temp": 298.48, "feels_like": 298.74, "temp_min": 297.56, "temp_max": 300.05, "pressure": 1015, "humidity": 64, "sea_level": 1015, "grnd_level": 933 }, "visibility": 10000, "wind": { "speed": 0.62, "deg": 349, "gust": 1.18 }, "rain": { "1h": 3.16 }, "clouds": { "all": 100 }, "dt": 1661870592, "sys": { "type": 2, "id": 2075663, "country": "IT", "sunrise": 1661834187, "sunset": 1661882248 }, "timezone": 7200, "id": 3163858, "name": "Zocca", "cod": 200 }';
    OWMCurrentWeather owm_current = OWMCurrentWeather.fromJson(jsonDecode(current));
    Weather weather = Weather.fromOWMCurrent(owm_current);
    expect(weather.current_data_set.length, 1);
    expect(weather.forecast_data_set.length, 0);

    expect(weather.current_data_set[0].longitude, 10.99);
    expect(weather.current_data_set[0].latitude, 44.34);

    expect(weather.current_data_set[0].provider, WeatherProvider.OWM);
    expect(weather.current_data_set[0].weather_type, WeatherDataType.OWM501);

    expect(weather.current_data_set[0].prediction_type, WeatherDataPredictionType.C);
    expect(weather.current_data_set[0].prediction_time_for, DateTime.fromMillisecondsSinceEpoch(1661870592000));

    expect(weather.current_data_set[0].temperature_min_celsius, 297.56);
    expect(weather.current_data_set[0].temperature_max_celsius, 300.05);
    expect(weather.current_data_set[0].atmospheric_pressure_hPa, 1015);
    expect(weather.current_data_set[0].humidity_in_percentage, 64);

    expect(weather.current_data_set[0].visibility_in_meters, 10000);

    expect(weather.current_data_set[0].cloudiness_in_percentage, 100);

    expect(weather.current_data_set[0].wind_speed, 0.62);
    expect(weather.current_data_set[0].wind_direction_in_degrees, 349);
    expect(weather.current_data_set[0].wind_speed_gusts, 1.18);

    expect(weather.current_data_set[0].precipitation_volume_set.length, 1);
    expect(weather.current_data_set[0].precipitation_volume_set[0].type, PrecipitationDataType.R);
    expect(weather.current_data_set[0].precipitation_volume_set[0].volume_in_mm, 3.16);
    expect(weather.current_data_set[0].precipitation_volume_set[0].recording_duration_in_seconds, WeatherData.ONE_HR_IN_SECONDS);

    expect(weather.current_data_set[0].recorded_at, DateTime.fromMillisecondsSinceEpoch(1661870592000));
  });

  test('Weather: Converting from OpenWeatherMaps SLC example response', () {
    var current = '{"coord":{"lon":-111.8762,"lat":40.7587},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"base":"stations","main":{"temp":1.2,"feels_like":-2.53,"temp_min":-2.01,"temp_max":4.47,"pressure":1028,"humidity":77},"visibility":10000,"wind":{"speed":3.6,"deg":190},"clouds":{"all":100},"dt":1673607967,"sys":{"type":2,"id":2004156,"country":"US","sunrise":1673621414,"sunset":1673655698},"timezone":-25200,"id":5780993,"name":"Salt Lake City","cod":200}';
    OWMCurrentWeather owm_current = OWMCurrentWeather.fromJson(jsonDecode(current));
    Weather weather = Weather.fromOWMCurrent(owm_current);
    expect(weather.current_data_set.length, 1);
    expect(weather.forecast_data_set.length, 0);

    expect(weather.current_data_set[0].longitude, -111.8762);
    expect(weather.current_data_set[0].latitude, 40.7587);

    expect(weather.current_data_set[0].provider, WeatherProvider.OWM);
    expect(weather.current_data_set[0].weather_type, WeatherDataType.OWM804);

    expect(weather.current_data_set[0].prediction_type, WeatherDataPredictionType.C);
    expect(weather.current_data_set[0].prediction_time_for, DateTime.fromMillisecondsSinceEpoch(1673607967000));

    expect(weather.current_data_set[0].temperature_min_celsius, -2.01);
    expect(weather.current_data_set[0].temperature_max_celsius, 4.47);
    expect(weather.current_data_set[0].atmospheric_pressure_hPa, 1028);
    expect(weather.current_data_set[0].humidity_in_percentage, 77);

    expect(weather.current_data_set[0].visibility_in_meters, 10000);

    expect(weather.current_data_set[0].cloudiness_in_percentage, 100);

    expect(weather.current_data_set[0].wind_speed, 3.6);
    expect(weather.current_data_set[0].wind_direction_in_degrees, 190);
    expect(weather.current_data_set[0].wind_speed_gusts, null);

    expect(weather.current_data_set[0].precipitation_volume_set.length, 0);

    expect(weather.current_data_set[0].recorded_at, DateTime.fromMillisecondsSinceEpoch(1673607967000));
  });

  test('Weather: Converting from OpenWeatherMaps SLC example response', () {
    var forecast = '{"cod":"200","message":0,"cnt":40,"list":[{"dt":1674507600,"main":{"temp":-0.01,"feels_like":-2.93,"temp_min":-1.35,"temp_max":-0.01,"pressure":1022,"sea_level":1022,"grnd_level":872,"humidity":67,"temp_kf":1.34},"weather":[{"id":801,"main":"Clouds","description":"few clouds","icon":"02d"}],"clouds":{"all":20},"wind":{"speed":2.4,"deg":314,"gust":2.82},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-23 21:00:00"},{"dt":1674518400,"main":{"temp":-1.18,"feels_like":-3.34,"temp_min":-3.53,"temp_max":-1.18,"pressure":1024,"sea_level":1024,"grnd_level":873,"humidity":75,"temp_kf":2.35},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03d"}],"clouds":{"all":34},"wind":{"speed":1.65,"deg":300,"gust":2.11},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-24 00:00:00"},{"dt":1674529200,"main":{"temp":-3.37,"feels_like":-3.37,"temp_min":-5.05,"temp_max":-3.37,"pressure":1027,"sea_level":1027,"grnd_level":874,"humidity":85,"temp_kf":1.68},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":69},"wind":{"speed":0.9,"deg":175,"gust":1.16},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-24 03:00:00"},{"dt":1674540000,"main":{"temp":-4.74,"feels_like":-4.74,"temp_min":-4.74,"temp_max":-4.74,"pressure":1031,"sea_level":1031,"grnd_level":875,"humidity":92,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":96},"wind":{"speed":0.79,"deg":191,"gust":0.94},"visibility":6011,"pop":0.2,"snow":{"3h":0.15},"sys":{"pod":"n"},"dt_txt":"2023-01-24 06:00:00"},{"dt":1674550800,"main":{"temp":-6.01,"feels_like":-6.01,"temp_min":-6.01,"temp_max":-6.01,"pressure":1032,"sea_level":1032,"grnd_level":876,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":0.52,"deg":155,"gust":0.72},"visibility":10000,"pop":0.43,"snow":{"3h":0.18},"sys":{"pod":"n"},"dt_txt":"2023-01-24 09:00:00"},{"dt":1674561600,"main":{"temp":-7.74,"feels_like":-10.31,"temp_min":-7.74,"temp_max":-7.74,"pressure":1034,"sea_level":1034,"grnd_level":877,"humidity":94,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"clouds":{"all":91},"wind":{"speed":1.37,"deg":134,"gust":1.37},"visibility":4437,"pop":0.26,"sys":{"pod":"n"},"dt_txt":"2023-01-24 12:00:00"},{"dt":1674572400,"main":{"temp":-7.56,"feels_like":-10.98,"temp_min":-7.56,"temp_max":-7.56,"pressure":1035,"sea_level":1035,"grnd_level":877,"humidity":94,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":95},"wind":{"speed":1.83,"deg":142,"gust":1.92},"visibility":4766,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-24 15:00:00"},{"dt":1674583200,"main":{"temp":-3.58,"feels_like":-3.58,"temp_min":-3.58,"temp_max":-3.58,"pressure":1034,"sea_level":1034,"grnd_level":878,"humidity":88,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":97},"wind":{"speed":1.3,"deg":244,"gust":1.66},"visibility":1314,"pop":0.2,"snow":{"3h":0.13},"sys":{"pod":"d"},"dt_txt":"2023-01-24 18:00:00"},{"dt":1674594000,"main":{"temp":-2.34,"feels_like":-5.88,"temp_min":-2.34,"temp_max":-2.34,"pressure":1031,"sea_level":1031,"grnd_level":877,"humidity":88,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":2.58,"deg":301,"gust":2.98},"visibility":867,"pop":0.28,"snow":{"3h":0.37},"sys":{"pod":"d"},"dt_txt":"2023-01-24 21:00:00"},{"dt":1674604800,"main":{"temp":-3.86,"feels_like":-7.17,"temp_min":-3.86,"temp_max":-3.86,"pressure":1033,"sea_level":1033,"grnd_level":878,"humidity":92,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":2.16,"deg":303,"gust":3.02},"visibility":7217,"pop":0.3,"snow":{"3h":0.34},"sys":{"pod":"d"},"dt_txt":"2023-01-25 00:00:00"},{"dt":1674615600,"main":{"temp":-7.12,"feels_like":-9.59,"temp_min":-7.12,"temp_max":-7.12,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":94,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"clouds":{"all":96},"wind":{"speed":1.36,"deg":134,"gust":1.41},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-25 03:00:00"},{"dt":1674626400,"main":{"temp":-7.95,"feels_like":-11.65,"temp_min":-7.95,"temp_max":-7.95,"pressure":1037,"sea_level":1037,"grnd_level":879,"humidity":92,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":82},"wind":{"speed":1.96,"deg":137,"gust":2.01},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-25 06:00:00"},{"dt":1674637200,"main":{"temp":-6.72,"feels_like":-9.11,"temp_min":-6.72,"temp_max":-6.72,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":92,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"clouds":{"all":87},"wind":{"speed":1.35,"deg":147,"gust":2.15},"visibility":8584,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-25 09:00:00"},{"dt":1674648000,"main":{"temp":-5.67,"feels_like":-5.67,"temp_min":-5.67,"temp_max":-5.67,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":93,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":93},"wind":{"speed":1.17,"deg":159,"gust":1.61},"visibility":1218,"pop":0.2,"snow":{"3h":0.22},"sys":{"pod":"n"},"dt_txt":"2023-01-25 12:00:00"},{"dt":1674658800,"main":{"temp":-5.22,"feels_like":-5.22,"temp_min":-5.22,"temp_max":-5.22,"pressure":1036,"sea_level":1036,"grnd_level":880,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":0.88,"deg":174,"gust":1.35},"visibility":512,"pop":0.36,"snow":{"3h":0.18},"sys":{"pod":"d"},"dt_txt":"2023-01-25 15:00:00"},{"dt":1674669600,"main":{"temp":-2.8,"feels_like":-2.8,"temp_min":-2.8,"temp_max":-2.8,"pressure":1035,"sea_level":1035,"grnd_level":880,"humidity":89,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":1.09,"deg":237,"gust":1.66},"visibility":1562,"pop":0.28,"snow":{"3h":0.22},"sys":{"pod":"d"},"dt_txt":"2023-01-25 18:00:00"},{"dt":1674680400,"main":{"temp":-1.99,"feels_like":-4.5,"temp_min":-1.99,"temp_max":-1.99,"pressure":1033,"sea_level":1033,"grnd_level":879,"humidity":91,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":1.8,"deg":303,"gust":1.93},"visibility":405,"pop":0.48,"snow":{"3h":0.34},"sys":{"pod":"d"},"dt_txt":"2023-01-25 21:00:00"},{"dt":1674691200,"main":{"temp":-2.88,"feels_like":-5.77,"temp_min":-2.88,"temp_max":-2.88,"pressure":1034,"sea_level":1034,"grnd_level":879,"humidity":94,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":1.97,"deg":316,"gust":2.61},"visibility":533,"pop":0.62,"snow":{"3h":0.55},"sys":{"pod":"d"},"dt_txt":"2023-01-26 00:00:00"},{"dt":1674702000,"main":{"temp":-4.62,"feels_like":-4.62,"temp_min":-4.62,"temp_max":-4.62,"pressure":1037,"sea_level":1037,"grnd_level":881,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":0.81,"deg":345,"gust":1.72},"visibility":3368,"pop":0.53,"snow":{"3h":0.24},"sys":{"pod":"n"},"dt_txt":"2023-01-26 03:00:00"},{"dt":1674712800,"main":{"temp":-5.7,"feels_like":-5.7,"temp_min":-5.7,"temp_max":-5.7,"pressure":1039,"sea_level":1039,"grnd_level":882,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":96},"wind":{"speed":0.22,"deg":36,"gust":1.36},"visibility":7600,"pop":0.35,"snow":{"3h":0.15},"sys":{"pod":"n"},"dt_txt":"2023-01-26 06:00:00"},{"dt":1674723600,"main":{"temp":-7.82,"feels_like":-7.82,"temp_min":-7.82,"temp_max":-7.82,"pressure":1043,"sea_level":1043,"grnd_level":884,"humidity":95,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":64},"wind":{"speed":0.99,"deg":104,"gust":1.22},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-26 09:00:00"},{"dt":1674734400,"main":{"temp":-8.1,"feels_like":-11.21,"temp_min":-8.1,"temp_max":-8.1,"pressure":1044,"sea_level":1044,"grnd_level":884,"humidity":94,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":67},"wind":{"speed":1.61,"deg":118,"gust":1.39},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-26 12:00:00"},{"dt":1674745200,"main":{"temp":-7.74,"feels_like":-11.64,"temp_min":-7.74,"temp_max":-7.74,"pressure":1044,"sea_level":1044,"grnd_level":885,"humidity":93,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],"clouds":{"all":76},"wind":{"speed":2.11,"deg":124,"gust":1.97},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-26 15:00:00"},{"dt":1674756000,"main":{"temp":-3.11,"feels_like":-5.57,"temp_min":-3.11,"temp_max":-3.11,"pressure":1040,"sea_level":1040,"grnd_level":884,"humidity":86,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],"clouds":{"all":76},"wind":{"speed":1.66,"deg":211,"gust":2.38},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-26 18:00:00"},{"dt":1674766800,"main":{"temp":-1.38,"feels_like":-1.38,"temp_min":-1.38,"temp_max":-1.38,"pressure":1036,"sea_level":1036,"grnd_level":882,"humidity":79,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":95},"wind":{"speed":1.29,"deg":236,"gust":2.1},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-26 21:00:00"},{"dt":1674777600,"main":{"temp":-2.88,"feels_like":-2.88,"temp_min":-2.88,"temp_max":-2.88,"pressure":1037,"sea_level":1037,"grnd_level":881,"humidity":88,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":96},"wind":{"speed":0.22,"deg":1,"gust":1.16},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 00:00:00"},{"dt":1674788400,"main":{"temp":-5.82,"feels_like":-9.31,"temp_min":-5.82,"temp_max":-5.82,"pressure":1037,"sea_level":1037,"grnd_level":880,"humidity":85,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":80},"wind":{"speed":2.05,"deg":135,"gust":2.31},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 03:00:00"},{"dt":1674799200,"main":{"temp":-5.93,"feels_like":-9.78,"temp_min":-5.93,"temp_max":-5.93,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":83,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":55},"wind":{"speed":2.29,"deg":132,"gust":2.91},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 06:00:00"},{"dt":1674810000,"main":{"temp":-5.86,"feels_like":-10.04,"temp_min":-5.86,"temp_max":-5.86,"pressure":1033,"sea_level":1033,"grnd_level":877,"humidity":83,"temp_kf":0},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03n"}],"clouds":{"all":27},"wind":{"speed":2.56,"deg":137,"gust":3.35},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 09:00:00"},{"dt":1674820800,"main":{"temp":-5.36,"feels_like":-9.41,"temp_min":-5.36,"temp_max":-5.36,"pressure":1030,"sea_level":1030,"grnd_level":874,"humidity":79,"temp_kf":0},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03n"}],"clouds":{"all":45},"wind":{"speed":2.53,"deg":139,"gust":3.37},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 12:00:00"},{"dt":1674831600,"main":{"temp":-3.7,"feels_like":-7.37,"temp_min":-3.7,"temp_max":-3.7,"pressure":1026,"sea_level":1026,"grnd_level":872,"humidity":79,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":100},"wind":{"speed":2.47,"deg":150,"gust":3.47},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 15:00:00"},{"dt":1674842400,"main":{"temp":0.44,"feels_like":-2.08,"temp_min":0.44,"temp_max":0.44,"pressure":1023,"sea_level":1023,"grnd_level":871,"humidity":71,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":100},"wind":{"speed":2.11,"deg":178,"gust":4.13},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 18:00:00"},{"dt":1674853200,"main":{"temp":2.26,"feels_like":0.45,"temp_min":2.26,"temp_max":2.26,"pressure":1018,"sea_level":1018,"grnd_level":868,"humidity":74,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":100},"wind":{"speed":1.77,"deg":195,"gust":3.85},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 21:00:00"},{"dt":1674864000,"main":{"temp":0.56,"feels_like":0.56,"temp_min":0.56,"temp_max":0.56,"pressure":1016,"sea_level":1016,"grnd_level":866,"humidity":82,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":92},"wind":{"speed":0.43,"deg":195,"gust":1.24},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-28 00:00:00"},{"dt":1674874800,"main":{"temp":-2.53,"feels_like":-6.01,"temp_min":-2.53,"temp_max":-2.53,"pressure":1017,"sea_level":1017,"grnd_level":865,"humidity":73,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":60},"wind":{"speed":2.49,"deg":139,"gust":2.85},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-28 03:00:00"},{"dt":1674885600,"main":{"temp":-1.58,"feels_like":-3.69,"temp_min":-1.58,"temp_max":-1.58,"pressure":1015,"sea_level":1015,"grnd_level":863,"humidity":76,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":74},"wind":{"speed":1.58,"deg":147,"gust":1.81},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-28 06:00:00"},{"dt":1674896400,"main":{"temp":0.17,"feels_like":-2.52,"temp_min":0.17,"temp_max":0.17,"pressure":1013,"sea_level":1013,"grnd_level":863,"humidity":80,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":2.22,"deg":205,"gust":5.38},"visibility":4889,"pop":0.24,"snow":{"3h":0.22},"sys":{"pod":"n"},"dt_txt":"2023-01-28 09:00:00"},{"dt":1674907200,"main":{"temp":-0.97,"feels_like":-0.97,"temp_min":-0.97,"temp_max":-0.97,"pressure":1015,"sea_level":1015,"grnd_level":864,"humidity":90,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":0.45,"deg":299,"gust":3.05},"visibility":9459,"pop":0.5,"snow":{"3h":0.71},"sys":{"pod":"n"},"dt_txt":"2023-01-28 12:00:00"},{"dt":1674918000,"main":{"temp":-4.06,"feels_like":-6.35,"temp_min":-4.06,"temp_max":-4.06,"pressure":1019,"sea_level":1019,"grnd_level":866,"humidity":90,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":67},"wind":{"speed":1.48,"deg":163,"gust":1.57},"visibility":10000,"pop":0.26,"snow":{"3h":0.19},"sys":{"pod":"d"},"dt_txt":"2023-01-28 15:00:00"},{"dt":1674928800,"main":{"temp":0.61,"feels_like":0.61,"temp_min":0.61,"temp_max":0.61,"pressure":1017,"sea_level":1017,"grnd_level":867,"humidity":73,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":84},"wind":{"speed":0.61,"deg":207,"gust":2.63},"visibility":10000,"pop":0.24,"snow":{"3h":0.13},"sys":{"pod":"d"},"dt_txt":"2023-01-28 18:00:00"}],"city":{"id":5780993,"name":"Salt Lake City","coord":{"lat":40.7587,"lon":-111.8762},"country":"US","population":186440,"timezone":-25200,"sunrise":1674485108,"sunset":1674520390}}';
    OWMForecastWeather owm_forecast = OWMForecastWeather.fromJson(jsonDecode(forecast));
    Weather weather = Weather.fromOWMForecast(owm_forecast);
    expect(weather.current_data_set.length, 0);
    expect(weather.forecast_data_set.length, 40);

    expect(weather.forecast_data_set[0].provider, WeatherProvider.OWM);
    expect(weather.forecast_data_set[0].weather_type, WeatherDataType.OWM801);

    expect(weather.forecast_data_set[0].longitude, -111.8762);
    expect(weather.forecast_data_set[0].latitude, 40.7587);

    expect(weather.forecast_data_set[0].temperature_min_celsius, -1.35);
    expect(weather.forecast_data_set[0].temperature_max_celsius, -0.01);

    expect(weather.forecast_data_set[0].wind_speed, 2.4);
    expect(weather.forecast_data_set[0].wind_direction_in_degrees, 314);
    expect(weather.forecast_data_set[0].wind_speed_gusts, 2.82);

    expect(weather.forecast_data_set[0].visibility_in_meters, 10000);
    expect(weather.forecast_data_set[0].cloudiness_in_percentage, 20);
    expect(weather.forecast_data_set[0].humidity_in_percentage, 67);
    expect(weather.forecast_data_set[0].atmospheric_pressure_hPa, 1022);

    expect(weather.forecast_data_set[0].percent_chance_of_rain, 0);
    expect(weather.forecast_data_set[0].percent_chance_of_snow, 0);

    expect(weather.forecast_data_set[0].precipitation_volume_set.length, 0);

    expect(weather.forecast_data_set[0].prediction_type, WeatherDataPredictionType.HP);
    expect(weather.forecast_data_set[0].prediction_time_for, DateTime.fromMillisecondsSinceEpoch(1674507600000));

    expect(weather.forecast_data_set[39].provider, WeatherProvider.OWM);
    expect(weather.forecast_data_set[39].weather_type, WeatherDataType.OWM600);

    expect(weather.forecast_data_set[39].longitude, -111.8762);
    expect(weather.forecast_data_set[39].latitude, 40.7587);

    expect(weather.forecast_data_set[39].temperature_min_celsius, 0.61);
    expect(weather.forecast_data_set[39].temperature_max_celsius, 0.61);

    expect(weather.forecast_data_set[39].wind_speed, 0.61);
    expect(weather.forecast_data_set[39].wind_direction_in_degrees, 207);
    expect(weather.forecast_data_set[39].wind_speed_gusts, 2.63);

    expect(weather.forecast_data_set[39].visibility_in_meters, 10000);
    expect(weather.forecast_data_set[39].cloudiness_in_percentage, 84);
    expect(weather.forecast_data_set[39].humidity_in_percentage, 73);
    expect(weather.forecast_data_set[39].atmospheric_pressure_hPa, 1017);

    expect(weather.forecast_data_set[39].percent_chance_of_rain, 0);
    expect(weather.forecast_data_set[39].percent_chance_of_snow, 24);

    expect(weather.forecast_data_set[39].precipitation_volume_set.length, 1);
    expect(weather.forecast_data_set[39].precipitation_volume_set[0].type, PrecipitationDataType.S);
    expect(weather.forecast_data_set[39].precipitation_volume_set[0].volume_in_mm, 0.13);
    expect(weather.forecast_data_set[39].precipitation_volume_set[0].recording_duration_in_seconds, WeatherData.THREE_HR_IN_SECONDS);

    expect(weather.forecast_data_set[39].prediction_type, WeatherDataPredictionType.HP);
    expect(weather.forecast_data_set[39].prediction_time_for, DateTime.fromMillisecondsSinceEpoch(1674928800000));
  });

  test('Weather: Adding from OpenWeatherMaps API docs example response', () {
    var current = '{"coord": { "lon": 10.99, "lat": 44.34 }, "weather": [ { "id": 501, "main": "Rain", "description": "moderate rain", "icon": "10d" } ], "base": "stations", "main": { "temp": 298.48, "feels_like": 298.74, "temp_min": 297.56, "temp_max": 300.05, "pressure": 1015, "humidity": 64, "sea_level": 1015, "grnd_level": 933 }, "visibility": 10000, "wind": { "speed": 0.62, "deg": 349, "gust": 1.18 }, "rain": { "1h": 3.16 }, "clouds": { "all": 100 }, "dt": 1661870592, "sys": { "type": 2, "id": 2075663, "country": "IT", "sunrise": 1661834187, "sunset": 1661882248 }, "timezone": 7200, "id": 3163858, "name": "Zocca", "cod": 200 }';
    OWMCurrentWeather owm_current = OWMCurrentWeather.fromJson(jsonDecode(current));
    Weather weather = Weather([], []);
    weather.addFromOWMCurrent(owm_current);
    expect(weather.current_data_set.length, 1);
    expect(weather.forecast_data_set.length, 0);

    expect(weather.current_data_set[0].longitude, 10.99);
    expect(weather.current_data_set[0].latitude, 44.34);

    expect(weather.current_data_set[0].provider, WeatherProvider.OWM);
    expect(weather.current_data_set[0].weather_type, WeatherDataType.OWM501);

    expect(weather.current_data_set[0].prediction_type, WeatherDataPredictionType.C);
    expect(weather.current_data_set[0].prediction_time_for, DateTime.fromMillisecondsSinceEpoch(1661870592000));

    expect(weather.current_data_set[0].temperature_min_celsius, 297.56);
    expect(weather.current_data_set[0].temperature_max_celsius, 300.05);
    expect(weather.current_data_set[0].atmospheric_pressure_hPa, 1015);
    expect(weather.current_data_set[0].humidity_in_percentage, 64);

    expect(weather.current_data_set[0].visibility_in_meters, 10000);

    expect(weather.current_data_set[0].cloudiness_in_percentage, 100);

    expect(weather.current_data_set[0].wind_speed, 0.62);
    expect(weather.current_data_set[0].wind_direction_in_degrees, 349);
    expect(weather.current_data_set[0].wind_speed_gusts, 1.18);

    expect(weather.current_data_set[0].precipitation_volume_set.length, 1);
    expect(weather.current_data_set[0].precipitation_volume_set[0].type, PrecipitationDataType.R);
    expect(weather.current_data_set[0].precipitation_volume_set[0].volume_in_mm, 3.16);
    expect(weather.current_data_set[0].precipitation_volume_set[0].recording_duration_in_seconds, WeatherData.ONE_HR_IN_SECONDS);

    expect(weather.current_data_set[0].recorded_at, DateTime.fromMillisecondsSinceEpoch(1661870592000));
  });

  test('Weather: Converting from OpenWeatherMaps SLC example response', () {
    var current = '{"coord":{"lon":-111.8762,"lat":40.7587},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"base":"stations","main":{"temp":1.2,"feels_like":-2.53,"temp_min":-2.01,"temp_max":4.47,"pressure":1028,"humidity":77},"visibility":10000,"wind":{"speed":3.6,"deg":190},"clouds":{"all":100},"dt":1673607967,"sys":{"type":2,"id":2004156,"country":"US","sunrise":1673621414,"sunset":1673655698},"timezone":-25200,"id":5780993,"name":"Salt Lake City","cod":200}';
    OWMCurrentWeather owm_current = OWMCurrentWeather.fromJson(jsonDecode(current));
    Weather weather = Weather([], []);
    weather.addFromOWMCurrent(owm_current);
    expect(weather.current_data_set.length, 1);
    expect(weather.forecast_data_set.length, 0);

    expect(weather.current_data_set[0].longitude, -111.8762);
    expect(weather.current_data_set[0].latitude, 40.7587);

    expect(weather.current_data_set[0].provider, WeatherProvider.OWM);
    expect(weather.current_data_set[0].weather_type, WeatherDataType.OWM804);

    expect(weather.current_data_set[0].prediction_type, WeatherDataPredictionType.C);
    expect(weather.current_data_set[0].prediction_time_for, DateTime.fromMillisecondsSinceEpoch(1673607967000));

    expect(weather.current_data_set[0].temperature_min_celsius, -2.01);
    expect(weather.current_data_set[0].temperature_max_celsius, 4.47);
    expect(weather.current_data_set[0].atmospheric_pressure_hPa, 1028);
    expect(weather.current_data_set[0].humidity_in_percentage, 77);

    expect(weather.current_data_set[0].visibility_in_meters, 10000);

    expect(weather.current_data_set[0].cloudiness_in_percentage, 100);

    expect(weather.current_data_set[0].wind_speed, 3.6);
    expect(weather.current_data_set[0].wind_direction_in_degrees, 190);
    expect(weather.current_data_set[0].wind_speed_gusts, null);

    expect(weather.current_data_set[0].precipitation_volume_set.length, 0);

    expect(weather.current_data_set[0].prediction_type, WeatherDataPredictionType.C);
    expect(weather.current_data_set[0].prediction_time_for, DateTime.fromMillisecondsSinceEpoch(1673607967000));
  });

  test('Weather: Converting from OpenWeatherMaps SLC example response', () {
    var forecast = '{"cod":"200","message":0,"cnt":40,"list":[{"dt":1674507600,"main":{"temp":-0.01,"feels_like":-2.93,"temp_min":-1.35,"temp_max":-0.01,"pressure":1022,"sea_level":1022,"grnd_level":872,"humidity":67,"temp_kf":1.34},"weather":[{"id":801,"main":"Clouds","description":"few clouds","icon":"02d"}],"clouds":{"all":20},"wind":{"speed":2.4,"deg":314,"gust":2.82},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-23 21:00:00"},{"dt":1674518400,"main":{"temp":-1.18,"feels_like":-3.34,"temp_min":-3.53,"temp_max":-1.18,"pressure":1024,"sea_level":1024,"grnd_level":873,"humidity":75,"temp_kf":2.35},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03d"}],"clouds":{"all":34},"wind":{"speed":1.65,"deg":300,"gust":2.11},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-24 00:00:00"},{"dt":1674529200,"main":{"temp":-3.37,"feels_like":-3.37,"temp_min":-5.05,"temp_max":-3.37,"pressure":1027,"sea_level":1027,"grnd_level":874,"humidity":85,"temp_kf":1.68},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":69},"wind":{"speed":0.9,"deg":175,"gust":1.16},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-24 03:00:00"},{"dt":1674540000,"main":{"temp":-4.74,"feels_like":-4.74,"temp_min":-4.74,"temp_max":-4.74,"pressure":1031,"sea_level":1031,"grnd_level":875,"humidity":92,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":96},"wind":{"speed":0.79,"deg":191,"gust":0.94},"visibility":6011,"pop":0.2,"snow":{"3h":0.15},"sys":{"pod":"n"},"dt_txt":"2023-01-24 06:00:00"},{"dt":1674550800,"main":{"temp":-6.01,"feels_like":-6.01,"temp_min":-6.01,"temp_max":-6.01,"pressure":1032,"sea_level":1032,"grnd_level":876,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":0.52,"deg":155,"gust":0.72},"visibility":10000,"pop":0.43,"snow":{"3h":0.18},"sys":{"pod":"n"},"dt_txt":"2023-01-24 09:00:00"},{"dt":1674561600,"main":{"temp":-7.74,"feels_like":-10.31,"temp_min":-7.74,"temp_max":-7.74,"pressure":1034,"sea_level":1034,"grnd_level":877,"humidity":94,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"clouds":{"all":91},"wind":{"speed":1.37,"deg":134,"gust":1.37},"visibility":4437,"pop":0.26,"sys":{"pod":"n"},"dt_txt":"2023-01-24 12:00:00"},{"dt":1674572400,"main":{"temp":-7.56,"feels_like":-10.98,"temp_min":-7.56,"temp_max":-7.56,"pressure":1035,"sea_level":1035,"grnd_level":877,"humidity":94,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":95},"wind":{"speed":1.83,"deg":142,"gust":1.92},"visibility":4766,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-24 15:00:00"},{"dt":1674583200,"main":{"temp":-3.58,"feels_like":-3.58,"temp_min":-3.58,"temp_max":-3.58,"pressure":1034,"sea_level":1034,"grnd_level":878,"humidity":88,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":97},"wind":{"speed":1.3,"deg":244,"gust":1.66},"visibility":1314,"pop":0.2,"snow":{"3h":0.13},"sys":{"pod":"d"},"dt_txt":"2023-01-24 18:00:00"},{"dt":1674594000,"main":{"temp":-2.34,"feels_like":-5.88,"temp_min":-2.34,"temp_max":-2.34,"pressure":1031,"sea_level":1031,"grnd_level":877,"humidity":88,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":2.58,"deg":301,"gust":2.98},"visibility":867,"pop":0.28,"snow":{"3h":0.37},"sys":{"pod":"d"},"dt_txt":"2023-01-24 21:00:00"},{"dt":1674604800,"main":{"temp":-3.86,"feels_like":-7.17,"temp_min":-3.86,"temp_max":-3.86,"pressure":1033,"sea_level":1033,"grnd_level":878,"humidity":92,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":2.16,"deg":303,"gust":3.02},"visibility":7217,"pop":0.3,"snow":{"3h":0.34},"sys":{"pod":"d"},"dt_txt":"2023-01-25 00:00:00"},{"dt":1674615600,"main":{"temp":-7.12,"feels_like":-9.59,"temp_min":-7.12,"temp_max":-7.12,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":94,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"clouds":{"all":96},"wind":{"speed":1.36,"deg":134,"gust":1.41},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-25 03:00:00"},{"dt":1674626400,"main":{"temp":-7.95,"feels_like":-11.65,"temp_min":-7.95,"temp_max":-7.95,"pressure":1037,"sea_level":1037,"grnd_level":879,"humidity":92,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":82},"wind":{"speed":1.96,"deg":137,"gust":2.01},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-25 06:00:00"},{"dt":1674637200,"main":{"temp":-6.72,"feels_like":-9.11,"temp_min":-6.72,"temp_max":-6.72,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":92,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"clouds":{"all":87},"wind":{"speed":1.35,"deg":147,"gust":2.15},"visibility":8584,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-25 09:00:00"},{"dt":1674648000,"main":{"temp":-5.67,"feels_like":-5.67,"temp_min":-5.67,"temp_max":-5.67,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":93,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":93},"wind":{"speed":1.17,"deg":159,"gust":1.61},"visibility":1218,"pop":0.2,"snow":{"3h":0.22},"sys":{"pod":"n"},"dt_txt":"2023-01-25 12:00:00"},{"dt":1674658800,"main":{"temp":-5.22,"feels_like":-5.22,"temp_min":-5.22,"temp_max":-5.22,"pressure":1036,"sea_level":1036,"grnd_level":880,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":0.88,"deg":174,"gust":1.35},"visibility":512,"pop":0.36,"snow":{"3h":0.18},"sys":{"pod":"d"},"dt_txt":"2023-01-25 15:00:00"},{"dt":1674669600,"main":{"temp":-2.8,"feels_like":-2.8,"temp_min":-2.8,"temp_max":-2.8,"pressure":1035,"sea_level":1035,"grnd_level":880,"humidity":89,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":1.09,"deg":237,"gust":1.66},"visibility":1562,"pop":0.28,"snow":{"3h":0.22},"sys":{"pod":"d"},"dt_txt":"2023-01-25 18:00:00"},{"dt":1674680400,"main":{"temp":-1.99,"feels_like":-4.5,"temp_min":-1.99,"temp_max":-1.99,"pressure":1033,"sea_level":1033,"grnd_level":879,"humidity":91,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":1.8,"deg":303,"gust":1.93},"visibility":405,"pop":0.48,"snow":{"3h":0.34},"sys":{"pod":"d"},"dt_txt":"2023-01-25 21:00:00"},{"dt":1674691200,"main":{"temp":-2.88,"feels_like":-5.77,"temp_min":-2.88,"temp_max":-2.88,"pressure":1034,"sea_level":1034,"grnd_level":879,"humidity":94,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":1.97,"deg":316,"gust":2.61},"visibility":533,"pop":0.62,"snow":{"3h":0.55},"sys":{"pod":"d"},"dt_txt":"2023-01-26 00:00:00"},{"dt":1674702000,"main":{"temp":-4.62,"feels_like":-4.62,"temp_min":-4.62,"temp_max":-4.62,"pressure":1037,"sea_level":1037,"grnd_level":881,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":0.81,"deg":345,"gust":1.72},"visibility":3368,"pop":0.53,"snow":{"3h":0.24},"sys":{"pod":"n"},"dt_txt":"2023-01-26 03:00:00"},{"dt":1674712800,"main":{"temp":-5.7,"feels_like":-5.7,"temp_min":-5.7,"temp_max":-5.7,"pressure":1039,"sea_level":1039,"grnd_level":882,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":96},"wind":{"speed":0.22,"deg":36,"gust":1.36},"visibility":7600,"pop":0.35,"snow":{"3h":0.15},"sys":{"pod":"n"},"dt_txt":"2023-01-26 06:00:00"},{"dt":1674723600,"main":{"temp":-7.82,"feels_like":-7.82,"temp_min":-7.82,"temp_max":-7.82,"pressure":1043,"sea_level":1043,"grnd_level":884,"humidity":95,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":64},"wind":{"speed":0.99,"deg":104,"gust":1.22},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-26 09:00:00"},{"dt":1674734400,"main":{"temp":-8.1,"feels_like":-11.21,"temp_min":-8.1,"temp_max":-8.1,"pressure":1044,"sea_level":1044,"grnd_level":884,"humidity":94,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":67},"wind":{"speed":1.61,"deg":118,"gust":1.39},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-26 12:00:00"},{"dt":1674745200,"main":{"temp":-7.74,"feels_like":-11.64,"temp_min":-7.74,"temp_max":-7.74,"pressure":1044,"sea_level":1044,"grnd_level":885,"humidity":93,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],"clouds":{"all":76},"wind":{"speed":2.11,"deg":124,"gust":1.97},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-26 15:00:00"},{"dt":1674756000,"main":{"temp":-3.11,"feels_like":-5.57,"temp_min":-3.11,"temp_max":-3.11,"pressure":1040,"sea_level":1040,"grnd_level":884,"humidity":86,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],"clouds":{"all":76},"wind":{"speed":1.66,"deg":211,"gust":2.38},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-26 18:00:00"},{"dt":1674766800,"main":{"temp":-1.38,"feels_like":-1.38,"temp_min":-1.38,"temp_max":-1.38,"pressure":1036,"sea_level":1036,"grnd_level":882,"humidity":79,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":95},"wind":{"speed":1.29,"deg":236,"gust":2.1},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-26 21:00:00"},{"dt":1674777600,"main":{"temp":-2.88,"feels_like":-2.88,"temp_min":-2.88,"temp_max":-2.88,"pressure":1037,"sea_level":1037,"grnd_level":881,"humidity":88,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":96},"wind":{"speed":0.22,"deg":1,"gust":1.16},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 00:00:00"},{"dt":1674788400,"main":{"temp":-5.82,"feels_like":-9.31,"temp_min":-5.82,"temp_max":-5.82,"pressure":1037,"sea_level":1037,"grnd_level":880,"humidity":85,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":80},"wind":{"speed":2.05,"deg":135,"gust":2.31},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 03:00:00"},{"dt":1674799200,"main":{"temp":-5.93,"feels_like":-9.78,"temp_min":-5.93,"temp_max":-5.93,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":83,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":55},"wind":{"speed":2.29,"deg":132,"gust":2.91},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 06:00:00"},{"dt":1674810000,"main":{"temp":-5.86,"feels_like":-10.04,"temp_min":-5.86,"temp_max":-5.86,"pressure":1033,"sea_level":1033,"grnd_level":877,"humidity":83,"temp_kf":0},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03n"}],"clouds":{"all":27},"wind":{"speed":2.56,"deg":137,"gust":3.35},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 09:00:00"},{"dt":1674820800,"main":{"temp":-5.36,"feels_like":-9.41,"temp_min":-5.36,"temp_max":-5.36,"pressure":1030,"sea_level":1030,"grnd_level":874,"humidity":79,"temp_kf":0},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03n"}],"clouds":{"all":45},"wind":{"speed":2.53,"deg":139,"gust":3.37},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 12:00:00"},{"dt":1674831600,"main":{"temp":-3.7,"feels_like":-7.37,"temp_min":-3.7,"temp_max":-3.7,"pressure":1026,"sea_level":1026,"grnd_level":872,"humidity":79,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":100},"wind":{"speed":2.47,"deg":150,"gust":3.47},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 15:00:00"},{"dt":1674842400,"main":{"temp":0.44,"feels_like":-2.08,"temp_min":0.44,"temp_max":0.44,"pressure":1023,"sea_level":1023,"grnd_level":871,"humidity":71,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":100},"wind":{"speed":2.11,"deg":178,"gust":4.13},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 18:00:00"},{"dt":1674853200,"main":{"temp":2.26,"feels_like":0.45,"temp_min":2.26,"temp_max":2.26,"pressure":1018,"sea_level":1018,"grnd_level":868,"humidity":74,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":100},"wind":{"speed":1.77,"deg":195,"gust":3.85},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 21:00:00"},{"dt":1674864000,"main":{"temp":0.56,"feels_like":0.56,"temp_min":0.56,"temp_max":0.56,"pressure":1016,"sea_level":1016,"grnd_level":866,"humidity":82,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":92},"wind":{"speed":0.43,"deg":195,"gust":1.24},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-28 00:00:00"},{"dt":1674874800,"main":{"temp":-2.53,"feels_like":-6.01,"temp_min":-2.53,"temp_max":-2.53,"pressure":1017,"sea_level":1017,"grnd_level":865,"humidity":73,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":60},"wind":{"speed":2.49,"deg":139,"gust":2.85},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-28 03:00:00"},{"dt":1674885600,"main":{"temp":-1.58,"feels_like":-3.69,"temp_min":-1.58,"temp_max":-1.58,"pressure":1015,"sea_level":1015,"grnd_level":863,"humidity":76,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":74},"wind":{"speed":1.58,"deg":147,"gust":1.81},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-28 06:00:00"},{"dt":1674896400,"main":{"temp":0.17,"feels_like":-2.52,"temp_min":0.17,"temp_max":0.17,"pressure":1013,"sea_level":1013,"grnd_level":863,"humidity":80,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":2.22,"deg":205,"gust":5.38},"visibility":4889,"pop":0.24,"snow":{"3h":0.22},"sys":{"pod":"n"},"dt_txt":"2023-01-28 09:00:00"},{"dt":1674907200,"main":{"temp":-0.97,"feels_like":-0.97,"temp_min":-0.97,"temp_max":-0.97,"pressure":1015,"sea_level":1015,"grnd_level":864,"humidity":90,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":0.45,"deg":299,"gust":3.05},"visibility":9459,"pop":0.5,"snow":{"3h":0.71},"sys":{"pod":"n"},"dt_txt":"2023-01-28 12:00:00"},{"dt":1674918000,"main":{"temp":-4.06,"feels_like":-6.35,"temp_min":-4.06,"temp_max":-4.06,"pressure":1019,"sea_level":1019,"grnd_level":866,"humidity":90,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":67},"wind":{"speed":1.48,"deg":163,"gust":1.57},"visibility":10000,"pop":0.26,"snow":{"3h":0.19},"sys":{"pod":"d"},"dt_txt":"2023-01-28 15:00:00"},{"dt":1674928800,"main":{"temp":0.61,"feels_like":0.61,"temp_min":0.61,"temp_max":0.61,"pressure":1017,"sea_level":1017,"grnd_level":867,"humidity":73,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":84},"wind":{"speed":0.61,"deg":207,"gust":2.63},"visibility":10000,"pop":0.24,"snow":{"3h":0.13},"sys":{"pod":"d"},"dt_txt":"2023-01-28 18:00:00"}],"city":{"id":5780993,"name":"Salt Lake City","coord":{"lat":40.7587,"lon":-111.8762},"country":"US","population":186440,"timezone":-25200,"sunrise":1674485108,"sunset":1674520390}}';
    OWMForecastWeather owm_forecast = OWMForecastWeather.fromJson(jsonDecode(forecast));
    Weather weather = Weather([], []);
    weather.addFromOWMForecast(owm_forecast);
    expect(weather.current_data_set.length, 0);
    expect(weather.forecast_data_set.length, 40);

    expect(weather.forecast_data_set[0].provider, WeatherProvider.OWM);
    expect(weather.forecast_data_set[0].weather_type, WeatherDataType.OWM801);

    expect(weather.forecast_data_set[0].longitude, -111.8762);
    expect(weather.forecast_data_set[0].latitude, 40.7587);

    expect(weather.forecast_data_set[0].temperature_min_celsius, -1.35);
    expect(weather.forecast_data_set[0].temperature_max_celsius, -0.01);

    expect(weather.forecast_data_set[0].wind_speed, 2.4);
    expect(weather.forecast_data_set[0].wind_direction_in_degrees, 314);
    expect(weather.forecast_data_set[0].wind_speed_gusts, 2.82);

    expect(weather.forecast_data_set[0].visibility_in_meters, 10000);
    expect(weather.forecast_data_set[0].cloudiness_in_percentage, 20);
    expect(weather.forecast_data_set[0].humidity_in_percentage, 67);
    expect(weather.forecast_data_set[0].atmospheric_pressure_hPa, 1022);

    expect(weather.forecast_data_set[0].percent_chance_of_rain, 0);
    expect(weather.forecast_data_set[0].percent_chance_of_snow, 0);

    expect(weather.forecast_data_set[0].precipitation_volume_set.length, 0);

    expect(weather.forecast_data_set[0].prediction_type, WeatherDataPredictionType.HP);
    expect(weather.forecast_data_set[0].prediction_time_for, DateTime.fromMillisecondsSinceEpoch(1674507600000));

    expect(weather.forecast_data_set[39].provider, WeatherProvider.OWM);
    expect(weather.forecast_data_set[39].weather_type, WeatherDataType.OWM600);

    expect(weather.forecast_data_set[39].longitude, -111.8762);
    expect(weather.forecast_data_set[39].latitude, 40.7587);

    expect(weather.forecast_data_set[39].temperature_min_celsius, 0.61);
    expect(weather.forecast_data_set[39].temperature_max_celsius, 0.61);

    expect(weather.forecast_data_set[39].wind_speed, 0.61);
    expect(weather.forecast_data_set[39].wind_direction_in_degrees, 207);
    expect(weather.forecast_data_set[39].wind_speed_gusts, 2.63);

    expect(weather.forecast_data_set[39].visibility_in_meters, 10000);
    expect(weather.forecast_data_set[39].cloudiness_in_percentage, 84);
    expect(weather.forecast_data_set[39].humidity_in_percentage, 73);
    expect(weather.forecast_data_set[39].atmospheric_pressure_hPa, 1017);

    expect(weather.forecast_data_set[39].percent_chance_of_rain, 0);
    expect(weather.forecast_data_set[39].percent_chance_of_snow, 24);

    expect(weather.forecast_data_set[39].precipitation_volume_set.length, 1);
    expect(weather.forecast_data_set[39].precipitation_volume_set[0].type, PrecipitationDataType.S);
    expect(weather.forecast_data_set[39].precipitation_volume_set[0].volume_in_mm, 0.13);
    expect(weather.forecast_data_set[39].precipitation_volume_set[0].recording_duration_in_seconds, WeatherData.THREE_HR_IN_SECONDS);

    expect(weather.forecast_data_set[39].prediction_type, WeatherDataPredictionType.HP);
    expect(weather.forecast_data_set[39].prediction_time_for, DateTime.fromMillisecondsSinceEpoch(1674928800000));
  });
}
