import 'dart:ui';

import 'package:overlap/enums/board_cell_state.dart';

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
  final List<BoardCellState> board;
  final List<BlockState> blocks;

  GameState({
    required List<BoardCellState> board,
    required List<BlockState> blocks,
  })  : board = List<BoardCellState>.from(board),
        blocks = blocks.map((block) => block.copyWith()).toList();
}
