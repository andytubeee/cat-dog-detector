import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

Future<Null> main() async{
  cameras = await availableCameras();
  runApp(new CameraApp(cameras));
}

class CameraApp extends StatefulWidget {
  var cameras
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}