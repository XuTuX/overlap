import 'package:overlap/enum/bord_enum.dart';

class StageData {
  final int id;
  final String title;
  final int minMoves;
  final List<List<int>> solutionPattern;
  final List<String> blockNames;
  final String? background;

  const StageData({
    required this.id,
    required this.title,
    required this.minMoves,
    required this.solutionPattern,
    required this.blockNames,
    this.background,
  });
}

List<Cellstate> patternToCells(List<List<int>> pattern) {
  final flattened = <Cellstate>[];
  for (final row in pattern) {
    for (final value in row) {
      flattened.add(value == 1 ? Cellstate.occupied : Cellstate.empty);
    }
  }
  return flattened;
}

final List<StageData> arcadeStages = [
  StageData(
    id: 1,
    title: 'Stage 1: Spark',
    minMoves: 3,
    blockNames: ['O', 'T'],
    solutionPattern: [
      [0, 1, 1, 1, 0],
      [0, 1, 1, 1, 0],
      [0, 0, 1, 0, 0],
      [0, 0, 1, 0, 0],
      [0, 0, 0, 0, 0],
    ],
  ),
  StageData(
    id: 2,
    title: 'Stage 2: Bridge',
    minMoves: 4,
    blockNames: ['O', 'S', 'Z', 'T'],
    solutionPattern: [
      [1, 1, 0, 1, 1],
      [1, 1, 0, 1, 1],
      [0, 0, 0, 0, 0],
      [0, 1, 1, 1, 0],
      [0, 0, 1, 0, 0],
    ],
  ),
  StageData(
    id: 3,
    title: 'Stage 3: Arrow',
    minMoves: 4,
    blockNames: ['T', 'L', 'J'],
    solutionPattern: [
      [0, 1, 0, 1, 0],
      [0, 1, 1, 1, 0],
      [1, 1, 1, 1, 1],
      [0, 1, 1, 1, 0],
      [0, 1, 0, 1, 0],
    ],
  ),
  StageData(
    id: 4,
    title: 'Stage 4: Steps',
    minMoves: 5,
    blockNames: ['L', 'J', 'S', 'Z', 'O'],
    solutionPattern: [
      [1, 0, 0, 0, 0],
      [1, 1, 0, 0, 0],
      [0, 1, 1, 0, 0],
      [0, 0, 1, 1, 0],
      [0, 0, 0, 1, 1],
    ],
  ),
  StageData(
    id: 5,
    title: 'Stage 5: Pulse',
    minMoves: 5,
    blockNames: ['T', 'O', 'S', 'Z'],
    solutionPattern: [
      [0, 1, 1, 1, 0],
      [1, 1, 1, 1, 1],
      [0, 1, 1, 1, 0],
      [0, 0, 1, 0, 0],
      [0, 0, 1, 0, 0],
    ],
  ),
  StageData(
    id: 6,
    title: 'Stage 6: Fork',
    minMoves: 5,
    blockNames: ['T', 'L', 'J', 'O'],
    solutionPattern: [
      [0, 1, 0, 1, 0],
      [1, 1, 1, 1, 1],
      [0, 1, 1, 1, 0],
      [0, 1, 0, 1, 0],
      [0, 1, 0, 1, 0],
    ],
  ),
  StageData(
    id: 7,
    title: 'Stage 7: Spiral',
    minMoves: 6,
    blockNames: ['S', 'Z', 'L', 'J', 'T', 'O'],
    solutionPattern: [
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1],
      [1, 0, 0, 0, 0],
    ],
  ),
  StageData(
    id: 8,
    title: 'Stage 8: Shield',
    minMoves: 6,
    blockNames: ['O', 'T', 'J', 'L', 'S', 'Z'],
    solutionPattern: [
      [0, 1, 1, 1, 0],
      [1, 1, 1, 1, 1],
      [1, 1, 0, 1, 1],
      [0, 1, 0, 1, 0],
      [0, 1, 0, 1, 0],
    ],
  ),
  StageData(
    id: 9,
    title: 'Stage 9: Gateway',
    minMoves: 6,
    blockNames: ['L', 'J', 'T', 'O', 'S'],
    solutionPattern: [
      [1, 1, 0, 1, 1],
      [1, 1, 0, 1, 1],
      [1, 1, 0, 1, 1],
      [0, 1, 0, 1, 0],
      [0, 1, 1, 1, 0],
    ],
  ),
  StageData(
    id: 10,
    title: 'Stage 10: Cascade',
    minMoves: 6,
    blockNames: ['L', 'J', 'S', 'Z', 'T', 'O'],
    solutionPattern: [
      [0, 0, 1, 1, 1],
      [0, 1, 1, 1, 0],
      [1, 1, 1, 0, 0],
      [1, 1, 0, 0, 0],
      [1, 0, 0, 0, 0],
    ],
  ),
  StageData(
    id: 11,
    title: 'Stage 11: Twin',
    minMoves: 7,
    blockNames: ['O', 'T', 'S', 'Z', 'L', 'J'],
    solutionPattern: [
      [1, 0, 0, 0, 1],
      [1, 1, 0, 1, 1],
      [1, 1, 1, 1, 1],
      [1, 1, 0, 1, 1],
      [1, 0, 0, 0, 1],
    ],
  ),
  StageData(
    id: 12,
    title: 'Stage 12: Comet',
    minMoves: 7,
    blockNames: ['S', 'Z', 'T', 'L', 'J', 'O'],
    solutionPattern: [
      [0, 0, 1, 0, 0],
      [0, 1, 1, 1, 0],
      [1, 1, 1, 1, 1],
      [0, 1, 1, 1, 0],
      [0, 0, 1, 0, 0],
    ],
  ),
  StageData(
    id: 13,
    title: 'Stage 13: Prism',
    minMoves: 7,
    blockNames: ['T', 'O', 'L', 'J', 'S', 'Z'],
    solutionPattern: [
      [0, 1, 1, 1, 0],
      [1, 1, 0, 1, 1],
      [1, 1, 0, 1, 1],
      [1, 1, 1, 1, 1],
      [0, 1, 0, 1, 0],
    ],
  ),
  StageData(
    id: 14,
    title: 'Stage 14: Labyrinth',
    minMoves: 8,
    blockNames: ['L', 'J', 'T', 'S', 'Z', 'O'],
    solutionPattern: [
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1],
      [1, 0, 0, 0, 1],
    ],
  ),
  StageData(
    id: 15,
    title: 'Stage 15: Crown',
    minMoves: 8,
    blockNames: ['T', 'L', 'J', 'O', 'S', 'Z'],
    solutionPattern: [
      [0, 1, 0, 1, 0],
      [1, 1, 1, 1, 1],
      [1, 1, 0, 1, 1],
      [0, 1, 1, 1, 0],
      [0, 0, 1, 0, 0],
    ],
  ),
  StageData(
    id: 16,
    title: 'Stage 16: Nebula',
    minMoves: 8,
    blockNames: ['T', 'S', 'Z', 'L', 'J', 'O'],
    solutionPattern: [
      [1, 1, 1, 1, 1],
      [1, 1, 0, 1, 1],
      [0, 1, 1, 1, 0],
      [0, 1, 1, 1, 0],
      [1, 1, 0, 1, 1],
    ],
  ),
  StageData(
    id: 17,
    title: 'Stage 17: Hive',
    minMoves: 9,
    blockNames: ['O', 'L', 'J', 'T', 'S', 'Z'],
    solutionPattern: [
      [0, 1, 1, 1, 0],
      [1, 1, 0, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 0, 1, 1],
      [0, 1, 1, 1, 0],
    ],
  ),
  StageData(
    id: 18,
    title: 'Stage 18: Vortex',
    minMoves: 9,
    blockNames: ['L', 'J', 'S', 'Z', 'T', 'O'],
    solutionPattern: [
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 1, 0, 1],
      [1, 0, 1, 0, 1],
      [1, 1, 1, 1, 1],
    ],
  ),
  StageData(
    id: 19,
    title: 'Stage 19: Halo',
    minMoves: 9,
    blockNames: ['T', 'L', 'J', 'O', 'S', 'Z'],
    solutionPattern: [
      [0, 1, 1, 1, 0],
      [1, 1, 0, 1, 1],
      [1, 1, 0, 1, 1],
      [1, 1, 0, 1, 1],
      [0, 1, 1, 1, 0],
    ],
  ),
  StageData(
    id: 20,
    title: 'Stage 20: Heartcore',
    minMoves: 10,
    blockNames: ['O', 'T', 'L', 'J', 'S', 'Z'],
    solutionPattern: [
      [0, 1, 1, 1, 0],
      [1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1],
      [0, 1, 1, 1, 0],
      [0, 0, 1, 0, 0],
    ],
  ),
];
