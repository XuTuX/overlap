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

  // 튜토리얼 완료 여부 불러오기 (기본값 false)
  bool isTutorialCompleted() =>
      _box.get('tutorialCompleted', defaultValue: false);
}
