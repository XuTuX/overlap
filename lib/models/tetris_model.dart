import 'package:overlap/constants/game_constant.dart';
import 'package:flutter/material.dart';

class TetrisModel extends StatelessWidget {
  final List<Offset> blockList;
  const TetrisModel({super.key, required this.blockList});

  @override
  Widget build(BuildContext context) {
    final double cellSpacing = 1.0;

    final minX = blockList.map((e) => e.dx).reduce((a, b) => a < b ? a : b);
    final minY = blockList.map((e) => e.dy).reduce((a, b) => a < b ? a : b);

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
                borderRadius: BorderRadius.circular(5),
                color: Colors.amber,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
