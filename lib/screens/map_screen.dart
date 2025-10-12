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

  // 수동 GPS 마커 (Long Press로 설정한 좌표)
  Marker? _manualGpsMarker;

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

      // 수동 GPS 마커 추가
      if (_manualGpsMarker != null) {
        _markers.add(_manualGpsMarker!);
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
    setState(() {
      // 기존 GPS 마커 제거
      _manualGpsMarker = Marker(
        markerId: const MarkerId('manual_gps_marker'),
        position: position,
        infoWindow: InfoWindow(
          title: '📍 수동 GPS 설정 위치',
          snippet:
              '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          onTap: () {
            // 마커 터치 시 제거
            setState(() {
              _manualGpsMarker = null;
              _updateMarkers();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('수동 GPS 설정 위치가 해제되었습니다'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );

      _updateMarkers();
    });

    // PhotoProvider에 GPS 좌표 설정
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    photoProvider.setGPS(position.latitude, position.longitude);

    // 사용자 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'GPS 좌표가 설정되었습니다: (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})',
        ),
        duration: const Duration(seconds: 3),
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
      await ExifUtils.setGPS(
        currentPhoto.path,
        currentPhoto.latitude ?? 0.0,
        currentPhoto.longitude ?? 0.0,
      );

      // 성공 후 사진 정보 업데이트 (GPS 데이터 추가됨 표시)
      photoProvider.updatePhotoInfo(
        currentPhoto.id,
        latitude: currentPhoto.latitude ?? 0.0,
        longitude: currentPhoto.longitude ?? 0.0,
        hasExif: true,
      );

      // 성공 피드백
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS 정보가 사진 파일에 성공적으로 저장되었습니다!')),
      );

      // 선택 해제 (다음 선택을 위해)
      _selectedPhotoId = null;
      photoProvider.setCurrentPhoto(null);
      _addMarkersForPhotos(photoProvider.getPhotosWithGpsData());
    } catch (e) {
      // 실패 피드백
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GPS 저장 실패: $e'), backgroundColor: Colors.red),
      );
    }
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
            onPressed: _saveGPSToPhoto,
            tooltip: 'GPS 정보 저장',
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
