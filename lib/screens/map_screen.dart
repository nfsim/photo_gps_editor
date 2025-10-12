import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/photo_model.dart';
import '../providers/photo_provider.dart';
import '../services/map_service.dart';
import '../utils/exif_utils.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final CameraPosition _initialCameraPosition =
      MapService.getInitialCameraPosition();

  // 선택된 사진 ID 추적
  String? _selectedPhotoId;

  // Long Press로 선택된 GPS 위치 (저장 버튼에서 사용할 미리보기 좌표)
  LatLng? _selectedLocationForGPS;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // 위치 권한 요청
    await MapService.requestLocationPermission();

    // 사진 위치 마커 설정 (다음 프레임 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupMapWithPhotoLocations();
    });
  }

  void _setupMapWithPhotoLocations() {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final photosWithGps = photoProvider.getPhotosWithGpsData();

    if (photosWithGps.isNotEmpty) {
      _addMarkersForPhotos(photosWithGps);
      _adjustCameraToFitPhotos(photosWithGps);
    }
  }

  void _addMarkersForPhotos(List<PhotoModel> photos) {
    setState(() {
      _markers.clear();

      // 사진 마커 추가
      for (final photo in photos) {
        if (photo.latitude != null && photo.longitude != null) {
          final markerId = MarkerId(photo.id);
          final isSelected = _selectedPhotoId == photo.id;

          _markers.add(
            Marker(
              markerId: markerId,
              position: LatLng(photo.latitude!, photo.longitude!),
              infoWindow: InfoWindow(
                title: isSelected ? '📍 선택된 사진' : '사진 위치',
                snippet: photo.takenDate?.toString() ?? '촬영일 미상',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                isSelected
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueAzure,
              ),
              onTap: () => _selectPhoto(photo),
            ),
          );
        }
      }

      // 선택된 GPS 위치 미리보기 마커 추가
      if (_selectedLocationForGPS != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('selected_gps_location'),
            position: _selectedLocationForGPS!,
            infoWindow: InfoWindow(
              title: '🎯 선택된 GPS 위치',
              snippet: '저장 버튼을 눌러 사진에 적용하세요',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    });
  }

  void _selectPhoto(PhotoModel photo) {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);

    setState(() {
      // 사진 선택 토글
      _selectedPhotoId = _selectedPhotoId == photo.id ? null : photo.id;

      if (_selectedPhotoId != null) {
        // PhotoProvider에 선택된 사진 설정
        photoProvider.setCurrentPhoto(photo);

        // 성공 피드백
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 "${photo.path.split('/').last}" 사진을 선택했습니다'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // 선택 해제 - null 넣지 말고 null이 아닌 photo 객체 유지
        _selectedPhotoId = null;
        photoProvider.setCurrentPhoto(null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사진 선택이 해제되었습니다'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });

    // 마커 업데이트
    final photosWithGps = photoProvider.getPhotosWithGpsData();
    _addMarkersForPhotos(photosWithGps);
  }

  void _adjustCameraToFitPhotos(List<PhotoModel> photos) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final photo in photos) {
      if (photo.latitude != null && photo.longitude != null) {
        minLat = minLat < photo.latitude! ? minLat : photo.latitude!;
        maxLat = maxLat > photo.latitude! ? maxLat : photo.latitude!;
        minLng = minLng < photo.longitude! ? minLng : photo.longitude!;
        maxLng = maxLng > photo.longitude! ? maxLng : photo.longitude!;
      }
    }

    if (minLat < double.infinity && maxLat > -double.infinity) {
      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapLongPress(LatLng position) {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final selectedPhotosWithoutGps =
        photoProvider.selectedPhotos.where((p) => !p.hasGpsData).toList();

    if (selectedPhotosWithoutGps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'GPS 좌표를 적용할 수 있는 사진이 없습니다.\n모든 선택된 사진에 이미 GPS 정보가 있습니다.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Long Press는 GPS 위치 선택만 (미리보기)
    setState(() {
      _selectedLocationForGPS = position;
      _updateMarkers();
    });

    // 사용자 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'GPS 위치 선택됨: (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})\n저장 버튼을 눌러 사진에 적용하세요',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '저장',
          onPressed: () => _applySelectedLocationToPhotos(),
        ),
      ),
    );
  }

  void _updateMarkers() {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final photosWithGps = photoProvider.getPhotosWithGpsData();
    _addMarkersForPhotos(photosWithGps);
  }

  Future<void> _moveToCurrentLocation() async {
    final LatLng? currentLocation = await MapService.getCurrentLocation();
    if (currentLocation != null) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 15.0),
      );

      // 현재 위치 마커 추가 (옵션)
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: currentLocation,
            infoWindow: const InfoWindow(title: '현재 위치'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );
      });
    } else {
      // 권한이 없을 때 다이얼로그 표시
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('위치 권한 필요'),
              content: const Text(
                '현재 위치를 표시하려면 위치 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _saveGPSToPhoto() async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final currentPhoto = photoProvider.currentPhoto;

    if (currentPhoto == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('GPS를 저장할 사진을 선택해주세요.')));
      return;
    }

    try {
      // ScaffoldMessenger를 통해 진행 상황 표시
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('GPS 정보를 사진에 저장하는 중...')));

      // GPS 주소를 파일에 저장 (현재 좌표 사용)
      final result = await ExifUtils.setGPS(
        currentPhoto.path,
        currentPhoto.latitude ?? 0.0,
        currentPhoto.longitude ?? 0.0,
      );

      // 결과 확인
      if (result.containsKey('exifSaved') && result['exifSaved'] == true) {
        // 성공 후 사진 정보 업데이트 (GPS 데이터 추가됨 표시)
        photoProvider.updatePhotoInfo(
          currentPhoto.id,
          latitude: currentPhoto.latitude ?? 0.0,
          longitude: currentPhoto.longitude ?? 0.0,
          hasExif: true,
        );

        // 성공 피드백
        if (!mounted) return;
        final gallerySuccess = result['galleryAdded'] as bool? ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              gallerySuccess
                  ? 'GPS 정보가 사진에 저장되고 갤러리로 복사되었습니다!\n(Google Photos에서 새로고침해보세요)'
                  : 'GPS 정보가 사진에 저장되었습니다!\n(갤러리 재활성화 필요)',
            ),
            duration: const Duration(seconds: 4),
          ),
        );

        // 선택 해제 (다음 선택을 위해)
        _selectedPhotoId = null;
        photoProvider.setCurrentPhoto(null);
        _addMarkersForPhotos(photoProvider.getPhotosWithGpsData());
      } else {
        // EXIF 저장 실패
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS 좌표를 EXIF에 저장할 수 없습니다. 사진 권한을 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 실패 피드백
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GPS 저장 실패: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _applyGpsToSelectedPhotos(
    LatLng position,
    List<PhotoModel> photosToApply,
  ) async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final results = <Map<String, dynamic>>[];

    // 각 사진에 GPS 좌표 적용
    for (final photo in photosToApply) {
      try {
        final result = await ExifUtils.setGPS(
          photo.path,
          position.latitude,
          position.longitude,
        );

        if (result.containsKey('exifSaved') && result['exifSaved'] == true) {
          // PhotoProvider 업데이트
          photoProvider.setGPS(position.latitude, position.longitude);
          photoProvider.updatePhotoInfo(
            photo.id,
            latitude: position.latitude,
            longitude: position.longitude,
            hasExif: true,
          );
          results.add({
            'photo': photo,
            'success': true,
            'galleryAdded': result['galleryAdded'] ?? false,
          });
        } else {
          results.add({'photo': photo, 'success': false});
        }
      } catch (e) {
        results.add({'photo': photo, 'success': false, 'error': e.toString()});
      }
    }

    // 결과 정리 및 피드백
    final successCount = results.where((r) => r['success'] == true).length;
    final totalCount = photosToApply.length;

    if (successCount > 0) {
      await _handleSuccessfulGpsApplication(successCount, totalCount, results);
    }

    // 마커 업데이트 - 새로 적용된 GPS 사진들을 파란색 마커로 표시
    _updateMarkers();
  }

  Future<void> _handleSuccessfulGpsApplication(
    int successCount,
    int totalCount,
    List<Map<String, dynamic>> results,
  ) async {
    final galleryAdded = results.where((r) => r['galleryAdded'] == true).length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          successCount == totalCount
              ? '$successCount/$totalCount장의 사진에 GPS 좌표가 적용되었습니다.\n${galleryAdded > 0 ? '갤러리에도 복사되었습니다.' : ''}'
              : '$successCount/$totalCount장의 사진에 GPS 좌표가 적용되었습니다.\n일부 사진은 실패했습니다.',
        ),
        duration: const Duration(seconds: 5),
      ),
    );

    if (galleryAdded > 0) {
      // 갤러리가 업데이트되었으므로 추가 안내
      await Future.delayed(const Duration(seconds: 3));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Photos에서 새로고침하여 GPS 정보가 표시되는지 확인해보세요.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _saveGPSToPhotoAtCoordinates(LatLng position) async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final currentPhoto = photoProvider.currentPhoto;

    if (currentPhoto == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('GPS를 저장할 사진을 선택해주세요.')));
      return;
    }

    try {
      // ScaffoldMessenger를 통해 진행 상황 표시
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('수동 GPS 좌표를 사진에 저장하는 중...')));

      // GPS 주소를 파일에 저장 (선택된 좌표 사용)
      final result = await ExifUtils.setGPS(
        currentPhoto.path,
        position.latitude,
        position.longitude,
      );

      // 결과 확인 및 처리
      if (result.containsKey('exifSaved') && result['exifSaved'] == true) {
        // 성공 후 사진 정보 업데이트 (GPS 데이터 추가됨 표시)
        photoProvider.updatePhotoInfo(
          currentPhoto.id,
          latitude: position.latitude,
          longitude: position.longitude,
          hasExif: true,
        );

        // PhotoProvider에서 GPS 좌표 업데이트 (important!)
        photoProvider.setGPS(position.latitude, position.longitude);

        // 선택된 GPS 위치 클리어 (다음 작업을 위해)
        setState(() {
          _selectedLocationForGPS = null;
          _updateMarkers();
        });

        // 성공 피드백
        if (!mounted) return;
        final gallerySuccess = result['galleryAdded'] as bool? ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              gallerySuccess
                  ? '수동 GPS 좌표가 사진에 저장되고 갤러리로 복사되었습니다!\n(Google Photos에서 새로고침해보세요)'
                  : '수동 GPS 좌표가 사진에 저장되었습니다!\n(갤러리 재활성화 필요)',
            ),
            duration: const Duration(seconds: 4),
          ),
        );

        // 선택 해제 (다음 선택을 위해)
        _selectedPhotoId = null;
        photoProvider.setCurrentPhoto(null);
        _addMarkersForPhotos(photoProvider.getPhotosWithGpsData());
      } else {
        // EXIF 저장 실패
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS 좌표를 EXIF에 저장할 수 없습니다. 사진 권한을 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 실패 피드백
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('수동 GPS 저장 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _applySelectedLocationToPhotos() async {
    if (_selectedLocationForGPS == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '먼저 지도에서 GPS 위치를 선택해주세요.\nLong Press로 원하는 위치를 선택한 후 저장 버튼을 누르세요.',
          ),
        ),
      );
      return;
    }

    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    final selectedPhotosWithoutGps =
        photoProvider.selectedPhotos.where((p) => !p.hasGpsData).toList();

    if (selectedPhotosWithoutGps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS 좌표를 적용할 사진이 없습니다.\n모든 선택된 사진에 이미 GPS 정보가 있습니다.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // 선택된 GPS 위치를 GPS 없는 사진들에 적용
    await _applyGpsToSelectedPhotos(
      _selectedLocationForGPS!,
      selectedPhotosWithoutGps,
    );

    // 적용 완료 후 선택된 위치 클리어
    setState(() {
      _selectedLocationForGPS = null;
      _updateMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 위치 지도'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onLongPress: _onMapLongPress,
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
        compassEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _applySelectedLocationToPhotos,
            tooltip: '선택된 GPS 위치를 사진에 적용',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _moveToCurrentLocation,
            tooltip: '현재 위치로 이동',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
