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
    final ArcadeGameController controller = Get.find<ArcadeGameController>();
    final metrics = GameLayoutScope.of(context);

    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(controller.availableBlocks.length, (index) {
          final block = controller.availableBlocks[index];

          final draggable = Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Draggable(
                key: ValueKey('${block.name}-$index'),
                feedback: TetrisModel(blockList: block.offsets),
                childWhenDragging: SizedBox(
                  width: metrics.blockBoxSize,
                  height: metrics.blockBoxSize,
                ),
                child: Container(
                  width: metrics.blockBoxSize - 1,
                  height: metrics.blockBoxSize - 1,
                  padding: EdgeInsets.all(metrics.scaledPadding(2)),
                  child: TetrisModel(blockList: block.offsets),
                ),
                dragAnchorStrategy: (draggable, context, position) {
                  final offsetX = context.size!.width / 2;
                  final offsetY =
                      context.size!.height + metrics.scaledPadding(27);
                  return Offset(offsetX, offsetY);
                },
                onDragEnd: (details) {
                  final renderObject =
                      controller.gridKey.currentContext?.findRenderObject();
                  if (renderObject is! RenderBox) return;
                  final gridBox = renderObject;
                  final gridPosition = gridBox.localToGlobal(Offset.zero);

                  final dragPosition = details.offset;

                  final col = ((dragPosition.dx -
                              gridPosition.dx +
                              metrics.boardCellSize * 0.6) /
                          metrics.boardCellSize)
                      .floor();

                  final row = ((dragPosition.dy -
                              gridPosition.dy +
                              metrics.boardCellSize * 0.6) /
                          metrics.boardCellSize)
                      .floor();

                  controller.insert(block, col, row);
                },
              ),
              Positioned(
                top: -metrics.scaledPadding(20),
                right: -metrics.scaledPadding(14),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => controller.rotateBlock(index),
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: metrics.rotateIconSize * 1.7,
                      minHeight: metrics.rotateIconSize * 1.7,
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(metrics.scaledPadding(4)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        color: AppColors.surface.withFraction(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withFraction(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/image/rotate.png',
                        width: metrics.rotateIconSize * 0.6,
                        height: metrics.rotateIconSize * 0.6,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: metrics.scaledPadding(6)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: metrics.blockBoxSize,
                    height: metrics.blockBoxSize,
                    child: draggable,
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
