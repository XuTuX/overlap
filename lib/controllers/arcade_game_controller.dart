import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/arcade_controller.dart';
import 'package:overlap/enums/board_cell_state.dart';
import 'package:overlap/models/game_state.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeGameController extends GetxController {
  final RxList<BoardCellState> boardList = RxList.generate(
    GameConfig.columns * GameConfig.rows,
    (_) => BoardCellState.empty,
  );
  final RxList<BoardCellState> solveList = RxList.generate(
    GameConfig.columns * GameConfig.rows,
    (_) => BoardCellState.empty,
  );

  final RxList<BlockState> availableBlocks = <BlockState>[].obs;

  final List<GameState> undoStack = [];

  final RxBool glowBoard = false.obs;
  final RxBool shakeBoard = false.obs;

  final GlobalKey gridKey = GlobalKey();

  final Rx<StageData?> currentStage = Rx<StageData?>(null);
  final RxInt currentMoves = 0.obs;
  final RxBool isStageCleared = false.obs;

  int calculateStars(int moves, int target) {
    if (moves <= target) {
      return 3;
    }
    if (moves <= target * 2) {
      return 2;
    }
    return 1;
  }

  @override
  void onInit() {
    super.onInit();
    _clearSolveBoard();
  }

  void _clearSolveBoard() {
    for (int i = 0; i < solveList.length; i++) {
      solveList[i] = BoardCellState.empty;
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
    for (final name in stage.blockNames.toSet()) {
      final shape = GameConfig.blockShapes[name];
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
    return row >= 0 &&
        row < GameConfig.rows &&
        col >= 0 &&
        col < GameConfig.columns;
  }

  void _toggleCell(RxList<BoardCellState> target, int col, int row) {
    if (!_isWithinBoard(col, row)) {
      return;
    }
    final index = row * GameConfig.columns + col;
    target[index] = target[index] == BoardCellState.empty
        ? BoardCellState.occupied
        : BoardCellState.empty;
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
    final boardCopy = List<BoardCellState>.from(boardList);
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
      boardList[i] = BoardCellState.empty;
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
      double x = offset.dx - GameConfig.blockPivot;
      double y = offset.dy - GameConfig.blockPivot;

      double rotatedX = -y;
      double rotatedY = x;

      rotatedBlock.add(
        Offset(
          rotatedX + GameConfig.blockPivot,
          rotatedY + GameConfig.blockPivot,
        ),
      );
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
    currentMoves.value += 1;

    if (isSolutionMatched()) {
      _handleStageCleared();
    }
  }

  void restartStage() {
    final stage = currentStage.value;
    if (stage == null) return;
    loadStage(stage);
  }

  void _handleStageCleared() async {
    if (isStageCleared.value) return;

    triggerBoardGlow();

    final stage = currentStage.value;
    if (stage != null) {
      final int moves = currentMoves.value;
      final int stars = calculateStars(moves, stage.minMoves);
      final ArcadeController arcadeController = Get.find<ArcadeController>();
      arcadeController.recordStageProgress(stageId: stage.id, stars: stars);
    }

    await Future.delayed(const Duration(milliseconds: 700));
    isStageCleared.value = true;
  }
}
