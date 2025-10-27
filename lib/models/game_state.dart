import 'dart:ui';

import 'package:overlap/enum/bord_enum.dart';

class BlockState {
  final String name;
  final List<Offset> offsets;

  BlockState({
    required this.name,
    required List<Offset> offsets,
  }) : offsets = List<Offset>.from(offsets);

  BlockState copyWith({String? name, List<Offset>? offsets}) {
    return BlockState(
      name: name ?? this.name,
      offsets: offsets ?? this.offsets,
    );
  }
}

class GameState {
  final List<Cellstate> board;
  final List<BlockState> blocks;

  GameState({
    required List<Cellstate> board,
    required List<BlockState> blocks,
  })  : board = List<Cellstate>.from(board),
        blocks = blocks.map((block) => block.copyWith()).toList();
}
