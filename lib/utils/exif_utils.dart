import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/services.dart';

const MethodChannel _exifChannel = MethodChannel(
  'com.example.photo_gps_editor/exif',
);

class ExifUtils {
  static Future<Map<String, double?>> readGPS(String path) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      final Map<String, IfdTag> data = await readExifFromBytes(bytes);

      if (!data.containsKey('GPS GPSLatitude') ||
          !data.containsKey('GPS GPSLongitude') ||
          !data.containsKey('GPS GPSLatitudeRef') ||
          !data.containsKey('GPS GPSLongitudeRef')) {
        return {};
      }

      final latValsList = data['GPS GPSLatitude']!.values.toList();
      final latRefList = data['GPS GPSLatitudeRef']!.values.toList();
      final lonValsList = data['GPS GPSLongitude']!.values.toList();
      final lonRefList = data['GPS GPSLongitudeRef']!.values.toList();

      if (latValsList.isEmpty ||
          latRefList.isEmpty ||
          lonValsList.isEmpty ||
          lonRefList.isEmpty) {
        return {};
      }

      final latVals = latValsList;
      final latRef = String.fromCharCode(latRefList[0].toInt());
      final lonVals = lonValsList;
      final lonRef = String.fromCharCode(lonRefList[0].toInt());

      if (latVals.isEmpty ||
          lonVals.isEmpty ||
          latVals.length < 3 ||
          lonVals.length < 3) {
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

      return {'latitude': lat, 'longitude': lon};
    } catch (e) {
      // EXIF read error - ignored for robustness
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
