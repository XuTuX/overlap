import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class HiveGameBox {
  HiveGameBox._(this._box);

  factory HiveGameBox() => HiveGameBox._(Hive.box('gameBox'));

  static HiveGameBox? tryOpen({
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    try {
      return HiveGameBox._(Hive.box('gameBox'));
    } catch (error, stackTrace) {
      debugPrint('HiveGameBox.tryOpen failed: $error');
      onError?.call(error, stackTrace);
      return null;
    }
  }

  final Box _box;

  bool setTutorialCompleted(bool value) =>
      _writeSafely(() => _box.put('tutorialCompleted', value));

  double getHighScore() => _readSafely<double>(
      () => (_box.get('Score', defaultValue: 0.0) as num).toDouble(), 0.0);

  bool setHighScore(double newScore) {
    final currentHighScore = getHighScore();
    if (newScore <= currentHighScore) {
      return false;
    }
    return _writeSafely(() => _box.put('Score', newScore));
  }

  Map<int, int> getStageStars() => _readSafely<Map<int, int>>(() {
        final raw = _box.get('stageStars');
        if (raw is Map) {
          return raw.map((key, value) {
            final intKey = int.parse(key.toString());
            final intValue = (value as num).toInt();
            return MapEntry(intKey, intValue);
          });
        }
        return <int, int>{};
      }, const <int, int>{});

  int getStageStar(int stageId) => getStageStars()[stageId] ?? 0;

  bool setStageStar(int stageId, int stars) {
    final Map<int, int> current = getStageStars();
    final int existing = current[stageId] ?? 0;
    if (stars <= existing) {
      return false;
    }
    current[stageId] = stars;
    final stored = current.map((key, value) => MapEntry(key.toString(), value));
    return _writeSafely(() => _box.put('stageStars', stored));
  }

  int getClearedStage() => _readSafely<int>(
      () => _box.get('clearedStage', defaultValue: 0) as int, 0);

  bool setClearedStage(int stageId) {
    final current = getClearedStage();
    if (stageId <= current) {
      return false;
    }
    return _writeSafely(() => _box.put('clearedStage', stageId));
  }

  bool isTutorialCompleted() => _readSafely<bool>(
        () => _box.get('tutorialCompleted', defaultValue: false) as bool,
        false,
      );

  T _readSafely<T>(T Function() reader, T fallback) {
    try {
      return reader();
    } catch (error, stackTrace) {
      debugPrint('HiveGameBox read failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return fallback;
    }
  }

  bool _writeSafely(FutureOr<void> Function() writer) {
    try {
      final result = writer();
      if (result is Future<void>) {
        unawaited(
          result.catchError(
            (error, stackTrace) {
              debugPrint('HiveGameBox write async failed: $error');
              debugPrintStack(stackTrace: stackTrace as StackTrace?);
            },
          ),
        );
      }
      return true;
    } catch (error, stackTrace) {
      debugPrint('HiveGameBox write failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}
