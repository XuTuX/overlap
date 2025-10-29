import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/controller/game_controller.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/widget/count_down_overlay.dart';
import 'package:overlap/widget/game_board.dart';
import 'package:overlap/widget/game_drag.dart';
import 'package:overlap/widget/game_over.dart';
import 'package:overlap/widget/score_widget.dart';
import 'package:overlap/widget/solve_board.dart';
import 'package:overlap/widget/timer.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameController gameController = Get.find<GameController>();
  final HiveGameBox hiveGameBox = HiveGameBox();

  @override
  void initState() {
    super.initState();
    gameController.resetGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Obx(() {
          final double highScore = hiveGameBox.getHighScore();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 홈 버튼
              IconButton(
                icon: const Icon(Icons.home_rounded, color: Colors.white),
                onPressed: () {
                  Get.dialog(
                    Dialog(
                      backgroundColor: Colors.black.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.exit_to_app_rounded,
                              size: 48,
                              color: AppColors.accent,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '홈 화면으로 돌아가시겠어요?',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '진행 중인 게임은 저장되지 않습니다.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: Get.back,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                  ),
                                  child: const Text('취소'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.offAllNamed('/home');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('나가기'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                  );
                },
              ),
              // 점수 표시
              Expanded(
                child: Center(
                  child: ScoreWidget(
                    score: gameController.score.toString(),
                    highScore: highScore.toString(),
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

            return Column(
              children: [
                const SizedBox(height: 40),
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
                SizedBox(height: CELL_HEIGHT),
                const GameBoard(),
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
                SizedBox(height: CELL_HEIGHT * 2),
                const GameDrag(),
              ],
            );
          }),
        ),
      ),
    );
  }
}
