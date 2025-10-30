import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/models/stage_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HiveGameBox hive = HiveGameBox();
    final double highScore = hive.getHighScore();

    // ⭐ 누적 별 개수 계산
    int totalStars = 0;
    for (final stage in arcadeStages) {
      totalStars += hive.getStageStar(stage.id);
    }
    final int maxStars = arcadeStages.length * 3;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const _HomeHeader(),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded,
                color: Colors.white),
            onPressed: () => Get.toNamed('/tutorial'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF090B1A), Color(0xFF131A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const _FloatingOrb(
              left: -60,
              top: 40,
              size: 160,
              color: Color(0xFF3D5AFE),
            ),
            const _FloatingOrb(
              right: -40,
              top: 220,
              size: 120,
              color: Color(0xFFFF8A65),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '다양한 모드에서 게임을 즐겨보세요.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 📦 모드 카드
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _BigModeCard(
                            title: 'Arcade Mode',
                            subtitle: '다양한 퍼즐 스테이지에 도전해보세요.',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9A8B), Color(0xFFFAD0C4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            icon: Icons.grid_view_rounded,
                            onTap: () => Get.toNamed('/arcade'),
                          ),
                          const SizedBox(height: 28),
                          _BigModeCard(
                            title: 'Infinite Mode',
                            subtitle: '무한한 플레이로 실력을 증명하세요.',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            icon: Icons.all_inclusive_rounded,
                            onTap: () => Get.toNamed('/game'),
                          ),
                        ],
                      ),
                    ),

                    // ⭐ 아래 요약 정보 박스
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatTile(
                            icon: Icons.star_rounded,
                            label: 'Arcade Stars',
                            value: '$totalStars / $maxStars',
                          ),
                          _StatTile(
                            icon: Icons.military_tech_rounded,
                            label: 'High Score',
                            value: highScore.toStringAsFixed(1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Overlap Puzzle',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.videogame_asset_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ],
    );
  }
}

class _BigModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _BigModeCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.22,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FloatingOrb extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final double size;
  final Color color;

  const _FloatingOrb({
    this.left,
    this.right,
    this.top,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.25),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: size / 1.8,
              spreadRadius: size / 4,
            ),
          ],
        ),
      ),
    );
  }
}
