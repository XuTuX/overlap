import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/controllers/arcade_game_controller.dart';
import 'package:overlap/models/tetris_model.dart';
import 'package:overlap/widgets/game_layout_scope.dart';

class ArcadeGameDrag extends StatelessWidget {
  const ArcadeGameDrag({super.key});

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController gameController =
        Get.find<ArcadeGameController>();
    final metrics = GameLayoutScope.of(context);
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(gameController.availableBlocks.length, (index) {
          final block = gameController.availableBlocks[index];
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: metrics.scaledPadding(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Draggable(
                        key: ValueKey('${block.name}-$index'),
                        feedback: TetrisModel(blockList: block.offsets),
                        childWhenDragging: SizedBox(
                          width: metrics.blockBoxSize,
                          height: metrics.blockBoxSize,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            TetrisModel(blockList: block.offsets),
                            Positioned(
                              top: metrics.scaledPadding(8),
                              right: metrics.scaledPadding(8),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: metrics.scaledPadding(6),
                                  vertical: metrics.scaledPadding(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        dragAnchorStrategy: (draggable, context, position) {
                          final offsetX = context.size!.width / 2;
                          final offsetY =
                              context.size!.height + metrics.scaledPadding(27);
                          return Offset(offsetX, offsetY);
                        },
                        onDragEnd: (details) {
                          final renderObject = gameController
                              .gridKey.currentContext
                              ?.findRenderObject();
                          if (renderObject is! RenderBox) return;
                          final gridBox = renderObject;

                          final gridPosition =
                              gridBox.localToGlobal(Offset.zero);
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
                  ),
                  SizedBox(
                    height: metrics.scaledPadding(12),
                  ),
                  ElevatedButton(
                    onPressed: () => gameController.rotateBlock(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      shadowColor: AppColors.accent.withFraction(0.25),
                      elevation: 6 * metrics.scale,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.all(metrics.scaledPadding(12)),
                      minimumSize: Size.square(
                        metrics.rotateIconSize + metrics.scaledPadding(24),
                      ),
                    ),
                    child: Image.asset(
                      'assets/image/rotate.png',
                      width: metrics.rotateIconSize,
                      height: metrics.rotateIconSize,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }
}
