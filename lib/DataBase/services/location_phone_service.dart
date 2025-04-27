import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart';
import 'package:molokosbor/DataBase/models/drop_point.dart';
import 'package:molokosbor/DataBase/models/profiles.dart';

import 'package:url_launcher/url_launcher.dart';

class LocationPhoneService {
  Future<void> map(DropPoint drop_point) async {
    final availableMaps = await MapLauncher.installedMaps;
    final address =
        "${drop_point!.settlement!.coords} ${drop_point!.settlement!.name} ${drop_point!.adress}";
    print(address);
    const apiKey = '0bb9cf09-ec3f-459e-a521-4cef3b3347e8';
    final url = Uri.parse(
        'https://geocode-maps.yandex.ru/v1/?apikey=$apiKey&geocode=$address&format=json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final point = data['response']['GeoObjectCollection']['featureMember']
            .first['GeoObject']['Point']['pos'];
        final coords = point.split(' ');
        final latitude = double.parse(coords[1]);
        final longitude = double.parse(coords[0]);
        await availableMaps.first
            .showMarker(coords: Coords(latitude, longitude), title: address);
      }
    } catch (e) {
      debugPrint('Error opening map: \$e');
    }
  }


}
