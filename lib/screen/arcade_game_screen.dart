import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/controller/arcade_game_controller.dart';
import 'package:overlap/models/stage_data.dart';
import 'package:overlap/widget/arcade_game_board.dart';
import 'package:overlap/widget/arcade_game_drag.dart';
import 'package:overlap/widget/arcade_solve_board.dart';
import 'package:overlap/widget/arcade_stage_cleared_overlay.dart';

class ArcadeGameScreen extends StatelessWidget {
  const ArcadeGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController controller = Get.find<ArcadeGameController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final stage = controller.currentStage.value;
            if (stage == null) {
              return _buildNoStageSelected();
            }

            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    SizedBox(height: CELL_HEIGHT),
                    _StageStatsRow(stage: stage),
                    SizedBox(height: CELL_HEIGHT),
                    const ArcadeGameBoard(),
                    SizedBox(height: CELL_HEIGHT),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              thickness: 3,
                              color: AppColors.divider,
                            ),
                          ),
                          IconButton(
                            onPressed: controller.undo,
                            icon: const Icon(
                              Icons.undo_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          IconButton(
                            onPressed: controller.restartStage,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              thickness: 3,
                              color: AppColors.divider,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: CELL_HEIGHT * 2),
                    const ArcadeGameDrag(),
                    SizedBox(height: CELL_HEIGHT),
                  ],
                ),
                if (controller.isStageCleared.value)
                  const Positioned.fill(
                    child: ArcadeStageClearedOverlay(),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNoStageSelected() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '스테이지가 선택되지 않았어요.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.offAllNamed('/arcade'),
            child: const Text('아케이드 맵으로 이동'),
          ),
        ],
      ),
    );
  }
}

class _StageStatsRow extends StatelessWidget {
  final StageData stage;

  const _StageStatsRow({required this.stage});

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController controller = Get.find<ArcadeGameController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppColors.surface.withFraction(0.82),
                border: Border.all(
                  color: Colors.white.withFraction(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withFraction(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Obx(() {
                final moves = controller.currentMoves.value;
                final minMoves = stage.minMoves;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '최소 배치',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$minMoves회',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 3,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '현재 배치',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$moves회',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          const ArcadeSolveBoard(),
        ],
      ),
    );
  }
}
