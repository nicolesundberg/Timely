import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:timely/owm/owm_forecast_weather.dart';

// Tests modeled after:
//    https://docs.flutter.dev/cookbook/testing/unit/introduction
//    https://docs.flutter.dev/cookbook/testing/unit/mocking
//    https://api.flutter.dev/flutter/package-matcher_matcher/TypeMatcher-class.html

void main() {
  test('OWMForecastWeather: Parsing SLC example OpenWeatherMaps response', () {
    var string = '{"cod":"200","message":0,"cnt":40,"list":[{"dt":1674507600,"main":{"temp":-0.01,"feels_like":-2.93,"temp_min":-1.35,"temp_max":-0.01,"pressure":1022,"sea_level":1022,"grnd_level":872,"humidity":67,"temp_kf":1.34},"weather":[{"id":801,"main":"Clouds","description":"few clouds","icon":"02d"}],"clouds":{"all":20},"wind":{"speed":2.4,"deg":314,"gust":2.82},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-23 21:00:00"},{"dt":1674518400,"main":{"temp":-1.18,"feels_like":-3.34,"temp_min":-3.53,"temp_max":-1.18,"pressure":1024,"sea_level":1024,"grnd_level":873,"humidity":75,"temp_kf":2.35},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03d"}],"clouds":{"all":34},"wind":{"speed":1.65,"deg":300,"gust":2.11},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-24 00:00:00"},{"dt":1674529200,"main":{"temp":-3.37,"feels_like":-3.37,"temp_min":-5.05,"temp_max":-3.37,"pressure":1027,"sea_level":1027,"grnd_level":874,"humidity":85,"temp_kf":1.68},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":69},"wind":{"speed":0.9,"deg":175,"gust":1.16},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-24 03:00:00"},{"dt":1674540000,"main":{"temp":-4.74,"feels_like":-4.74,"temp_min":-4.74,"temp_max":-4.74,"pressure":1031,"sea_level":1031,"grnd_level":875,"humidity":92,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":96},"wind":{"speed":0.79,"deg":191,"gust":0.94},"visibility":6011,"pop":0.2,"snow":{"3h":0.15},"sys":{"pod":"n"},"dt_txt":"2023-01-24 06:00:00"},{"dt":1674550800,"main":{"temp":-6.01,"feels_like":-6.01,"temp_min":-6.01,"temp_max":-6.01,"pressure":1032,"sea_level":1032,"grnd_level":876,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":0.52,"deg":155,"gust":0.72},"visibility":10000,"pop":0.43,"snow":{"3h":0.18},"sys":{"pod":"n"},"dt_txt":"2023-01-24 09:00:00"},{"dt":1674561600,"main":{"temp":-7.74,"feels_like":-10.31,"temp_min":-7.74,"temp_max":-7.74,"pressure":1034,"sea_level":1034,"grnd_level":877,"humidity":94,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"clouds":{"all":91},"wind":{"speed":1.37,"deg":134,"gust":1.37},"visibility":4437,"pop":0.26,"sys":{"pod":"n"},"dt_txt":"2023-01-24 12:00:00"},{"dt":1674572400,"main":{"temp":-7.56,"feels_like":-10.98,"temp_min":-7.56,"temp_max":-7.56,"pressure":1035,"sea_level":1035,"grnd_level":877,"humidity":94,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":95},"wind":{"speed":1.83,"deg":142,"gust":1.92},"visibility":4766,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-24 15:00:00"},{"dt":1674583200,"main":{"temp":-3.58,"feels_like":-3.58,"temp_min":-3.58,"temp_max":-3.58,"pressure":1034,"sea_level":1034,"grnd_level":878,"humidity":88,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":97},"wind":{"speed":1.3,"deg":244,"gust":1.66},"visibility":1314,"pop":0.2,"snow":{"3h":0.13},"sys":{"pod":"d"},"dt_txt":"2023-01-24 18:00:00"},{"dt":1674594000,"main":{"temp":-2.34,"feels_like":-5.88,"temp_min":-2.34,"temp_max":-2.34,"pressure":1031,"sea_level":1031,"grnd_level":877,"humidity":88,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":2.58,"deg":301,"gust":2.98},"visibility":867,"pop":0.28,"snow":{"3h":0.37},"sys":{"pod":"d"},"dt_txt":"2023-01-24 21:00:00"},{"dt":1674604800,"main":{"temp":-3.86,"feels_like":-7.17,"temp_min":-3.86,"temp_max":-3.86,"pressure":1033,"sea_level":1033,"grnd_level":878,"humidity":92,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":2.16,"deg":303,"gust":3.02},"visibility":7217,"pop":0.3,"snow":{"3h":0.34},"sys":{"pod":"d"},"dt_txt":"2023-01-25 00:00:00"},{"dt":1674615600,"main":{"temp":-7.12,"feels_like":-9.59,"temp_min":-7.12,"temp_max":-7.12,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":94,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"clouds":{"all":96},"wind":{"speed":1.36,"deg":134,"gust":1.41},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-25 03:00:00"},{"dt":1674626400,"main":{"temp":-7.95,"feels_like":-11.65,"temp_min":-7.95,"temp_max":-7.95,"pressure":1037,"sea_level":1037,"grnd_level":879,"humidity":92,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":82},"wind":{"speed":1.96,"deg":137,"gust":2.01},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-25 06:00:00"},{"dt":1674637200,"main":{"temp":-6.72,"feels_like":-9.11,"temp_min":-6.72,"temp_max":-6.72,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":92,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04n"}],"clouds":{"all":87},"wind":{"speed":1.35,"deg":147,"gust":2.15},"visibility":8584,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-25 09:00:00"},{"dt":1674648000,"main":{"temp":-5.67,"feels_like":-5.67,"temp_min":-5.67,"temp_max":-5.67,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":93,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":93},"wind":{"speed":1.17,"deg":159,"gust":1.61},"visibility":1218,"pop":0.2,"snow":{"3h":0.22},"sys":{"pod":"n"},"dt_txt":"2023-01-25 12:00:00"},{"dt":1674658800,"main":{"temp":-5.22,"feels_like":-5.22,"temp_min":-5.22,"temp_max":-5.22,"pressure":1036,"sea_level":1036,"grnd_level":880,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":0.88,"deg":174,"gust":1.35},"visibility":512,"pop":0.36,"snow":{"3h":0.18},"sys":{"pod":"d"},"dt_txt":"2023-01-25 15:00:00"},{"dt":1674669600,"main":{"temp":-2.8,"feels_like":-2.8,"temp_min":-2.8,"temp_max":-2.8,"pressure":1035,"sea_level":1035,"grnd_level":880,"humidity":89,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":1.09,"deg":237,"gust":1.66},"visibility":1562,"pop":0.28,"snow":{"3h":0.22},"sys":{"pod":"d"},"dt_txt":"2023-01-25 18:00:00"},{"dt":1674680400,"main":{"temp":-1.99,"feels_like":-4.5,"temp_min":-1.99,"temp_max":-1.99,"pressure":1033,"sea_level":1033,"grnd_level":879,"humidity":91,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":1.8,"deg":303,"gust":1.93},"visibility":405,"pop":0.48,"snow":{"3h":0.34},"sys":{"pod":"d"},"dt_txt":"2023-01-25 21:00:00"},{"dt":1674691200,"main":{"temp":-2.88,"feels_like":-5.77,"temp_min":-2.88,"temp_max":-2.88,"pressure":1034,"sea_level":1034,"grnd_level":879,"humidity":94,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":100},"wind":{"speed":1.97,"deg":316,"gust":2.61},"visibility":533,"pop":0.62,"snow":{"3h":0.55},"sys":{"pod":"d"},"dt_txt":"2023-01-26 00:00:00"},{"dt":1674702000,"main":{"temp":-4.62,"feels_like":-4.62,"temp_min":-4.62,"temp_max":-4.62,"pressure":1037,"sea_level":1037,"grnd_level":881,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":0.81,"deg":345,"gust":1.72},"visibility":3368,"pop":0.53,"snow":{"3h":0.24},"sys":{"pod":"n"},"dt_txt":"2023-01-26 03:00:00"},{"dt":1674712800,"main":{"temp":-5.7,"feels_like":-5.7,"temp_min":-5.7,"temp_max":-5.7,"pressure":1039,"sea_level":1039,"grnd_level":882,"humidity":95,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":96},"wind":{"speed":0.22,"deg":36,"gust":1.36},"visibility":7600,"pop":0.35,"snow":{"3h":0.15},"sys":{"pod":"n"},"dt_txt":"2023-01-26 06:00:00"},{"dt":1674723600,"main":{"temp":-7.82,"feels_like":-7.82,"temp_min":-7.82,"temp_max":-7.82,"pressure":1043,"sea_level":1043,"grnd_level":884,"humidity":95,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":64},"wind":{"speed":0.99,"deg":104,"gust":1.22},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-26 09:00:00"},{"dt":1674734400,"main":{"temp":-8.1,"feels_like":-11.21,"temp_min":-8.1,"temp_max":-8.1,"pressure":1044,"sea_level":1044,"grnd_level":884,"humidity":94,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":67},"wind":{"speed":1.61,"deg":118,"gust":1.39},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-26 12:00:00"},{"dt":1674745200,"main":{"temp":-7.74,"feels_like":-11.64,"temp_min":-7.74,"temp_max":-7.74,"pressure":1044,"sea_level":1044,"grnd_level":885,"humidity":93,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],"clouds":{"all":76},"wind":{"speed":2.11,"deg":124,"gust":1.97},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-26 15:00:00"},{"dt":1674756000,"main":{"temp":-3.11,"feels_like":-5.57,"temp_min":-3.11,"temp_max":-3.11,"pressure":1040,"sea_level":1040,"grnd_level":884,"humidity":86,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],"clouds":{"all":76},"wind":{"speed":1.66,"deg":211,"gust":2.38},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-26 18:00:00"},{"dt":1674766800,"main":{"temp":-1.38,"feels_like":-1.38,"temp_min":-1.38,"temp_max":-1.38,"pressure":1036,"sea_level":1036,"grnd_level":882,"humidity":79,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":95},"wind":{"speed":1.29,"deg":236,"gust":2.1},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-26 21:00:00"},{"dt":1674777600,"main":{"temp":-2.88,"feels_like":-2.88,"temp_min":-2.88,"temp_max":-2.88,"pressure":1037,"sea_level":1037,"grnd_level":881,"humidity":88,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":96},"wind":{"speed":0.22,"deg":1,"gust":1.16},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 00:00:00"},{"dt":1674788400,"main":{"temp":-5.82,"feels_like":-9.31,"temp_min":-5.82,"temp_max":-5.82,"pressure":1037,"sea_level":1037,"grnd_level":880,"humidity":85,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":80},"wind":{"speed":2.05,"deg":135,"gust":2.31},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 03:00:00"},{"dt":1674799200,"main":{"temp":-5.93,"feels_like":-9.78,"temp_min":-5.93,"temp_max":-5.93,"pressure":1036,"sea_level":1036,"grnd_level":879,"humidity":83,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":55},"wind":{"speed":2.29,"deg":132,"gust":2.91},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 06:00:00"},{"dt":1674810000,"main":{"temp":-5.86,"feels_like":-10.04,"temp_min":-5.86,"temp_max":-5.86,"pressure":1033,"sea_level":1033,"grnd_level":877,"humidity":83,"temp_kf":0},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03n"}],"clouds":{"all":27},"wind":{"speed":2.56,"deg":137,"gust":3.35},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 09:00:00"},{"dt":1674820800,"main":{"temp":-5.36,"feels_like":-9.41,"temp_min":-5.36,"temp_max":-5.36,"pressure":1030,"sea_level":1030,"grnd_level":874,"humidity":79,"temp_kf":0},"weather":[{"id":802,"main":"Clouds","description":"scattered clouds","icon":"03n"}],"clouds":{"all":45},"wind":{"speed":2.53,"deg":139,"gust":3.37},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-27 12:00:00"},{"dt":1674831600,"main":{"temp":-3.7,"feels_like":-7.37,"temp_min":-3.7,"temp_max":-3.7,"pressure":1026,"sea_level":1026,"grnd_level":872,"humidity":79,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":100},"wind":{"speed":2.47,"deg":150,"gust":3.47},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 15:00:00"},{"dt":1674842400,"main":{"temp":0.44,"feels_like":-2.08,"temp_min":0.44,"temp_max":0.44,"pressure":1023,"sea_level":1023,"grnd_level":871,"humidity":71,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":100},"wind":{"speed":2.11,"deg":178,"gust":4.13},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 18:00:00"},{"dt":1674853200,"main":{"temp":2.26,"feels_like":0.45,"temp_min":2.26,"temp_max":2.26,"pressure":1018,"sea_level":1018,"grnd_level":868,"humidity":74,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":100},"wind":{"speed":1.77,"deg":195,"gust":3.85},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-27 21:00:00"},{"dt":1674864000,"main":{"temp":0.56,"feels_like":0.56,"temp_min":0.56,"temp_max":0.56,"pressure":1016,"sea_level":1016,"grnd_level":866,"humidity":82,"temp_kf":0},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"clouds":{"all":92},"wind":{"speed":0.43,"deg":195,"gust":1.24},"visibility":10000,"pop":0,"sys":{"pod":"d"},"dt_txt":"2023-01-28 00:00:00"},{"dt":1674874800,"main":{"temp":-2.53,"feels_like":-6.01,"temp_min":-2.53,"temp_max":-2.53,"pressure":1017,"sea_level":1017,"grnd_level":865,"humidity":73,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":60},"wind":{"speed":2.49,"deg":139,"gust":2.85},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-28 03:00:00"},{"dt":1674885600,"main":{"temp":-1.58,"feels_like":-3.69,"temp_min":-1.58,"temp_max":-1.58,"pressure":1015,"sea_level":1015,"grnd_level":863,"humidity":76,"temp_kf":0},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04n"}],"clouds":{"all":74},"wind":{"speed":1.58,"deg":147,"gust":1.81},"visibility":10000,"pop":0,"sys":{"pod":"n"},"dt_txt":"2023-01-28 06:00:00"},{"dt":1674896400,"main":{"temp":0.17,"feels_like":-2.52,"temp_min":0.17,"temp_max":0.17,"pressure":1013,"sea_level":1013,"grnd_level":863,"humidity":80,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":2.22,"deg":205,"gust":5.38},"visibility":4889,"pop":0.24,"snow":{"3h":0.22},"sys":{"pod":"n"},"dt_txt":"2023-01-28 09:00:00"},{"dt":1674907200,"main":{"temp":-0.97,"feels_like":-0.97,"temp_min":-0.97,"temp_max":-0.97,"pressure":1015,"sea_level":1015,"grnd_level":864,"humidity":90,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13n"}],"clouds":{"all":100},"wind":{"speed":0.45,"deg":299,"gust":3.05},"visibility":9459,"pop":0.5,"snow":{"3h":0.71},"sys":{"pod":"n"},"dt_txt":"2023-01-28 12:00:00"},{"dt":1674918000,"main":{"temp":-4.06,"feels_like":-6.35,"temp_min":-4.06,"temp_max":-4.06,"pressure":1019,"sea_level":1019,"grnd_level":866,"humidity":90,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":67},"wind":{"speed":1.48,"deg":163,"gust":1.57},"visibility":10000,"pop":0.26,"snow":{"3h":0.19},"sys":{"pod":"d"},"dt_txt":"2023-01-28 15:00:00"},{"dt":1674928800,"main":{"temp":0.61,"feels_like":0.61,"temp_min":0.61,"temp_max":0.61,"pressure":1017,"sea_level":1017,"grnd_level":867,"humidity":73,"temp_kf":0},"weather":[{"id":600,"main":"Snow","description":"light snow","icon":"13d"}],"clouds":{"all":84},"wind":{"speed":0.61,"deg":207,"gust":2.63},"visibility":10000,"pop":0.24,"snow":{"3h":0.13},"sys":{"pod":"d"},"dt_txt":"2023-01-28 18:00:00"}],"city":{"id":5780993,"name":"Salt Lake City","coord":{"lat":40.7587,"lon":-111.8762},"country":"US","population":186440,"timezone":-25200,"sunrise":1674485108,"sunset":1674520390}}';
    OWMForecastWeather owmweather = OWMForecastWeather.fromJson(jsonDecode(string));
    expect(owmweather.city.id, 5780993);
    expect(owmweather.city.name, 'Salt Lake City');
    expect(owmweather.city.coord.lon, -111.8762);
    expect(owmweather.city.coord.lat, 40.7587);
    expect(owmweather.city.country, 'US');
    expect(owmweather.city.population, 186440);
    expect(owmweather.city.timezone, -25200);
    expect(owmweather.city.sunrise, 1674485108);
    expect(owmweather.city.sunset, 1674520390);

    expect(owmweather.cod, '200');

    expect(owmweather.message, 0);

    expect(owmweather.cnt, 40);

    expect(owmweather.weather![0].dt, 1674507600);

    expect(owmweather.weather![0].main.temp, -0.01);
    expect(owmweather.weather![0].main.feels_like, -2.93);
    expect(owmweather.weather![0].main.temp_min, -1.35);
    expect(owmweather.weather![0].main.temp_max, -0.01);
    expect(owmweather.weather![0].main.pressure, 1022);
    expect(owmweather.weather![0].main.humidity, 67);
    expect(owmweather.weather![0].main.sea_level, 1022);
    expect(owmweather.weather![0].main.grnd_level, 872);

    expect(owmweather.weather![0].weather!.first.id, 801);
    expect(owmweather.weather![0].weather!.first.main, 'Clouds');
    expect(owmweather.weather![0].weather!.first.description, 'few clouds');
    expect(owmweather.weather![0].weather!.first.icon, '02d');

    expect(owmweather.weather![0].clouds!.all, 20);

    expect(owmweather.weather![0].wind!.speed, 2.4);
    expect(owmweather.weather![0].wind!.deg, 314);
    expect(owmweather.weather![0].wind!.gust, 2.82);

    expect(owmweather.weather![0].visibility, 10000);

    expect(owmweather.weather![0].pop, 0);

    expect(owmweather.weather![0].rain, null);

    expect(owmweather.weather![0].snow, null);

    expect(owmweather.weather![0].sys!.pod, 'd');

    expect(owmweather.weather![0].dt_txt, '2023-01-23 21:00:00');

    expect(owmweather.weather![39].dt, 1674928800);

    expect(owmweather.weather![39].main.temp, 0.61);
    expect(owmweather.weather![39].main.feels_like, 0.61);
    expect(owmweather.weather![39].main.temp_min, 0.61);
    expect(owmweather.weather![39].main.temp_max, 0.61);
    expect(owmweather.weather![39].main.pressure, 1017);
    expect(owmweather.weather![39].main.humidity, 73);
    expect(owmweather.weather![39].main.sea_level, 1017);
    expect(owmweather.weather![39].main.grnd_level, 867);

    expect(owmweather.weather![39].weather!.first.id, 600);
    expect(owmweather.weather![39].weather!.first.main, 'Snow');
    expect(owmweather.weather![39].weather!.first.description, 'light snow');
    expect(owmweather.weather![39].weather!.first.icon, '13d');

    expect(owmweather.weather![39].clouds!.all, 84);

    expect(owmweather.weather![39].wind!.speed, 0.61);
    expect(owmweather.weather![39].wind!.deg, 207);
    expect(owmweather.weather![39].wind!.gust, 2.63);

    expect(owmweather.weather![39].visibility, 10000);

    expect(owmweather.weather![39].pop, 0.24);

    expect(owmweather.weather![39].rain, null);

    expect(owmweather.weather![39].snow!.oneHr, null);
    expect(owmweather.weather![39].snow!.threeHr, 0.13);

    expect(owmweather.weather![39].sys!.pod, 'd');

    expect(owmweather.weather![39].dt_txt, '2023-01-28 18:00:00');
  });
}