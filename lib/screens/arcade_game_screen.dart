import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/arcade_game_controller.dart';
import 'package:overlap/models/stage_data.dart';
import 'package:overlap/widgets/arcade_game_board.dart';
import 'package:overlap/widgets/arcade_game_drag.dart';
import 'package:overlap/widgets/arcade_solve_board.dart';
import 'package:overlap/widgets/arcade_stage_cleared_overlay.dart';
import 'package:overlap/widgets/game_layout_scope.dart';

class ArcadeGameScreen extends StatelessWidget {
  const ArcadeGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController controller = Get.find<ArcadeGameController>();
    final metrics = GameConfig.layoutOf(context);

    return GameLayoutScope(
      metrics: metrics,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: metrics.scaledPadding(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: metrics.scaledPadding(10)),
                IconButton(
                  onPressed: controller.restartStage,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                  ),
                  iconSize: 24 * metrics.scale,
                ),
              ],
            ),
          ),
        ),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bodyMetrics = GameConfig.layoutOf(
                  context,
                  maxHeightOverride: constraints.maxHeight,
                  maxWidthOverride: constraints.maxWidth,
                );
                return GameLayoutScope(
                  metrics: bodyMetrics,
                  child: Builder(
                    builder: (innerContext) {
                      return Obx(() {
                        final stage = controller.currentStage.value;
                        if (stage == null) {
                          return _buildNoStageSelected();
                        }

                        final metrics = GameLayoutScope.of(innerContext);

                        return Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: metrics.scaledPadding(24)),
                                SizedBox(height: metrics.cellHeight),
                                _StageStatsRow(stage: stage),
                                SizedBox(height: metrics.cellHeight),
                                Flexible(
                                  flex: 6,
                                  child: Center(
                                    child: const ArcadeGameBoard(),
                                  ),
                                ),
                                SizedBox(height: metrics.scaledPadding(16)),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: metrics.scaledPadding(20)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          thickness:
                                              math.max(1.5, 3 * metrics.scale),
                                          color: AppColors.divider,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: controller.undo,
                                        icon: const Icon(
                                          Icons.undo_rounded,
                                          color: AppColors.textSecondary,
                                        ),
                                        iconSize: 24 * metrics.scale,
                                      ),
                                      IconButton(
                                        onPressed: controller.restartStage,
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          color: AppColors.textSecondary,
                                        ),
                                        iconSize: 24 * metrics.scale,
                                      ),
                                      Expanded(
                                        child: Divider(
                                          thickness:
                                              math.max(1.5, 3 * metrics.scale),
                                          color: AppColors.divider,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: metrics.cellHeight * 1.5,
                                      bottom: metrics.cellHeight,
                                    ),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: const ArcadeGameDrag(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (controller.isStageCleared.value)
                              const Positioned.fill(
                                child: ArcadeStageClearedOverlay(),
                              ),
                          ],
                        );
                      });
                    },
                  ),
                );
              },
            ),
          ),
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
            onPressed: () => Get.offAllNamed(
              '/arcade',
            ),
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
    final metrics = GameLayoutScope.of(context);
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: metrics.scaledPadding(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: metrics.scaledPadding(12)),
              padding: EdgeInsets.all(metrics.scaledPadding(20)),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(math.max(12, 24 * metrics.scale)),
                color: AppColors.surface.withFraction(0.82),
                border: Border.all(
                  color: Colors.white.withFraction(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withFraction(0.18),
                    blurRadius: 16 * metrics.scale,
                    offset: Offset(0, 6 * metrics.scale),
                  ),
                ],
              ),
              child: Obx(() {
                final moves = controller.currentMoves.value;
                final target = stage.minMoves;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          color: AppColors.accent,
                          size: 18 * metrics.scale,
                        ),
                        SizedBox(width: metrics.scaledPadding(6)),
                        Text(
                          '목표 $target회',
                          style: TextStyle(
                            fontSize: 16 * metrics.scale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: metrics.scaledPadding(10)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: AppColors.textSecondary,
                          size: 18 * metrics.scale,
                        ),
                        SizedBox(width: metrics.scaledPadding(6)),
                        Text(
                          '$moves회 사용',
                          style: TextStyle(
                            fontSize: 18 * metrics.scale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
          SizedBox(width: metrics.scaledPadding(12)),
          const ArcadeSolveBoard(),
        ],
      ),
    );
  }
}
