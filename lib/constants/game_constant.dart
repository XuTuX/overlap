import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kTabletBreakpoint = 768.0;

// 가령 세로, 가로의 Breakpoint를 다르게 잡아서 (예: 600, 900) 좀 더 정교하게 구분할 수도 있음
// ex) if (Get.width > 900 && Get.height > 600) { ... } else { ... }

class ResponsiveSizes {
  static const double kTabletBreakpoint = 768.0;

  static double getBoardSize() =>
      Get.width >= kTabletBreakpoint ? Get.width * 0.35 : Get.width * 0.5;

  static double getSolveSize() =>
      Get.width >= kTabletBreakpoint ? Get.width * 0.19 : Get.width * 0.28;

  static double cellHeight() =>
      Get.width >= kTabletBreakpoint ? Get.height * 0.02 : Get.height * 0.01;

  static double timerSize() =>
      Get.width >= kTabletBreakpoint ? Get.width * 0.15 : Get.width * 0.25;

  static double mainTextSize() => Get.width >= kTabletBreakpoint ? 45 : 30;

  static double scoreTextSize() => Get.width >= kTabletBreakpoint ? 36 : 24;

  static double highScoreTextSize() => Get.width >= kTabletBreakpoint ? 30 : 20;

  static double gameOverTextSize() => Get.width >= kTabletBreakpoint ? 45 : 32;

  static double gameOverIconSize() => Get.width >= kTabletBreakpoint ? 45 : 32;

  static double rotateIconSize() => Get.width >= kTabletBreakpoint ? 36 : 24;
}

double BOARD_SIZE = ResponsiveSizes.getBoardSize();
double BOARD_CELL_SIZE = BOARD_SIZE / ROW;

double SOLVE_SIZE = ResponsiveSizes.getSolveSize();
double SOLVE_CELL_SIZE = SOLVE_SIZE / COL;

double BLOCK_BOX_SIZE = BOARD_SIZE * (3 / 5);

double CELL_HEIGHT = ResponsiveSizes.cellHeight();

double TIMER_SIZE = ResponsiveSizes.timerSize();

const int COL = 5;
const int ROW = 5;
const double CENTER_POINT = 1.0;
int BLOCK_LIST_COUNTS = 2;
int DURATION = 2;

Map<String, List<Offset>> blockShapes = {
  '0': [
    Offset(0, 0),
    Offset(1, 0),
    Offset(1, 1),
    Offset(0, 1),
  ],
  'T': [
    Offset(0, 0),
    Offset(1, 0),
    Offset(2, 0),
    Offset(1, 1),
  ],
  'L': [
    Offset(0, 0),
    Offset(0, 1),
    Offset(0, 2),
    Offset(1, 2),
  ],
  'J': [
    Offset(1, 0),
    Offset(1, 1),
    Offset(1, 2),
    Offset(0, 2),
  ],
  'S': [
    Offset(1, 0),
    Offset(2, 0),
    Offset(0, 1),
    Offset(1, 1),
  ],
  'Z': [
    Offset(0, 0),
    Offset(1, 0),
    Offset(1, 1),
    Offset(2, 1),
  ],
};
