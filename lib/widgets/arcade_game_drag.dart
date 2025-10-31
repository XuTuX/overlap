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
          final double buttonPadding = metrics.scaledPadding(10);
          final double minButtonSize =
              metrics.rotateIconSize + metrics.scaledPadding(18);
          final double bottomSpacing = metrics.scaledPadding(12);
          final draggableBlock = Draggable(
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
              final offsetY = context.size!.height + metrics.scaledPadding(27);
              return Offset(offsetX, offsetY);
            },
            onDragEnd: (details) {
              final renderObject =
                  gameController.gridKey.currentContext?.findRenderObject();
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
          );

          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: metrics.scaledPadding(6)),
              child: SizedBox(
                width: metrics.blockBoxSize +
                    minButtonSize +
                    metrics.scaledPadding(18),
                height: metrics.blockBoxSize +
                    metrics.scaledPadding(28) +
                    bottomSpacing,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      bottom: bottomSpacing,
                      child: SizedBox(
                        width: metrics.blockBoxSize,
                        height: metrics.blockBoxSize,
                        child: draggableBlock,
                      ),
                    ),
                    Positioned(
                      right: minButtonSize * 0.6,
                      top: metrics.blockBoxSize * 0.25,
                      child: Container(
                        width: metrics.scaledPadding(3),
                        height: metrics.blockBoxSize * 0.5,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withFraction(0.35),
                          borderRadius: BorderRadius.circular(
                            12 * metrics.scale,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Transform.translate(
                        offset: Offset(
                          minButtonSize * 0.25,
                          -metrics.scaledPadding(6),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  gameController.rotateBlock(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.surface.withFraction(0.9),
                                shadowColor:
                                    AppColors.accent.withFraction(0.25),
                                elevation: 8 * metrics.scale,
                                shape: const CircleBorder(),
                                padding: EdgeInsets.all(buttonPadding),
                                minimumSize: Size.square(minButtonSize),
                              ),
                              child: Image.asset(
                                'assets/image/rotate.png',
                                width: metrics.rotateIconSize,
                                height: metrics.rotateIconSize,
                                color: AppColors.accent,
                              ),
                            ),
                            SizedBox(height: metrics.scaledPadding(3)),
                            Text(
                              '회전',
                              style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.4,
                                      ) ??
                                  TextStyle(
                                    fontSize: metrics.rotateIconSize * 0.42,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}
