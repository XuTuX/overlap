// timer_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class TimerController extends GetxController {
  final CountDownController countdownController = CountDownController();

  RxInt duration = 60.obs;

  final RxDouble remainingTime = 60.0.obs;
  final RxInt restartCounter = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer();
    });
  }

  void reduceTime() {
    if (duration.value > 10) {
      duration.value -= 1;
    }
  }

  void startTimer() {
    restartCounter.value++;
    remainingTime.value = duration.toDouble();
    countdownController.restart();
  }

  void resetTimer() {
    duration.value = 60;
    startTimer();
  }
}
