// circular_timer_view.dart
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/game_controller.dart';
import 'package:overlap/controllers/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircularTimer extends StatelessWidget {
  CircularTimer({super.key});

  final TimerController timerController = Get.find<TimerController>();
  final GameController gameController = Get.find<GameController>();

  @override
  Widget build(BuildContext context) {
    final metrics = GameConfig.layoutOf(context);
    return Center(
      child: Obx(() => TweenAnimationBuilder<Duration>(
            key: ValueKey(timerController.restartCounter.value),
            duration: Duration(seconds: timerController.duration.value),
            tween: Tween(
                begin: Duration(seconds: timerController.duration.value),
                end: Duration.zero),
            onEnd: gameController.gameover,
            builder: (context, value, child) {
              final seconds = value.inMilliseconds / 1000.0;
              timerController.remainingTime.value = seconds;

              final bool isWarning = seconds <= 10;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: metrics.timerSize,
                    height: metrics.timerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isWarning
                            ? AppColors.warningGradient
                            : AppColors.highlightGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isWarning
                                  ? AppColors.accentTertiary
                                  : AppColors.accent)
                              .withFraction(0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surface,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            value:
                                1 - (seconds / timerController.duration.value),
                            strokeWidth: 11.0,
                            backgroundColor:
                                AppColors.surfaceAlt.withFraction(0.6),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isWarning
                                  ? AppColors.accentTertiary
                                  : AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    seconds.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24.0,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            },
          )),
    );
  }
}
