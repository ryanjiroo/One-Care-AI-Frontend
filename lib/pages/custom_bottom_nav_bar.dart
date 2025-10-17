import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  // Parameter untuk mengetahui item mana yang sedang dipilih
  final int selectedIndex;

  // Fungsi yang akan dipanggil saat item di-tap
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap, // Langsung panggil fungsi onTap yang diterima
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.connect_without_contact),
          label: 'Connect',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
