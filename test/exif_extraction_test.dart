import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/services/exif_test_service.dart';

/// EXIF 추출 기능 테스트
void main() {
  group('EXIF 추출 기능 테스트', () {
    test('GPS 포함 이미지로 EXIF 추출 테스트', () async {
      final gpsImageFile = File('test/assets/test_img_with_gps.jpg');
      expect(await gpsImageFile.exists(), isTrue);

      // GPS 포함 이미지 테스트 실행
      await ExifTestService.testGPSExtraction(gpsImageFile);

      print('✅ GPS 포함 이미지 테스트 완료');
    });

    test('GPS 미포함 이미지로 EXIF 추출 테스트', () async {
      final noGpsImageFile = File('test/assets/test_img_no_gps.jpeg');
      expect(await noGpsImageFile.exists(), isTrue);

      // GPS 미포함 이미지 테스트 실행
      await ExifTestService.testGPSExtraction(noGpsImageFile);

      print('✅ GPS 미포함 이미지 테스트 완료');
    });

    test('배치 EXIF 추출 테스트', () async {
      final gpsImage = File('test/assets/test_img_with_gps.jpg');
      final noGpsImage = File('test/assets/test_img_no_gps.jpeg');

      final testFiles = [gpsImage, noGpsImage];

      for (final file in testFiles) {
        expect(await file.exists(), isTrue);
      }

      // 배치 테스트 실행
      await ExifTestService.testBatchGPSExtraction(testFiles);

      print('✅ 배치 EXIF 추출 테스트 완료');
    });

    test('메인 테스트 함수 실행', () async {
      await runExifExtractionTests();

      print('🎯 전체 EXIF 추출 테스트 완료');
    });
  });
}
