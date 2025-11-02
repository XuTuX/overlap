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
  static const double boardHeightSafeFractionPhone = 0.28;
  static const double boardHeightSafeFractionTablet = 0.3;

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

  static GameLayoutMetrics layoutOf(
    BuildContext context, {
    double? maxHeightOverride,
    double? maxWidthOverride,
  }) {
    final mediaQueryData = MediaQuery.of(context);
    final size = mediaQueryData.size;
    final orientation = mediaQueryData.orientation;
    final padding = mediaQueryData.padding;
    final viewInsets = mediaQueryData.viewInsets;
    final scaffoldState = Scaffold.maybeOf(context);
    final double appBarHeight = scaffoldState?.appBarMaxHeight ?? 0.0;
    final bool isTablet = size.shortestSide >= tabletBreakpoint;
    final double safeWidth =
        max(0.0, size.width - padding.horizontal - viewInsets.horizontal);
    final double baseWidth = safeWidth > 0 ? safeWidth : size.width;

    final double effectiveWidth = maxWidthOverride != null &&
            maxWidthOverride.isFinite &&
            maxWidthOverride > 0
        ? min(baseWidth, maxWidthOverride)
        : baseWidth;
    double safeHeight = max(
      0.0,
      size.height - padding.vertical - viewInsets.vertical - appBarHeight,
    );
    if (maxHeightOverride != null &&
        maxHeightOverride.isFinite &&
        maxHeightOverride > 0) {
      safeHeight = min(safeHeight, maxHeightOverride);
    }

    final double availableWidth = orientation == Orientation.landscape
        ? min(size.height, effectiveWidth)
        : effectiveWidth;
    final double fallbackWidth = min(effectiveWidth, size.height);
    final double widthForLayout = max(availableWidth, fallbackWidth);

    final double maxBoardWidth =
        max(min(widthForLayout, effectiveWidth) - 32, 160);

    final double boardHeightFraction =
        isTablet ? boardHeightSafeFractionTablet : boardHeightSafeFractionPhone;
    double boardSize = maxBoardWidth;
    if (safeHeight.isFinite && safeHeight > 0) {
      final double boardByHeight = (safeHeight * boardHeightFraction) / 1.1;
      if (boardByHeight > 0) {
        boardSize = min(boardSize, boardByHeight);
      }
    }
    boardSize = boardSize.clamp(160.0, maxBoardWidth);

    double solveSize = (boardSize * 0.55).clamp(80.0, boardSize * 0.88);
    double timerSize = (boardSize * 0.45).clamp(70.0, boardSize * 0.8);

    final double cellHeight =
        (isTablet ? size.height * 0.02 : size.height * 0.01)
            .clamp(12.0, 32.0)
            .toDouble();

    GameLayoutMetrics metrics = GameLayoutMetrics(
      screenSize: Size(effectiveWidth, size.height),
      safeHeight: safeHeight,
      isTablet: isTablet,
      boardSize: boardSize,
      solveBoardSize: solveSize,
      cellHeight: cellHeight,
      timerSize: timerSize,
      scale: 1.0,
    );

    final double estimatedHeight =
        metrics.estimatedVerticalFootprint(hasWarning: false);
    if (estimatedHeight > 0 && safeHeight > 0) {
      final double scaleFactor = min(1.0, safeHeight / estimatedHeight);
      if (scaleFactor < 1.0) {
        metrics = metrics.scaled(scaleFactor);
      }
    }

    double widthAllowance = effectiveWidth - 24.0;
    if (widthAllowance <= 0) {
      widthAllowance = effectiveWidth;
    }
    final double boardFootprint = metrics.boardSize * 1.1;
    final double headerSpacing =
        metrics.scaledPadding(20) * 2 + metrics.scaledPadding(12);
    final double headerFootprint =
        metrics.timerSize + metrics.solveBoardSize + headerSpacing;
    final int blockCount = GameConfig.availableBlockCount;
    final double dragSpacing = metrics.scaledPadding(12) * (blockCount + 1);
    final double dragFootprint =
        blockCount * metrics.blockBoxSize + dragSpacing;
    final double maxContentFootprint = max(
      boardFootprint,
      max(headerFootprint, dragFootprint),
    );

    if (widthAllowance > 0 && maxContentFootprint > widthAllowance) {
      final double widthScale =
          (widthAllowance / maxContentFootprint).clamp(0.1, 1.0);
      metrics = metrics.scaled(widthScale);
    }

    if (metrics.scale > 1.0) {
      metrics = metrics.scaled(1.0 / metrics.scale);
    }

    return metrics;
  }
}

class GameLayoutMetrics {
  const GameLayoutMetrics({
    required this.screenSize,
    required this.safeHeight,
    required this.isTablet,
    required this.boardSize,
    required this.solveBoardSize,
    required this.cellHeight,
    required this.timerSize,
    required this.scale,
  });

  final Size screenSize;
  final double safeHeight;
  final bool isTablet;
  final double boardSize;
  final double solveBoardSize;
  final double cellHeight;
  final double timerSize;
  final double scale;

  double get boardCellSize => boardSize / GameConfig.columns;
  double get solveCellSize => solveBoardSize / GameConfig.columns;
  double get blockBoxSize => boardSize * 0.52;
  double get mainTextSize => (isTablet ? 45 : 30) * scale;
  double get scoreTextSize => (isTablet ? 36 : 24) * scale;
  double get highScoreTextSize => (isTablet ? 30 : 20) * scale;
  double get gameOverTextSize => (isTablet ? 45 : 32) * scale;
  double get gameOverIconSize => (isTablet ? 45 : 32) * scale;
  double get rotateIconSize => (isTablet ? 36 : 24) * scale;
  double get boardToToolbarSpacing => 10.0 * spacingScale;

