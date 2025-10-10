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
      // GPS 위도 추출 및 변환
      final latitudeRef = data['GPS GPSLatitudeRef']?.toString();
      final latitudeValues = data['GPS GPSLatitude']?.values;

      // GPS 경도 추출 및 변환
      final longitudeRef = data['GPS GPSLongitudeRef']?.toString();
      final longitudeValues = data['GPS GPSLongitude']?.values;

      if (latitudeValues == null ||
          longitudeValues == null ||
          latitudeRef == null ||
          longitudeRef == null) {
        return null; // GPS 데이터 불완전
      }

      final latitude = _convertGpsToDecimal(latitudeValues, latitudeRef);
      final longitude = _convertGpsToDecimal(longitudeValues, longitudeRef);

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
      // IfdValues를 List로 변환
      final List<dynamic> gpsList = _convertIfdValuesToList(values);
      if (gpsList.length < 3) return null;

      // EXIF GPS 값 처리 (exif 패키지 형식에 따라)
      final degrees = _extractNumericValue(gpsList[0]);
      final minutes = _extractNumericValue(gpsList[1]);
      final seconds = _extractNumericValue(gpsList[2]);

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

  /// IfdValues를 List로 변환
  static List<dynamic> _convertIfdValuesToList(dynamic values) {
    if (values is List) return values;
    // exif 패키지의 IfdValues 타입에 따라 변환
    return values?.values?.toList() ?? [];
  }

  /// 다양한 형식의 숫자 값 추출
  static double? _extractNumericValue(dynamic value) {
    try {
      if (value is num) {
        return value.toDouble();
      } else if (value is List && value.length >= 1) {
        // GPS 값은 다양한 형식으로 올 수 있음
        final firstValue = value[0];
        if (firstValue is num) {
          return firstValue.toDouble();
        } else if (firstValue is String) {
          return double.tryParse(firstValue);
        }
      }
      // 다른 형식이 있다면 추가 처리 가능
      return double.tryParse(value.toString());
    } catch (e) {
      print('숫자 값 추출 중 오류: $e');
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
