import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:overlap/constants/app_colors.dart';

class StageBox extends StatefulWidget {
  final String label;
  final int stars;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const StageBox({
    super.key,
    required this.label,
    required this.stars,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<StageBox> createState() => _StageBoxState();
}

class _StageBoxState extends State<StageBox>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isUnlocked) {
      widget.onTap?.call();
    } else {
      _shakeController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = widget.isUnlocked;
    final Color accent =
        unlocked ? const Color(0xFF6C9BFF) : const Color(0xFF3A3D46);

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final double shake = sin(_shakeController.value * pi * 6) * 6;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          _handleTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed && unlocked ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 카드 높이에 따라 텍스트 크기 자동 보정
              final double fontSize = constraints.maxHeight * 0.4;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: unlocked
                        ? [
                            accent.withFraction(0.95),
                            accent.withFraction(0.6),
                          ]
                        : [
                            accent.withFraction(0.45),
                            accent.withFraction(0.25),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withFraction(unlocked ? 0.25 : 0.1),
                    width: 1.2,
                  ),
                  boxShadow: unlocked
                      ? [
                          BoxShadow(
                            color: accent.withFraction(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // 유리 느낌
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.white
                                .withFraction(unlocked ? 0.05 : 0.04),
                          ),
                        ),
                      ),

                      // 상단 라이트 효과
                      if (unlocked)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: constraints.maxHeight * 0.25,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withFraction(0.12),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),

                      // 잠금 상태 어둡게
                      if (!unlocked)
                        Positioned.fill(
                          child:
                              Container(color: Colors.black.withFraction(0.35)),
                        ),

                      // 메인 콘텐츠
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 상단 번호 - 폰트 크기 자동 조정
                            Expanded(
                              flex: 3,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.label.padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w900,
                                    color: unlocked
                                        ? Colors.white.withFraction(0.95)
                                        : Colors.white.withFraction(0.4),
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(flex: 1),
                            _StarRow(stars: widget.stars, isUnlocked: unlocked),
                          ],
                        ),
                      ),

                      // 중앙 자물쇠
                      if (!unlocked)
                        const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ),

                      // 하단 라인 반사
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white
                                    .withFraction(unlocked ? 0.25 : 0.1),
                                Colors.transparent,
                                Colors.white
                                    .withFraction(unlocked ? 0.25 : 0.1),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int stars;
  final bool isUnlocked;
  const _StarRow({required this.stars, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            scale: filled ? 1.15 : 1.0,
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: 18,
              color: filled
                  ? const Color(0xFFFFD36E)
                  : (isUnlocked
                      ? Colors.white.withFraction(0.4)
                      : Colors.white24),
            ),
          ),
        );
      }),
    );
  }
}
