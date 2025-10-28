import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/enum/bord_enum.dart';
import 'package:overlap/models/game_state.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeGameController extends GetxController {
  final HiveGameBox hiveGameBox = HiveGameBox();

  final RxList<Cellstate> boardList =
      RxList.generate(COL * ROW, (_) => Cellstate.empty);
  final RxList<Cellstate> solveList =
      RxList.generate(COL * ROW, (_) => Cellstate.empty);

  final RxList<BlockState> availableBlocks = <BlockState>[].obs;

  final List<GameState> undoStack = [];

  final RxBool glowBoard = false.obs;
  final RxBool shakeBoard = false.obs;

  final GlobalKey gridKey = GlobalKey();

  final Rx<StageData?> currentStage = Rx<StageData?>(null);
  final RxInt currentMoves = 0.obs;
  final RxBool isStageCleared = false.obs;

  @override
  void onInit() {
    super.onInit();
    _clearSolveBoard();
  }

  void _clearSolveBoard() {
    for (int i = 0; i < solveList.length; i++) {
      solveList[i] = Cellstate.empty;
    }
    solveList.refresh();
  }

  void loadStage(StageData stage) {
    currentStage.value = stage;
    currentMoves.value = 0;
    isStageCleared.value = false;
    glowBoard.value = false;
    shakeBoard.value = false;

    resetBoard();
    undoStack.clear();

    final cells = patternToCells(stage.solutionPattern);
    for (int i = 0; i < solveList.length; i++) {
      solveList[i] = cells[i];
    }
    solveList.refresh();

    final blocks = <BlockState>[];
    for (final name in stage.blockNames) {
      final shape = blockShapes[name];
      if (shape == null) {
        debugPrint('Unknown block name: $name');
        continue;
      }
      blocks.add(BlockState(name: name, offsets: shape));
    }
    availableBlocks.assignAll(blocks);
  }

  void triggerBoardGlow() {
    glowBoard.value = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      glowBoard.value = false;
    });
  }

  void triggerBoardShake() {
    shakeBoard.value = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      shakeBoard.value = false;
    });
  }

  bool _isWithinBoard(int col, int row) {
    return row >= 0 && row < ROW && col >= 0 && col < COL;
  }

  void _toggleCell(RxList<Cellstate> target, int col, int row) {
    if (!_isWithinBoard(col, row)) {
      return;
    }
    final index = row * COL + col;
    target[index] =
        target[index] == Cellstate.empty ? Cellstate.occupied : Cellstate.empty;
  }

  bool isSolutionMatched() {
    for (int i = 0; i < solveList.length; i++) {
      if (boardList[i] != solveList[i]) {
        return false;
      }
    }
    return true;
  }

  void saveState() {
    final boardCopy = List<Cellstate>.from(boardList);
    final blocksCopy =
        availableBlocks.map((block) => block.copyWith()).toList();

    undoStack.add(GameState(
      board: boardCopy,
      blocks: blocksCopy,
    ));
  }

  void undo() {
    if (undoStack.isEmpty || isStageCleared.value) {
      return;
    }

    final previousState = undoStack.removeLast();

    for (int i = 0; i < boardList.length; i++) {
      boardList[i] = previousState.board[i];
    }
    boardList.refresh();

    availableBlocks.assignAll(
      previousState.blocks.map((block) => block.copyWith()).toList(),
    );

    if (currentMoves.value > 0) {
      currentMoves.value -= 1;
    }
  }

  void resetBoard() {
    for (int i = 0; i < boardList.length; i++) {
      boardList[i] = Cellstate.empty;
    }
    boardList.refresh();
  }

  bool canPlace(BlockState block, int col, int row) {
    for (final offset in block.offsets) {
      final newcol = col + offset.dx.toInt();
      final newrow = row + offset.dy.toInt();

      if (!_isWithinBoard(newcol, newrow)) {
        return false;
      }
    }
    return true;
  }

  void rotateBlock(int index) {
    if (index < 0 || index >= availableBlocks.length) {
      return;
    }
    final block = availableBlocks[index];
    final rotatedBlock = <Offset>[];

    for (final offset in block.offsets) {
      double x = offset.dx - CENTER_POINT;
      double y = offset.dy - CENTER_POINT;

      double rotatedX = -y;
      double rotatedY = x;

      rotatedBlock
          .add(Offset(rotatedX + CENTER_POINT, rotatedY + CENTER_POINT));
    }

    final minY = rotatedBlock.map((o) => o.dy).reduce(min);
    final minX = rotatedBlock.map((o) => o.dx).reduce(min);

    final normalizedBlock =
        rotatedBlock.map((o) => Offset(o.dx - minX, o.dy - minY)).toList();

    availableBlocks[index] = block.copyWith(offsets: normalizedBlock);
    availableBlocks.refresh();
  }

  void insert(BlockState block, int col, int row) {
    if (isStageCleared.value) return;
    if (!canPlace(block, col, row)) return;

    saveState();

    for (final offset in block.offsets) {
      final newcol = col + offset.dx.toInt();
      final newrow = row + offset.dy.toInt();
      _toggleCell(boardList, newcol, newrow);
    }
    boardList.refresh();
    availableBlocks.remove(block);
    currentMoves.value += 1;

    if (availableBlocks.isEmpty) {
      if (isSolutionMatched()) {
        _handleStageCleared();
      } else {
        triggerBoardShake();
        Future.delayed(const Duration(milliseconds: 200), () {
          undo();
        });
      }
    }
  }

  void restartStage() {
    final stage = currentStage.value;
    if (stage == null) return;
    loadStage(stage);
  }

  void _handleStageCleared() {
    triggerBoardGlow();
    isStageCleared.value = true;
    final stage = currentStage.value;
    if (stage != null) {
      hiveGameBox.setClearedStage(stage.id);
    }
  }
}
