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
        color: Colors.black.withValues(alpha: 0.6),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AppColors.surface.withFraction(0.92),
            border: Border.all(
              color: AppColors.accent.withFraction(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withFraction(0.4),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Stage ${stage.id} Clear!',
                style: TextStyle(
                  fontSize: ResponsiveSizes.gameOverTextSize(),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stage.title,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Obx(() {
                final moves = controller.currentMoves.value;
                return Text(
                  '$moves 회 사용 / 최소 ${stage.minMoves}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.restartStage,
                    icon: const Icon(Icons.replay),
                    label: const Text('다시 도전'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.isStageCleared.value = false;
                      Get.offAllNamed('/arcade');
                    },
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('맵으로'),
                  ),
                ],
              ),
              if (nextStage != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    controller.loadStage(nextStage);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Stage ${nextStage.id} 시작'),
                ),
              ],
            ],
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
