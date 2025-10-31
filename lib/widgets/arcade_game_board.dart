import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/arcade_game_controller.dart';
import 'package:overlap/enums/board_cell_state.dart';

class ArcadeGameBoard extends StatelessWidget {
  const ArcadeGameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController gameController = Get.find<ArcadeGameController>();
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
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          height: (BOARD_SIZE * 1.1),
          width: (BOARD_SIZE * 1.1),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: AppColors.boardGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: boardColor, width: 5),
            boxShadow: [
              BoxShadow(
                color: boardColor.withFraction(0.35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: GridView.builder(
            key: gameController.gridKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              crossAxisCount: COL,
            ),
            itemCount: COL * ROW,
            itemBuilder: (context, index) {
              return Obx(() {
                final isOccupied =
                    gameController.boardList[index] == BoardCellState.occupied;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: BOARD_CELL_SIZE,
                  height: BOARD_CELL_SIZE,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        );
      }),
    );
  }
}
