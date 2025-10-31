import 'package:flutter/widgets.dart';
import 'package:overlap/constants/game_constants.dart';

class GameLayoutScope extends InheritedWidget {
  const GameLayoutScope({
    super.key,
    required this.metrics,
    required super.child,
  });

  final GameLayoutMetrics metrics;

  static GameLayoutMetrics of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<GameLayoutScope>();
    if (scope != null) {
      return scope.metrics;
    }
    return GameConfig.layoutOf(context);
  }

  static GameLayoutMetrics? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GameLayoutScope>()
        ?.metrics;
  }

  @override
  bool updateShouldNotify(GameLayoutScope oldWidget) {
    return oldWidget.metrics != metrics;
  }
}
