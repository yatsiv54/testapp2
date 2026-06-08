import 'package:camera/camera.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;

  CameraService._internal();

  List<CameraDescription> cameras = [];

  Future<void> init() async {
    cameras = await availableCameras();
  }
}
