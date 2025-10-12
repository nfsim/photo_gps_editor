import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/photo_model.dart';
import '../providers/photo_provider.dart';
import '../widgets/permission_dialog.dart';
import '../utils/exif_utils.dart';
import 'map_screen.dart';

class ImageSelectScreen extends StatefulWidget {
  const ImageSelectScreen({super.key});

  @override
  State<ImageSelectScreen> createState() => _ImageSelectScreenState();
}

class _ImageSelectScreenState extends State<ImageSelectScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // 카메라와 사진 라이브러리 권한 확인
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status;

    if (cameraStatus.isDenied || photosStatus.isDenied) {
      if (mounted) {
        await PermissionDialog.showPermissionDialog(
          context,
          title: '권한 필요',
          message: '사진 촬영 및 갤러리 접근을 위해 권한이 필요합니다.',
          onGranted: () async {
            await [Permission.camera, Permission.photos].request();
          },
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
      photoProvider.setSelecting(true);

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files.map((file) => File(file.path!)).toList();
        photoProvider.addPhotos(files);

        // Read GPS EXIF for each file
        for (final file in files) {
          final String photoId = file.path.hashCode.toString();
          try {
            final gps = await ExifUtils.readGPS(file.path);
            if (gps.isNotEmpty &&
                gps['latitude'] != null &&
                gps['longitude'] != null) {
              photoProvider.updatePhotoInfo(
                photoId,
                latitude: gps['latitude'],
                longitude: gps['longitude'],
                hasExif: true,
              );
              print(
                'Updated photo $photoId with GPS: ${gps['latitude']}, ${gps['longitude']}',
              );
            } else {
              print('No GPS found for photo $photoId');
            }
          } catch (e) {
            // Ignore EXIF read errors
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${files.length}장의 사진을 선택했습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('갤러리 접근 중 오류 발생: $e')));
      }
    } finally {
      if (mounted) {
        Provider.of<PhotoProvider>(context, listen: false).setSelecting(false);
      }
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
      photoProvider.setSelecting(true);

      // Camera functionality disabled for now - need to use file_picker for camera access
      // TODO: Implement camera with file_picker or add back image_picker selectively

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('카메라 기능은 현재 비활성화되었습니다.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('카메라 촬영 중 오류 발생: $e')));
      }
    } finally {
      if (mounted) {
        Provider.of<PhotoProvider>(context, listen: false).setSelecting(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 선택'),
        actions: [
          Consumer<PhotoProvider>(
            builder: (context, photoProvider, child) {
              return TextButton(
                onPressed:
                    photoProvider.selectedPhotos.isEmpty
                        ? null
                        : () {
                          photoProvider.clearPhotos();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('선택된 사진을 모두 삭제했습니다.')),
                          );
                        },
                child: const Text('전체 삭제'),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 선택 버튼 영역
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리에서 선택'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhotoWithCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('카메라 촬영'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 선택 상태 표시
          Consumer<PhotoProvider>(
            builder: (context, photoProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '선택된 사진: ${photoProvider.selectedPhotoCount}장',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (photoProvider.isSelecting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // 선택된 사진 그리드
          Expanded(
            child: Consumer<PhotoProvider>(
              builder: (context, photoProvider, child) {
                if (photoProvider.selectedPhotos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '선택된 사진이 없습니다.\n갤러리에서 선택하거나 카메라로 촬영하세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photoProvider.selectedPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = photoProvider.selectedPhotos[index];
                    return _PhotoGridItem(
                      photo: photo,
                      onRemove: () => photoProvider.removePhotoAt(index),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 지도 보기 버튼 (FLOATING ACTION)
      floatingActionButton: Consumer<PhotoProvider>(
        builder: (context, photoProvider, child) {
          if (photoProvider.selectedPhotos.isEmpty) return const SizedBox();
          return FloatingActionButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MapScreen()),
                ),
            tooltip: '지도에서 GPS 위치 확인',
            child: const Icon(Icons.map),
          );
        },
      ),
    );
  }
}

class _PhotoGridItem extends StatelessWidget {
  final PhotoModel photo;
  final VoidCallback onRemove;

  const _PhotoGridItem({required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 이미지
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(photo.file),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 삭제 버튼
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),

        // GPS 표시 아이콘
        if (photo.hasGpsData)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
      ],
    );
  }
}
