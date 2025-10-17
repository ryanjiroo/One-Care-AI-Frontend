import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'after_scan_emotion_page.dart'; // Pastikan file ini ada

class CareEmotionPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CareEmotionPage({super.key, required this.cameras});

  @override
  State<CareEmotionPage> createState() => _CareEmotionPageState();
}

class _CareEmotionPageState extends State<CareEmotionPage>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String _statusMessage = 'Arahkan kamera atau pilih dari galeri.';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => widget.cameras.first,
      ),
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Fungsi utama untuk memproses gambar dan mengirim ke API.
  Future<void> _predictFromImageFile(File imageFile) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Memproses gambar...';
    });

    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/png;base64,${base64.encode(imageBytes)}';

      final url = Uri.parse(
        'https://digihack-emotion.reishandy.id/predict_frame',
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
        final String? resultUrl =
            responseData['result_url']; // Ambil URL gambar

        if (resultUrl != null) {
          setState(() => _statusMessage = 'Analisis berhasil!');
          _showScanCompleteDialog(resultUrl); // Kirim URL ke dialog
        } else {
          throw Exception('URL hasil tidak ditemukan di respons server.');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Gagal menganalisis: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Mengambil gambar dari kamera.
  Future<void> _captureAndPredict() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      await _predictFromImageFile(File(image.path));
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Gagal mengambil gambar: $e');
      }
    }
  }

  /// Memilih gambar dari galeri.
  Future<void> _pickAndPredictFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _predictFromImageFile(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Gagal memilih gambar: $e');
      }
    }
  }

  /// Menampilkan dialog setelah analisis selesai.
  void _showScanCompleteDialog(String resultUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 32.0,
              horizontal: 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/success_icon.png', height: 80),
                const SizedBox(height: 24),
                const Text(
                  'Emosi anak kamu telah\nberhasil di analisis',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        // Navigasi ke halaman hasil dengan mengirim URL gambar
                        builder: (context) =>
                            AfterScanEmotionPage(resultImageUrl: resultUrl),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE81F67),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lihat Hasil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Sisa kode di bawah ini (build, _buildUIOverlay, _buildScanAnimation) tidak berubah
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller),
                _buildUIOverlay(),
                if (_isProcessing) _buildScanAnimation(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildUIOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Identify the Emotion',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _isProcessing ? null : _pickAndPredictFromGallery,
              ),
              GestureDetector(
                onTap: _isProcessing ? null : _captureAndPredict,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isProcessing
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: _isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.flip_camera_ios_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanAnimation() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment(0, _animation.value * 2 - 1),
            heightFactor: 1.0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.withOpacity(0.0),
                    Colors.pink.shade300,
                    Colors.pink.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade200,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
