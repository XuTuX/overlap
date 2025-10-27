import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/controller/game_controller.dart';
import 'package:overlap/enum/bord_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SolveBoard extends StatelessWidget {
  const SolveBoard({super.key});

  @override
  Widget build(BuildContext context) {
    GameController solveController = Get.put(GameController());
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            height: SOLVE_SIZE,
            width: SOLVE_SIZE,
            child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: COL),
                itemCount: COL * ROW,
                itemBuilder: (context, index) {
                  return Obx(() {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      width: SOLVE_CELL_SIZE,
                      height: SOLVE_CELL_SIZE,
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          color: solveController.solveList[index] ==
                                  Cellstate.occupied
                              ? Colors.amber // 나의 색상
                              : Colors.grey[300]),
                    );
                  });
                }),
          ),
        ],
      ),
    );
  }
}
