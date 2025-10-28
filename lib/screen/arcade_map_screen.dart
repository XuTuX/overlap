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
    final HiveGameBox hive = HiveGameBox();
    final int startIndex =
        hive.getClearedStage().clamp(0, arcadeStages.length - 1);
    _currentIndex = startIndex;
    _pageController = PageController(
      viewportFraction: 0.82,
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
    final int clearedStage = hive.getClearedStage();
    final double progress =
        (clearedStage / arcadeStages.length).clamp(0.0, 1.0);

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
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 360,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: arcadeStages.length,
                  itemBuilder: (context, index) {
                    final StageData stage = arcadeStages[index];
                    final int stageId = stage.id;
                    final bool isCleared = stageId <= clearedStage;
                    final bool isUnlocked = stageId <= clearedStage + 1;
                    final bool isSelected = index == _currentIndex;

                    return AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: isSelected ? 1.0 : 0.94,
                      child: _StagePreviewCard(
                        stage: stage,
                        isCleared: isCleared,
                        isUnlocked: isUnlocked,
                        onPlay: () {
                          if (!isUnlocked) return;
                          controller.isStageCleared.value = false;
                          controller.loadStage(stage);
                          Get.toNamed('/arcade/game');
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              _StageIndicator(
                itemCount: arcadeStages.length,
                currentIndex: _currentIndex,
                clearedStage: clearedStage,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: OutlinedButton.icon(
                  onPressed: () => Get.back(),
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

  const _ProgressHeader({
    required this.clearedStage,
    required this.progress,
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
        ],
      ),
    );
  }
}

class _StagePreviewCard extends StatelessWidget {
  final StageData stage;
  final bool isCleared;
  final bool isUnlocked;
  final VoidCallback onPlay;

  const _StagePreviewCard({
    required this.stage,
    required this.isCleared,
    required this.isUnlocked,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> gradient = _stageGradient(isCleared, isUnlocked);
    final Color chipColor = isUnlocked
        ? Colors.white.withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.14);

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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.16),
                ),
                child: Text(
                  isCleared
                      ? 'Cleared'
                      : isUnlocked
                          ? 'Ready'
                          : 'Locked',
                  style: const TextStyle(
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
            '최소 ${stage.minMoves}번 배치 · 블록 ${stage.blockNames.length}개',
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
            children: stage.blockNames
                .toSet()
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
