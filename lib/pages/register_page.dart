import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk menangani input dari user
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State untuk mengatur visibilitas password
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // State untuk menampilkan loading indicator
  bool _isLoading = false;

  // State untuk menyimpan pesan error
  String? _errorMessage;

  // Fungsi untuk membuka URL
  final Uri _termsOfServiceUrl = Uri.parse('https://example.com/terms');
  final Uri _privacyPolicyUrl = Uri.parse('https://example.com/privacy');

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  // Fungsi untuk simulasi proses registrasi
  void _register() async {
    // Reset state error dan set loading
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Simulasi delay seperti memanggil API (2 detik)
    await Future.delayed(const Duration(seconds: 2));

    // Logika sederhana untuk validasi
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields must be filled.';
        _isLoading = false;
      });
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
        _isLoading = false;
      });
    } else {
      // Jika berhasil, navigasi ke halaman berikutnya
      print('Registration Successful!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
        // Contoh navigasi:
        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      }
      // Set isLoading kembali ke false jika tetap di halaman ini
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Membersihkan controller saat widget dihapus
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Create an account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      // PERUBAHAN UTAMA: Menggunakan SingleChildScrollView untuk seluruh body
      body: SafeArea(
        child: SingleChildScrollView(
          // <-- DIBUNGKUS DENGAN INI
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Input Nama
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Input Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'example@example.com',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Input Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink, width: 2.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Input Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink, width: 2.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Register
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _errorMessage != null
                        ? Colors.red
                        : const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                // Pesan Error (hanya muncul jika ada)
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],

                // Memberi jarak agar konten bawah tidak terlalu mepet
                const SizedBox(height: 48),

                // Link "Sudah punya akun? Masuk."
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              // Kembali ke halaman login
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Log in.',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Teks Kebijakan
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      children: [
                        const TextSpan(
                          text: 'By using One CARE, you agree to the ',
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => _launchUrl(_termsOfServiceUrl),
                            child: const Text(
                              'Terms',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => _launchUrl(_privacyPolicyUrl),
                            child: const Text(
                              'Privacy Policy.',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ), // Jarak ke bagian paling bawah layar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
