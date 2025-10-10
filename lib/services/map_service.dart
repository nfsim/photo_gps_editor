import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class MapService {
  static const String googleMapsApiKeyWeb = 'YOUR_WEB_API_KEY';
  static const String googleMapsApiKeyAndroid = 'YOUR_ANDROID_API_KEY';
  static const String googleMapsApiKeyIOS = 'YOUR_IOS_API_KEY';

  // 위치 권한을 확인하고 요청하는 함수
  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한 거부됨
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 영구적으로 거부됨
      return false;
    }

    // 권한 허용됨
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // 현재 위치를 가져오는 함수
  static Future<gmaps.LatLng?> getCurrentLocation() async {
    try {
      final bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return gmaps.LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('현재 위치 가져오기 실패: $e');
      return null;
    }
  }

  // 두 좌표 사이의 거리를 계산 (미터 단위)
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // 지도 카메라 초기 위치 결정
  static gmaps.CameraPosition getInitialCameraPosition() {
    return const gmaps.CameraPosition(
      target: gmaps.LatLng(37.5665, 126.9780), // 서울 시청 기본 위치
      zoom: 10.0,
    );
  }

  // 좌표 목록의 바운더리를 계산
  static gmaps.LatLngBounds? calculateLatLngBounds(
    List<gmaps.LatLng> coordinates,
  ) {
    if (coordinates.isEmpty) return null;

    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    return gmaps.LatLngBounds(
      southwest: gmaps.LatLng(minLat, minLng),
      northeast: gmaps.LatLng(maxLat, maxLng),
    );
  }

  // 위치가 유효한 범위 내인지 확인 (지구 위 실제 좌표 범위)
  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }
}
