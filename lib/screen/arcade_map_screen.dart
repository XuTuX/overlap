import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/controller/arcade_game_controller.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeMapScreen extends StatelessWidget {
  const ArcadeMapScreen({super.key});

  final List<Offset> _normalizedPositions = const [
    Offset(0.50, 0.92),
    Offset(0.58, 0.85),
    Offset(0.67, 0.74),
    Offset(0.76, 0.62),
    Offset(0.83, 0.50),
    Offset(0.86, 0.38),
    Offset(0.80, 0.27),
    Offset(0.70, 0.18),
    Offset(0.58, 0.14),
    Offset(0.50, 0.16),
    Offset(0.42, 0.14),
    Offset(0.30, 0.18),
    Offset(0.20, 0.27),
    Offset(0.14, 0.38),
    Offset(0.17, 0.50),
    Offset(0.24, 0.62),
    Offset(0.33, 0.74),
    Offset(0.42, 0.85),
    Offset(0.47, 0.72),
    Offset(0.50, 0.58),
  ];

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController controller = Get.find<ArcadeGameController>();
    final HiveGameBox hive = HiveGameBox();
    final clearedStage = hive.getClearedStage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arcade Map'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = min(constraints.maxWidth, constraints.maxHeight);
          final boardSize = size * 0.95;
          final total = min(arcadeStages.length, _normalizedPositions.length);
          final stagePositions = _scaledPositions(boardSize, total);

          return Center(
            child: SizedBox(
              width: boardSize,
              height: boardSize,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(boardSize, boardSize),
                    painter: _HeartPathPainter(
                      points: stagePositions,
                      highlightCount: min(clearedStage + 1, stagePositions.length),
                    ),
                  ),
                  for (int i = 0; i < total; i++)
                    _buildStageNode(
                      controller: controller,
                      hive: hive,
                      stage: arcadeStages[i],
                      position: stagePositions[i],
                      clearedStage: clearedStage,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Offset> _scaledPositions(double boardSize, int count) {
    final positions = <Offset>[];
    for (int i = 0; i < count; i++) {
      final normalized = _normalizedPositions[i];
      positions.add(
        Offset(
          normalized.dx * boardSize,
          normalized.dy * boardSize,
        ),
      );
    }
    return positions;
  }

  Widget _buildStageNode({
    required ArcadeGameController controller,
    required HiveGameBox hive,
    required StageData stage,
    required Offset position,
    required int clearedStage,
  }) {
    final bool isCleared = stage.id <= clearedStage;
    final bool isCurrent = stage.id == clearedStage + 1;
    final bool isUnlocked = isCleared || isCurrent;

    const double nodeSize = 56;
    final Color baseColor = isCleared
        ? AppColors.accent
        : isCurrent
            ? AppColors.accentSecondary
            : AppColors.surfaceAlt.withFraction(0.9);

    return Positioned(
      left: position.dx - nodeSize / 2,
      top: position.dy - nodeSize / 2,
      child: Tooltip(
        message: stage.title,
        child: GestureDetector(
          onTap: isUnlocked
              ? () {
                  controller.loadStage(stage);
                  Get.toNamed('/arcade/game');
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor,
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: isUnlocked ? 0.5 : 0.2),
                  blurRadius: isCurrent ? 18 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: isUnlocked
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stage.id.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: isCleared ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (isCurrent)
                    const Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeartPathPainter extends CustomPainter {
  final List<Offset> points;
  final int highlightCount;

  _HeartPathPainter({
    required this.points,
    required this.highlightCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final basePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final offset in points.skip(1)) {
      basePath.lineTo(offset.dx, offset.dy);
    }

    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(basePath, basePaint);

    final highlighted = Path()..moveTo(points.first.dx, points.first.dy);
    final highlightLimit = min(highlightCount, points.length);
    for (int i = 1; i < highlightLimit; i++) {
      highlighted.lineTo(points[i].dx, points[i].dy);
    }

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        colors: AppColors.highlightGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(highlighted, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _HeartPathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.highlightCount != highlightCount;
  }
}
