import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:overlap/controllers/arcade_controller.dart';
import 'package:overlap/controllers/game_controller.dart';
import 'package:overlap/controllers/timer_controller.dart';

class _StubTimerController extends TimerController {
  @override
  void resetTimer() {}

  @override
  void startTimer() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('ArcadeController persistence fallback', () {
    test('uses in-memory fallback when Hive is unavailable', () async {
      final controller = ArcadeController(hiveGameBox: null);

      controller.onInit();

      expect(controller.usingFallbackStorage.value, isTrue);
      expect(controller.stageStars.isEmpty, isTrue);

      controller.recordStageProgress(stageId: 1, stars: 3);

      await Future.microtask(() {});

      expect(controller.stageStars[1], 3);
      expect(controller.clearedStage.value, 1);
      expect(controller.persistenceWarning.value, isNotNull);
    });
  });

  group('GameController high score fallback', () {
    test('stores best score when persistence layer is unavailable', () async {
      final controller = GameController(
        hiveGameBox: null,
        timerController: _StubTimerController(),
      );

      controller.onInit();
      controller.score.value = 12.5;

      controller.gameover();

      await Future.microtask(() {});

      expect(controller.bestScore.value, closeTo(12.5, 0.001));
      expect(controller.persistenceWarning.value, isNotNull);
    });
  });
}
