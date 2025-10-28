import 'dart:math';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/controller/timer_controller.dart';
import 'package:overlap/enum/bord_enum.dart';
import 'package:overlap/models/game_state.dart';
import 'package:overlap/models/hive_game_box.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameController extends GetxController {
  final TimerController timerController = Get.put(TimerController());
  final HiveGameBox hiveGameBox = HiveGameBox();
  final Random _random = Random();

  final RxList<Cellstate> boardList =
      RxList.generate(COL * ROW, (_) => Cellstate.empty);
  final RxList<Cellstate> solveList =
      RxList.generate(COL * ROW, (_) => Cellstate.empty);

  final RxList<BlockState> availableBlocks = <BlockState>[].obs;

  final List<GameState> undoStack = [];
  final RxBool glowBoard = false.obs;

  final GlobalKey gridKey = GlobalKey();
  final RxInt stage = 1.obs;

  final RxDouble score = 0.0.obs;

  final RxBool isGameOver = false.obs;

  final RxBool isCountdownDone = false.obs;

  final RxBool shakeBoard = false.obs;

  @override
  void onInit() {
    super.onInit();
    applyNextBlockOverlay();
  }

  void startCountdown() async {
    await Future.delayed(Duration(seconds: DURATION));
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
        _random.nextInt(COL - 2) + 1.0, // 블록 크기에 따라 조정
        _random.nextInt(ROW - 2) + 1.0,
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

  void toggleBlockOnSolve(List<Offset> block, int col, int row) {
    for (var offset in block) {
      final targetCol = col + (offset.dx - CENTER_POINT).toInt();
      final targetRow = row + (offset.dy - CENTER_POINT).toInt();
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
    if (isGameOver.value) return; // 게임 오버면 아무것도 하지 않음
    double newScore = score.value + timerController.remainingTime.value;
    score.value = double.parse(newScore.toStringAsFixed(1));
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
    if (isGameOver.value) return; // 게임 오버면 아무것도 하지 않음{

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
      boardList[i] = Cellstate.empty;
    }
    boardList.refresh();
  }

  void generateBlock() {
    if (isGameOver.value) return; // 게임 오버면 아무것도 하지 않음

    availableBlocks.clear();

    final allBlockNames = blockShapes.keys.toList()..shuffle(_random);
    final count = min(BLOCK_LIST_COUNTS, allBlockNames.length);
    for (var i = 0; i < count; i++) {
      final blockName = allBlockNames[i];
      final offsets = blockShapes[blockName]!;
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
    if (isGameOver.value) return; // 게임 오버면 아무것도 하지 않음
    final block = availableBlocks[index];
    final rotatedBlock = <Offset>[];

    // 회전 연산 수행
    for (final offset in block.offsets) {
      double x = offset.dx - CENTER_POINT;
      double y = offset.dy - CENTER_POINT;

      double rotatedX = -y;
      double rotatedY = x;

      rotatedBlock
          .add(Offset(rotatedX + CENTER_POINT, rotatedY + CENTER_POINT));
    }

    // rotatedBlock 내의 y 좌표의 최솟값 구하기
    final minY = rotatedBlock.map((o) => o.dy).reduce(min);
    final minX = rotatedBlock.map((o) => o.dx).reduce(min);

    // 모든 Offset의 y값에서 minY를 빼서 최소 y가 0이 되도록 조정
    final normalizedBlock =
        rotatedBlock.map((o) => Offset(o.dx - minX, o.dy - minY)).toList();

    availableBlocks[index] = block.copyWith(offsets: normalizedBlock);
    availableBlocks.refresh(); // GetX 상태 업데이트
  }

  void resetGame() {
    // 7) 게임 오버 상태 초기화
    isGameOver.value = false;
    isCountdownDone.value = false;
    // 1) 보드 초기화
    resetBoard();
    undoStack.clear();
    stage.value = 1;

    // 2) 점수 초기화
    score.value = 0.0;
    // 3) 타이머 초기화
    timerController.resetTimer();

    // 4) 스테이지 설정
    applyNextBlockOverlay();

    startCountdown();
  }

  void gameover() {
    isGameOver.value = true;
    hiveGameBox.setHighScore(score.value); // 최고 점수 저장
  }

  void insert(BlockState block, int col, int row) {
    if (isGameOver.value) return; // 게임 오버면 아무것도 하지 않음

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
        timerController.startTimer(); // 타이머 재시작!
      } else {
        // 틀렸을 경우, 다른 처리
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
