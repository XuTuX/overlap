import 'dart:math';
import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/constants/level_data.dart';
import 'package:overlap/controller/timer_controller.dart';
import 'package:overlap/enum/bord_enum.dart';
import 'package:overlap/models/game_state.dart';
import 'package:overlap/models/hive_game_box.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameController extends GetxController {
  final TimerController timerController = Get.put(TimerController());
  final HiveGameBox hiveGameBox = HiveGameBox();

  final RxList<Cellstate> boardList =
      RxList.generate(COL * ROW, (_) => Cellstate.empty);
  RxList<Cellstate> solveList =
      RxList.generate(COL * ROW, (_) => Cellstate.empty);

  RxList<List<Offset>> blockList = <List<Offset>>[].obs;
  RxList<String> blocknames = <String>[].obs; // .obs를 사용해 RxList로 선언

  final List<GameState> undoStack = [];
  RxBool glowBoard = false.obs;

  GlobalKey gridkey = GlobalKey();
  RxInt stage = 1.obs;
  RxDouble score = 0.0.obs;

  RxBool isGameOver = false.obs;

  RxBool isCountdownDone = false.obs;

  LevelData? get _currentLevelConfig {
    final index = stage.value - 1;
    if (index < 0 || index >= kLevelData.length) {
      return null;
    }
    return kLevelData[index];
  }

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
    Future.delayed(Duration(milliseconds: 500), () {
      glowBoard.value = false;
    });
  }

  void generatePuzzle() {
    solveList.fillRange(0, solveList.length, Cellstate.empty);

    final level = _currentLevelConfig;
    if (level != null) {
      for (int row = 0; row < level.map.length; row++) {
        final rowLayout = level.map[row];
        for (int col = 0; col < rowLayout.length; col++) {
          final cell = rowLayout[col];
          if (cell != '.' && cell != '0') {
            final index = row * COL + col;
            solveList[index] = Cellstate.occupied;
          }
        }
      }
      update();
      return;
    }

    _generateRandomPuzzle();
  }

  void _generateRandomPuzzle() {
    List<List<Offset>> selectedBlocks =
        blockList.map((block) => List<Offset>.from(block)).toList();

    for (List<Offset> block in selectedBlocks) {
      Offset startPosition = Offset(
        Random().nextInt(COL - 2) + 1.toDouble(), // 블록 크기에 따라 조정
        Random().nextInt(ROW - 2) + 1.toDouble(),
      );

      List<Offset> rotatedBlock = randomRotateBlock(block);

      toggleBlockOnSolve(
        rotatedBlock,
        startPosition.dx.toInt(),
        startPosition.dy.toInt(),
      );
    }
    update();
  }

  void toggleBlockOnSolve(List<Offset> block, int col, int row) {
    for (var offset in block) {
      int newcol = col + (offset.dx - CENTER_POINT).toInt();
      int newrow = row + (offset.dy - CENTER_POINT).toInt();

      int index = newrow * COL + newcol;

      solveList[index] = solveList[index] == Cellstate.empty
          ? Cellstate.occupied
          : Cellstate.empty;
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
      blockList.clear();
      applyNextBlockOverlay();
    }
  }

  void applyNextBlockOverlay() {
    blockList.clear();
    blocknames.clear();
    generateBlock();
    generatePuzzle();
  }

  List<Offset> randomRotateBlock(List<Offset> block) {
    int angle = [0, 90, 180, 270][Random().nextInt(4)];
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
    List<Cellstate> boardCopy = List<Cellstate>.from(boardList);

    List<List<Offset>> blockListCopy =
        blockList.map((block) => List<Offset>.from(block)).toList();

    List<String> blockNamesCopy = List<String>.from(blocknames);

    undoStack.add(GameState(
      board: boardCopy,
      blockList: blockListCopy,
      blockNames: blockNamesCopy,
    ));
  }

  void undo() {
    if (isGameOver.value) return; // 게임 오버면 아무것도 하지 않음{

    if (undoStack.isEmpty) {
      return;
    }

    GameState previousState = undoStack.removeLast();

    for (int i = 0; i < boardList.length; i++) {
      boardList[i] = previousState.board[i];
    }
    boardList.refresh();

    blockList.clear();
    for (final block in previousState.blockList) {
      blockList.add(List<Offset>.from(block));
    }
    blockList.refresh();

    blocknames.assignAll(previousState.blockNames);
  }

  void resetBoard() {
    for (int i = 0; i < boardList.length; i++) {
      boardList[i] = Cellstate.empty;
    }
    boardList.refresh();
  }

  void generateBlock() {
    if (isGameOver.value) return; // 게임 오버면 아무것도 하지 않음

    blocknames.clear();
    blockList.clear();
    final level = _currentLevelConfig;
    if (level != null) {
      for (final blockKey in level.blockKeys) {
        final blockShape = blockShapes[blockKey];
        if (blockShape == null) continue;
        blocknames.add(blockKey);
        blockList.add(List<Offset>.from(blockShape));
      }
      return;
    }

    final random = Random();

    List<String> allBlockNames = blockShapes.keys.toList();
    allBlockNames.shuffle(random);

    final count = min(BLOCK_LIST_COUNTS, allBlockNames.length);
    for (int i = 0; i < count; i++) {
      String blockName = allBlockNames[i];
      blocknames.add(blockName);
      blockList.add(List<Offset>.from(blockShapes[blockName]!));
    }
  }

  void insertAfterRemove(List<Offset> block, int col, int row) {
    saveState();
    for (var offset in block) {
      final newcol = col + (offset.dx).toInt();
      final newrow = row + (offset.dy).toInt();

      int index = newrow * COL + newcol;

      boardList[index] = boardList[index] == Cellstate.empty
          ? Cellstate.occupied
          : Cellstate.empty;
    }
    blockList.remove(block);
  }

  bool canplace(List<Offset> block, int col, int row) {
    for (var offset in block) {
      final newcol = col + (offset.dx).toInt();
      final newrow = row + (offset.dy).toInt();

      if (newrow < 0 || newrow >= ROW || newcol < 0 || newcol >= COL) {
        return false;
      }
    }
    return true;
  }

  void rotateBlock(int index) {
    if (isGameOver.value) return; // 게임 오버면 아무것도 하지 않음
    List<Offset> originalBlock = blockList[index];
    List<Offset> rotatedBlock = [];

    // 회전 연산 수행
    for (var offset in originalBlock) {
      double x = offset.dx - CENTER_POINT;
      double y = offset.dy - CENTER_POINT;

      double rotatedX = -y;
      double rotatedY = x;

      rotatedBlock
          .add(Offset(rotatedX + CENTER_POINT, rotatedY + CENTER_POINT));
    }

    // rotatedBlock 내의 y 좌표의 최솟값 구하기
    double minY = rotatedBlock.map((o) => o.dy).reduce(min);
    double minX = rotatedBlock.map((o) => o.dx).reduce(min);

    // 모든 Offset의 y값에서 minY를 빼서 최소 y가 0이 되도록 조정
    rotatedBlock =
        rotatedBlock.map((o) => Offset(o.dx - minX, o.dy - minY)).toList();

    blockList[index] = rotatedBlock;
    blockList.refresh(); // GetX 상태 업데이트
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

// GameController 안

  void insert(List<Offset> block, int col, int row) {
    if (isGameOver.value) return; // 게임 오버면 아무것도 하지 않음

    if (!canplace(block, col, row)) return;

    insertAfterRemove(block, col, row);

    if (blockList.isEmpty) {
      bool isMatched = isSolutionMatched();

      if (isMatched) {
        triggerBoardGlow();
        savescore();
        timerController.reduceTime();
        stage.value += 1;
        resetBoard();
        undoStack.clear();
        applyNextBlockOverlay();
        timerController.startTimer(); // 타이머 재시작!
      } else {
        // 틀렸을 경우, 다른 처리
        print("모든 블록을 놓았지만 정답이 아닙니다.");
        triggerBoardShake();
        Future.delayed(Duration(milliseconds: 200), () {
          undo();
        });
      }
    }
  }

  RxBool shakeBoard = false.obs;

  void triggerBoardShake() {
    shakeBoard.value = true;

    Future.delayed(Duration(milliseconds: 500), () {
      shakeBoard.value = false;
    });
  }
}
