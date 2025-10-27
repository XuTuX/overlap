// circular_timer_view.dart
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/controller/game_controller.dart';
import 'package:overlap/controller/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircularTimer extends StatelessWidget {
  final TimerController timerController = Get.put(TimerController());
  final GameController gameController = Get.put(GameController());

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(
                    width: TIMER_SIZE,
                    height: TIMER_SIZE,
                    child: CircularProgressIndicator(
                      value: 1 - (seconds / timerController.duration.value),
                      strokeWidth: 11.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isWarning ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    seconds.toStringAsFixed(1), // 0.1초 단위로 표시
                    style: const TextStyle(
                      fontSize: 24.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          )),
    );
  }
}
