import 'package:flutter/material.dart';

class SimpleAfterScanPage extends StatelessWidget {
  final String resultImageUrl;

  const SimpleAfterScanPage({super.key, required this.resultImageUrl});

  @override
  Widget build(BuildContext context) {
    // Gabungkan base URL dengan path gambar dari API
    final String fullImageUrl =
        'https://digihack-emotion.reishandy.id$resultImageUrl';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Analisis"),
        backgroundColor: Colors.pink,
      ),
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Gambar Hasil Deteksi Emosi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Widget untuk menampilkan gambar dari URL
              Image.network(
                fullImageUrl,
                fit: BoxFit.contain,
                // Tampilkan loading indicator saat gambar dimuat
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                // Tampilkan pesan error jika gambar gagal dimuat
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Gagal memuat gambar hasil.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
