import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/game_controller.dart';
import 'package:overlap/enums/board_cell_state.dart';
import 'package:overlap/widgets/game_layout_scope.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = GameLayoutScope.of(context);
    GameController gameController = Get.find<GameController>();
    return Center(
      child: Obx(() {
        Color boardColor;
        if (gameController.shakeBoard.value) {
          boardColor = AppColors.accentTertiary;
        } else {
          boardColor = gameController.glowBoard.value
              ? AppColors.accent
              : AppColors.textSecondary.withFraction(0.4);
        }
        return AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
          height: metrics.boardSize * 1.1,
          width: metrics.boardSize * 1.1,
          padding: EdgeInsets.all(metrics.scaledPadding(5)),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(math.max(12, 20 * metrics.scale)),
            gradient: LinearGradient(
              colors: AppColors.boardGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: boardColor,
              width: math.max(2, 5 * metrics.scale),
            ),
            boxShadow: [
              BoxShadow(
                color: boardColor.withFraction(0.35),
                blurRadius: 20 * metrics.scale,
                spreadRadius: 2 * metrics.scale,
              ),
            ],
          ),
          child: GridView.builder(
              key: gameController.gridKey,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: math.max(1, 4 * metrics.scale),
                  crossAxisSpacing: math.max(1, 4 * metrics.scale),
                  crossAxisCount: GameConfig.columns),
              itemCount: GameConfig.columns * GameConfig.rows,
              itemBuilder: (context, index) {
                return Obx(() {
                  final isOccupied = gameController.boardList[index] ==
                      BoardCellState.occupied;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: metrics.boardCellSize,
                    height: metrics.boardCellSize,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(math.max(6, 12 * metrics.scale)),
                      border: Border.all(
                        color: Colors.white.withFraction(0.04),
                      ),
                      gradient: isOccupied
                          ? LinearGradient(
                              colors: AppColors.highlightGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isOccupied
                          ? null
                          : AppColors.surfaceAlt.withFraction(0.85),
                      boxShadow: [
                        BoxShadow(
                          color: isOccupied
                              ? AppColors.accent.withFraction(0.35)
                              : Colors.black.withFraction(0.25),
                          blurRadius: 12 * metrics.scale,
                          offset: Offset(0, 4 * metrics.scale),
                        )
                      ],
                    ),
                  );
                });
              }),
        );
      }),
    );
  }
}
