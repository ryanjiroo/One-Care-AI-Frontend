import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';

void main() async {
  // Pastikan semuanya siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();

  // Lakukan semua proses inisialisasi di sini
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
