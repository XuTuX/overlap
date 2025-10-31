import 'dart:math';

import 'package:flutter/material.dart';

class GameConfig {
  GameConfig._();

  static const double tabletBreakpoint = 768.0;
  static const int columns = 5;
  static const int rows = 5;
  static const double blockPivot = 1.0;
  static const int availableBlockCount = 2;
  static const Duration countdownDelay = Duration(seconds: 2);

  static const Map<String, List<Offset>> blockShapes = {
    'O': [
      Offset.zero,
      Offset(1, 0),
      Offset(1, 1),
      Offset(0, 1),
    ],
    '0': [
      Offset.zero,
      Offset(1, 0),
      Offset(1, 1),
      Offset(0, 1),
    ],
    'T': [
      Offset.zero,
      Offset(1, 0),
      Offset(2, 0),
      Offset(1, 1),
    ],
    'L': [
      Offset.zero,
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
      Offset.zero,
      Offset(1, 0),
      Offset(1, 1),
      Offset(2, 1),
    ],
  };

  static GameLayoutMetrics layoutOf(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    final bool isTablet = mediaQuery.shortestSide >= tabletBreakpoint;

    final double availableWidth = orientation == Orientation.landscape
        ? mediaQuery.height
        : mediaQuery.width;
    final double fallbackWidth = min(mediaQuery.width, mediaQuery.height);
    final double widthForLayout = max(availableWidth, fallbackWidth);

    final double maxBoardSize =
        max(min(widthForLayout, mediaQuery.width) - 32, 200);
    final double boardCandidate =
        (isTablet ? mediaQuery.width * 0.35 : mediaQuery.width * 0.5)
            .clamp(180, maxBoardSize)
            .toDouble();
    final double boardSize = min(boardCandidate, maxBoardSize);

    final double solveCandidate =
        (isTablet ? mediaQuery.width * 0.19 : mediaQuery.width * 0.28)
            .clamp(140.0, boardSize * 0.8)
            .toDouble();
    final double timerCandidate =
        (isTablet ? mediaQuery.width * 0.15 : mediaQuery.width * 0.25)
            .clamp(120.0, boardSize)
            .toDouble();
    final double cellHeight =
        (isTablet ? mediaQuery.height * 0.02 : mediaQuery.height * 0.01)
            .clamp(12.0, 32.0)
            .toDouble();

    return GameLayoutMetrics(
      screenSize: mediaQuery,
      isTablet: isTablet,
      boardSize: boardSize,
      solveBoardSize: solveCandidate,
      cellHeight: cellHeight,
      timerSize: timerCandidate,
    );
  }
}

class GameLayoutMetrics {
  const GameLayoutMetrics({
    required this.screenSize,
    required this.isTablet,
    required this.boardSize,
    required this.solveBoardSize,
    required this.cellHeight,
    required this.timerSize,
  });

  final Size screenSize;
  final bool isTablet;
  final double boardSize;
  final double solveBoardSize;
  final double cellHeight;
  final double timerSize;

  double get boardCellSize => boardSize / GameConfig.columns;
  double get solveCellSize => solveBoardSize / GameConfig.columns;
  double get blockBoxSize => boardSize * 0.6;
  double get mainTextSize => isTablet ? 45 : 30;
  double get scoreTextSize => isTablet ? 36 : 24;
  double get highScoreTextSize => isTablet ? 30 : 20;
  double get gameOverTextSize => isTablet ? 45 : 32;
  double get gameOverIconSize => isTablet ? 45 : 32;
  double get rotateIconSize => isTablet ? 36 : 24;
}
