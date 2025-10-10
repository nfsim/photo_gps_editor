import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/photo_model.dart';
import '../services/exif_service.dart';

class PhotoProvider extends ChangeNotifier {
  final List<PhotoModel> _selectedPhotos = [];
  bool _isSelecting = false; // 사진 선택 중인지 여부

  // 선택된 사진 목록
  List<PhotoModel> get selectedPhotos => List.unmodifiable(_selectedPhotos);

  // 선택된 사진 개수
  int get selectedPhotoCount => _selectedPhotos.length;

  // 사진 선택 중인지 여부
  bool get isSelecting => _isSelecting;

  // 새로운 사진 추가 (중복 방지)
  void addPhotos(List<File> files) {
    final newPhotos = files.map((file) => PhotoModel.fromFile(file)).toList();

    for (final newPhoto in newPhotos) {
      if (!_selectedPhotos.contains(newPhoto)) {
        _selectedPhotos.add(newPhoto);
      }
    }
    notifyListeners();
  }

  // 단일 사진 추가
  void addPhoto(File file) {
    addPhotos([file]);
  }

  // 사진 제거
  void removePhoto(PhotoModel photo) {
    _selectedPhotos.remove(photo);
    notifyListeners();
  }

  // 특정 인덱스의 사진 제거
  void removePhotoAt(int index) {
    if (index >= 0 && index < _selectedPhotos.length) {
      _selectedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  // 전체 사진 초기화
  void clearPhotos() {
    _selectedPhotos.clear();
    notifyListeners();
  }

  // 사진 선택 상태 설정
  void setSelecting(bool selecting) {
    _isSelecting = selecting;
    notifyListeners();
  }

  // GPS 데이터가 있는 사진만 필터링
  List<PhotoModel> getPhotosWithGpsData() {
    return _selectedPhotos.where((photo) => photo.hasGpsData).toList();
  }

  // GPS 데이터가 없는 사진 수
  int get photosWithoutGpsDataCount =>
      _selectedPhotos.where((photo) => !photo.hasGpsData).length;

  // 선택된 사진들의 총 용량 계산 (비동기)
  Future<int> getTotalFileSize() async {
    int totalSize = 0;
    for (final photo in _selectedPhotos) {
      totalSize += await photo.fileSize;
    }
    return totalSize;
  }

  // 사진 정보 업데이트 (EXIF 데이터로)
  void updatePhotoInfo(
    String photoId, {
    DateTime? takenDate,
    double? latitude,
    double? longitude,
    String? device,
    bool? hasExif,
  }) {
    final index = _selectedPhotos.indexWhere((photo) => photo.id == photoId);
    if (index != -1) {
      _selectedPhotos[index] = _selectedPhotos[index].copyWith(
        takenDate: takenDate,
        latitude: latitude,
        longitude: longitude,
        device: device,
        hasExif: hasExif,
      );
      notifyListeners();
    }
  }

  // 사진 재배치
  void reorderPhotos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final photo = _selectedPhotos.removeAt(oldIndex);
    _selectedPhotos.insert(newIndex, photo);
    notifyListeners();
  }

  // 선택된 모든 사진들의 EXIF 데이터 추출 (비동기)
  Future<void> extractExifFromSelectedPhotos({
    void Function(int completed, int total)? onProgress,
    void Function(String error)? onError,
  }) async {
    if (_selectedPhotos.isEmpty) return;

    final photoFiles = _selectedPhotos.map((photo) => photo.file).toList();
    final results = await ExifService.extractMultipleExifData(
      photoFiles,
      onProgress: onProgress,
    );

    for (final result in results) {
      final index = result['index'] as int;
      final exifData = result['exifData'] as Map<String, dynamic>?;

      if (exifData != null) {
        try {
          updatePhotoInfo(
            _selectedPhotos[index].id,
            takenDate: exifData['takenDate'] as DateTime?,
            latitude: exifData['latitude'] as double?,
            longitude: exifData['longitude'] as double?,
            device: exifData['device'] as String?,
            hasExif: exifData['hasExif'] as bool?,
          );
        } catch (e) {
          final errorMsg = '사진 EXIF 업데이트 중 오류: $e';
          print(errorMsg);
          onError?.call(errorMsg);
        }
      } else {
        // EXIF 데이터가 없는 사진 표시
        updatePhotoInfo(_selectedPhotos[index].id, hasExif: false);
      }
    }
  }

  // 단일 사진의 EXIF 데이터 추출
  Future<void> extractExifFromPhoto(
    PhotoModel photo, {
    void Function(String error)? onError,
  }) async {
    try {
      final exifData = await ExifService.extractExifData(photo.file);

      if (exifData != null) {
        updatePhotoInfo(
          photo.id,
          takenDate: exifData['takenDate'] as DateTime?,
          latitude: exifData['latitude'] as double?,
          longitude: exifData['longitude'] as double?,
          device: exifData['device'] as String?,
          hasExif: exifData['hasExif'] as bool?,
        );
      } else {
        updatePhotoInfo(photo.id, hasExif: false);
      }
    } catch (e) {
      final errorMsg = '사진 EXIF 추출 중 오류: $e';
      print(errorMsg);
      onError?.call(errorMsg);
    }
  }
}
