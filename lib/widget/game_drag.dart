import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/models/tetris_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/game_controller.dart';

class GameDrag extends StatelessWidget {
  const GameDrag({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.put(GameController());
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(gameController.availableBlocks.length, (index) {
          final block = gameController.availableBlocks[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Draggable(
                  key: ValueKey('${block.name}-$index'), // 각 항목에 고유한 키 부여
                  feedback: TetrisModel(blockList: block.offsets),
                  childWhenDragging: Container(
                    width: BLOCK_BOX_SIZE,
                    height: BLOCK_BOX_SIZE,
                  ),
                  child: TetrisModel(blockList: block.offsets),
                  dragAnchorStrategy: (draggable, context, position) {
                    final offsetX = context.size!.width / 2;
                    final offsetY = context.size!.height + 27;
                    return Offset(offsetX, offsetY);
                  },
                  onDragEnd: (details) {
                    RenderBox gridBox = gameController.gridKey.currentContext
                        ?.findRenderObject() as RenderBox;
                    Offset gridPosition = gridBox.localToGlobal(Offset.zero);

                    Offset dragPosition = details.offset;

                    int col = ((dragPosition.dx -
                                gridPosition.dx +
                                BOARD_CELL_SIZE * 0.5) /
                            BOARD_CELL_SIZE)
                        .floor();

                    int row = ((dragPosition.dy -
                                gridPosition.dy +
                                BOARD_CELL_SIZE * 0.5) /
                            BOARD_CELL_SIZE)
                        .floor();

                    gameController.insert(block, col, row);
                  },
                ),
              ),
              SizedBox(
                height: CELL_HEIGHT,
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
                  width: ResponsiveSizes.rotateIconSize(),
                  height: ResponsiveSizes.rotateIconSize(),
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
