import 'package:get/get.dart';
import 'package:overlap/models/arcade_chapter.dart';
import 'package:overlap/models/hive_game_box.dart';

class ArcadeController extends GetxController {
  ArcadeController({HiveGameBox? hiveGameBox})
      : _hiveGameBox = hiveGameBox ?? _tryCreateHiveGameBox();

  final HiveGameBox? _hiveGameBox;
  final Map<int, int> _fallbackStageStars = <int, int>{};
  int _fallbackClearedStage = 0;

  final Rx<ArcadeChapter?> selectedMonth = Rx<ArcadeChapter?>(null);
  final Rx<int?> selectedStage = Rx<int?>(null);
  final RxMap<int, int> stageStars = <int, int>{}.obs;
  final RxInt clearedStage = 0.obs;

  List<ArcadeChapter> get chapters => arcadeChapters;

  static HiveGameBox? _tryCreateHiveGameBox() {
    try {
      return HiveGameBox();
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (selectedMonth.value == null && chapters.isNotEmpty) {
      selectedMonth.value = chapters.first;
    }
    refreshProgress();
  }

  void refreshProgress() {
    final hiveGameBox = _hiveGameBox;
    if (hiveGameBox != null) {
      stageStars.assignAll(hiveGameBox.getStageStars());
      clearedStage.value = hiveGameBox.getClearedStage();
    } else {
      stageStars.assignAll(_fallbackStageStars);
      clearedStage.value = _fallbackClearedStage;
    }
  }

  void selectMonth(ArcadeChapter chapter) {
    selectedMonth.value = chapter;
    selectedStage.value = null;
  }

  void selectStage(int stageId) {
    selectedStage.value = stageId;
  }

  int starsForStage(int stageId) => stageStars[stageId] ?? 0;

  bool isStageCleared(int stageId) => stageId <= clearedStage.value;

  bool isStageUnlocked(int stageId) => stageId <= clearedStage.value + 1;

  void recordStageProgress({
    required int stageId,
    required int stars,
  }) {
    if (stars < 0) return;

    final hiveGameBox = _hiveGameBox;
    if (hiveGameBox != null) {
      hiveGameBox.setStageStar(stageId, stars);
      if (stars > 0) {
        hiveGameBox.setClearedStage(stageId);
      }
    } else {
      final int existing = _fallbackStageStars[stageId] ?? 0;
      if (stars > existing) {
        _fallbackStageStars[stageId] = stars;
      }
      if (stars > 0 && stageId > _fallbackClearedStage) {
        _fallbackClearedStage = stageId;
      }
    }

    final int current = stageStars[stageId] ?? 0;
    if (stars > current) {
      stageStars[stageId] = stars;
    }
    if (stars > 0 && stageId > clearedStage.value) {
      clearedStage.value = stageId;
    }
  }
}
