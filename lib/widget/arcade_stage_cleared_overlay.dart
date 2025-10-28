import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/controller/arcade_game_controller.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeStageClearedOverlay extends StatelessWidget {
  const ArcadeStageClearedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController controller = Get.find<ArcadeGameController>();
    final StageData? stage = controller.currentStage.value;
    if (stage == null) return const SizedBox.shrink();

    final nextStage = _findNextStage(stage);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(
          scale: 0.9 + 0.1 * value,
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.65),
              Colors.black.withOpacity(0.55),
            ],
          ),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.82,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4E5DAB).withOpacity(0.95),
                      const Color(0xFFFEB47B).withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Obx(() {
                  final moves = controller.currentMoves.value;
                  final minMoves = stage.minMoves;
                  final delta = moves - minMoves;
                  final perfect = delta <= 0;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_rounded,
                          color: Colors.white, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'STAGE ${stage.id} CLEAR!',
                        style: TextStyle(
                          fontSize: ResponsiveSizes.gameOverTextSize(),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        perfect ? 'Perfect!' : 'Well Done!',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _ResultChip(
                              icon: Icons.flag_rounded,
                              label: '최소 배치',
                              value: '$minMoves회'),
                          _ResultChip(
                              icon: Icons.touch_app_rounded,
                              label: '사용 배치',
                              value: '$moves회'),
                          _ResultChip(
                            icon: perfect
                                ? Icons.star_rounded
                                : Icons.trending_up_rounded,
                            label: '결과',
                            value: perfect ? '최소 배치 달성!' : '+${delta}회 초과',
                            highlight: perfect,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: _GlassButton(
                              icon: Icons.replay_rounded,
                              text: '다시 도전',
                              onPressed: controller.restartStage,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _GlassButton(
                              icon: Icons.map_rounded,
                              text: '맵으로',
                              onPressed: () {
                                controller.isStageCleared.value = false;
                                Get.offAllNamed('/arcade');
                              },
                            ),
                          ),
                        ],
                      ),
                      if (nextStage != null) ...[
                        const SizedBox(height: 20),
                        _NextStageButton(
                          nextStage: nextStage,
                          onPressed: () {
                            controller.isStageCleared.value = false;
                            controller.loadStage(nextStage);
                          },
                        ),
                      ]
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  StageData? _findNextStage(StageData current) {
    final index = arcadeStages.indexWhere((s) => s.id == current.id);
    if (index < 0 || index + 1 >= arcadeStages.length) return null;
    return arcadeStages[index + 1];
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _GlassButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _NextStageButton extends StatelessWidget {
  final StageData nextStage;
  final VoidCallback onPressed;

  const _NextStageButton({
    required this.nextStage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.play_arrow_rounded),
      label: Text('Stage ${nextStage.id} 계속하기'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _ResultChip({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = highlight
        ? Colors.white.withOpacity(0.28)
        : Colors.white.withOpacity(0.16);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white70, height: 1.1)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