  double dragTopPadding({required bool hasWarning}) {
    final double base = hasWarning ? 12.0 : 16.0;
    return max(base * spacingScale, 6.0);
  }

  GameLayoutMetrics scaled(double factor) {
    final double clampedFactor = factor.clamp(0.1, 1.0);
    return GameLayoutMetrics(
      screenSize: screenSize,
      safeHeight: safeHeight,
      isTablet: isTablet,
      boardSize: boardSize * clampedFactor,
      solveBoardSize: solveBoardSize * clampedFactor,
      cellHeight: cellHeight * clampedFactor,
      timerSize: timerSize * clampedFactor,
      scale: scale * clampedFactor,
    );
  }

  double estimatedVerticalFootprint({required bool hasWarning}) {
    final double topSpacing = scaledPadding(12);
    final double timerHeight = timerSize + scaledPadding(40);
    final double solveHeight = solveBoardSize;
    final double headerHeight = max(timerHeight, solveHeight);
    final double spacingAfterHeader =
        hasWarning ? scaledPadding(4) : scaledPadding(8);

    final double warningSpacing = hasWarning ? scaledPadding(8) : 0.0;
    final double bannerHeight = hasWarning ? scaledPadding(72) : 0.0;
    final double boardHeight = boardSize * 1.1;
    final double spacingAfterBoard = boardToToolbarSpacing;
    final double spacingBeforeDrag = dragTopPadding(hasWarning: hasWarning);
    final double dragHeight =
        blockBoxSize + scaledPadding(12) + rotateIconSize + scaledPadding(24);

    return topSpacing +
        headerHeight +
        spacingAfterHeader +
        warningSpacing +
        bannerHeight +
        boardHeight +
        spacingAfterBoard +
        spacingBeforeDrag +
        dragHeight;
  }

  double scaledPadding(double value) => value * spacingScale;

  double get spacingScale => scale.clamp(0.85, 1.0);

  GameLayoutFlex flexDistribution({required bool hasWarning}) {
    final double header = _headerSectionFootprint(hasWarning: hasWarning);
    final double board = _boardSectionFootprint();
    final double rack = _rackSectionFootprint(hasWarning: hasWarning);
    final double total = header + board + rack;
    if (total <= 0) {
      return const GameLayoutFlex(header: 3, board: 5, rack: 4);
    }

    const int totalFlex = 12;
    int headerFlex = max(2, (header / total * totalFlex).round());
    int boardFlex = max(4, (board / total * totalFlex).round());
    int rackFlex = max(3, totalFlex - headerFlex - boardFlex);

    if (rackFlex < 2) {
      final int deficit = 2 - rackFlex;
      rackFlex += deficit;
      if (boardFlex - deficit >= 4) {
        boardFlex -= deficit;
      } else {
        final int remaining = deficit - (boardFlex - 4);
        boardFlex = 4;
        headerFlex = max(2, headerFlex - remaining);
      }
    }

    int sum = headerFlex + boardFlex + rackFlex;
    while (sum > totalFlex) {
      if (boardFlex > 4) {
        boardFlex -= 1;
      } else if (headerFlex > 2) {
        headerFlex -= 1;
      } else if (rackFlex > 2) {
        rackFlex -= 1;
      } else {
        break;
      }
      sum = headerFlex + boardFlex + rackFlex;
    }

    while (sum < totalFlex) {
      boardFlex += 1;
      sum = headerFlex + boardFlex + rackFlex;
    }

    return GameLayoutFlex(
      header: headerFlex,
      board: boardFlex,
      rack: rackFlex,
    );
  }

  double _headerSectionFootprint({required bool hasWarning}) {
    final double topSpacing = scaledPadding(12);
    final double headerHeight =
        max(timerSize + scaledPadding(40), solveBoardSize);
    final double spacingAfterHeader =
        hasWarning ? scaledPadding(10) : scaledPadding(16);
    final double warningSpacing = hasWarning ? scaledPadding(8) : 0.0;
    final double bannerHeight = hasWarning ? scaledPadding(72) : 0.0;
    return topSpacing +
        headerHeight +
        spacingAfterHeader +
        warningSpacing +
        bannerHeight;
  }

  double _boardSectionFootprint() {
    return boardSize * 1.1 + boardToToolbarSpacing;
  }

  double _rackSectionFootprint({required bool hasWarning}) {
    final double dividerHeight = max(1.5, 3 * scale) + scaledPadding(24);
    final double dragHeight =
        blockBoxSize + scaledPadding(12) + rotateIconSize + scaledPadding(24);
    final double topPadding = dragTopPadding(hasWarning: hasWarning);
    return topPadding + dividerHeight + dragHeight + scaledPadding(12);
  }

  GameLayoutMetrics ensureFitsHeight(
    double availableHeight, {
    required bool hasWarning,
  }) {
    if (!availableHeight.isFinite || availableHeight <= 0) {
      return this;
    }
    final double estimate = estimatedVerticalFootprint(hasWarning: hasWarning);
    if (estimate <= availableHeight) {
      return this;
    }
    final double factor = (availableHeight / estimate).clamp(0.1, 1.0);
    return scaled(factor);
  }
}

class GameLayoutFlex {
  const GameLayoutFlex({
    required this.header,
    required this.board,
    required this.rack,
  });

  final int header;
  final int board;
  final int rack;
}
