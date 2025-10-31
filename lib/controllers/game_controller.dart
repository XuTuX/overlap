import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:overlap/controllers/timer_controller.dart';
import 'package:overlap/enums/board_cell_state.dart';
import 'package:overlap/models/game_state.dart';
import 'package:overlap/models/hive_game_box.dart';

class GameController extends GetxController {
  GameController({HiveGameBox? hiveGameBox, TimerController? timerController})
      : timerController = timerController ?? Get.put(TimerController()) {
    _assignHiveBox(hiveGameBox);
  }

  final TimerController timerController;
  HiveGameBox? _hiveGameBox;
  final Random _random = Random();
  final RxDouble bestScore = 0.0.obs;
  final RxnString persistenceWarning = RxnString();
  double _fallbackHighScore = 0.0;
  bool _hasShownWarning = false;

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

  final GlobalKey gridKey = GlobalKey();
  final RxInt stage = 1.obs;

  final RxDouble score = 0.0.obs;

  final RxBool isGameOver = false.obs;

  final RxBool isCountdownDone = false.obs;

  final RxBool shakeBoard = false.obs;

  void _assignHiveBox(HiveGameBox? hiveGameBox) {
    _hiveGameBox =
        hiveGameBox ?? HiveGameBox.tryOpen(onError: _recordPersistenceFailure);
    if (_hiveGameBox == null) {
      _ensureWarning();
    } else {
      _scheduleWarningUpdate(null);
    }
  }

  void _recordPersistenceFailure(Object error, StackTrace stackTrace) {
    debugPrint('GameController storage error: $error');
    debugPrintStack(stackTrace: stackTrace);
    _hiveGameBox = null;
    _ensureWarning();
  }

  void _ensureWarning() {
    if (_hasShownWarning) return;
    _hasShownWarning = true;
    _scheduleWarningUpdate(
      '하이스코어를 저장할 수 없습니다. 저장소 권한이나 공간을 확인한 뒤 다시 시도해주세요.',
      markWarningShown: true,
    );
  }

  void _applyWarning(String? message, {bool markWarningShown = false}) {
    persistenceWarning.value = message;
    _hasShownWarning = markWarningShown ? true : message != null;
  }

  void _scheduleWarningUpdate(String? message,
      {bool markWarningShown = false}) {
    void apply() => _applyWarning(message, markWarningShown: markWarningShown);
    final binding = SchedulerBinding.instance;

    binding.addPostFrameCallback((_) => apply());
  }

  void _updateBestScore(double newHighScore) {
    if (newHighScore <= bestScore.value) {
      return;
    }
    final binding = SchedulerBinding.instance;

    binding.addPostFrameCallback((_) {
      if (newHighScore > bestScore.value) {
        bestScore.value = newHighScore;
      }
    });
  }

  double _readHighScore() {
    final hiveGameBox = _hiveGameBox;
    if (hiveGameBox != null) {
      return hiveGameBox.getHighScore();
    }
    return _fallbackHighScore;
  }

  void retryStorage() {
    _assignHiveBox(null);
    bestScore.value = _readHighScore();
  }

  @override
  void onInit() {
    super.onInit();
    applyNextBlockOverlay();
    bestScore.value = _readHighScore();
  }

  void startCountdown() async {
    await Future.delayed(GameConfig.countdownDelay);
    isCountdownDone.value = true;
  }

