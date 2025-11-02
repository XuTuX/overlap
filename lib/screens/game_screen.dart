import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/game_controller.dart';
import 'package:overlap/widgets/count_down_overlay.dart';
import 'package:overlap/widgets/exit_dialog.dart';
import 'package:overlap/widgets/game_board.dart';
import 'package:overlap/widgets/game_drag.dart';
import 'package:overlap/widgets/game_layout_scope.dart';
import 'package:overlap/widgets/game_over.dart';
import 'package:overlap/widgets/score_widget.dart';
import 'package:overlap/widgets/solve_board.dart';
import 'package:overlap/widgets/storage_warning_banner.dart';
import 'package:overlap/widgets/timer.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController gameController = Get.find<GameController>();

  @override
  void initState() {
    super.initState();
    gameController.resetGame();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = GameConfig.layoutOf(context);
    return GameLayoutScope(
      metrics: metrics,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Obx(() {
            final double highScore = gameController.bestScore.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 홈 버튼
                IconButton(
                  icon:
                      const Icon(Icons.home_rounded, color: AppColors.textPrimary),
                  iconSize: 24 * metrics.scale,
                  onPressed: () {
                    if (gameController.isGameOver.value) {
                      // 게임이 끝났으면 바로 홈으로 이동
                      Get.back(); // 또는 Get.offAll(HomeScreen()); 필요 시 교체
                    } else {
                      // 게임 중이면 ExitDialog 띄우기
                      Get.dialog(const ExitDialog());
                    }
                  },
                ),

                // 점수 표시
                Expanded(
                  child: Center(
                    child: ScoreWidget(
                      score: gameController.score.value,
                      highScore: highScore,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
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
                        if (!gameController.isCountdownDone.value) {
                          return const CountdownOverlay();
                        }

                        final originalMetrics =
                            GameLayoutScope.of(innerContext);
                        final message = gameController.persistenceWarning.value;
                        final hasWarning = message != null;

                        final double availableHeight =
                            constraints.maxHeight.isFinite
                                ? constraints.maxHeight
                                : originalMetrics.safeHeight;

                        final adjustedMetrics =
                            originalMetrics.ensureFitsHeight(
                          availableHeight,
                          hasWarning: hasWarning,
                        );

                        return GameLayoutScope(
                          metrics: adjustedMetrics,
                          child: Builder(
                            builder: (metricsContext) {
                              final metrics =
                                  GameLayoutScope.of(metricsContext);
                              final layoutFlex = metrics.flexDistribution(
                                  hasWarning: hasWarning);

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: metrics.scaledPadding(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    24,
                                                  ),
                                                  color: AppColors.surface
                                                      .withFraction(0.8),
                                                  border: Border.all(
                                                    color: AppColors.textPrimary
                                                        .withFraction(0.12),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors
                                                          .textPrimary
                                                          .withFraction(0.14),
                                                      blurRadius:
                                                          18 * metrics.scale,
                                                      offset: Offset(
                                                        0,
                                                        6 * metrics.scale,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Obx(() {
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      gameController
                                                              .isGameOver.value
                                                          ? const Gameover()
                                                          : CircularTimer(),
                                                    ],
                                                  );
                                                }),
                                              ),
                                              const SolveBoard(),
                                            ],
                                          ),
                                          if (message != null)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: metrics.scaledPadding(10),
                                              ),
                                              child: StorageWarningBanner(
                                                message: message,
                                                onRetry:
                                                    gameController.retryStorage,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: layoutFlex.board,
                                    fit: FlexFit.loose,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: const GameBoard(),
                                    ),
                                  ),
                                  Flexible(
                                    flex: layoutFlex.rack,
                                    fit: FlexFit.loose,
                                    child: LayoutBuilder(
                                      builder:
                                          (context, dragSectionConstraints) {
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                    onPressed:
                                                        gameController.undo,
                                                    icon: const Icon(
                                                      Icons.restore_rounded,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                    iconSize:
                                                        24 * metrics.scale,
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
                                                    hasWarning: hasWarning,
                                                  ),
                                                  bottom:
                                                      metrics.scaledPadding(18),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxHeight: dragSectionConstraints
                                                              .maxHeight
                                                              .isFinite
                                                          ? dragSectionConstraints
                                                              .maxHeight
                                                          : metrics.safeHeight *
                                                              0.3,
                                                    ),
                                                    child: const GameDrag(),
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
                              );
                            },
                          ),
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
}
