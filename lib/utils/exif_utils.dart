import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

const MethodChannel _exifChannel = MethodChannel(
  'com.example.photo_gps_editor/exif',
);

class ExifUtils {
  static Future<Map<String, double?>> readGPS(String path) async {
    try {
      print('Reading EXIF for file: ${p.basename(path)}');
      final file = File(path);
      final bytes = await file.readAsBytes();
      final Map<String, IfdTag> data = await readExifFromBytes(bytes);
      // TEMP LOGS TO REMOVE AFTER DEBUGGING
      print('All EXIF keys: ${data.keys.toList()}');
      print(
        'EXIF data keys for GPS: ${data.keys.where((k) => k.contains('GPS'))}',
      );
      for (var key in data.keys.where((k) => k.contains('GPS'))) {
        print(
          'GPS Tag $key: ${data[key]}, values: ${data[key]!.values}, toList: ${data[key]!.values.toList()}',
        );
      }

      if (!data.containsKey('GPS GPSLatitude') ||
          !data.containsKey('GPS GPSLongitude') ||
          !data.containsKey('GPS GPSLatitudeRef') ||
          !data.containsKey('GPS GPSLongitudeRef')) {
        print('GPS tags not found in EXIF');
        return {};
      }

      final latValsList = data['GPS GPSLatitude']!.values.toList() as List;
      final latRefList = data['GPS GPSLatitudeRef']!.values.toList() as List;
      final lonValsList = data['GPS GPSLongitude']!.values.toList() as List;
      final lonRefList = data['GPS GPSLongitudeRef']!.values.toList() as List;

      print(
        'latValsList: $latValsList, latRefList: $latRefList, lonValsList: $lonValsList, lonRefList: $lonRefList',
      );

      if (latValsList.isEmpty ||
          latRefList.isEmpty ||
          lonValsList.isEmpty ||
          lonRefList.isEmpty) {
        print('GPS lists empty');
        return {};
      }

      final latVals = latValsList;
      final latRef = String.fromCharCode(latRefList[0].toInt());
      final lonVals = lonValsList;
      final lonRef = String.fromCharCode(lonRefList[0].toInt());

      print(
        'LatVals: $latVals, LatRef: $latRef, LonVals: $lonVals, LonRef: $lonRef',
      );

      if (latVals.isEmpty ||
          lonVals.isEmpty ||
          latVals.length < 3 ||
          lonVals.length < 3) {
        print('GPS values malformed or empty');
        return {};
      }

      final latDegrees = latVals[0].toDouble();
      final latMinutes = latVals[1].toDouble();
      final latSeconds = latVals[2].toDouble();
      final lat =
          (latDegrees + latMinutes / 60 + latSeconds / 3600) *
          (latRef == 'N' ? 1 : -1);

      final lonDegrees = lonVals[0].toDouble();
      final lonMinutes = lonVals[1].toDouble();
      final lonSeconds = lonVals[2].toDouble();
      final lon =
          (lonDegrees + lonMinutes / 60 + lonSeconds / 3600) *
          (lonRef == 'E' ? 1 : -1);

      print('Calculated GPS: lat=$lat, lon=$lon');

      return {'latitude': lat, 'longitude': lon};
    } catch (e) {
      print('EXIF read error: $e');
      return {};
    }
  }

  static Future<void> setGPS(
    String path,
    double latitude,
    double longitude, [
    double altitude = 0,
  ]) async {
    await _exifChannel.invokeMethod('setExifGPS', {
      'path': path,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
    });
  }
}
