import 'package:flutter/material.dart';
import 'dart:io'; // Bu importu eklemeyi unutmayın

class DisplayResultsScreen extends StatelessWidget {
  final String imagePath;
  const DisplayResultsScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Burada sunucudan gelen sonucu alıp işleyebiliriz
    final result = 'Katarakt Tespit Edil...'; // Örnek sonuç

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonuç'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Fotoğrafı Üstte Göster
            Image.file(
              File(imagePath),
              height: 250,  // Fotoğraf boyutunu ayarladık
              width: 250,   // Fotoğraf boyutunu ayarladık
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),

            // Sonuç Alanı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Column(
                children: [
                  Text(
                    'Sonucunuz',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result,  // Buraya modelinize göre dinamik sonuç gelecek
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Yeni Fotoğraf Çekme Butonu
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Yeni Fotoğraf Çek'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
