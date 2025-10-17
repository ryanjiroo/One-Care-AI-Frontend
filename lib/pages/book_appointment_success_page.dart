import 'package:flutter/material.dart'; // <-- PERBAIKAN DI SINI

class BookAppointmentSuccessPage extends StatelessWidget {
  const BookAppointmentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon
              Image.asset(
                'assets/images/success_icon.png', // Pastikan path ini benar
                height: 120,
              ),
              const SizedBox(height: 48),

              // Success Message
              const Text(
                'Your Book Appointment\nwas successfully booked!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 48),

              // Homepage Button
              ElevatedButton(
                onPressed: () {
                  // Tambahkan logika navigasi ke Homepage di sini
                  // Contoh: Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(builder: (context) => HomePage()),
                  //   (Route<dynamic> route) => false,
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE81F67),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Homepage',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
