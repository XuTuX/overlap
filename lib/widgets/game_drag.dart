import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/models/tetris_model.dart';
import 'package:overlap/widgets/game_layout_scope.dart';

import '../controllers/game_controller.dart';

class GameDrag extends StatelessWidget {
  const GameDrag({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.find<GameController>();
    final metrics = GameLayoutScope.of(context);
    final TextStyle labelStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ) ??
            TextStyle(
              fontSize: metrics.rotateIconSize * 0.42,
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            );

    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(controller.availableBlocks.length, (index) {
          final block = controller.availableBlocks[index];
          final double buttonPadding = metrics.scaledPadding(10);
          final double buttonSize =
              metrics.rotateIconSize + metrics.scaledPadding(16);
          final double controlSpacing = metrics.scaledPadding(18);
          final double bottomPadding = metrics.scaledPadding(8);

          final draggable = Draggable(
            key: ValueKey('${block.name}-$index'),
            feedback: TetrisModel(blockList: block.offsets),
            childWhenDragging: SizedBox(
              width: metrics.blockBoxSize,
              height: metrics.blockBoxSize,
            ),
            child: Container(
              width: metrics.blockBoxSize,
              height: metrics.blockBoxSize,
              padding: EdgeInsets.all(metrics.scaledPadding(2)),
              child: TetrisModel(blockList: block.offsets),
            ),
            dragAnchorStrategy: (draggable, context, position) {
              final offsetX = context.size!.width / 2;
              final offsetY = context.size!.height + metrics.scaledPadding(27);
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
                          metrics.boardCellSize * 0.5) /
                      metrics.boardCellSize)
                  .floor();

              final row = ((dragPosition.dy -
                          gridPosition.dy +
                          metrics.boardCellSize * 0.5) /
                      metrics.boardCellSize)
                  .floor();

              controller.insert(block, col, row);
            },
          );

          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: metrics.scaledPadding(6)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: metrics.blockBoxSize,
                        height: metrics.blockBoxSize,
                        child: draggable,
                      ),
                      SizedBox(height: controlSpacing),
                      ElevatedButton(
                        onPressed: () => controller.rotateBlock(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.surface.withFraction(0.92),
                          shadowColor: AppColors.accent.withFraction(0.25),
                          elevation: 8 * metrics.scale,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.all(buttonPadding),
                          minimumSize: Size.square(buttonSize),
                        ),
                        child: Image.asset(
                          'assets/image/rotate.png',
                          width: metrics.rotateIconSize,
                          height: metrics.rotateIconSize,
                          color: AppColors.accent,
                        ),
                      ),
                      SizedBox(height: metrics.scaledPadding(2)),
                      Text('회전', style: labelStyle),
                    ],
                  ),
                  SizedBox(height: bottomPadding),
                ],
              ),
            ),
          );
        }),
      );
    });
  }
}
