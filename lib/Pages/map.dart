import 'package:flutter/material.dart';
import 'package:yandex_maps_mapkit_lite/mapkit.dart';
import 'package:yandex_maps_mapkit_lite/yandex_map.dart';

class Mapss extends StatefulWidget {
  const Mapss({super.key});

  @override
  State<Mapss> createState() => _MapssState();
}

class _MapssState extends State<Mapss> {
  @override
   Widget build(BuildContext context) {
     MapWindow? _mapWindow;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Карта (Yandex Mapkit)"),
      ),
      body: YandexMap(onMapCreated: (mapWindow) => _mapWindow = mapWindow)
    );
}}