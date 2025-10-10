import 'dart:io';
import 'package:exif/exif.dart';

class ExifService {
  /// 사진 파일로부터 EXIF 데이터를 추출하는 메인 메서드
  static Future<Map<String, dynamic>?> extractExifData(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final data = await readExifFromBytes(bytes);

      if (data.isEmpty) {
        return null;
      }

      return _parseExifData(data);
    } catch (e) {
      print('EXIF 추출 중 오류 발생: $e');
      return null;
    }
  }

  /// EXIF 데이터를 파싱하여 필요한 정보 추출
  static Map<String, dynamic> _parseExifData(Map<String, IfdTag> data) {
    final result = <String, dynamic>{};

    // 촬영 날짜 추출
    final dateTime = data['Image DateTime']?.toString();
    if (dateTime != null) {
      try {
        result['takenDate'] = _parseDateTime(dateTime);
      } catch (e) {
        print('촬영 날짜 파싱 오류: $e');
      }
    }

    // 기기 정보 추출
    final make = data['Image Make']?.toString();
    final model = data['Image Model']?.toString();
    if (make != null || model != null) {
      result['device'] = [make, model].where((e) => e != null).join(' ').trim();
    }

    // GPS 정보 추출 및 변환이 주된 기능
    final gpsData = _extractGpsData(data);
    if (gpsData != null) {
      result.addAll(gpsData);
    }

    result['hasExif'] = true;
    result['exifComplete'] = gpsData != null;

    return result;
  }

  /// GPS 데이터를 추출하고 Decimal 좌표로 변환
  static Map<String, dynamic>? _extractGpsData(Map<String, IfdTag> data) {
    try {
      print('GPS 데이터 추출 시작...');

      // 디버깅: 모든 GPS 관련 키 확인
      final gpsKeys = data.keys.where((k) => k.contains('GPS')).toList();
      print('GPS 관련 키들: $gpsKeys');

      // GPS 위도 추출 및 변환
      final latitudeRef = data['GPS GPSLatitudeRef']?.toString();
      final latitudeTag = data['GPS GPSLatitude'];
      final latitudeValues = latitudeTag?.values;

      print('GPS GPSLatitude tag: $latitudeTag');
      print(
        'GPS GPSLatitude values: $latitudeValues (type: ${latitudeValues?.runtimeType})',
      );

      // GPS 경도 추출 및 변환
      final longitudeRef = data['GPS GPSLongitudeRef']?.toString();
      final longitudeTag = data['GPS GPSLongitude'];
      final longitudeValues = longitudeTag?.values;

      print(
        'GPS GPSLongitude values: $longitudeValues (type: ${longitudeValues?.runtimeType})',
      );
      print('Refs - Lat: $latitudeRef, Lon: $longitudeRef');

      if (latitudeValues == null ||
          longitudeValues == null ||
          latitudeRef == null ||
          longitudeRef == null) {
        print('GPS 데이터 불완전 - 값들이 null입니다');
        return null; // GPS 데이터 불완전
      }

      // IfdValues를 List로 변환
      final latValuesList = latitudeValues.toList();
      final lonValuesList = longitudeValues.toList();

      print('DMS 값들 정리:');
      print('  위도 리스트: $latValuesList (${latValuesList.runtimeType})');
      for (int i = 0; i < latValuesList.length; i++) {
        print(
          '  위도[$i]: ${latValuesList[i]} (${latValuesList[i].runtimeType})',
        );
      }
      print('  경도 리스트: $lonValuesList (${lonValuesList.runtimeType})');
      for (int i = 0; i < lonValuesList.length; i++) {
        print(
          '  경도[$i]: ${lonValuesList[i]} (${lonValuesList[i].runtimeType})',
        );
      }

      final latitude = _convertGpsToDecimal(latValuesList, latitudeRef);
      final longitude = _convertGpsToDecimal(lonValuesList, longitudeRef);

      print('변환된 좌표 - 위도: $latitude, 경도: $longitude');

      if (latitude == null || longitude == null) {
        return null;
      }

      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      print('GPS 데이터 추출 중 오류: $e');
      return null;
    }
  }

  /// DMS (Degrees, Minutes, Seconds) 형식을 Decimal Degrees로 변환
  static double? _convertGpsToDecimal(dynamic values, String ref) {
    try {
      // GPS 데이터는 보통 3개의 값으로 구성됨 (도, 분, 초)
      if (values is! List || values.length < 3) return null;

      // 각 GPS 값 추출 (GPS 형식)
      final degrees = _extractGpsValue(values[0]);
      final minutes = _extractGpsValue(values[1]);
      final seconds = _extractGpsValue(values[2]);

      if (degrees == null || minutes == null || seconds == null) {
        return null;
      }

      // Decimal degrees 계산
      var decimal = degrees + (minutes / 60.0) + (seconds / 3600.0);

      // 남반구 또는 서경의 경우 음수로 변환
      if (ref == 'S' || ref == 'W') {
        decimal = -decimal;
      }

      return decimal;
    } catch (e) {
      print('GPS 좌표 변환 중 오류: $e');
      return null;
    }
  }

  /// GPS 값에서 숫자 추출 (exif 패키지 Rational 값 처리용)
  static double? _extractGpsValue(dynamic value) {
    try {
      // exif 패키지에서는 값들이 Rational 형태로 "813/25" 등으로 올 수 있음
      if (value is num) {
        return value.toDouble();
      } else if (value is Ratio) {
        // Ratio 타입 처리 (exif 패키지의 Rational 수)
        return value.toDouble();
      } else if (value is String) {
        // Rational 값들 처리: "813/25" -> 32.52
        final stringValue = value.toString().trim();

        // 분수 표현 처리 (예: "813/25")
        if (stringValue.contains('/')) {
          final parts = stringValue.split('/');
          if (parts.length == 2) {
            final numerator = double.tryParse(parts[0]);
            final denominator = double.tryParse(parts[1]);
            if (numerator != null && denominator != null && denominator != 0) {
              return numerator / denominator;
            }
          }
        }

        // 일반 숫자 파싱
        return double.tryParse(stringValue);
      } else if (value is List && value.isNotEmpty) {
        // 리스트인 경우 재귀적으로 첫 번째 값 처리
        return _extractGpsValue(value[0]);
      } else {
        // 다른 형식의 값들 처리 (Rational 객체 등)
        final stringValue = value.toString();

        // Rational 문짝수열일 경우 처리
        if (stringValue.contains('(') && stringValue.contains(')')) {
          // Rational 객체의 toString형태일 경우
          final match = RegExp(r'(\d+)/(\d+)').firstMatch(stringValue);
          if (match != null) {
            final numerator = double.tryParse(match.group(1)!);
            final denominator = double.tryParse(match.group(2)!);
            if (numerator != null && denominator != null && denominator != 0) {
              return numerator / denominator;
            }
          }
        }

        // 마지막으로 직접 숫자 파싱 시도
        return double.tryParse(stringValue.replaceAll(RegExp(r'[^\d./-]'), ''));
      }
    } catch (e) {
      print('GPS 값 추출 중 오류: $e (${value?.runtimeType})');
      return null;
    }
  }

  /// EXIF 날짜 문자열 파싱 (예: "2023:10:01 12:34:56")
  static DateTime? _parseDateTime(String dateTimeString) {
    try {
      // "YYYY:MM:DD HH:MM:SS" 형식 파싱
      final parts = dateTimeString.split(' ');
      if (parts.length != 2) return null;

      final dateParts = parts[0].split(':');
      final timeParts = parts[1].split(':');

      if (dateParts.length != 3 || timeParts.length != 3) return null;

      return DateTime(
        int.parse(dateParts[0]), // 년
        int.parse(dateParts[1]), // 월
        int.parse(dateParts[2]), // 일
        int.parse(timeParts[0]), // 시
        int.parse(timeParts[1]), // 분
        int.parse(timeParts[2]), // 초
      );
    } catch (e) {
      print('EXIF 날짜 파싱 중 오류: $e');
      return null;
    }
  }

  /// 여러 사진들의 EXIF 데이터를 배치로 추출 (성능 최적화)
  static Future<List<Map<String, dynamic>>> extractMultipleExifData(
    List<File> imageFiles, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final results = <Map<String, dynamic>>[];
    final total = imageFiles.length;

    for (int i = 0; i < total; i++) {
      final file = imageFiles[i];
      final exifData = await extractExifData(file);
      results.add({'file': file, 'exifData': exifData, 'index': i});

      onProgress?.call(i + 1, total);
    }

    return results;
  }

  /// GPS 좌표 유효성 검사
  static bool isValidGpsCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;

    // 위도: -90 ~ 90
    if (latitude < -90 || latitude > 90) return false;

    // 경도: -180 ~ 180
    if (longitude < -180 || longitude > 180) return false;

    return true;
  }
}
