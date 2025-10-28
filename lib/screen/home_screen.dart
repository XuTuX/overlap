import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/models/stage_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HiveGameBox hiveGameBox = HiveGameBox();
    final int clearedStage = hiveGameBox.getClearedStage();
    final double highScore = hiveGameBox.getHighScore();
    final bool allCleared = clearedStage >= arcadeStages.length;

    final String progressText = allCleared
        ? '20 스테이지 모두 클리어!'
        : clearedStage == 0
            ? '아직 클리어한 스테이지가 없어요.'
            : '마지막 클리어: Stage $clearedStage';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset(
                    'assets/image/highscore.png',
                    fit: BoxFit.contain,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  allCleared
                      ? 'All Clear!'
                      : 'Next: Stage ${clearedStage + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: Image.asset(
                'assets/image/main.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: CELL_HEIGHT),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                progressText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Text(
                  '최고 점수: ${highScore.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: CELL_HEIGHT * 1.5),
            TextButton(
              onPressed: () => Get.toNamed('/arcade'),
              style: TextButton.styleFrom(
                overlayColor: AppColors.accent.withValues(alpha: 0.2),
                backgroundColor: AppColors.surface.withValues(alpha: 0.95),
                padding: const EdgeInsets.all(12),
                minimumSize: Size(Get.width * 0.4, 50),
                maximumSize: Size(Get.width * 0.5, 100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      'assets/image/play.png',
                      fit: BoxFit.contain,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'ARCADE MAP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: CELL_HEIGHT),
            TextButton(
              onPressed: () => Get.toNamed('/game'),
              style: TextButton.styleFrom(
                overlayColor: AppColors.accentSecondary.withValues(alpha: 0.2),
                backgroundColor: AppColors.surface.withValues(alpha: 0.95),
                padding: const EdgeInsets.all(12),
                minimumSize: Size(Get.width * 0.4, 50),
                maximumSize: Size(Get.width * 0.5, 100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      'assets/image/play.png',
                      fit: BoxFit.contain,
                      color: AppColors.accentSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'INFINITE MODE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
