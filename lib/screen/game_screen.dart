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
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.put(GameController());
    final HiveGameBox hiveGameBox = HiveGameBox();

    // 시작하자마자 카운트다운 시작
    Future.microtask(() => gameController.startCountdown());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
              return CountdownOverlay();
            }

            return Column(
              children: [
                SizedBox(height: 40),
                Obx(() {
                  double highScore = hiveGameBox.getHighScore();
                  return ScoreWidget(
                    score: gameController.score.toString(),
                    highScore: highScore.toString(),
                  );
                }),
                SizedBox(height: CELL_HEIGHT),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
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
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Obx(() {
                        return Column(
                          children: [
                            gameController.isGameOver.value
                                ? Gameover()
                                : CircularTimer(),
                          ],
                        );
                      }),
                    ),
                    SolveBoard(),
                  ],
                ),
                SizedBox(height: CELL_HEIGHT),
                GameBoard(),
                SizedBox(height: CELL_HEIGHT),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                            thickness: 3, color: AppColors.divider),
                      ),
                      IconButton(
                        onPressed: gameController.undo,
                        icon: Icon(
                          Icons.restore_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                            thickness: 3, color: AppColors.divider),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: CELL_HEIGHT * 2),
                GameDrag(),
              ],
            );
          }),
        ),
      ),
    );
  }
}
