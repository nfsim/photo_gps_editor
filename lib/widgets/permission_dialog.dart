import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialog {
  static Future<void> showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onGranted,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부 클릭으로 닫히지 않음
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('권한 허용'),
              onPressed: () async {
                Navigator.of(context).pop();
                await onGranted();
              },
            ),
            TextButton(
              child: const Text('설정으로 이동'),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings(); // 설정 앱으로 이동
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> checkAndRequestPermission(
    BuildContext context,
    Permission permission, {
    String? title,
    String? message,
  }) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      if (context.mounted) {
        await showPermissionDialog(
          context,
          title: title ?? '권한 필요',
          message: message ?? '이 기능을 사용하려면 권한이 필요합니다.',
          onGranted: () async {
            final result = await permission.request();
            if (context.mounted && result.isGranted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('권한이 허용되었습니다.')));
            }
          },
        );
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await showPermissionDialog(
          context,
          title: title ?? '권한 필요',
          message: message ?? '권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.',
          onGranted: () async {
            await openAppSettings();
          },
        );
      }
      return false;
    }

    return false;
  }
}
