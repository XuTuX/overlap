import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/models/stage_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HiveGameBox hive = HiveGameBox();
    final int clearedStage = hive.getClearedStage();
    final double highScore = hive.getHighScore();

    final bool allCleared = clearedStage >= arcadeStages.length;
    final double progress =
        (clearedStage / arcadeStages.length).clamp(0.0, 1.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF090B1A),
              Color(0xFF131A2E),
            ],
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
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HomeHeader(),
                    const SizedBox(height: 24),
                    _ModeCard(
                      title: 'Arcade Mode',
                      subtitle: allCleared
                          ? '축하해요! 모든 퍼즐을 완수했어요.'
                          : 'Stage ${clearedStage + 1} 도전 준비 완료',
                      accent: AppColors.accent,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9A8B), Color(0xFFFAD0C4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      chips: const ['Stage Run', 'Puzzle', 'Progression'],
                      onTap: () => Get.toNamed('/arcade'),
                      trailing: CircleAvatar(
                        radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
                        child: Text(
                          '$clearedStage/${arcadeStages.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ModeCard(
                      title: 'Infinite Mode',
                      subtitle:
                          '최고 점수 ${highScore.toStringAsFixed(1)}점, 기록 갱신에 도전!',
                      accent: AppColors.accentSecondary,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      chips: const ['Endless', 'Speed', 'Score Hunt'],
                      onTap: () => Get.toNamed('/game'),
                      trailing: Icon(
                        Icons.all_inclusive_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _QuickStats(
                      clearedStage: clearedStage,
                      progress: progress,
                      highScore: highScore,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Overlap Puzzle',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '모드를 선택해 새로운 퍼즐을 즐겨보세요.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.videogame_asset_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final LinearGradient gradient;
  final List<String> chips;
  final VoidCallback onTap;
  final Widget trailing;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.gradient,
    required this.chips,
    required this.onTap,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing,
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map(
                    (label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final int clearedStage;
  final double progress;
  final double highScore;

  const _QuickStats({
    required this.clearedStage,
    required this.progress,
    required this.highScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatTile(
            icon: Icons.flag_rounded,
            label: 'Cleared',
            value: '$clearedStage/${arcadeStages.length}',
          ),
          _StatTile(
            icon: Icons.show_chart_rounded,
            label: 'Progress',
            value: '${(progress * 100).round()}%',
          ),
          _StatTile(
            icon: Icons.stars_rounded,
            label: 'High Score',
            value: highScore.toStringAsFixed(1),
          ),
        ],
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
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
