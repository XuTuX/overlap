import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/controller/arcade_game_controller.dart';
import 'package:overlap/models/arcade_chapter.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeMapScreen extends StatefulWidget {
  const ArcadeMapScreen({super.key});

  @override
  State<ArcadeMapScreen> createState() => _ArcadeMapScreenState();
}

class _ArcadeMapScreenState extends State<ArcadeMapScreen> {
  late final List<ArcadeChapter> _chapters;
  late final List<int> _initialStagePages;

  @override
  void initState() {
    super.initState();
    final HiveGameBox hive = HiveGameBox();
    final int clearedStage = hive.getClearedStage();
    final int highestStageId = arcadeStageMap.isEmpty
        ? 1
        : arcadeStageMap.keys.reduce(max);
    final int normalizedNextStageId =
        (clearedStage + 1).clamp(1, highestStageId);

    _chapters = arcadeChapters
        .where((chapter) => chapter.stages.isNotEmpty)
        .toList(growable: false);

    _initialStagePages = _chapters.map((chapter) {
      final stages = chapter.stages;
      if (stages.isEmpty) {
        return 0;
      }
      final int index =
          stages.indexWhere((stage) => stage.id >= normalizedNextStageId);
      if (index == -1) {
        return stages.length - 1;
      }
      return index;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final ArcadeGameController controller = Get.find<ArcadeGameController>();
    final HiveGameBox hive = HiveGameBox();
    final int clearedStage = hive.getClearedStage();
    final double progress =
        (clearedStage / arcadeStages.length).clamp(0.0, 1.0);
    final Map<int, int> stageStars = hive.getStageStars();
    final int totalStars = stageStars.values.fold(0, (p, c) => p + c);
    final int maxStars = arcadeStages.length * 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arcade Mode'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B1124),
              Color(0xFF141C31),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: _ProgressHeader(
                  clearedStage: clearedStage,
                  progress: progress,
                  totalStars: totalStars,
                  maxStars: maxStars,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _chapters.isEmpty
                    ? const _EmptyChapterPlaceholder()
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
                        itemCount: _chapters.length,
                        itemBuilder: (context, index) {
                          final ArcadeChapter chapter = _chapters[index];
                          final int initialPage = index < _initialStagePages.length
                              ? _initialStagePages[index]
                              : 0;
                          return _ArcadeChapterCard(
                            key: ValueKey(chapter.id),
                            chapter: chapter,
                            clearedStage: clearedStage,
                            stageStars: stageStars,
                            controller: controller,
                            initialPage: initialPage,
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: OutlinedButton.icon(
                  onPressed: () => Get.offAllNamed('/home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  label: const Text(
                    '홈으로 돌아가기',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int clearedStage;
  final double progress;
  final int totalStars;
  final int maxStars;

  const _ProgressHeader({
    required this.clearedStage,
    required this.progress,
    required this.totalStars,
    required this.maxStars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Arcade Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                child: Text(
                  'Stage ${clearedStage + 1 > arcadeStages.length ? arcadeStages.length : clearedStage + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF8A65),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).round()}% 완료',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFC850)),
              const SizedBox(width: 6),
              Text(
                '$totalStars / $maxStars',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '획득한 별',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcadeChapterCard extends StatefulWidget {
  final ArcadeChapter chapter;
  final int clearedStage;
  final Map<int, int> stageStars;
  final ArcadeGameController controller;
  final int initialPage;

  const _ArcadeChapterCard({
    super.key,
    required this.chapter,
    required this.clearedStage,
    required this.stageStars,
    required this.controller,
    required this.initialPage,
  });

  @override
  State<_ArcadeChapterCard> createState() => _ArcadeChapterCardState();
}

class _ArcadeChapterCardState extends State<_ArcadeChapterCard> {
  late final PageController _pageController;
  late int _currentIndex;

  List<StageData> get _stages => widget.chapter.stages;

  @override
  void initState() {
    super.initState();
    final List<StageData> stages = _stages;
    if (stages.isEmpty) {
      _currentIndex = 0;
      _pageController = PageController(viewportFraction: 0.82);
      return;
    }

    final int maxIndex = stages.length - 1;
    _currentIndex = widget.initialPage.clamp(0, maxIndex);
    _pageController = PageController(
      viewportFraction: 0.82,
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<StageData> stages = _stages;
    final bool hasStages = stages.isNotEmpty;
    final List<_ChapterStepSummary> stepSummaries =
        _buildStepSummaries(widget.chapter.stepCount, stages);

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapter.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stages.length} Stages',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Text(
                  'Step 1-${widget.chapter.stepCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (stepSummaries.any((summary) => summary.totalStages > 0)) ...[
            const SizedBox(height: 18),
            _StepSummaryRow(summaries: stepSummaries),
          ],
          if (hasStages) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 360,
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: stages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final StageData stage = stages[index];
                  final int stageId = stage.id;
                  final bool isCleared = stageId <= widget.clearedStage;
                  final bool isUnlocked = stageId <= widget.clearedStage + 1;
                  final bool isSelected = index == _currentIndex;
                  final int stars = widget.stageStars[stageId] ?? 0;

                  return AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected ? 1.0 : 0.94,
                    child: _StagePreviewCard(
                      stage: stage,
                      isCleared: isCleared,
                      isUnlocked: isUnlocked,
                      stars: stars,
                      onPlay: () {
                        if (!isUnlocked) return;
                        widget.controller.isStageCleared.value = false;
                        widget.controller.loadStage(stage);
                        Get.toNamed('/arcade/game');
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            _StageIndicator(
              stages: stages,
              currentIndex: _currentIndex,
              clearedStage: widget.clearedStage,
            ),
          ] else ...[
            const SizedBox(height: 32),
            _ChapterComingSoonBadge(title: widget.chapter.title),
          ],
        ],
      ),
    );
  }

  List<_ChapterStepSummary> _buildStepSummaries(
    int stepCount,
    List<StageData> stages,
  ) {
    if (stepCount <= 0) {
      return const [];
    }

    final List<_ChapterStepSummary> summaries = [];
    final int baseSize = stages.length ~/ stepCount;
    final int remainder = stages.length % stepCount;

    int cursor = 0;
    for (int i = 0; i < stepCount; i++) {
      final int stepNumber = i + 1;
      final int extra = i < remainder ? 1 : 0;
      final int size = baseSize + extra;

      if (cursor >= stages.length || size <= 0) {
        summaries.add(
          _ChapterStepSummary(
            label: '$stepNumber',
            collectedStars: 0,
            maxStars: 0,
            clearedStages: 0,
            totalStages: 0,
          ),
        );
        continue;
      }

      final int end = min(cursor + size, stages.length);
      final List<StageData> group = stages.sublist(cursor, end);
      cursor = end;

      final int collectedStars = group.fold<int>(
        0,
        (sum, stage) => sum + (widget.stageStars[stage.id] ?? 0),
      );
      final int maxStars = group.length * 3;
      final int clearedCount = group.fold<int>(
        0,
        (sum, stage) => sum + ((widget.stageStars[stage.id] ?? 0) > 0 ? 1 : 0),
      );

      summaries.add(
        _ChapterStepSummary(
          label: '$stepNumber',
          collectedStars: collectedStars,
          maxStars: maxStars,
          clearedStages: clearedCount,
          totalStages: group.length,
        ),
      );
    }

    return summaries;
  }
}

class _ChapterStepSummary {
  final String label;
  final int collectedStars;
  final int maxStars;
  final int clearedStages;
  final int totalStages;

  const _ChapterStepSummary({
    required this.label,
    required this.collectedStars,
    required this.maxStars,
    required this.clearedStages,
    required this.totalStages,
  });
}

class _StepSummaryRow extends StatelessWidget {
  final List<_ChapterStepSummary> summaries;

  const _StepSummaryRow({required this.summaries});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: summaries.map((summary) {
        final bool hasStages = summary.totalStages > 0;
        final Color background = hasStages
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.04);
        final Color borderColor = hasStages
            ? Colors.white.withValues(alpha: 0.24)
            : Colors.white.withValues(alpha: 0.1);

        return Container(
          width: 118,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: background,
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${summary.label}단계',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '별 ${summary.collectedStars}/${summary.maxStars}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.clearedStages}/${summary.totalStages} 스테이지',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ChapterComingSoonBadge extends StatelessWidget {
  final String title;

  const _ChapterComingSoonBadge({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title 챕터는 준비 중이에요',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '새로운 스테이지를 곧 만나보실 수 있어요.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChapterPlaceholder extends StatelessWidget {
  const _EmptyChapterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '새로운 챕터를 준비 중이에요!',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StagePreviewCard extends StatelessWidget {
  final StageData stage;
  final bool isCleared;
  final bool isUnlocked;
  final int stars;
  final VoidCallback onPlay;

  const _StagePreviewCard({
    required this.stage,
    required this.isCleared,
    required this.isUnlocked,
    required this.stars,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> gradient = _stageGradient(isCleared, isUnlocked);
    final Color chipColor = isUnlocked
        ? Colors.white.withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.14);
    final Iterable<String> uniqueBlocks = stage.blockNames.toSet();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: Text(
                  stage.id.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StageStateBadge(
                isCleared: isCleared,
                isUnlocked: isUnlocked,
                stars: stars,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _CompactStarRow(stars: stars),
          const SizedBox(height: 12),
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
            '목표 ${stage.minMoves}회 · 사용 블록 ${uniqueBlocks.length}종',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '사용 블록',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: uniqueBlocks
                .map(
                  (block) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(18),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isUnlocked ? onPlay : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.background,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.4),
                disabledForegroundColor: AppColors.background.withValues(
                  alpha: 0.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                isUnlocked ? 'Stage ${stage.id} 시작' : '잠금 해제 필요',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _stageGradient(bool isCleared, bool isUnlocked) {
    if (isCleared) {
      return const [Color(0xFF3CD3AD), Color(0xFF4CB8C4)];
    }
    if (isUnlocked) {
      return const [Color(0xFFFF9A8B), Color(0xFFFF6A88)];
    }
    return [
      const Color(0xFF23283B),
      const Color(0xFF1A1F30),
    ];
  }
}

class _StageStateBadge extends StatelessWidget {
  final bool isCleared;
  final bool isUnlocked;
  final int stars;

  const _StageStateBadge({
    required this.isCleared,
    required this.isUnlocked,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    Color background;

    if (!isUnlocked) {
      label = 'Locked';
      icon = Icons.lock_rounded;
      background = Colors.white.withValues(alpha: 0.12);
    } else if (isCleared) {
      label = '$stars / 3';
      icon = Icons.star_rounded;
      background = const Color(0xFFFFC850).withValues(alpha: 0.3);
    } else {
      label = 'Ready';
      icon = Icons.play_arrow_rounded;
      background = Colors.white.withValues(alpha: 0.16);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: background,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStarRow extends StatelessWidget {
  final int stars;
  const _CompactStarRow({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: 20,
            color: filled
                ? const Color(0xFFFFC850)
                : Colors.white.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}

class _StageIndicator extends StatelessWidget {
  final List<StageData> stages;
  final int currentIndex;
  final int clearedStage;

  const _StageIndicator({
    required this.stages,
    required this.currentIndex,
    required this.clearedStage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stages.length, (index) {
        final int stageId = stages[index].id;
        final bool isCleared = stageId <= clearedStage;
        final bool isActive = index == currentIndex;
        final bool isUnlocked = stageId <= clearedStage + 1;

        final Color color = isCleared
            ? AppColors.accent
            : isUnlocked
                ? AppColors.accentSecondary
                : Colors.white24;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
