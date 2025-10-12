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
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final CameraPosition _initialCameraPosition =
      MapService.getInitialCameraPosition();

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
          _markers.add(
            Marker(
              markerId: markerId,
              position: LatLng(photo.latitude!, photo.longitude!),
              infoWindow: InfoWindow(
                title: '사진 위치',
                snippet: photo.takenDate?.toString() ?? '촬영일 미상',
                onTap: () => _showPhotoDetails(photo),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
          );
        }
      }
    });
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

      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  void _showPhotoDetails(PhotoModel photo) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('사진 정보', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text('위치: ${photo.latitude}, ${photo.longitude}'),
                if (photo.takenDate != null)
                  Text('촬영일: ${photo.takenDate!.toString()}'),
                if (photo.device != null) Text('기기: ${photo.device}'),
                Text('경로: ${photo.path}'),
              ],
            ),
          ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _moveToCurrentLocation() async {
    final LatLng? currentLocation = await MapService.getCurrentLocation();
    if (currentLocation != null) {
      await _mapController.animateCamera(
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

      // 성공 피드백
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS 정보가 사진 파일에 성공적으로 저장되었습니다!')),
      );
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
            child: const Icon(Icons.save),
            backgroundColor: Theme.of(context).colorScheme.secondary,
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
    _mapController.dispose();
    super.dispose();
  }
}
