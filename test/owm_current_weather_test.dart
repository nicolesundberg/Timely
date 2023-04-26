import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:timely/owm/owm_current_weather.dart';

// Tests modeled after:
//    https://docs.flutter.dev/cookbook/testing/unit/introduction
//    https://docs.flutter.dev/cookbook/testing/unit/mocking
//    https://api.flutter.dev/flutter/package-matcher_matcher/TypeMatcher-class.html

void main() {
  test('OWMCurrentWeather: Parsing OpenWeatherMaps API docs example response', () {
    var string = '{"coord": { "lon": 10.99, "lat": 44.34 }, "weather": [ { "id": 501, "main": "Rain", "description": "moderate rain", "icon": "10d" } ], "base": "stations", "main": { "temp": 298.48, "feels_like": 298.74, "temp_min": 297.56, "temp_max": 300.05, "pressure": 1015, "humidity": 64, "sea_level": 1015, "grnd_level": 933 }, "visibility": 10000, "wind": { "speed": 0.62, "deg": 349, "gust": 1.18 }, "rain": { "1h": 3.16 }, "clouds": { "all": 100 }, "dt": 1661870592, "sys": { "type": 2, "id": 2075663, "country": "IT", "sunrise": 1661834187, "sunset": 1661882248 }, "timezone": 7200, "id": 3163858, "name": "Zocca", "cod": 200 }';
    OWMCurrentWeather owmweather = OWMCurrentWeather.fromJson(jsonDecode(string));
    expect(owmweather.coord.lon, 10.99);
    expect(owmweather.coord.lat, 44.34);

    expect(owmweather.weather!.first.id, 501);
    expect(owmweather.weather!.first.main, 'Rain');
    expect(owmweather.weather!.first.description, 'moderate rain');
    expect(owmweather.weather!.first.icon, '10d');

    expect(owmweather.base, 'stations');

    expect(owmweather.main.temp, 298.48);
    expect(owmweather.main.feels_like, 298.74);
    expect(owmweather.main.temp_min, 297.56);
    expect(owmweather.main.temp_max, 300.05);
    expect(owmweather.main.pressure, 1015);
    expect(owmweather.main.humidity, 64);
    expect(owmweather.main.sea_level, 1015);
    expect(owmweather.main.grnd_level, 933);

    expect(owmweather.visibility, 10000);

    expect(owmweather.wind!.speed, 0.62);
    expect(owmweather.wind!.deg, 349);
    expect(owmweather.wind!.gust, 1.18);

    expect(owmweather.rain!.oneHr, 3.16);
    expect(owmweather.rain!.threeHr, null);

    expect(owmweather.snow, null);

    expect(owmweather.clouds!.all, 100);

    expect(owmweather.dt, 1661870592);
    expect(owmweather.recorded_at, DateTime.fromMillisecondsSinceEpoch(1661870592000));

    expect(owmweather.sys!.country, 'IT');
    expect(owmweather.sys!.sunrise, 1661834187);
    expect(owmweather.sys!.sunset, 1661882248);
    expect(owmweather.timezone, 7200);
    expect(owmweather.id, 3163858);
    expect(owmweather.name, 'Zocca');
  });

  test('OWMCurrentWeather: Parsing SLC example OpenWeatherMaps response', () {
    var string = '{"coord":{"lon":-111.8762,"lat":40.7587},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"base":"stations","main":{"temp":1.2,"feels_like":-2.53,"temp_min":-2.01,"temp_max":4.47,"pressure":1028,"humidity":77},"visibility":10000,"wind":{"speed":3.6,"deg":190},"clouds":{"all":100},"dt":1673607967,"sys":{"type":2,"id":2004156,"country":"US","sunrise":1673621414,"sunset":1673655698},"timezone":-25200,"id":5780993,"name":"Salt Lake City","cod":200}';
    OWMCurrentWeather owmweather = OWMCurrentWeather.fromJson(jsonDecode(string));
    expect(owmweather.coord.lon, -111.8762);
    expect(owmweather.coord.lat, 40.7587);

    expect(owmweather.weather!.first.id, 804);
    expect(owmweather.weather!.first.main, 'Clouds');
    expect(owmweather.weather!.first.description, 'overcast clouds');
    expect(owmweather.weather!.first.icon, '04n');

    expect(owmweather.base, 'stations');

    expect(owmweather.main.temp, 1.2);
    expect(owmweather.main.feels_like, -2.53);
    expect(owmweather.main.temp_min, -2.01);
    expect(owmweather.main.temp_max, 4.47);
    expect(owmweather.main.pressure, 1028);
    expect(owmweather.main.humidity, 77);
    expect(owmweather.main.sea_level, null);
    expect(owmweather.main.grnd_level, null);

    expect(owmweather.visibility, 10000);

    expect(owmweather.wind!.speed, 3.6);
    expect(owmweather.wind!.deg, 190);
    expect(owmweather.wind!.gust, null);

    expect(owmweather.rain, null);

    expect(owmweather.snow, null);

    expect(owmweather.clouds!.all, 100);

    expect(owmweather.dt, 1673607967);
    expect(owmweather.recorded_at, DateTime.fromMillisecondsSinceEpoch(1673607967000));

    expect(owmweather.sys!.country, 'US');
    expect(owmweather.sys!.sunrise, 1673621414);
    expect(owmweather.sys!.sunset, 1673655698);
    expect(owmweather.timezone, -25200);
    expect(owmweather.id, 5780993);
    expect(owmweather.name, 'Salt Lake City');
  });
}