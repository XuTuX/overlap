import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/controller/game_controller.dart';
import 'package:overlap/enum/bord_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SolveBoard extends StatelessWidget {
  const SolveBoard({super.key});

  @override
  Widget build(BuildContext context) {
    GameController solveController = Get.find<GameController>();
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            height: SOLVE_SIZE,
            width: SOLVE_SIZE,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: AppColors.boardGradient.reversed.toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.textSecondary.withFraction(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withFraction(0.35),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withFraction(0.04),
                          ),
                          gradient: solveController.solveList[index] ==
                                  Cellstate.occupied
                              ? LinearGradient(
                                  colors: AppColors.highlightGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: solveController.solveList[index] ==
                                  Cellstate.occupied
                              ? null
                              : AppColors.surface.withFraction(0.85),
                          boxShadow: [
                            BoxShadow(
                              color: solveController.solveList[index] ==
                                      Cellstate.occupied
                                  ? AppColors.accent.withFraction(0.3)
                                  : Colors.black.withFraction(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ]),
                    );
                  });
                }),
          ),
        ],
      ),
    );
  }
}
