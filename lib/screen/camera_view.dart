import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../main.dart';
import 'my_dialog.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.customPaint,
      required this.onImage,
      required this.getDefault,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final Function() getDefault;
  final CameraLensDirection initialDirection;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  int _cameraIndex = 0;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  Response? response;
  var hasilRes;

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
      }
    }
    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _liveFeedBody(),
    );
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        CameraPreview(_controller!),
        if (widget.customPaint != null) widget.customPaint!,
      ],
    );
  }

  Future<XFile?> takePicture() async {
    if (_controller!.value.isTakingPicture) {
      return null;
    }

    try {
      _controller!.stopImageStream();
      XFile file = await _controller!.takePicture();
      _controller!.startImageStream(_processCameraImage);
      return file;
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    // await _controller?.dispose();
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =  InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);



    if(await widget.onImage(inputImage) == true){

      AppLoading(context).showWithText("Verification");

      XFile? file = await takePicture();
      if(file == null){
        return false;
      }
      File fileImg = File(file.path);
      var formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(fileImg.path)
      });

      try{
        Dio dio = new Dio();
        response = await dio.post('https://api.luxand.cloud/photo/search', data: formData, options: Options(
            contentType: "multipart/form-data",
            headers: {
              "token":"d68909c9b870475181073d3005661f54"
            }
        ));
        print('RESPONSE WITH DIO');
        hasilRes = response?.data;
        print(response?.data);

      }on DioError catch (e) {
        print(e.response!.data);
        print(e.response!.headers);
        print(e.response!.requestOptions);
      }

      Navigator.pop(context);

      await showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Verifikasi'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(response?.data.toString() ?? ""),
                  Text(hasilRes.length > 0 ? "Wajah Ditemukan" : "Wajah tidak ditemukan"),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  widget.getDefault();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
