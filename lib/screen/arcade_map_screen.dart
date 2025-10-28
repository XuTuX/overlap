import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/controller/arcade_game_controller.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeMapScreen extends StatefulWidget {
  const ArcadeMapScreen({super.key});

  @override
  State<ArcadeMapScreen> createState() => _ArcadeMapScreenState();
}

class _ArcadeMapScreenState extends State<ArcadeMapScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final hive = HiveGameBox();
    final startIndex =
        hive.getClearedStage().clamp(0, arcadeStages.length - 1);
    _currentIndex = startIndex;
    _pageController = PageController(
      viewportFraction: 0.72,
      initialPage: startIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController controller = Get.find<ArcadeGameController>();
    final HiveGameBox hive = HiveGameBox();
    final int highestCleared = hive.getClearedStage();
    final double progress =
        (highestCleared / arcadeStages.length).clamp(0.0, 1.0);

    final int targetIndex =
        highestCleared.clamp(0, arcadeStages.length - 1);

    if (targetIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
        setState(() => _currentIndex = targetIndex);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arcade Mode'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF090C1C),
              Color(0xFF151D32),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '스테이지 선택',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      highestCleared >= arcadeStages.length
                          ? '모든 코스를 클리어했습니다!'
                          : 'Stage ${highestCleared + 1}까지 진행 중',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: progress,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF8A65),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _StagePathPainter(
                                stageCount: arcadeStages.length,
                                clearedStageId: highestCleared,
                                selectedIndex: _currentIndex,
                                progress: progress,
                              ),
                            ),
                          ),
                          PageView.builder(
                            controller: _pageController,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() => _currentIndex = index);
                            },
                            itemCount: arcadeStages.length,
                            itemBuilder: (context, index) {
                              final StageData stage = arcadeStages[index];
                              final int stageId = stage.id;
                              final bool isCleared = stageId <= highestCleared;
                              final bool isUnlocked =
                                  stageId <= highestCleared + 1;
                              final bool isCurrent =
                                  highestCleared >= arcadeStages.length
                                      ? index == arcadeStages.length - 1
                                      : stageId == highestCleared + 1;
                              final bool isSelected =
                                  index == _currentIndex;

                              return AnimatedScale(
                                scale: isSelected ? 1.0 : 0.92,
                                duration:
                                    const Duration(milliseconds: 250),
                                child: _StageCard(
                                  stage: stage,
                                  isCleared: isCleared,
                                  isUnlocked: isUnlocked,
                                  isCurrent: isCurrent,
                                  onPlay: () {
                                    if (!isUnlocked) {
                                      Get.snackbar(
                                        '잠겨있는 스테이지',
                                        '먼저 이전 스테이지를 완료해야 해요.',
                                        backgroundColor: Colors.black87,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }
                                    controller.loadStage(stage);
                                    controller.isStageCleared.value = false;
                                    Get.toNamed('/arcade/game');
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _StageIndicator(
                itemCount: arcadeStages.length,
                currentIndex: _currentIndex,
                clearedStage: highestCleared,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final StageData stage;
  final bool isCleared;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback onPlay;

  const _StageCard({
    required this.stage,
    required this.isCleared,
    required this.isUnlocked,
    required this.isCurrent,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> blockLabels =
        stage.blockNames.toSet().toList(growable: false);

    final List<Color> palette = isCleared
        ? const [Color(0xFF3CD3AD), Color(0xFF4CB8C4)]
        : isUnlocked
            ? const [Color(0xFFFF9A8B), Color(0xFFFF6A88)]
            : [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.06),
              ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: palette,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.last.withValues(
                alpha: isUnlocked ? 0.35 : 0.15,
              ),
              blurRadius: 24,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _StagePatternPainter(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.18),
                      child: Text(
                        '${stage.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isCleared)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Cleared',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (!isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Locked',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Next Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  stage.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '최소 ${stage.minMoves}번 배치 / 사용 블록 ${stage.blockNames.length}개',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '블록 조합',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: blockLabels
                      .map(
                        (block) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            block,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isUnlocked ? onPlay : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          isUnlocked ? 'Start Stage' : 'Locked',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Stage Goal',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          isCleared
                              ? '완료됨'
                              : 'Pattern ${stage.id.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (!isUnlocked)
              Positioned(
                top: 24,
                right: 24,
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 30,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final int clearedStage;

  const _StageIndicator({
    required this.itemCount,
    required this.currentIndex,
    required this.clearedStage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final int stageId = index + 1;
        final bool isCleared = stageId <= clearedStage;
        final bool isActive = index == currentIndex;
        final bool isUnlocked = stageId <= clearedStage + 1;

        final Color color = isCleared
            ? AppColors.accent
            : isUnlocked
                ? AppColors.accentSecondary
                : Colors.white24;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 22 : 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

class _StagePathPainter extends CustomPainter {
  final int stageCount;
  final int clearedStageId;
  final int selectedIndex;
  final double progress;

  _StagePathPainter({
    required this.stageCount,
    required this.clearedStageId,
    required this.selectedIndex,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stageCount <= 1) return;

    final double midY = size.height * 0.55;
    final double wave = size.height * 0.25;
    final double spacing = size.width / (stageCount - 1);

    final Path path = Path()..moveTo(0, midY);
    for (int i = 1; i < stageCount; i++) {
      final double x = spacing * i;
      final double controlX = spacing * (i - 0.5);
      final double controlY = midY + (i.isEven ? -wave : wave);
      path.quadraticBezierTo(controlX, controlY, x, midY);
    }

    final Paint basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, basePaint);

    final List<PathMetric> metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final PathMetric metric = metrics.first;
      final double drawLength = metric.length * progress;
      if (drawLength > 0) {
        final Path highlightPath = metric.extractPath(0, drawLength);
        final Paint highlightPaint = Paint()
          ..shader = const LinearGradient(
            colors: [
              Color(0xFFFFC371),
              Color(0xFFFF5F6D),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(highlightPath, highlightPaint);
      }
    }

    for (int i = 0; i < stageCount; i++) {
      final int stageId = i + 1;
      final bool isCleared = stageId <= clearedStageId;
      final bool isUnlocked = stageId <= clearedStageId + 1;
      final bool isSelected = i == selectedIndex;

      final double radius = isSelected
          ? 14
          : isCleared
              ? 11
              : 9;

      final Paint fillPaint = Paint()
        ..color = isCleared
            ? const Color(0xFFFF9A8B)
            : isUnlocked
                ? Colors.white.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.3);

      final Offset center = Offset(spacing * i, midY);
      canvas.drawCircle(center, radius, fillPaint);

      final Paint borderPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius, borderPaint);

      if (isSelected) {
        final Paint ringPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(center, radius + 4, ringPaint);
      }

      if (isCleared) {
        final Paint corePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.9);
        canvas.drawCircle(center, radius * 0.45, corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StagePathPainter oldDelegate) {
    return oldDelegate.stageCount != stageCount ||
        oldDelegate.clearedStageId != clearedStageId ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.progress != progress;
  }
}

class _StagePatternPainter extends CustomPainter {
  final Color color;

  _StagePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    for (double dx = -size.height; dx < size.width; dx += 30) {
      canvas.drawLine(
        Offset(dx, size.height),
        Offset(dx + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StagePatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
