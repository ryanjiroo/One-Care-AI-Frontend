import 'package:flutter/material.dart';

class AfterScanEmotionPage extends StatelessWidget {
  // Terima URL gambar hasil dari halaman sebelumnya
  final String resultImageUrl;
  const AfterScanEmotionPage({super.key, required this.resultImageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildTags(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildInfoGrid(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    // Gabungkan base URL dengan path relatif dari API untuk mendapatkan URL gambar lengkap
    final String fullImageUrl =
        'https://digihack-emotion.reishandy.id$resultImageUrl';

    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: Colors.transparent,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // Tampilkan gambar dari URL yang diterima dari API
        background: Image.network(
          fullImageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.error)),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET DI BAWAH INI MENGGUNAKAN DATA DUMMY ---

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Yeay, kami berhasil mengenali ekspresi dan perilaku anak kamu!',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Hasil Analisis", // Data Dummy
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '😊 Kondisi Terdeteksi', // Data Dummy
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTags() {
    // Data Dummy
    final List<String> tags = ["Tenang", "Fokus", "Stabil"];
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tags.map((tag) => _TagChip(label: tag)).toList(),
    );
  }

  Widget _buildDescription() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(color: Colors.black54, fontSize: 15, height: 1.5),
        children: [
          // Data Dummy
          TextSpan(
            text:
                "Ini adalah deskripsi dummy. Gambar di atas adalah hasil analisis dari server. Data teks di halaman ini adalah contoh statis.",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: const [
        // Data Dummy
        _InfoCard(
          icon: Icons.sentiment_satisfied_alt,
          title: 'Mood',
          value: "Netral",
        ),
        _InfoCard(icon: Icons.bar_chart, title: 'Tingkat Fokus', value: "75%"),
        _InfoCard(
          icon: Icons.favorite_border,
          title: 'Aktivitas',
          value: "Bermain",
        ),
        _InfoCard(
          icon: Icons.history_toggle_off,
          title: 'Respons Emosi',
          value: "Positif",
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.bookmark_border, color: Colors.white),
      label: const Text(
        'Simpan Riwayat Ini',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE81F67),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Helper Widget tidak perlu diubah
class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: Colors.grey.shade100,
      labelStyle: const TextStyle(color: Colors.black54),
      side: BorderSide(color: Colors.grey.shade300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF6F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFE81F67), size: 24),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1a1a1a),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
