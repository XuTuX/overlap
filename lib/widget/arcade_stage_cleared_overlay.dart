// arcade_stage_cleared_overlay.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/controller/arcade_game_controller.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeStageClearedOverlay extends StatelessWidget {
  const ArcadeStageClearedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArcadeGameController>();
    final stage = controller.currentStage.value;
    if (stage == null) return const SizedBox.shrink();

    final nextStage = _findNextStage(stage);
    final moves = controller.currentMoves.value;
    final targetMoves = stage.minMoves;
    final stars = controller.calculateStars(moves, targetMoves);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF171A26), Color(0xFF22283B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        // 하단 제스처 바/라운딩으로 인한 1px 오버플로우 방지
        minimum:
            const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 16),
        child: Center(
          child: SingleChildScrollView(
            // 작은 화면에서도 안전하게 보이도록
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 상단 아이콘
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'STAGE CLEAR',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ⭐ 별 등급
                        _StarRow(stars: stars),
                        const SizedBox(height: 14),

                        // 결과 요약
                        Text(
                          '목표 $targetMoves회 · $moves회로 클리어',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 버튼 3개
                        _ActionRow(
                          hasNext: nextStage != null,
                          onNext: nextStage == null
                              ? null
                              : () {
                                  controller.isStageCleared.value = false;
                                  controller.loadStage(nextStage);
                                },
                          onList: () {
                            controller.isStageCleared.value = false;
                            Get.offAllNamed('/arcade');
                          },
                          onHome: () => Get.offAllNamed('/home'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  StageData? _findNextStage(StageData current) {
    final index = arcadeStages.indexWhere((s) => s.id == current.id);
    if (index < 0 || index + 1 >= arcadeStages.length) return null;
    return arcadeStages[index + 1];
  }
}

class _StarRow extends StatelessWidget {
  final int stars;
  const _StarRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: 32,
            color: filled
                ? const Color(0xFFFFC850)
                : Colors.white.withValues(alpha: 0.35),
          ),
        );
      }),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool hasNext;
  final VoidCallback? onNext;
  final VoidCallback onList;
  final VoidCallback onHome;

  const _ActionRow({
    required this.hasNext,
    required this.onNext,
    required this.onList,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final double gap = 10;
      final double itemW = (c.maxWidth - gap * 2) / 3; // 정확히 3등분
      const double itemH = 50;

      Widget btn(IconData icon, String label, VoidCallback? onTap) {
        return SizedBox(
          width: itemW,
          height: itemH,
          child: FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
              ),
              textStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 6),
                Text(label),
              ],
            ),
          ),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          btn(Icons.play_arrow_rounded, '다음', hasNext ? onNext : null),
          SizedBox(width: gap),
          btn(Icons.map_rounded, '목록', onList),
          SizedBox(width: gap),
          btn(Icons.home_rounded, '홈', onHome),
        ],
      );
    });
  }
}
