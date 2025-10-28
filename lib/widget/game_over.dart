import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/controller/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Gameover extends StatelessWidget {
  const Gameover({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();
    return Column(
      children: [
        Text(
          'Game over',
          style: TextStyle(
            fontSize: ResponsiveSizes.gameOverTextSize(),
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
              onPressed: () => Get.offAllNamed('/home'),
              icon: Icon(
                Icons.home_rounded,
                size: ResponsiveSizes.gameOverIconSize(),
                color: AppColors.accent,
              ),
            ),
            IconButton(
              onPressed: gameController.resetGame,
              icon: Icon(
                Icons.replay_rounded,
                size: ResponsiveSizes.gameOverIconSize(),
                color: AppColors.accentSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
