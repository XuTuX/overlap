import 'dart:math' as math;

import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/controllers/game_controller.dart';
import 'package:overlap/enums/board_cell_state.dart';
import 'package:overlap/widgets/game_layout_scope.dart';

class SolveBoard extends StatelessWidget {
  const SolveBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = GameLayoutScope.of(context);
    GameController solveController = Get.find<GameController>();
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(metrics.scaledPadding(6)),
            height: metrics.solveBoardSize,
            width: metrics.solveBoardSize,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(math.max(10, 18 * metrics.scale)),
              gradient: LinearGradient(
                colors: AppColors.boardGradient.reversed.toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.textSecondary.withFraction(0.3),
                width: math.max(1.0, 2 * metrics.scale),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withFraction(0.35),
                  blurRadius: 16 * metrics.scale,
                  offset: Offset(0, 6 * metrics.scale),
                ),
              ],
            ),
            child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: GameConfig.columns),
                itemCount: GameConfig.columns * GameConfig.rows,
                itemBuilder: (context, index) {
                  return Obx(() {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      width: metrics.solveCellSize,
                      height: metrics.solveCellSize,
                      margin:
                          EdgeInsets.all(math.max(0.5, 2 * metrics.scale)),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              math.max(6, 12 * metrics.scale)),
                          border: Border.all(
                            color: Colors.white.withFraction(0.04),
                          ),
                          gradient: solveController.solveList[index] ==
                                  BoardCellState.occupied
                              ? LinearGradient(
                                  colors: AppColors.highlightGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: solveController.solveList[index] ==
                                  BoardCellState.occupied
                              ? null
                              : AppColors.surface.withFraction(0.85),
                          boxShadow: [
                            BoxShadow(
                              color: solveController.solveList[index] ==
                                      BoardCellState.occupied
                                  ? AppColors.accent.withFraction(0.3)
                                  : Colors.black.withFraction(0.2),
                              blurRadius: 10 * metrics.scale,
                              offset: Offset(0, 3 * metrics.scale),
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
