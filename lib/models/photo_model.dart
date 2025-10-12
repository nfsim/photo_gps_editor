import 'dart:io';

import '../utils/exif_utils.dart';

class PhotoModel {
  final String id; // 고유 ID
  final File file; // 이미지 파일
  final String path; // 파일 경로
  final DateTime? takenDate; // 촬영 날짜
  final double? latitude; // GPS 위도
  final double? longitude; // GPS 경도
  final String? device; // 촬영 기기 정보
  final bool hasExif; // EXIF 데이터 존재 여부

  PhotoModel({
    required this.id,
    required this.file,
    required this.path,
    this.takenDate,
    this.latitude,
    this.longitude,
    this.device,
    this.hasExif = false,
  });

  // 선택된 사진 목록 모델
  factory PhotoModel.fromFile(File file) {
    return PhotoModel(
      id: file.path.hashCode.toString(),
      file: file,
      path: file.path,
    );
  }

  // GPS 좌표가 있는지 확인
  bool get hasGpsData => latitude != null && longitude != null;

  // 파일 사이즈 (바이트)
  Future<int> get fileSize async {
    return await file.length();
  }

  // GPS 정보를 업데이트하고 새로운 PhotoModel 반환
  Future<PhotoModel> withNewGPS(
    double latitude,
    double longitude, [
    double altitude = 0,
  ]) async {
    // EXIF에 GPS 정보 저장
    await _updateExifGPS(latitude, longitude, altitude);
    // 새 PhotoModel 반환
    return copyWith(
      latitude: latitude,
      longitude: longitude,
      hasExif: hasExif || true, // GPS 설정되었으므로 exif 존재
    );
  }

  Future<void> _updateExifGPS(
    double latitude,
    double longitude, [
    double altitude = 0,
  ]) async {
    if (await isWritable()) {
      await ExifUtils.setGPS(path, latitude, longitude, altitude);
    } else {
      // 읽기 전용 파일은 EXIF 수정 불가능
      print('File is not writable, cannot update GPS EXIF: $path');
    }
  }

  Future<bool> isWritable() async {
    try {
      // 파일이 쓰기 가능한 디렉토리에 있는지 임시 파일 생성으로 확인
      await file.writeAsBytes([0], mode: FileMode.append, flush: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  PhotoModel copyWith({
    String? id,
    File? file,
    String? path,
    DateTime? takenDate,
    double? latitude,
    double? longitude,
    String? device,
    bool? hasExif,
  }) {
    return PhotoModel(
      id: id ?? this.id,
      file: file ?? this.file,
      path: path ?? this.path,
      takenDate: takenDate ?? this.takenDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      device: device ?? this.device,
      hasExif: hasExif ?? this.hasExif,
    );
  }

  @override
  String toString() {
    return 'PhotoModel(id: $id, path: $path, hasGps: $hasGpsData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhotoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
