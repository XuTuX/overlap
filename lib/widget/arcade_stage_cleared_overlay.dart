// arcade_stage_cleared_overlay.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/controller/arcade_game_controller.dart';
import 'package:overlap/models/arcade_stage_data.dart';
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
    final difference = moves - targetMoves;
    final bool isPerfect = difference <= 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF060912),
            Color(0xFF101523),
            Color(0xFF1D2237),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: 1.0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            builder: (_, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.28),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            top: -80,
                            right: -40,
                            child: _AccentBlob(
                              colors: [Color(0xFF5866FF), Color(0xFF8A79FF)],
                            ),
                          ),
                          const Positioned(
                            bottom: -60,
                            left: -50,
                            child: _AccentBlob(
                              colors: [Color(0xFF1CDAC5), Color(0xFF26F6F0)],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 6),
                              _StageBadge(label: 'Stage ${stage.id}'),
                              const SizedBox(height: 20),
                              const Icon(Icons.celebration_rounded,
                                  color: Colors.white, size: 32),
                              const SizedBox(height: 14),
                              const Text(
                                'STAGE CLEAR!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stage.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.82),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _StarRow(stars: stars),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 18),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: Colors.white.withOpacity(0.07),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.14),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        _InfoTile(
                                            label: '사용 이동',
                                            value: '$moves',
                                            accent: const Color(0xFF72F5D0)),
                                        const SizedBox(width: 12),
                                        _InfoTile(
                                            label: '목표 이동',
                                            value: '$targetMoves',
                                            accent: const Color(0xFFFFE28A)),
                                        const SizedBox(width: 12),
                                        _InfoTile(
                                          label: '평가',
                                          value: isPerfect
                                              ? 'PERFECT'
                                              : '+${difference.abs()}',
                                          accent: isPerfect
                                              ? const Color(0xFF9CF6FF)
                                              : const Color(0xFFFF8D70),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '목표 $targetMoves회 · $moves회로 클리어',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.78),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _PerformanceChip(
                                      label: isPerfect
                                          ? '완벽 해금! 다음 스테이지에서도 빛나요'
                                          : '목표보다 ${difference.abs()}회 더 사용했어요',
                                      color: isPerfect
                                          ? const Color(0xFF26F6F0)
                                          : const Color(0xFFFF9E74),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (nextStage != null)
                                _NextStageHint(title: nextStage.title),
                              const SizedBox(height: 14),
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
                        ],
                      ),
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

// 🌈 배경용 블러 컬러 구름 (리디자인)
class _AccentBlob extends StatelessWidget {
  final List<Color> colors;
  const _AccentBlob({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // 160 → 120으로 축소
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colors.first.withOpacity(0.28), // 불투명도 낮춤
            colors.last.withOpacity(0.12),
          ],
          center: Alignment.center,
          radius: 0.8,
        ),
      ),
    );
  }
}

/// 🔖 스테이지 배지
class _StageBadge extends StatelessWidget {
  final String label;
  const _StageBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// 📊 정보 타일
class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _InfoTile(
      {required this.label, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, color: accent, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// 💬 평가 문구
class _PerformanceChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PerformanceChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// 🔮 다음 스테이지 힌트
class _NextStageHint extends StatelessWidget {
  final String title;
  const _NextStageHint({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      '다음 스테이지: $title',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// ⭐ 별 표시
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
                : Colors.white.withOpacity(0.35),
          ),
        );
      }),
    );
  }
}

/// 🎮 하단 버튼 3개
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
      final double itemW = (c.maxWidth - gap * 2) / 3;
      const double itemH = 50;

      Widget btn(IconData icon, String label, VoidCallback? onTap) {
        return SizedBox(
          width: itemW,
          height: itemH,
          child: FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white.withOpacity(0.10),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.white.withOpacity(0.25)),
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
