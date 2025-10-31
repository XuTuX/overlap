import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/arcade_game_controller.dart';
import 'package:overlap/models/tetris_model.dart';

class ArcadeGameDrag extends StatelessWidget {
  const ArcadeGameDrag({super.key});

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController gameController =
        Get.find<ArcadeGameController>();
    final metrics = GameConfig.layoutOf(context);
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(gameController.availableBlocks.length, (index) {
          final block = gameController.availableBlocks[index];
          final blockWidget = Stack(
            children: [
              TetrisModel(blockList: block.offsets),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                ),
              ),
            ],
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Draggable(
                  key: ValueKey('${block.name}-$index'),
                  feedback: TetrisModel(blockList: block.offsets),
                  childWhenDragging: SizedBox(
                    width: metrics.blockBoxSize,
                    height: metrics.blockBoxSize,
                  ),
                  child: blockWidget,
                  dragAnchorStrategy: (draggable, context, position) {
                    final offsetX = context.size!.width / 2;
                    final offsetY = context.size!.height + 27;
                    return Offset(offsetX, offsetY);
                  },
                  onDragEnd: (details) {
                    final renderObject = gameController.gridKey.currentContext
                        ?.findRenderObject();
                    if (renderObject is! RenderBox) return;
                    final gridBox = renderObject;

                    final gridPosition = gridBox.localToGlobal(Offset.zero);
                    final dragPosition = details.offset;

                    final col = ((dragPosition.dx -
                                gridPosition.dx +
                                metrics.boardCellSize * 0.5) /
                            metrics.boardCellSize)
                        .floor();

                    final row = ((dragPosition.dy -
                                gridPosition.dy +
                                metrics.boardCellSize * 0.5) /
                            metrics.boardCellSize)
                        .floor();

                    gameController.insert(block, col, row);
                  },
                ),
              ),
              SizedBox(
                height: metrics.cellHeight,
              ),
              ElevatedButton(
                onPressed: () => gameController.rotateBlock(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shadowColor: AppColors.accent.withFraction(0.25),
                  elevation: 6,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                child: Image.asset(
                  'assets/image/rotate.png',
                  width: metrics.rotateIconSize,
                  height: metrics.rotateIconSize,
                  color: AppColors.accent,
                ),
              ),
            ],
          );
        }),
      );
    });
  }
}
