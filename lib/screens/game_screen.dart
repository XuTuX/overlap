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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Obx(() {
          final double highScore = gameController.bestScore.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 홈 버튼
              IconButton(
                icon: const Icon(Icons.home_rounded, color: Colors.white),
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
          child: Obx(() {
            if (!gameController.isCountdownDone.value) {
              return const CountdownOverlay();
            }

            final message = gameController.persistenceWarning.value;
            final hasWarning = message != null;

            return Column(
              children: [
                SizedBox(height: math.min(metrics.cellHeight * 2, 40)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppColors.surface.withFraction(0.8),
                        border: Border.all(
                          color: Colors.white.withFraction(0.04),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withFraction(0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Obx(() {
                        return Column(
                          children: [
                            gameController.isGameOver.value
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
                  StorageWarningBanner(
                    message: message,
                    onRetry: gameController.retryStorage,
                  ),
                SizedBox(
                  height: hasWarning
                      ? math.min(metrics.cellHeight * 0.75, 16)
                      : metrics.cellHeight,
                ),
                const GameBoard(),
                SizedBox(height: math.min(metrics.cellHeight, 24)),
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
                        onPressed: gameController.undo,
                        icon: const Icon(
                          Icons.restore_rounded,
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
                SizedBox(
                  height: hasWarning
                      ? math.min(metrics.cellHeight * 0.75, 16)
                      : math.min(metrics.cellHeight * 1.5, 32),
                ),
                const GameDrag(),
              ],
            );
          }),
        ),
      ),
    );
  }
}
