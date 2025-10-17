import 'package:flutter/material.dart';
import 'custom_bottom_nav_bar.dart';
import 'book_appointment_success_page.dart'; // Ganti package_path sesuai proyek Anda

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  // Variabel untuk menyimpan state pilihan pengguna
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedSchedule;

  // Daftar pilihan untuk dropdown dan chip
  final List<String> _days = ['Day', '1', '2', '3', '4', '5']; // Contoh
  final List<String> _months = [
    'Month',
    'January',
    'February',
    'March',
  ]; // Contoh
  final List<String> _schedules = [
    '10:30am - 11:30am',
    '11:30am - 12:30pm',
    '12:30am - 1:30pm',
    '2:30am - 3:30pm',
    '3:30am - 4:30pm',
    '4:30am - 5:30pm',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorInfo(),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const Divider(height: 48),
                  _buildSectionTitle('Select Date'),
                  const SizedBox(height: 16),
                  _buildDateSelectors(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Schedules'),
                  const SizedBox(height: 16),
                  _buildScheduleChips(),
                  const SizedBox(height: 48),
                  _buildBookingButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1,
        onTap: (index) {},
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      backgroundColor: const Color(0xFFE81F67),
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Care Connect',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.wifi_tethering, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar dokter
            Image.asset(
              'assets/images/doctor_image.png', // Pastikan path benar
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            // Overlay gradient agar teks lebih terbaca
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black26, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'David H. Brown',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text('4.8', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Icon(Icons.star, color: Colors.amber, size: 20),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Psychologists | Apollo hospital',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.schedule, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              '10:30am - 5:30pm',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(value: '15yr', label: 'Experience'),
        _StatItem(value: '50+', label: 'Treated'),
        _StatItem(value: '\Rp25.000,00', label: 'Hourly Rate'),
      ],
    );
  }

  Widget _buildDateSelectors() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            hint: 'Day',
            items: _days,
            value: _selectedDay,
            onChanged: (val) => setState(() => _selectedDay = val),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDropdown(
            hint: 'Month',
            items: _months,
            value: _selectedMonth,
            onChanged: (val) => setState(() => _selectedMonth = val),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleChips() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: _schedules.map((schedule) {
        final isSelected = _selectedSchedule == schedule;
        return ChoiceChip(
          label: Text(schedule),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedSchedule = selected ? schedule : null;
            });
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: const Color(0xFFE81F67).withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? const Color(0xFFE81F67) : Colors.black,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFFE81F67)
                  : Colors.grey.shade300,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      }).toList(),
    );
  }

  Widget _buildBookingButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BookAppointmentSuccessPage(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE81F67),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text(
        'Book Appointment',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Helper untuk Dropdown
  Widget _buildDropdown({
    required String hint,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: const TextStyle(color: Colors.grey)),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

// Helper untuk item statistik
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
