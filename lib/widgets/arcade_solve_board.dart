import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/arcade_game_controller.dart';
import 'package:overlap/enums/board_cell_state.dart';

class ArcadeSolveBoard extends StatelessWidget {
  const ArcadeSolveBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController controller = Get.find<ArcadeGameController>();
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
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
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: COL,
              ),
              itemCount: COL * ROW,
              itemBuilder: (context, index) {
                return Obx(() {
                  final isOccupied =
                      controller.solveList[index] == BoardCellState.occupied;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    width: SOLVE_CELL_SIZE,
                    height: SOLVE_CELL_SIZE,
                    margin: const EdgeInsets.all(2),
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
                          : AppColors.surface.withFraction(0.85),
                      boxShadow: [
                        BoxShadow(
                          color: isOccupied
                              ? AppColors.accent.withFraction(0.3)
                              : Colors.black.withFraction(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
