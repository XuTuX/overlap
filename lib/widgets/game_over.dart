import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/controllers/game_controller.dart';
import 'package:overlap/widgets/game_layout_scope.dart';

class Gameover extends StatelessWidget {
  const Gameover({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();
    final metrics = GameLayoutScope.of(context);
    return Column(
      children: [
        Text(
          'Game over',
          style: TextStyle(
            fontSize: metrics.gameOverTextSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                Get.delete<GameController>();
                Get.offAllNamed('/home');
              },
              icon: Icon(
                Icons.home_rounded,
                size: metrics.gameOverIconSize,
                color: AppColors.accent,
              ),
            ),
            IconButton(
              onPressed: gameController.resetGame,
              icon: Icon(
                Icons.replay_rounded,
                size: metrics.gameOverIconSize,
                color: AppColors.accentSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
