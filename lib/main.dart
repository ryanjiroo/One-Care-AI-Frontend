import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- BARIS TAMBAHAN

import 'firebase_options.dart';
import 'pages/login_page.dart';

void main() async {
  // Pastikan semuanya siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();

  // BARIS TAMBAHAN: Muat file .env sebelum inisialisasi Firebase
  await dotenv.load(fileName: ".env");

  // KODE SEBELUMNYA: Tetap ada dan tidak diubah
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await availableCameras();

  // Baru jalankan aplikasi setelah semua siap
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care App',
      theme: ThemeData(primarySwatch: Colors.pink),
      // Langsung ke LoginPage karena loading sudah ditangani splash screen
      home: const LoginPage(),
    );
  }
}
