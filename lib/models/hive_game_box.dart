import 'package:hive/hive.dart';

class HiveGameBox {
  final Box _box = Hive.box('gameBox');

  // 튜토리얼 완료 여부 저장
  void setTutorialCompleted(bool value) => _box.put('tutorialCompleted', value);

  double getHighScore() {
    return _box.get('Score', defaultValue: 0.0) as double;
  }

  void setHighScore(double newScore) {
    double currentHighScore = getHighScore();
    if (newScore > currentHighScore) {
      _box.put('Score', newScore);
    }
  }

  Map<int, int> getStageStars() {
    final raw = _box.get('stageStars');
    if (raw is Map) {
      return raw.map((key, value) {
        final intKey = int.parse(key.toString());
        final intValue = (value as num).toInt();
        return MapEntry(intKey, intValue);
      });
    }
    return {};
  }

  int getStageStar(int stageId) {
    return getStageStars()[stageId] ?? 0;
  }

  void setStageStar(int stageId, int stars) {
    final Map<int, int> current = getStageStars();
    final int existing = current[stageId] ?? 0;
    if (stars <= existing) {
      return;
    }
    current[stageId] = stars;
    final stored = current.map((key, value) => MapEntry(key.toString(), value));
    _box.put('stageStars', stored);
  }

  int getClearedStage() {
    return _box.get('clearedStage', defaultValue: 0) as int;
  }

  void setClearedStage(int stageId) {
    final current = getClearedStage();
    if (stageId > current) {
      _box.put('clearedStage', stageId);
    }
  }

  // 튜토리얼 완료 여부 불러오기 (기본값 false)
  bool isTutorialCompleted() =>
      _box.get('tutorialCompleted', defaultValue: false);
}
