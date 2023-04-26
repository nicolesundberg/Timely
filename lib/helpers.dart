import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

String getTimeZoneName() {
  return DateTime.now().timeZoneName;
}


Color stringToColor(String colorText) {
  //https://stackoverflow.com/questions/49835146/how-to-convert-flutter-color-to-string-and-back-to-a-color
  String valueString = colorText.split('(0x')[1].split(')')[0]; // kind of hacky..
  int value = int.parse(valueString, radix: 16);
  return Color(value);
}

Color getColorObject(String colorId) {
  var hexString = colorId;
  final buffer = StringBuffer();
  if (hexString?.length == 6 || hexString?.length == 7) buffer.write('ff');
  buffer.write(hexString?.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}


Future<String?> getLocationUsingPlacesAutocomplete(BuildContext context) async {
  try {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
      onError: (error) {
        log(error.errorMessage.toString());
      },
      mode: Mode.overlay,
      hint: 'Search Location',
      language: 'en',
      types: [''],
      components: [Component(Component.country, 'us')],
      strictbounds: false,
    );

    if (p != null) {
      var location =
      await GoogleMapsPlaces(apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!)
          .getDetailsByPlaceId(p.placeId!);
      return location.result.formattedAddress!;
    } else {
      return null;
    }
  } catch (e) {
    log(e.toString());
  }
  return null;
}
