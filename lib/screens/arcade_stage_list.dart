import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/controllers/arcade_controller.dart';
import 'package:overlap/controllers/arcade_game_controller.dart';
import 'package:overlap/models/arcade_chapter.dart';
import 'package:overlap/models/stage_data.dart';
import 'package:overlap/widgets/stage_box.dart';

class ArcadeStageListScreen extends StatefulWidget {
  const ArcadeStageListScreen({super.key});

  @override
  State<ArcadeStageListScreen> createState() => _ArcadeStageListScreenState();
}

class _ArcadeStageListScreenState extends State<ArcadeStageListScreen> {
  late final ArcadeController _arcadeController;
  late final ArcadeGameController _gameController;

  @override
  void initState() {
    super.initState();
    _arcadeController = Get.find<ArcadeController>();
    _gameController = Get.find<ArcadeGameController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ArcadeChapter? chapter = _arcadeController.selectedMonth.value;

      return Scaffold(
        appBar: AppBar(
          title: Text(chapter?.title ?? 'Arcade'),
          backgroundColor: Colors.transparent,
          centerTitle: true,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D1328),
                Color(0xFF111B33),
                Color(0xFF191F41),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: chapter == null
                  ? const _EmptySelection()
                  : _buildStageGrid(context, chapter),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStageGrid(BuildContext context, ArcadeChapter chapter) {
    final List<StageData> stages = chapter.stages;
    if (stages.isEmpty) {
      return _ComingSoonBanner(title: chapter.title);
    }
    final int totalSlots = chapter.totalStageSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${chapter.title} Stages',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          totalSlots == stages.length
              ? '총 ${stages.length}개의 스테이지가 기다리고 있어요.'
              : '총 $totalSlots개 중 ${stages.length}개의 스테이지가 공개되었어요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 24),
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.9,
                ),
                itemCount: totalSlots,
                itemBuilder: (context, index) {
                  final StageData? stageData =
                      index < stages.length ? stages[index] : null;
                  final int? stageId = stageData?.id;
                  final int displayNumber = stageData?.order ?? index + 1;
                  final int starCount = stageId == null
                      ? 0
                      : _arcadeController.starsForStage(stageId);
                  final bool isUnlocked = stageId != null &&
                      _arcadeController.isStageUnlocked(stageId);

                  return StageBox(
                    label: displayNumber.toString().padLeft(2, '0'),
                    stars: starCount,
                    isUnlocked: isUnlocked,
                    onTap: () {
                      if (!isUnlocked || stageData == null) return;
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

class _EmptySelection extends StatelessWidget {
  const _EmptySelection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: Colors.white.withValues(alpha: 0.6),
            size: 48,
          ),
          const SizedBox(height: 18),
          Text(
            '월을 선택하면 스테이지를 확인할 수 있어요.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$title 월의 스테이지는 곧 공개될 예정입니다.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '조금만 기다려 주세요!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