  void triggerBoardGlow() {
    glowBoard.value = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      glowBoard.value = false;
    });
  }

  void generatePuzzle() {
    _generateRandomPuzzle();
  }

  void _generateRandomPuzzle() {
    final selectedBlocks =
        availableBlocks.map((block) => block.copyWith()).toList();

    for (final block in selectedBlocks) {
      final startPosition = Offset(
        _random.nextInt(GameConfig.columns - 2) + 1.0,
        _random.nextInt(GameConfig.rows - 2) + 1.0,
      );

      final rotatedBlock = randomRotateBlock(block.offsets);

      toggleBlockOnSolve(
        rotatedBlock,
        startPosition.dx.toInt(),
        startPosition.dy.toInt(),
      );
    }
    update();
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

  void toggleBlockOnSolve(List<Offset> block, int col, int row) {
    for (var offset in block) {
      final targetCol = col + (offset.dx - GameConfig.blockPivot).toInt();
      final targetRow = row + (offset.dy - GameConfig.blockPivot).toInt();
      _toggleCell(solveList, targetCol, targetRow);
    }
    update();
  }

  bool isSolutionMatched() {
    for (int i = 0; i < solveList.length; i++) {
      if (boardList[i] != solveList[i]) {
        return false;
      }
    }
    return true;
  }

  void checkAndApplyNextBlock() {
    if (isSolutionMatched()) {
      undoStack.clear();
      availableBlocks.clear();
      applyNextBlockOverlay();
    }
  }

  void applyNextBlockOverlay() {
    availableBlocks.clear();
    generateBlock();
    generatePuzzle();
  }

  List<Offset> randomRotateBlock(List<Offset> block) {
    final angle = [0, 90, 180, 270][_random.nextInt(4)];
    if (angle == 0) return block;

    List<Offset> rotatedBlock = [];
    double centerX = 1;
    double centerY = 1;

    for (Offset offset in block) {
      double x = offset.dx - centerX;
      double y = offset.dy - centerY;
      switch (angle) {
        case 90:
          rotatedBlock.add(Offset(centerX - y, centerY + x));
          break;
        case 180:
          rotatedBlock.add(Offset(centerX - x, centerY - y));
          break;
        case 270:
          rotatedBlock.add(Offset(centerX + y, centerY - x));
          break;
      }
    }
    return rotatedBlock;
  }

  void savescore() {
    if (isGameOver.value) return;
    double newScore = score.value + timerController.remainingTime.value;
    score.value = double.parse(newScore.toStringAsFixed(1));
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
    if (isGameOver.value) return;

    if (undoStack.isEmpty) {
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
  }

  void resetBoard() {
    for (int i = 0; i < boardList.length; i++) {
      boardList[i] = BoardCellState.empty;
    }
    boardList.refresh();
  }

  void generateBlock() {
    if (isGameOver.value) return;

    availableBlocks.clear();

    final allBlockNames = GameConfig.blockShapes.keys.toList()
      ..shuffle(_random);
    final count = min(GameConfig.availableBlockCount, allBlockNames.length);
    for (var i = 0; i < count; i++) {
      final blockName = allBlockNames[i];
      final offsets = GameConfig.blockShapes[blockName]!;
      availableBlocks.add(BlockState(name: blockName, offsets: offsets));
    }
  }

  void insertAfterRemove(BlockState block, int col, int row) {
    saveState();
    for (final offset in block.offsets) {
      final newcol = col + (offset.dx).toInt();
      final newrow = row + (offset.dy).toInt();

      _toggleCell(boardList, newcol, newrow);
    }
    availableBlocks.remove(block);
  }

  bool canPlace(BlockState block, int col, int row) {
    for (final offset in block.offsets) {
      final newcol = col + (offset.dx).toInt();
      final newrow = row + (offset.dy).toInt();

      if (!_isWithinBoard(newcol, newrow)) {
        return false;
      }
    }
    return true;
  }

  void rotateBlock(int index) {
    if (isGameOver.value) return;
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

  void resetGame() {
    isGameOver.value = false;
    isCountdownDone.value = false;
    resetBoard();
    // solveList도 비워주기
    for (int i = 0; i < solveList.length; i++) {
      solveList[i] = BoardCellState.empty;
    }
    solveList.refresh();

    undoStack.clear();
    stage.value = 1;
    score.value = 0.0;
    timerController.resetTimer();
    applyNextBlockOverlay();
    startCountdown();
  }

  void gameover() {
    isGameOver.value = true;
    final newHighScore = score.value;
    final currentBest = _readHighScore();
    final hiveGameBox = _hiveGameBox;
    final isNewPersonalBest = newHighScore > currentBest;

    if (hiveGameBox != null && isNewPersonalBest) {
      final stored = hiveGameBox.setHighScore(newHighScore);
      if (!stored) {
        _recordPersistenceFailure(
          'Failed to persist high score',
          StackTrace.current,
        );
      }
    }
    _fallbackHighScore = max(_fallbackHighScore, newHighScore);
    _updateBestScore(newHighScore);
  }

  void insert(BlockState block, int col, int row) {
    if (isGameOver.value) return;

    if (!canPlace(block, col, row)) return;

    insertAfterRemove(block, col, row);

    if (availableBlocks.isEmpty) {
      final isMatched = isSolutionMatched();

      if (isMatched) {
        triggerBoardGlow();
        savescore();
        timerController.reduceTime();
        stage.value += 1;

        undoStack.clear();
        applyNextBlockOverlay();
        timerController.startTimer();
      } else {
        debugPrint("모든 블록을 놓았지만 정답이 아닙니다.");
        triggerBoardShake();
        Future.delayed(const Duration(milliseconds: 200), () {
          undo();
        });
      }
    }
  }

  void triggerBoardShake() {
    shakeBoard.value = true;

    Future.delayed(const Duration(milliseconds: 500), () {
      shakeBoard.value = false;
    });
  }
}
