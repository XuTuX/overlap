import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/arcade_game_controller.dart';
import 'package:overlap/enums/board_cell_state.dart';
import 'package:overlap/widgets/game_layout_scope.dart';

class ArcadeSolveBoard extends StatelessWidget {
  const ArcadeSolveBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController controller = Get.find<ArcadeGameController>();
    final metrics = GameLayoutScope.of(context);
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
                  color: AppColors.textPrimary.withFraction(0.18),
                  blurRadius: 16 * metrics.scale,
                  offset: Offset(0, 6 * metrics.scale),
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: GameConfig.columns,
              ),
              itemCount: GameConfig.columns * GameConfig.rows,
              itemBuilder: (context, index) {
                return Obx(() {
                  final isOccupied =
                      controller.solveList[index] == BoardCellState.occupied;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    width: metrics.solveCellSize,
                    height: metrics.solveCellSize,
                    margin:
                        EdgeInsets.all(math.max(0.5, 2 * metrics.scale)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          math.max(6, 12 * metrics.scale)),
                      border: Border.all(
                        color: AppColors.textPrimary.withFraction(0.08),
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
                            : AppColors.textPrimary.withFraction(0.12),
                          blurRadius: 10 * metrics.scale,
                          offset: Offset(0, 3 * metrics.scale),
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
