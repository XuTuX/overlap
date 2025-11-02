import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/controllers/arcade_game_controller.dart';
import 'package:overlap/models/arcade_stage_data.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeStageClearedOverlay extends StatelessWidget {
  const ArcadeStageClearedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ArcadeGameController>();
    final stage = c.currentStage.value;
    if (stage == null) return const SizedBox.shrink();

    final next = _nextStage(stage);
    final moves = c.currentMoves.value;
    final target = stage.minMoves;
    final diff = moves - target;

    // ⭐ 별 개수 계산 로직
    final int stars = moves <= target
        ? 3
        : moves <= target * 2
            ? 2
            : 1;

    final bool perfect = diff <= 0;
    final bool good = diff <= 3 && diff > 0;
    final String resultLabel = perfect
        ? "PERFECT"
        : good
            ? "GOOD"
            : "SOSO";

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.grey.shade900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 320,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      perfect
                          ? Icons.emoji_events_rounded
                          : good
                              ? Icons.military_tech_rounded
                              : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      resultLabel,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Stars(stars: stars), // ✅ 별 개수 전달
                    const SizedBox(height: 16),
                    Text(
                      '$moves / $target',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (diff > 0)
                      Text(
                        '+${diff.abs()}회 더 이동',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (next != null)
                          _btn('다음', Icons.play_arrow_rounded, () {
                            c.isStageCleared.value = false;
                            c.loadStage(next);
                          }),
                        if (next != null) const SizedBox(width: 12),
                        _btn('홈', Icons.home_rounded,
                            () => Get.offAllNamed('/home')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  StageData? _nextStage(StageData s) {
    final i = arcadeStages.indexWhere((x) => x.id == s.id);
    if (i < 0 || i + 1 >= arcadeStages.length) return null;
    return arcadeStages[i + 1];
  }

  Widget _btn(String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.08),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int stars;
  const _Stars({required this.stars});

  @override
  Widget build(BuildContext context) {
    // ⭐ 별 개수만큼 노란색, 나머진 회색
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? Colors.amberAccent : Colors.white24,
            size: 30,
          ),
        );
      }),
    );
  }
}
