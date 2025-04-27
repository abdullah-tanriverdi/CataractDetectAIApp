import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io' as io; // Mobil için
import 'package:image_picker/image_picker.dart'; // Mobil için
import 'dart:html' as html; // Web için
import 'package:image/image.dart' as img; // resize için

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CataractPredictor(),
    );
  }
}

class CataractPredictor extends StatefulWidget {
  @override
  _CataractPredictorState createState() => _CataractPredictorState();
}

class _CataractPredictorState extends State<CataractPredictor> {
  Interpreter? _interpreter;
  Uint8List? _imageBytes;
  String _result = 'Sonuç bekleniyor...';
  bool _isModelLoaded = false;
  bool _isPredicting = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('cataract_model.tflite');
    setState(() {
      _isModelLoaded = true;
    });
    print('Model başarıyla yüklendi.');
  }

  Future<void> pickImage() async {
    if (isWeb()) {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(uploadInput.files!.first);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _imageBytes = reader.result as Uint8List;
          });
        });
      });
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageBytes = io.File(pickedFile.path).readAsBytesSync();
        });
      }
    }
  }

  Future<void> predict() async {
    if (_interpreter == null || _imageBytes == null) return;

    setState(() {
      _isPredicting = true;
    });

    try {
      // Görseli 224x224 resize et
      img.Image? image = img.decodeImage(_imageBytes!);
      img.Image resizedImage = img.copyResize(image!, width: 224, height: 224);

      // input tensoru hazırla
      var input = List.generate(
          1,
              (i) => List.generate(
              224,
                  (y) => List.generate(
                  224,
                      (x) => List.generate(
                      3,
                          (c) =>
                          resizedImage.getPixel(x, y).toNormalizedChannel(c)))));

      var output = List.filled(2, 0.0).reshape([1, 2]);

      _interpreter!.run(input, output);

      print('Model output: $output');

      int predictedClass = output[0][0] > output[0][1] ? 0 : 1;

      setState(() {
        _result = predictedClass == 0 ? "Normal Göz" : "Katarakt Var";
        _isPredicting = false;
      });
    } catch (e) {
      print("Tahmin sırasında hata: $e");
      setState(() {
        _result = "Hata oluştu!";
        _isPredicting = false;
      });
    }
  }

  bool isWeb() {
    try {
      return identical(0, 0.0);
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Katarakt Tespiti'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageBytes == null
                  ? Text('Bir görsel seçin.')
                  : Image.memory(_imageBytes!, height: 300),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Görsel Seç'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                _isModelLoaded && _imageBytes != null && !_isPredicting
                    ? predict
                    : null,
                child: Text('Sonucu Göster'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              SizedBox(height: 20),
              _isPredicting
                  ? CircularProgressIndicator()
                  : Text(
                _result,
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Kanal bilgisi normalize eden küçük yardımcı fonksiyon
extension NormalizePixel on int {
  double toNormalizedChannel(int channel) {
    if (channel == 0) {
      return ((this >> 16) & 0xFF) / 255.0;
    } else if (channel == 1) {
      return ((this >> 8) & 0xFF) / 255.0;
    } else {
      return (this & 0xFF) / 255.0;
    }
  }
}
