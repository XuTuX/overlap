import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/widgets/game_layout_scope.dart';

class TetrisModel extends StatelessWidget {
  final List<Offset> blockList;
  const TetrisModel({super.key, required this.blockList});

  @override
  Widget build(BuildContext context) {
    final metrics = GameLayoutScope.of(context);
    final double gap = math.max(0.6, 1.0 * metrics.scale);

    final double minX = blockList.map((e) => e.dx).reduce(math.min);
    final double maxX = blockList.map((e) => e.dx).reduce(math.max);
    final double minY = blockList.map((e) => e.dy).reduce(math.min);
    final double maxY = blockList.map((e) => e.dy).reduce(math.max);

    final int widthCells = (maxX - minX).abs().toInt() + 1;
    final int heightCells = (maxY - minY).abs().toInt() + 1;

    final double rawCellSize = metrics.boardCellSize - 2 - gap * 2;
    final double cellSize = math.max(6.0, rawCellSize);

    final double blockWidth = widthCells * (cellSize + gap) + gap;
    final double blockHeight = heightCells * (cellSize + gap) + gap;

    final double containerSide =
        metrics.blockBoxSize + metrics.scaledPadding(4);

    return SizedBox(
      width: containerSide,
      height: containerSide,
      child: Center(
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.transparent)),
          width: blockWidth,
          height: blockHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: blockList.map((offset) {
              final double offsetX = offset.dx - minX;
              final double offsetY = offset.dy - minY;
              return Positioned(
                left: gap + offsetX * (cellSize + gap),
                top: gap + offsetY * (cellSize + gap),
                child: Container(
                  width: cellSize - 3,
                  height: cellSize - 3,
                  margin: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      math.max(6, 12 * metrics.scale),
                    ),
                    gradient: LinearGradient(
                      colors: AppColors.highlightGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withFraction(0.45),
                        blurRadius: 12 * metrics.scale,
                        offset: Offset(0, 4 * metrics.scale),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
