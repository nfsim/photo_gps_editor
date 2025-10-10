import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/services/exif_service.dart';

/// EXIF 추출 기능 테스트
void main() {
  group('EXIF 추출 기능 테스트', () {
    test('GPS 포함 이미지로 EXIF 추출 테스트', () async {
      final gpsImageFile = File('test/assets/test_img_with_gps.jpg');
      expect(await gpsImageFile.exists(), isTrue);

      // EXIF 추출 실행 및 검증
      final exifData = await ExifService.extractExifData(gpsImageFile);

      expect(exifData, isNotNull);
      expect(exifData!['hasExif'], isTrue);
      expect(exifData['latitude'], isNotNull, reason: 'GPS 이미지는 위도를 포함해야 함');
      expect(exifData['longitude'], isNotNull, reason: 'GPS 이미지는 경도를 포함해야 함');
      expect(exifData['exifComplete'], isTrue, reason: 'GPS 추출이 완료되어야 함');

      // GPS 좌표 유효성 검사
      final latitude = exifData['latitude'] as double;
      final longitude = exifData['longitude'] as double;

      expect(
        ExifService.isValidGpsCoordinates(latitude, longitude),
        isTrue,
        reason: '추출된 GPS 좌표가 유효해야 함',
      );

      print('✅ GPS 포함 이미지 테스트 완료');
    });

    test('GPS 미포함 이미지로 EXIF 추출 테스트', () async {
      final noGpsImageFile = File('test/assets/test_img_no_gps.jpeg');
      expect(await noGpsImageFile.exists(), isTrue);

      // EXIF 추출 실행
      final exifData = await ExifService.extractExifData(noGpsImageFile);

      if (exifData != null) {
        expect(exifData['hasExif'], isTrue);
        expect(exifData['latitude'], isNull, reason: 'GPS 없는 이미지는 위도가 없어야 함');
        expect(exifData['longitude'], isNull, reason: 'GPS 없는 이미지는 경도가 없어야 함');
        expect(
          exifData['exifComplete'],
          isFalse,
          reason: 'GPS 추출 실패는 false여야 함',
        );
      }

      print('✅ GPS 미포함 이미지 테스트 완료');
    });

    test('배치 EXIF 추출 테스트', () async {
      final gpsImage = File('test/assets/test_img_with_gps.jpg');
      final noGpsImage = File('test/assets/test_img_no_gps.jpeg');

      final testFiles = [gpsImage, noGpsImage];

      for (final file in testFiles) {
        expect(await file.exists(), isTrue);
      }

      // 배치 추출 실행
      final results = await ExifService.extractMultipleExifData(testFiles);
      expect(results.length, equals(2));

      // 각 파일별 EXIF 데이터 검증
      final gpsResult = results.firstWhere((r) => r['file'] == gpsImage);
      final noGpsResult = results.firstWhere((r) => r['file'] == noGpsImage);

      expect(gpsResult['exifData'], isNotNull);
      expect((gpsResult['exifData'] as Map)['latitude'], isNotNull);

      if (noGpsResult['exifData'] != null) {
        expect((noGpsResult['exifData'] as Map)['latitude'], isNull);
      }

      print('✅ 배치 EXIF 추출 테스트 완료');
    });
  });
}
