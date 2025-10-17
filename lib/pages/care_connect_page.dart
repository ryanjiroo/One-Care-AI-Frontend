import 'package:flutter/material.dart';
// Ganti dengan path yang benar ke file-file Anda
import 'custom_bottom_nav_bar.dart';
import 'home_page.dart';
import 'book_appointment_page.dart';

class CareConnectPage extends StatelessWidget {
  const CareConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFE81F67)),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          title: const Text(
            'Care Connect',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.wifi_tethering, color: Color(0xFFE81F67)),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Connect Discussion'),
              Tab(text: 'Connect Professional'),
            ],
            indicatorColor: Color(0xFFE81F67),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3.0,
          ),
        ),
        body: const TabBarView(
          children: [
            _ConnectDiscussionView(),
            _ConnectProfessionalView(), // This view is now updated
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          },
        ),
      ),
    );
  }
}

// --- WIDGET UNTUK KONTEN TAB DISCUSSION (Tidak Berubah) ---
class _ConnectDiscussionView extends StatelessWidget {
  const _ConnectDiscussionView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title: 'Connect Discussion'),
          const SizedBox(height: 16),
          _buildDiscussionCard(
            profileImageUrl: 'https://i.pravatar.cc/150?img=1',
            name: 'Amanda Cowell',
            date: '2 Oktober 2025',
            content:
                'Halo semuanya 👋, aku mau tanya. Anak aku akhir-akhir ini sering tantrum kalau jam tidur malam. Kadang sampai 1-2 jam susah ditenangkan 😥. Ada yang punya tips biar bedtime lebih mudah?',
            likes: '123',
            comments: '98',
            saves: '7',
          ),
          const SizedBox(height: 24),
          _buildDiscussionCard(
            profileImageUrl: 'https://i.pravatar.cc/150?img=2',
            name: 'Susina Aylse',
            date: '1 Oktober 2025',
            content:
                'Halo Parents 💕, banyak orang tua cerita ke saya kalau merasa stres ketika anak menolak terapi atau sulit diajak kerja sama. Itu wajar, dan bukan berarti Anda gagal.\n\nTips sederhana untuk meredakan stres:\n→ Tarik napas dalam 3 kali.\n→ Ambil jeda sebentar (5 menit untuk diri sendiri).\n→ Gunakan kalimat positif ke anak: \'Mama tahu kamu capek, kita istirahat dulu ya.\'\n\nIngat, anak belajar dari energi kita. Kalau kita tenang, mereka lebih mudah ikut tenang. 😊\n\nBagaimana dengan pengalaman Anda? Apa ada trik yang biasanya berhasil di rumah?',
            likes: '123',
            comments: '98',
            saves: '7',
          ),
        ],
      ),
    );
  }
}

// --- WIDGET UNTUK KONTEN TAB PROFESSIONAL (Diperbarui) ---
class _ConnectProfessionalView extends StatelessWidget {
  const _ConnectProfessionalView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(title: 'Connect Professional'),
            const SizedBox(height: 16),
            _buildProfessionalCard(
              context: context,
              profileImageUrl: 'https://i.pravatar.cc/150?img=3',
              name: 'David H. Brown',
              specialty: 'Psychologists',
              hospital: 'Apollo hospital',
            ),
            const SizedBox(height: 16),
            _buildProfessionalCard(
              context: context,
              profileImageUrl: 'https://i.pravatar.cc/150?img=4',
              name: 'Robert Johnson',
              specialty: 'Psychologists',
              hospital: 'ABC hospital',
            ),
            const SizedBox(height: 16),
            _buildProfessionalCard(
              context: context,
              profileImageUrl: 'https://i.pravatar.cc/150?img=5',
              name: 'Laura White',
              specialty: 'Psychologists',
              hospital: 'Cedar Dental care',
            ),
            const SizedBox(height: 16),
            _buildProfessionalCard(
              context: context,
              profileImageUrl: 'https://i.pravatar.cc/150?img=6',
              name: 'Brian Clark',
              specialty: 'Therapist',
              hospital: 'ABC hospital',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFE81F67),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- HELPER WIDGETS (Beberapa Diperbarui/Ditambahkan) ---

// Header Bagian (Judul + Filter)
Widget _buildSectionHeader({required String title}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE81F67),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          _buildFilterChip(
            label: 'New',
            icon: Icons.fiber_new,
            isSelected: true,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Top', icon: Icons.arrow_upward),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Hot', icon: Icons.local_fire_department),
        ],
      ),
    ],
  );
}

// Chip Filter (New, Top, Hot)
Widget _buildFilterChip({
  required String label,
  required IconData icon,
  bool isSelected = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFFE81F67) : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(icon, color: isSelected ? Colors.white : Colors.black54, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// Kartu Diskusi
Widget _buildDiscussionCard({
  required String profileImageUrl,
  required String name,
  required String date,
  required String content,
  required String likes,
  required String comments,
  required String saves,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(profileImageUrl),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
      const SizedBox(height: 12),
      Row(
        children: [
          _buildActionButton(icon: Icons.favorite_border, count: likes),
          const SizedBox(width: 24),
          _buildActionButton(icon: Icons.chat_bubble_outline, count: comments),
          const SizedBox(width: 24),
          _buildActionButton(icon: Icons.bookmark_border, count: saves),
        ],
      ),
    ],
  );
}

// Tombol Aksi (Like, Comment, Save)
Widget _buildActionButton({required IconData icon, required String count}) {
  return Row(
    children: [
      Icon(icon, color: Colors.grey.shade600, size: 20),
      const SizedBox(width: 4),
      Text(count, style: TextStyle(color: Colors.grey.shade700)),
    ],
  );
}

// **KARTU PROFESIONAL BARU**
Widget _buildProfessionalCard({
  required BuildContext context,
  required String profileImageUrl,
  required String name,
  required String specialty,
  required String hospital,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$specialty | $hospital',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildInfoRow(
              icon: Icons.star,
              text: '4.8',
              iconColor: Colors.amber,
            ),
            const SizedBox(width: 24),
            _buildInfoRow(
              icon: Icons.schedule,
              text: '10:30am - 5:30pm',
              iconColor: Colors.grey,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BookAppointmentPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF16E9D),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Book Appointment',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

// Widget Helper untuk Baris Info (Rating & Waktu)
Widget _buildInfoRow({
  required IconData icon,
  required String text,
  required Color iconColor,
}) {
  return Row(
    children: [
      Icon(icon, color: iconColor, size: 20),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
    ],
  );
}
