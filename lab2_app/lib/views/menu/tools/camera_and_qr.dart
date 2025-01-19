import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:open_filex/open_filex.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class CameraAndQr extends StatefulWidget {
  const CameraAndQr({super.key});

  @override
  State<CameraAndQr> createState() => _CameraAndQrState();
}

class _CameraAndQrState extends State<CameraAndQr> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool isQRVisible = true;
  bool isRecording = false;
  bool isVideoMode = false;
  QRViewController? qrController;
  Barcode? qrResult;
  String? savedMediaPath;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrController?.pauseCamera();
    } else if (Platform.isIOS) {
      qrController?.resumeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.veryHigh,
      );
      await _cameraController!.initialize();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No camera found.')),
      );
    }
  }

  Future<void> _captureAndSaveImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile image = await _cameraController!.takePicture();
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String imagePath =
            p.join(appDir.path, 'Pictures', '${DateTime.now()}.jpg');
        await Directory(p.dirname(imagePath)).create(recursive: true);
        final savedImage = await File(image.path).copy(imagePath);
        setState(() {
          savedMediaPath = savedImage.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved at: $savedMediaPath')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }

  Future<void> _recordVideo() async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !isRecording) {
      try {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String videoPath =
            p.join(appDir.path, 'Videos', '${DateTime.now()}.mp4');
        await Directory(p.dirname(videoPath)).create(recursive: true);

        await _cameraController!.startVideoRecording();
        setState(() {
          isRecording = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting video recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        isRecording) {
      try {
        final XFile video = await _cameraController!.stopVideoRecording();
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String videoPath =
            p.join(appDir.path, 'Videos', '${DateTime.now()}.mp4');
        await Directory(p.dirname(videoPath)).create(recursive: true);
        final savedVideo = await File(video.path).copy(videoPath);

        setState(() {
          isRecording = false;
          savedMediaPath = savedVideo.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video saved at: $savedMediaPath')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping video recording: $e')),
        );
      }
    }
  }

  Future<void> _openSavedMedia() async {
    if (savedMediaPath != null && await File(savedMediaPath!).exists()) {
      try {
        final result = await OpenFilex.open(savedMediaPath!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'File opened. Type: ${result.type}, Message: ${result.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening media: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved media found.')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrResult = scanData;
      });
    });
  }

  @override
  void dispose() {
    qrController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleQRVisibility() {
    setState(() {
      isQRVisible = !isQRVisible;
      if (isQRVisible) {
        _cameraController?.dispose();
        _cameraController = null;
      } else {
        _initializeCamera();
        qrController?.pauseCamera();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera, Video, and QR Code"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(20),
              Text(
                'Camera, Video, and QR Code Tools',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Gap(20),
              if (isQRVisible)
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 4.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
              if (isQRVisible) const Gap(10),
              if (isQRVisible)
                Center(
                  child: qrResult != null
                      ? Text(
                          'Format: ${describeEnum(qrResult!.format)}\nData: ${qrResult!.code}')
                      : const Text('Scan a QR code'),
                ),
              if (!isQRVisible &&
                  _cameraController != null &&
                  _cameraController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: 1,
                  child: CameraPreview(_cameraController!),
                ),
              const Gap(20),
              ElevatedButton(
                onPressed: _toggleQRVisibility,
                child: Text(isQRVisible
                    ? 'Switch to Camera Mode'
                    : 'Switch to QR Scanner Mode'),
              ),
              const Gap(20),
              if (!isQRVisible)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: isVideoMode
                          ? (isRecording ? _stopRecording : _recordVideo)
                          : _captureAndSaveImage,
                      child: Text(isVideoMode
                          ? (isRecording ? 'Stop Recording' : 'Record Video')
                          : 'Capture Image'),
                    ),
                    const Gap(10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isVideoMode = !isVideoMode;
                        });
                      },
                      child: Text(isVideoMode
                          ? 'Switch to Photo Mode'
                          : 'Switch to Video Mode'),
                    ),
                  ],
                ),
              const Gap(10),
              if (savedMediaPath != null)
                Column(
                  children: [
                    Text('Saved Media:'),
                    const Gap(10),
                    savedMediaPath!.endsWith('.mp4')
                        ? Text('Video saved at: $savedMediaPath')
                        : Image.file(
                            File(savedMediaPath!),
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                  ],
                ),
              const Gap(20),
              ElevatedButton(
                onPressed: _openSavedMedia,
                child: const Text('Open Saved Media'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
