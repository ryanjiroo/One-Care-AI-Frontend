import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class CareBehaviourPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CareBehaviourPage({super.key, required this.cameras});

  @override
  State<CareBehaviourPage> createState() => _CareBehaviourPageState();
}

class _CareBehaviourPageState extends State<CareBehaviourPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  // Timer untuk menjalankan prediksi secara berkala
  Timer? _timer;

  bool _isProcessing = false;
  String _statusMessage = 'Menginisialisasi kamera...';
  String? _resultImageUrl;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      // Gunakan kamera belakang untuk deteksi perilaku
      widget.cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () =>
            widget.cameras.first, // Fallback jika tidak ada kamera belakang
      ),
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {
            _statusMessage = 'Kamera aktif. Analisis dimulai...';
          });
          // Mulai prediksi real-time setelah kamera siap
          _startRealtimePrediction();
        })
        .catchError((error) {
          setState(() {
            _statusMessage = 'Gagal menginisialisasi kamera: $error';
          });
        });
  }

  @override
  void dispose() {
    // Hentikan timer dan controller saat halaman ditutup untuk mencegah memory leak
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Memulai timer untuk mengambil dan memprediksi gambar secara berkala.
  void _startRealtimePrediction() {
    // Atur interval pengiriman gambar (misalnya, setiap 2 detik)
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _captureAndPredict();
    });
  }

  /// Mengambil gambar dan mengirimkannya ke API.
  Future<void> _captureAndPredict() async {
    // Jangan kirim request baru jika yang sebelumnya masih diproses
    if (_isProcessing || !_controller.value.isInitialized) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller.takePicture();
      final imageFile = File(image.path);

      final imageBytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/png;base64,${base64.encode(imageBytes)}';

      final url = Uri.parse(
        'https://digihack-behaviour.reishandy.id/predict_frame',
      );

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'image': base64Image}),
          )
          .timeout(const Duration(seconds: 45));

      if (mounted && response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          // Perbarui URL gambar hasil untuk ditampilkan di UI
          _resultImageUrl = responseData['result_url'];
          _statusMessage = 'Hasil diperbarui.';
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Gagal menganalisis: Coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Tumpuk (Stack) tampilan kamera dengan hasil gambar di atasnya
            return Stack(
              fit: StackFit.expand,
              children: [CameraPreview(_controller), _buildUIOverlay()],
            );
          } else {
            // Tampilkan loading indicator saat kamera sedang diinisialisasi
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  /// Widget untuk menampilkan UI di atas kamera (status dan gambar hasil).
  Widget _buildUIOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Bar berisi tombol kembali dan status
        Container(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          color: Colors.black.withOpacity(0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Real-time Behaviour Detection',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),
              const SizedBox(height: 8),
              if (_statusMessage.isNotEmpty)
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),

        // Tampilkan gambar hasil di tengah jika ada
        Expanded(
          child: Center(
            child: _resultImageUrl == null
                ? const SizedBox.shrink() // Jika tidak ada hasil, kosong
                : Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.pink, width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      // Tampilkan gambar dari URL yang didapat dari API
                      child: Image.network(
                        'https://digihack-behaviour.reishandy.id$_resultImageUrl',
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
