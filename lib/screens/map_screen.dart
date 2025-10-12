import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/photo_model.dart';
import '../providers/photo_provider.dart';
import '../services/map_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final CameraPosition _initialCameraPosition =
      MapService.getInitialCameraPosition();
  bool _isMapReady = false;

  void _undo() {
    Provider.of<PhotoProvider>(context, listen: false).undoGPS();
  }

  void _redo() {
    Provider.of<PhotoProvider>(context, listen: false).redoGPS();
  }

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // 위치 권한 요청
    await MapService.requestLocationPermission();
  }

  Set<Marker> _createMarkers(List<PhotoModel> photos, String? selectedId) {
    return photos
        .map((photo) {
          if (photo.latitude != null && photo.longitude != null) {
            final markerId = MarkerId(photo.id);
            final isSelected = selectedId == photo.id;

            return Marker(
              markerId: markerId,
              position: LatLng(photo.latitude!, photo.longitude!),
              infoWindow: InfoWindow(
                title: '사진 위치',
                snippet: photo.takenDate?.toString() ?? '촬영일 미상',
                onTap: () => _showPhotoDetails(photo),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                isSelected
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueAzure,
              ),
              draggable: isSelected,
            );
          }
          return null;
        })
        .whereType<Marker>()
        .toSet();
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
    setState(() {
      _isMapReady = true;
    });
  }

  Future<void> _moveToCurrentLocation() async {
    final LatLng? currentLocation = await MapService.getCurrentLocation();
    if (currentLocation != null) {
      await _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 15.0),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 위치 지도'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<PhotoProvider>(
        builder: (context, photoProvider, child) {
          final photos = photoProvider.getPhotosWithGpsData();
          if (photos.isNotEmpty && _isMapReady) {
            _adjustCameraToFitPhotos(photos);
          }
          final markers = _createMarkers(
            photos,
            photoProvider.currentPhoto?.id,
          );
          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialCameraPosition,
            markers: markers,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
            compassEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
      floatingActionButton: Consumer<PhotoProvider>(
        builder:
            (context, provider, child) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (provider.canUndo)
                  FloatingActionButton(
                    onPressed: _undo,
                    tooltip: 'GPS 수정 취소',
                    child: const Icon(Icons.undo),
                  ),
                if (provider.canUndo) const SizedBox(height: 8),
                if (provider.canRedo)
                  FloatingActionButton(
                    onPressed: _redo,
                    tooltip: 'GPS 수정 다시 실행',
                    child: const Icon(Icons.redo),
                  ),
                if (provider.canRedo) const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: _moveToCurrentLocation,
                  tooltip: '현재 위치로 이동',
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
