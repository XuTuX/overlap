import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/controller/arcade_controller.dart';
import 'package:overlap/controller/arcade_game_controller.dart';
import 'package:overlap/models/arcade_chapter.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeStageListScreen extends StatefulWidget {
  const ArcadeStageListScreen({super.key});

  @override
  State<ArcadeStageListScreen> createState() => _ArcadeStageListScreenState();
}

class _ArcadeStageListScreenState extends State<ArcadeStageListScreen>
    with SingleTickerProviderStateMixin {
  late final ArcadeController _arcadeController;
  late final ArcadeGameController _gameController;
  late final AnimationController _bgAnimation;

  @override
  void initState() {
    super.initState();
    _arcadeController = Get.find<ArcadeController>();
    _gameController = Get.find<ArcadeGameController>();
    _arcadeController.refreshProgress();

    _bgAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ArcadeChapter? chapter = _arcadeController.selectedMonth.value;

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            chapter?.title ?? 'Arcade',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // 움직이는 네온 배경
            AnimatedBuilder(
              animation: _bgAnimation,
              builder: (context, _) {
                final double shift = _bgAnimation.value * 0.8;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(const Color(0xFF0D1328),
                            const Color(0xFF191F41), shift)!,
                        Color.lerp(const Color(0xFF111B33),
                            const Color(0xFF0A1124), 1 - shift)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: chapter == null
                    ? const _EmptySelection()
                    : _buildStageGrid(context, chapter),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStageGrid(BuildContext context, ArcadeChapter chapter) {
    final List<int> stageIds = chapter.stageIds;

    if (stageIds.isEmpty) {
      return _ComingSoonBanner(title: chapter.title);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${chapter.title} - Stages',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '총 ${stageIds.length}개의 스테이지가 기다리고 있어요.',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 22),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final int crossAxisCount = maxWidth < 460
                  ? 3
                  : maxWidth < 760
                      ? 4
                      : 5;

              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.88,
                ),
                itemCount: stageIds.length,
                itemBuilder: (context, index) {
                  final int stageId = stageIds[index];
                  final int displayNumber = index + 1;
                  final StageData? stageData = arcadeStageMap[stageId];
                  final int starCount =
                      _arcadeController.starsForStage(stageId);
                  final bool isAvailable = stageData != null;
                  final bool unlockedByProgress =
                      _arcadeController.isStageUnlocked(stageId);
                  final bool isUnlocked = isAvailable && unlockedByProgress;
                  final bool isCleared =
                      isAvailable && _arcadeController.isStageCleared(stageId);

                  return _StageCard(
                    index: displayNumber,
                    stars: starCount,
                    unlocked: isUnlocked,
                    cleared: isCleared,
                    onTap: () {
                      if (!isUnlocked) return;
                      _arcadeController.selectStage(stageId);
                      _gameController.isStageCleared.value = false;
                      _gameController.loadStage(stageData);
                      Get.toNamed('/arcade/game');
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StageCard extends StatefulWidget {
  final int index;
  final int stars;
  final bool unlocked;
  final bool cleared;
  final VoidCallback onTap;

  const _StageCard({
    required this.index,
    required this.stars,
    required this.unlocked,
    required this.cleared,
    required this.onTap,
  });

  @override
  State<_StageCard> createState() => _StageCardState();
}

class _StageCardState extends State<_StageCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color baseColor =
        widget.unlocked ? const Color(0xFF2E376D) : Colors.grey.shade800;
    final double opacity = widget.unlocked ? 1 : 0.4;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (widget.unlocked) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.97 : 1.0,
        child: Stack(
          children: [
            // 카드 배경
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.25 * opacity),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.unlocked
                            ? Text(
                                'STAGE',
                                style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.8 * opacity),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              )
                            : const Icon(Icons.lock_outline_rounded,
                                color: Colors.white54, size: 26),
                        const SizedBox(height: 6),
                        Text(
                          widget.index.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(opacity),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            return Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: i < widget.stars
                                  ? Colors.amberAccent
                                  : Colors.white.withOpacity(0.3),
                            );
                          }),
                        ),
                        if (widget.cleared) ...[
                          const SizedBox(height: 4),
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.lightGreenAccent, size: 20),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySelection extends StatelessWidget {
  const _EmptySelection();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '월을 선택하면 스테이지를 확인할 수 있어요.',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}

class _ComingSoonBanner extends StatelessWidget {
  final String title;
  const _ComingSoonBanner({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$title 월의 스테이지는 곧 공개됩니다.',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '조금만 기다려 주세요!',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
