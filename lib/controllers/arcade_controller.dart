import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:overlap/models/arcade_chapter.dart';
import 'package:overlap/models/arcade_stage_data.dart';
import 'package:overlap/models/hive_game_box.dart';

final List<ArcadeChapter> _availableChapters = arcadeChapters
    .where((chapter) => chapter.stageCount > 0)
    .toList(growable: false);

class ArcadeController extends GetxController {
  ArcadeController({HiveGameBox? hiveGameBox}) {
    _assignHiveBox(hiveGameBox);
  }

  HiveGameBox? _hiveGameBox;
  final Map<int, int> _fallbackStageStars = <int, int>{};
  int _fallbackClearedStage = 0;
  final RxBool usingFallbackStorage = false.obs;
  final RxnString persistenceWarning = RxnString();
  bool _hasShownWarning = false;

  final Rx<ArcadeChapter?> selectedMonth = Rx<ArcadeChapter?>(null);
  final Rx<int?> selectedStage = Rx<int?>(null);
  final RxMap<int, int> stageStars = <int, int>{}.obs;
  final RxInt clearedStage = 0.obs;

  List<ArcadeChapter> get chapters => _availableChapters;

  void _assignHiveBox(HiveGameBox? hiveGameBox) {
    if (hiveGameBox != null) {
      _hiveGameBox = hiveGameBox;
      usingFallbackStorage.value = false;
      _scheduleWarningUpdate(null);
      return;
    }
    _hiveGameBox = HiveGameBox.tryOpen(onError: _recordPersistenceFailure);
    if (_hiveGameBox == null) {
      usingFallbackStorage.value = true;
      _ensureWarning();
    }
  }

  void _recordPersistenceFailure(Object error, StackTrace stackTrace) {
    debugPrint('ArcadeController storage error: $error');
    debugPrintStack(stackTrace: stackTrace);
    _hiveGameBox = null;
    usingFallbackStorage.value = true;
    _ensureWarning();
  }

  void _ensureWarning() {
    if (_hasShownWarning) {
      return;
    }
    _hasShownWarning = true;
    _scheduleWarningUpdate(
      '진행도를 저장하지 못했습니다. 저장소 권한이나 용량을 확인한 뒤 다시 시도해주세요.',
      markWarningShown: true,
    );
  }

  void _loadFallbackProgress() {
    stageStars.assignAll(_fallbackStageStars);
    clearedStage.value = _fallbackClearedStage;
  }

  void _persistStageFallback(int stageId, int stars) {
    final int existing = _fallbackStageStars[stageId] ?? 0;
    if (stars > existing) {
      _fallbackStageStars[stageId] = stars;
    }
    if (stars > 0 && stageId > _fallbackClearedStage) {
      _fallbackClearedStage = stageId;
    }
  }

  void retryStorage() {
    _assignHiveBox(null);
    if (_hiveGameBox != null) {
      refreshProgress();
    } else {
      _loadFallbackProgress();
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
      _ensureWarning();
      _loadFallbackProgress();
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
    var persisted = false;
    if (hiveGameBox != null) {
      final bool storedStars = hiveGameBox.setStageStar(stageId, stars);
      final bool storedCleared =
          stars > 0 ? hiveGameBox.setClearedStage(stageId) : true;
      persisted = storedStars && storedCleared;
      if (!persisted) {
        _recordPersistenceFailure(
          'Failed to persist stage progress for $stageId',
          StackTrace.current,
        );
      }
    }
    if (!persisted) {
      _persistStageFallback(stageId, stars);
    }

    final int current = stageStars[stageId] ?? 0;
    if (stars > current) {
      stageStars[stageId] = stars;
    }
    if (stars > 0 && stageId > clearedStage.value) {
      clearedStage.value = stageId;
    }
  }

  void _applyWarning(String? message, {bool markWarningShown = false}) {
    persistenceWarning.value = message;
    _hasShownWarning = markWarningShown ? true : message != null;
  }

  void _scheduleWarningUpdate(String? message,
      {bool markWarningShown = false}) {
    final binding = WidgetsBinding.instance;
    final shouldDefer = binding.schedulerPhase != SchedulerPhase.idle &&
        binding.schedulerPhase != SchedulerPhase.postFrameCallbacks;
    if (shouldDefer) {
      Future.microtask(
        () => _applyWarning(message, markWarningShown: markWarningShown),
      );
    } else {
      _applyWarning(message, markWarningShown: markWarningShown);
    }
  }
}
