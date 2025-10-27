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
        children: List.generate(gameController.blockList.length, (index) {
          final block = gameController.blockList[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Draggable(
                  key: ValueKey(block), // 각 항목에 고유한 키 부여 (가능하면 고유한 값 사용)
                  feedback: TetrisModel(blockList: block),
                  childWhenDragging: Container(
                    width: BLOCK_BOX_SIZE,
                    height: BLOCK_BOX_SIZE,
                  ),
                  child: TetrisModel(blockList: block),
                  dragAnchorStrategy: (draggable, context, position) {
                    final offsetX = context.size!.width / 2;
                    final offsetY = context.size!.height + 27;
                    return Offset(offsetX, offsetY);
                  },
                  onDragEnd: (details) {
                    RenderBox gridBox = gameController.gridkey.currentContext
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
                  backgroundColor: Color.fromRGBO(224, 224, 224, 0.6),
                  shadowColor: Colors.transparent, // 그림자 제거로 미니멀하게
                  elevation: 0, // 평면 느낌
                  shape: const CircleBorder(), // 둥근 버튼
                  padding: const EdgeInsets.all(8), // 여백 넉넉하게
                ),
                child: Image.asset(
                  'assets/image/rotate.png',
                  width: ResponsiveSizes.rotateIconSize(),
                  height: ResponsiveSizes.rotateIconSize(),
                  color: Colors.orangeAccent, // 아이콘 색 통일감 있게 조정 (선택사항)
                ),
              ),
            ],
          );
        }),
      );
    });
  }
}
