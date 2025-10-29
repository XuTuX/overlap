import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArcadeMonthScreen extends StatelessWidget {
  const ArcadeMonthScreen({super.key});

  final List<Map<String, dynamic>> months = const [
    {
      'name': 'January',
      'gradient': [Color(0xFF7F7BFF), Color(0xFF6AC9FF)],
    },
    {
      'name': 'February',
      'gradient': [Color(0xFFFF8B8B), Color(0xFFFF6A88)],
    },
    {
      'name': 'March',
      'gradient': [Color(0xFF47E6B1), Color(0xFF50C9C3)],
    },
    {
      'name': 'April',
      'gradient': [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    },
    {
      'name': 'May',
      'gradient': [Color(0xFFFFA751), Color(0xFFFF7C5C)],
    },
    {
      'name': 'June',
      'gradient': [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
    },
    {
      'name': 'July',
      'gradient': [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
    },
    {
      'name': 'August',
      'gradient': [Color(0xFF43E97B), Color(0xFF38F9D7)],
    },
    {
      'name': 'September',
      'gradient': [Color(0xFFFF758C), Color(0xFFFF7EB3)],
    },
    {
      'name': 'October',
      'gradient': [Color(0xFFFFCC70), Color(0xFFFFAF7B)],
    },
    {
      'name': 'November',
      'gradient': [Color(0xFF30CFD0), Color(0xFF330867)],
    },
    {
      'name': 'December',
      'gradient': [Color(0xFF5EE7DF), Color(0xFFB490CA)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1124),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Arcade Mode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Month',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '매달 새로운 스테이지가 열립니다.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: months.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final gradient = month['gradient'] as List<Color>;
                    return _MonthCard(
                      title: month['name'],
                      gradient: gradient,
                      onTap: () {
                        // 각 월 클릭 시 이동 (예: 1월 스테이지 맵)
                        Get.toNamed('/arcade/january');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _MonthCard({
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '20 stages',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: const Row(
                    children: [
                      Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Play',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
