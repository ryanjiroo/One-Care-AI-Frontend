import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:camera/camera.dart';
import 'care_assistant_page.dart';
import 'custom_bottom_nav_bar.dart';
import 'care_connect_page.dart';
import 'care_emotion_page.dart';
import 'care_behaviour_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _selectedFilter = 'Days';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFeatureCards(),
              const SizedBox(height: 24),
              _buildMoodStatsSection(),
              const SizedBox(height: 24),
              _buildAiMoodPredictions(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CareConnectPage(),
                ),
              );
            }
          });
        },
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=1',
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, Sarah 👋',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'How\'s Your Day?',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // --- Feature Cards (Vertical) ---
  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildCard(
            title: 'Care Assistant',
            subtitle: 'AI Pendamping Kehidupan Kamu',
            buttonText: 'Konsultasi Dengan AI',
            color: const Color(0xFFE81F67),
            imagePath: 'assets/images/business-finance-employment-female.png',
            svgPath: 'assets/svgs/care_assistant.svg',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CareAssistantPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          // --- CARE BEHAVIOR CARD (UPDATED) ---
          _buildCard(
            title: 'Care Behavior',
            subtitle: 'Lacak Perkembangan Anak',
            buttonText: 'Kenali Sekarang',
            color: const Color(0xFFF16E9D),
            imagePath: 'assets/images/business-finance-employment-male.png',
            svgPath: 'assets/svgs/care_connect.svg',
            onPressed: () async {
              if (!context.mounted) return;
              // Get available cameras
              final cameras = await availableCameras();
              // Navigate to the real-time behavior page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CareBehaviourPage(cameras: cameras),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          // --- CARE EMOTION CARD ---
          _buildCard(
            title: 'Care Emotion',
            subtitle: 'Kenali Emosi Buah Hati Kamu',
            buttonText: 'Kenali Emosi Anak',
            color: const Color(0xFFE81F67),
            imagePath: 'assets/images/asian-female-doctor.png',
            svgPath: 'assets/svgs/care_insights.svg',
            onPressed: () async {
              if (!context.mounted) return;
              // Get available cameras
              final cameras = await availableCameras();
              // Navigate to the emotion page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CareEmotionPage(cameras: cameras),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Mood Stats (Chart) ---
  Widget _buildMoodStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Stats',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'See your special child moods!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildFilterButtons(),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: _buildLineChart()),
        ],
      ),
    );
  }

  // --- AI Mood Predictions ---
  Widget _buildAiMoodPredictions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Mood Predictions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Text('Next 1w'),
                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MoodIcon(day: 'Mon', svgPath: 'assets/svgs/Emotion_happy.svg'),
              _MoodIcon(day: 'Tue', svgPath: 'assets/svgs/Emotion_happy.svg'),
              _MoodIcon(
                day: 'Wed',
                svgPath: 'assets/svgs/Emotion_depressed.svg',
              ),
              _MoodIcon(day: 'Thu', svgPath: 'assets/svgs/Emotion_netral.svg'),
              _MoodIcon(day: 'Fri', svgPath: 'assets/svgs/Emotion_happy.svg'),
              _MoodIcon(day: 'Sat', svgPath: 'assets/svgs/Emotion_happy.svg'),
              _MoodIcon(
                day: 'Sun',
                svgPath: 'assets/svgs/Emotion_depressed.svg',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Card Template ---
  Widget _buildCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required Color color,
    required String imagePath,
    required String svgPath,
    required VoidCallback onPressed,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 160,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        svgPath,
                        height: 30,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(buttonText),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 80),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: -20,
          child: Image.asset(imagePath, height: 180, fit: BoxFit.contain),
        ),
      ],
    );
  }

  // --- Chart Filter Buttons ---
  Widget _buildFilterButtons() {
    final filters = ['All', 'Days', 'Weeks', 'Months', 'Years'];
    return SizedBox(
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              }
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: const Color(0xFFE81F67),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.transparent),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          );
        },
      ),
    );
  }

  // --- Line Chart ---
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(color: Colors.grey, fontSize: 12);
                switch (value.toInt()) {
                  case 0:
                    return const Text('Mon', style: style);
                  case 1:
                    return const Text('Tue', style: style);
                  case 2:
                    return const Text('Wed', style: style);
                  case 3:
                    return const Text('Thu', style: style);
                  case 4:
                    return const Text('Fri', style: style);
                  case 5:
                    return const Text('Sat', style: style);
                  case 6:
                    return const Text('Sun', style: style);
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 3.2),
              FlSpot(2, 2.5),
              FlSpot(3, 1),
              FlSpot(4, 2),
              FlSpot(5, 2.2),
              FlSpot(6, 3),
            ],
            isCurved: true,
            color: const Color(0xFFF16E9D),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF16E9D).withOpacity(0.4),
                  const Color(0xFFF16E9D).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                String moodText;
                if (barSpot.y >= 3) {
                  moodText = 'Happy';
                } else if (barSpot.y > 1.5) {
                  moodText = 'Neutral';
                } else {
                  moodText = 'Depressed';
                }
                return LineTooltipItem(
                  moodText,
                  const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

// --- Daily mood icon widget ---
class _MoodIcon extends StatelessWidget {
  final String day;
  final String svgPath;

  const _MoodIcon({required this.day, required this.svgPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        SvgPicture.asset(svgPath, height: 32, width: 32),
      ],
    );
  }
}
