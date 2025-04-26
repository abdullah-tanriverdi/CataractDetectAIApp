import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'display_results_screen.dart'; // Sonuçları gösteren ekran

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    // Kameraları yükle
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.isNotEmpty) {
        // Kameraların olup olmadığını kontrol et
        controller = CameraController(
          cameras[0], // Arka kamerayı seç
          ResolutionPreset.high,
        );
        initializeControllerFuture = controller.initialize();
      } else {
        print("Kamera bulunamadı!");
      }
      setState(() {}); // Ekranı güncelle
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return const Center(child: Text("Kamera bulunamadı!"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Fotoğraf Çek')),
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await initializeControllerFuture;
            final image = await controller.takePicture();
            // Fotoğrafı bir başka ekrana gönder
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayResultsScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
