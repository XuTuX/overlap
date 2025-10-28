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
    if (stage == null) {
      return const SizedBox.shrink();
    }

    final nextStage = _findNextStage(stage);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.65),
            Colors.black.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.82,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3E4A7A).withValues(alpha: 0.95),
                  AppColors.accent.withValues(alpha: 0.92),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withFraction(0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Obx(() {
              final moves = controller.currentMoves.value;
              final int minMoves = stage.minMoves;
              final int delta = moves - minMoves;
              final bool perfect = delta <= 0;
              final String statusText = perfect
                  ? '최소 배치 달성!'
                  : '+$delta회 초과 배치';

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Stage ${stage.id}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    stage.title,
                    style: TextStyle(
                      fontSize: ResponsiveSizes.gameOverTextSize(),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    perfect ? '완벽해요!' : '클리어 성공!',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ResultChip(
                        icon: Icons.flag_rounded,
                        label: '최소 배치',
                        value: '$minMoves회',
                      ),
                      _ResultChip(
                        icon: Icons.touch_app_rounded,
                        label: '사용 배치',
                        value: '$moves회',
                      ),
                      _ResultChip(
                        icon: perfect
                            ? Icons.star_rounded
                            : Icons.trending_up_rounded,
                        label: '결과',
                        value: statusText,
                        highlight: perfect,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: controller.restartStage,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('다시 도전'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            controller.isStageCleared.value = false;
                            Get.offAllNamed('/arcade');
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.map_rounded),
                          label: const Text('맵으로'),
                        ),
                      ),
                    ],
                  ),
                  if (nextStage != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          controller.loadStage(nextStage);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('Stage ${nextStage.id} 계속하기'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nextStage.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ]
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  StageData? _findNextStage(StageData current) {
    final index = arcadeStages.indexWhere((stage) => stage.id == current.id);
    if (index < 0) {
      return null;
    }
    final nextIndex = index + 1;
    if (nextIndex >= arcadeStages.length) {
      return null;
    }
    return arcadeStages[nextIndex];
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
        ? Colors.white.withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.16);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
