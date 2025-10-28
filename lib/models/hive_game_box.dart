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
