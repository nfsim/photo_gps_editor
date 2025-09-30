import 'package:flutter/material.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  Future<String> _loadLicense(BuildContext context) async {
    try {
      return await DefaultAssetBundle.of(context).loadString('LICENSE');
    } catch (_) {
      return 'LICENSE 파일을 불러올 수 없습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project License')),
      body: FutureBuilder<String>(
        future: _loadLicense(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(snapshot.data ?? 'LICENSE 파일을 불러올 수 없습니다.'),
            ),
          );
        },
      ),
    );
  }
}
