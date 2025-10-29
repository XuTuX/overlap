import 'package:flutter/material.dart';

class StageBox extends StatelessWidget {
  final String label;
  final int stars;
  final bool isUnlocked;
  final bool isCleared;
  final VoidCallback? onTap;

  const StageBox({
    super.key,
    required this.label,
    required this.stars,
    required this.isUnlocked,
    required this.isCleared,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isUnlocked
        ? (isCleared ? const Color(0xFF4ECDC4) : const Color(0xFF7B8CFE))
        : Colors.white24;
    final Color overlayColor =
        isUnlocked ? Colors.white.withValues(alpha: 0.08) : Colors.white12;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isUnlocked ? 1 : 0.6,
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                baseColor,
                baseColor.withValues(alpha: 0.72),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isCleared
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.3),
              width: isCleared ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: overlayColor,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Colors.black.withValues(alpha: 0.18),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          isUnlocked ? Icons.play_arrow_rounded : Icons.lock,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                      ],
                    ),
                    const Spacer(),
                    _StarRow(stars: stars, isUnlocked: isUnlocked),
                  ],
                ),
              ),
            ],
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
      children: List.generate(3, (index) {
        final bool filled = index < stars;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: 18,
            color: filled
                ? const Color(0xFFFFCF6F)
                : (isUnlocked
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.white38),
          ),
        );
      }),
    );
  }
}
