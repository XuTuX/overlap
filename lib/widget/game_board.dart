import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/controller/game_controller.dart';
import 'package:overlap/enum/bord_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    GameController gameController = Get.put(GameController());
    return Center(
      child: Obx(() {
        Color boardColor;
        if (gameController.shakeBoard.value) {
          boardColor = Colors.red;
        } else {
          boardColor = gameController.glowBoard.value
              ? Colors.yellow
              : Colors.grey[300]!;
        }
        return AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
          height: (BOARD_SIZE * 1.1),
          width: (BOARD_SIZE * 1.1),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: boardColor, width: 5),
          ),
          child: GridView.builder(
              key: gameController.gridkey,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 4, crossAxisSpacing: 4, crossAxisCount: COL),
              itemCount: COL * ROW,
              itemBuilder: (context, index) {
                return Obx(() {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: BOARD_CELL_SIZE,
                    height: BOARD_CELL_SIZE,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      color:
                          gameController.boardList[index] == Cellstate.occupied
                              ? Colors.amber
                              : Colors.grey[300],
                    ),
                  );
                });
              }),
        );
      }),
    );
  }
}
