import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/utils/exif_utils.dart';

void main() {
  group('ExifUtils GPS Tests', () {
    test('GPS 사진에서 EXIF GPS 읽기', () async {
      const gpsImagePath = 'test/resources/test_img_gps.jpg';
      final file = File(gpsImagePath);
      if (file.existsSync()) {
        final gpsData = await ExifUtils.readGPS(gpsImagePath);
        expect(gpsData.isNotEmpty, true);
        expect(gpsData['latitude'], isNotNull);
        expect(gpsData['latitude'] != 0.0, true);
        expect(gpsData['longitude'], isNotNull);
        expect(gpsData['longitude'] != 0.0, true);
      } else {
        fail('Test GPS image file not found: $gpsImagePath');
      }
    });

    test('GPS 없는 사진에서 EXIF GPS 읽기 (빈 결과)', () async {
      const noGpsImagePath = 'test/resources/test_img_no_gps.jpeg';
      final file = File(noGpsImagePath);
      if (file.existsSync()) {
        final gpsData = await ExifUtils.readGPS(noGpsImagePath);
        expect(gpsData.isEmpty, true);
      } else {
        fail('Test No GPS image file not found: $noGpsImagePath');
      }
    });
  });
}
