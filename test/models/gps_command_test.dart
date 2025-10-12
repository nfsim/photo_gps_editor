import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/models/gps_command.dart';
import 'package:photo_gps_editor/models/photo_model.dart';

void main() {
  group('GPSCommand Tests', () {
    test('SetGPSCommand execute and undo', () {
      final originalPhoto = PhotoModel(
        id: '1',
        file: File('dummy'),
        path: 'dummy',
        latitude: 37.0,
        longitude: 127.0,
      );

      final command = SetGPSCommand(40.0, 130.0);
      final executedPhoto = command.execute(originalPhoto);

      expect(executedPhoto.latitude, 40.0);
      expect(executedPhoto.longitude, 130.0);

      final undonePhoto = command.undo();
      expect(undonePhoto.latitude, 37.0);
      expect(undonePhoto.longitude, 127.0);
    });
  });
}
