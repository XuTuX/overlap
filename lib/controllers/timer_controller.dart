// timer_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class TimerController extends GetxController with WidgetsBindingObserver {
  final CountDownController countdownController = CountDownController();

  RxInt duration = 60.obs;

  final RxDouble remainingTime = 60.0.obs;
  final RxInt restartCounter = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    binding.addPostFrameCallback((_) {
      if (isClosed) return;
      startTimer();
    });
  }

  @override
  void onClose() {
    pauseTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void reduceTime() {
    if (isClosed) return;
    if (duration.value > 10) {
      duration.value -= 1;
    }
  }

  void startTimer() {
    if (isClosed) return;
    restartCounter.value++;
    remainingTime.value = duration.toDouble();
    countdownController.restart();
  }

  void resetTimer() {
    if (isClosed) return;
    duration.value = 60;
    startTimer();
  }

  void pauseTimer() {
    countdownController.pause();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      pauseTimer();
    }
  }
}
