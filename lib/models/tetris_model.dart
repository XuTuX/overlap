import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:flutter/material.dart';

class TetrisModel extends StatelessWidget {
  final List<Offset> blockList;
  const TetrisModel({super.key, required this.blockList});

  @override
  Widget build(BuildContext context) {
    const double cellSpacing = 1.0;

    final double minX =
        blockList.map((e) => e.dx).reduce((a, b) => a < b ? a : b);
    final double minY =
        blockList.map((e) => e.dy).reduce((a, b) => a < b ? a : b);

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
      width: BLOCK_BOX_SIZE + 4,
      height: BLOCK_BOX_SIZE + 4,
      child: Stack(
        children: blockList.map((offset) {
          final offsetX = offset.dx - minX;
          final offsetY = offset.dy - minY;
          return Positioned(
            left: offsetX * (BOARD_CELL_SIZE + cellSpacing),
            top: offsetY * (BOARD_CELL_SIZE + cellSpacing),
            child: Container(
              width: (BOARD_CELL_SIZE - cellSpacing * 2),
              height: (BOARD_CELL_SIZE - cellSpacing * 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: AppColors.highlightGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withFraction(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
