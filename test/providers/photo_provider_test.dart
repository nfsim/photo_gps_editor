import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_gps_editor/models/photo_model.dart';
import 'package:photo_gps_editor/providers/photo_provider.dart';

void main() {
  group('PhotoProvider GPS Tests', () {
    test('setCurrentPhoto sets current photo and clears history', () {
      final provider = PhotoProvider();
      final photo1 = PhotoModel(
        id: '1',
        file: File('test1.jpg'),
        path: 'test1.jpg',
        latitude: 37.0,
        longitude: 127.0,
      );
      final photo2 = PhotoModel(
        id: '2',
        file: File('test2.jpg'),
        path: 'test2.jpg',
        latitude: 40.0,
        longitude: 130.0,
      );

      provider.addPhoto(photo1.file);
      provider.addPhoto(photo2.file);

      provider.setCurrentPhoto(photo1);
      expect(provider.currentPhoto, photo1);

      provider.setGPS(38.0, 128.0);
      expect(provider.canUndo, true);

      // Changing current photo clears history
      provider.setCurrentPhoto(photo2);
      expect(provider.currentPhoto, photo2);
      expect(provider.canUndo, false);
      expect(provider.canRedo, false);
    });

    test('setGPS updates current photo and history', () {
      final provider = PhotoProvider();
      final photo = PhotoModel(
        id: '1',
        file: File('test.jpg'),
        path: 'test.jpg',
        latitude: 37.0,
        longitude: 127.0,
      );

      provider.addPhoto(photo.file);
      provider.setCurrentPhoto(photo);

      provider.setGPS(40.0, 130.0);

      expect(provider.currentPhoto!.latitude, 40.0);
      expect(provider.currentPhoto!.longitude, 130.0);
      expect(provider.canUndo, true);
      expect(provider.canRedo, false);
    });

    test('undoGPS reverts GPS change', () {
      final provider = PhotoProvider();
      final photo = PhotoModel(
        id: '1',
        file: File('test.jpg'),
        path: 'test.jpg',
        latitude: 37.0,
        longitude: 127.0,
      );

      provider.addPhoto(photo.file);
      provider.setCurrentPhoto(photo);

      provider.setGPS(40.0, 130.0);
      expect(provider.currentPhoto!.latitude, 40.0);
      expect(provider.currentPhoto!.longitude, 130.0);
      expect(provider.canUndo, true);

      provider.undoGPS();
      expect(provider.currentPhoto!.latitude, 37.0);
      expect(provider.currentPhoto!.longitude, 127.0);
      expect(provider.canUndo, false);
      expect(provider.canRedo, true);
    });

    test('redoGPS reapplies undone change', () {
      final provider = PhotoProvider();
      final photo = PhotoModel(
        id: '1',
        file: File('test.jpg'),
        path: 'test.jpg',
        latitude: 37.0,
        longitude: 127.0,
      );

      provider.addPhoto(photo.file);
      provider.setCurrentPhoto(photo);

      provider.setGPS(40.0, 130.0);
      provider.undoGPS();

      expect(provider.currentPhoto!.latitude, 37.0);
      expect(provider.canRedo, true);

      provider.redoGPS();
      expect(provider.currentPhoto!.latitude, 40.0);
      expect(provider.currentPhoto!.longitude, 130.0);
      expect(provider.canUndo, true);
      expect(provider.canRedo, false);
    });

    test('multiple GPS changes and undo/redo sequence', () {
      final provider = PhotoProvider();
      final photo = PhotoModel(
        id: '1',
        file: File('test.jpg'),
        path: 'test.jpg',
        latitude: 37.0,
        longitude: 127.0,
      );

      provider.addPhoto(photo.file);
      provider.setCurrentPhoto(photo);

      // First change
      provider.setGPS(38.0, 128.0);
      expect(provider.canUndo, true);
      expect(provider.canRedo, false);

      // Second change
      provider.setGPS(39.0, 129.0);
      expect(provider.canUndo, true);
      expect(provider.canRedo, false);

      // Undo twice
      provider.undoGPS();
      expect(provider.currentPhoto!.latitude, 38.0);
      expect(provider.canRedo, true);
      expect(provider.canUndo, true);

      provider.undoGPS();
      expect(provider.currentPhoto!.latitude, 37.0);
      expect(provider.canRedo, true);
      expect(provider.canUndo, false);

      // Redo once
      provider.redoGPS();
      expect(provider.currentPhoto!.latitude, 38.0);
      expect(provider.canRedo, true);
      expect(provider.canUndo, true);
    });

    test('setGPS does nothing without current photo', () {
      final provider = PhotoProvider();
      final photo = PhotoModel(
        id: '1',
        file: File('test.jpg'),
        path: 'test.jpg',
        latitude: 37.0,
        longitude: 127.0,
      );

      provider.addPhoto(photo.file);
      // No setCurrentPhoto

      provider.setGPS(40.0, 130.0);
      // Should not crash, history remains empty

      expect(provider.canUndo, false);
      expect(provider.canRedo, false);
    });
  });
}
