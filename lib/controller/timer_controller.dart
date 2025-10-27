// timer_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class TimerController extends GetxController {
  final CountDownController countdownController = CountDownController();

  RxInt duration = 60.obs; // 타이머 시간 (초)

  final RxDouble remainingTime = 60.0.obs;
  final RxInt restartCounter = 0.obs; // 타이머 재시작 시마다 값이 바뀌는 변수

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer(); // 최초 시작
    });
  }

  void reduceTime() {
    if (duration.value > 10) {
      duration.value -= 1;
    }
  }

  void startTimer() {
    restartCounter.value++; // 재시작할 때마다 값 변경
    remainingTime.value = duration.toDouble();
    countdownController.restart();
  }

  void resetTimer() {
    duration.value = 60; // 무조건 60초로 초기화
    startTimer();
  }
}
