import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/arcade_game_controller.dart';
import 'package:overlap/models/stage_data.dart';
import 'package:overlap/screens/arcade_stage_list.dart';
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
          automaticallyImplyLeading: false,
          title: Obx(() {
            final StageData? stage = controller.currentStage.value;
            final String stageLabel =
                stage != null ? 'Stage ${stage.order ?? stage.id}' : 'Arcade';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                    iconSize: 24 * metrics.scale,
                    onPressed: () =>
                        Get.offAll(() => const ArcadeStageListScreen())),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stageLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24 * metrics.scale,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.restartStage,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textPrimary,
                  ),
                  iconSize: 24 * metrics.scale,
                ),
              ],
            );
          }),
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
                        final layoutFlex =
                            metrics.flexDistribution(hasWarning: false);

                        return Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: metrics.scaledPadding(12),
                                    ),
                                    child: _ArcadeHeader(stage: stage),
                                  ),
                                ),
                                Flexible(
                                  flex: layoutFlex.board,
                                  fit: FlexFit.loose,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: const ArcadeGameBoard(),
                                  ),
                                ),
                                Flexible(
                                  flex: layoutFlex.rack,
                                  fit: FlexFit.loose,
                                  child: LayoutBuilder(
                                    builder: (context, dragSectionConstraints) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          SizedBox(
                                            height:
                                                metrics.boardToToolbarSpacing,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Divider(
                                                    thickness: math.max(
                                                      1.5,
                                                      3 * metrics.scale,
                                                    ),
                                                    color: AppColors.divider,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: controller.undo,
                                                  icon: const Icon(
                                                    Icons.restore_rounded,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  iconSize: 24 * metrics.scale,
                                                ),
                                                Expanded(
                                                  child: Divider(
                                                    thickness: math.max(
                                                      1.5,
                                                      3 * metrics.scale,
                                                    ),
                                                    color: AppColors.divider,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                top: metrics.dragTopPadding(
                                                  hasWarning: false,
                                                ),
                                                bottom:
                                                    metrics.scaledPadding(18),
                                              ),
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxHeight: dragSectionConstraints
                                                            .maxHeight.isFinite
                                                        ? dragSectionConstraints
                                                            .maxHeight
                                                        : metrics.safeHeight *
                                                            0.3,
                                                  ),
                                                  child: const ArcadeGameDrag(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
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

class _ArcadeHeader extends StatelessWidget {
  const _ArcadeHeader({required this.stage});

  final StageData stage;

  @override
  Widget build(BuildContext context) {
    final metrics = GameLayoutScope.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: metrics.scaledPadding(10)),
        _StageStatsRow(stage: stage),
      ],
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
      padding: EdgeInsets.symmetric(horizontal: metrics.scaledPadding(30)),
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
                  color: AppColors.textPrimary.withFraction(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withFraction(0.14),
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
