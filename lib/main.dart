import 'dart:io';

import 'package:catdogml/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<Null> main() async{
  cameras = await availableCameras();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AppScaffold(),
    );
  }
}

class AppScaffold extends StatefulWidget {
  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _isLoading;
  File _image;
  List _output;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Cats vs Dogs Detector")),
        body: _isLoading
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _image == null ? Container() : Image.file(_image),
                    SizedBox(
                      height: 16,
                    ),
                    _output == null
                        ? Text("")
                        : Text(
                            "${_output[0]["label"].toString().split(" ")[1]}",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                  ],
                ),
              ),
        floatingActionButton: Stack(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 700),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "FabCamera",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraApp()),
                        );
                      },
                      child: Icon(Icons.camera),
                    )
                  ],
                )),
            SizedBox(
              height: 16,
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  heroTag: "FabImage",
                  onPressed: chooseImage,
                  child: Icon(Icons.image),
                )),
          ],
        ));
  }

  void chooseImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = image;
    });
    classifyImage(image);
  }

  void classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _isLoading = false;
      _output = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
  }
}
