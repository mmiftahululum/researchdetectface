import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'camera_view.dart';
import 'face_detector_painter.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  FaceDetector faceDetector =
      GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
  ));
  bool isBusy = false;
  CustomPaint? customPaint;
  int hitung = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hitung = 0;
  }

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Absensi ' + hitung.toString()),
      ),
      body: CameraView(
        customPaint: customPaint,
        onImage: (inputImage) {
          return processImage(inputImage);
        },
        getDefault: (){
          setState(() {
            hitung=0;
            isBusy = false;
          });
        },
        initialDirection: CameraLensDirection.front,
      ),
    );
  }

  processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      if(faces.length > 0){
        hitung++;
        if(hitung == 5){
          return true;
        }
      }else{
        hitung = 0;
      }
      // final painter = FaceDetectorPainter(
      //     faces,
      //     inputImage.inputImageData!.size,
      //     inputImage.inputImageData!.imageRotation);
      // customPaint = CustomPaint(painter: painter);
    } else {
      hitung = 0;
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
    return false;
  }
}
