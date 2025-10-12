import 'package:photo_gps_editor/models/photo_model.dart';

abstract class GPSCommand {
  PhotoModel execute(PhotoModel photo);
  PhotoModel undo();
}

class SetGPSCommand implements GPSCommand {
  late PhotoModel _originalPhoto;
  final double newLatitude;
  final double newLongitude;

  SetGPSCommand(this.newLatitude, this.newLongitude);

  @override
  PhotoModel execute(PhotoModel photo) {
    _originalPhoto = photo.copyWith();
    return photo.copyWith(latitude: newLatitude, longitude: newLongitude);
  }

  @override
  PhotoModel undo() {
    return _originalPhoto;
  }
}
