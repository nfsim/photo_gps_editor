import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/photo_model.dart';
import '../models/gps_command.dart';

class PhotoProvider extends ChangeNotifier {
  final List<PhotoModel> _selectedPhotos = [];
  bool _isSelecting = false; // 사진 선택 중인지 여부
  PhotoModel? _currentPhoto;
  final List<GPSCommand> _undoStack = [];
  final List<GPSCommand> _redoStack = [];

  // current photo for GPS editing
  PhotoModel? get currentPhoto => _currentPhoto;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

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

  // GPS editing current photo management
  void setCurrentPhoto(PhotoModel photo) {
    if (_currentPhoto != photo) {
      _currentPhoto = photo;
      _undoStack.clear();
      _redoStack.clear();
      notifyListeners();
    }
  }

  void setGPS(double latitude, double longitude) {
    if (_currentPhoto == null) return;
    final command = SetGPSCommand(latitude, longitude);
    _currentPhoto = command.execute(_currentPhoto!);
    _undoStack.add(command);
    _redoStack.clear();
    // Update in selected photos list
    final index = _selectedPhotos.indexWhere((p) => p.id == _currentPhoto!.id);
    if (index != -1) {
      _selectedPhotos[index] = _currentPhoto!;
    }
    notifyListeners();
  }

  void undoGPS() {
    if (_undoStack.isNotEmpty) {
      final command = _undoStack.removeLast();
      _currentPhoto = command.undo();
      _redoStack.add(command);
      // Update in selected photos list
      final index = _selectedPhotos.indexWhere(
        (p) => p.id == _currentPhoto!.id,
      );
      if (index != -1) {
        _selectedPhotos[index] = _currentPhoto!;
      }
      notifyListeners();
    }
  }

  void redoGPS() {
    if (_redoStack.isNotEmpty) {
      final command = _redoStack.removeLast();
      _currentPhoto = command.execute(_currentPhoto!);
      _undoStack.add(command);
      // Update in selected photos list
      final index = _selectedPhotos.indexWhere(
        (p) => p.id == _currentPhoto!.id,
      );
      if (index != -1) {
        _selectedPhotos[index] = _currentPhoto!;
      }
      notifyListeners();
    }
  }
}
