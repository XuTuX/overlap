import 'dart:ui';

import 'package:overlap/enum/bord_enum.dart';

class GameState {
  final List<Cellstate> board;
  final List<List<Offset>> blockList;
  final List<String> blockNames;

  GameState({
    required this.board,
    required this.blockList,
    required this.blockNames,
  });
}
