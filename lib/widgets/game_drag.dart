import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/models/tetris_model.dart';
import 'package:overlap/widgets/game_layout_scope.dart';
import '../controllers/game_controller.dart';

class GameDrag extends StatelessWidget {
  const GameDrag({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.find<GameController>();
    final metrics = GameLayoutScope.of(context);

    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(controller.availableBlocks.length, (index) {
          final block = controller.availableBlocks[index];

          final draggable = Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // --- 블록 자체 ---
              Draggable(
                key: ValueKey('${block.name}-$index'),
                feedback: TetrisModel(blockList: block.offsets),
                childWhenDragging: SizedBox(
                  width: metrics.blockBoxSize,
                  height: metrics.blockBoxSize,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent)),
                  width: metrics.blockBoxSize - 1,
                  height: metrics.blockBoxSize - 1,
                  padding: EdgeInsets.all(metrics.scaledPadding(2)),
                  child: TetrisModel(blockList: block.offsets),
                ),
                dragAnchorStrategy: (draggable, context, position) {
                  final offsetX = context.size!.width / 2;
                  final offsetY =
                      context.size!.height + metrics.scaledPadding(27);
                  return Offset(offsetX, offsetY);
                },
                onDragEnd: (details) {
                  final renderObject =
                      controller.gridKey.currentContext?.findRenderObject();
                  if (renderObject is! RenderBox) return;
                  final gridBox = renderObject;
                  final gridPosition = gridBox.localToGlobal(Offset.zero);

                  final dragPosition = details.offset;

                  final col = ((dragPosition.dx -
                              gridPosition.dx +
                              metrics.boardCellSize * 0.6) /
                          metrics.boardCellSize)
                      .floor();

                  final row = ((dragPosition.dy -
                              gridPosition.dy +
                              metrics.boardCellSize * 0.6) /
                          metrics.boardCellSize)
                      .floor();

                  controller.insert(block, col, row);
                },
              ),

              // --- 회전 아이콘 (더 큰 터치 영역 + 살짝 더 우상단으로 이동) ---
              Positioned(
                top: -metrics.scaledPadding(20), // 기존보다 위로
                right: -metrics.scaledPadding(14), // 기존보다 오른쪽으로
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => controller.rotateBlock(index),
                  child: Container(
                    // 터치 가능한 영역을 더 넓힘 (1.7배)
                    constraints: BoxConstraints(
                      minWidth: metrics.rotateIconSize * 1.7,
                      minHeight: metrics.rotateIconSize * 1.7,
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(metrics.scaledPadding(4)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        color: AppColors.surface.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/image/rotate.png',
                        width: metrics.rotateIconSize * 0.6,
                        height: metrics.rotateIconSize * 0.6,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: metrics.scaledPadding(6)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: metrics.blockBoxSize,
                    height: metrics.blockBoxSize,
                    child: draggable,
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }
}
