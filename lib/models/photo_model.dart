import 'dart:io';

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
