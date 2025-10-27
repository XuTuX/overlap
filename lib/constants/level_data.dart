import 'package:overlap/constants/game_constant.dart';

class LevelData {
  final List<String> map;
  final List<String> blockKeys;

  const LevelData({
    required this.map,
    required this.blockKeys,
  })  : assert(map.length == ROW,
            'Each level map must contain exactly $ROW rows.'),
        assert(
          _areRowsValid(map),
          'Each level map row must contain exactly $COL characters.',
        );

  static bool _areRowsValid(List<String> rows) {
    for (final row in rows) {
      if (row.length != COL) return false;
    }
    return true;
  }
}

const List<LevelData> kLevelData = [
  LevelData(
    map: [
      '.....',
      '.XX..',
      '.XX..',
      '.....',
      '.....',
    ],
    blockKeys: ['0'],
  ),
  LevelData(
    map: [
      '.....',
      '.XXX.',
      'X.X..',
      'X....',
      'XX...',
    ],
    blockKeys: ['T', 'L'],
  ),
  LevelData(
    map: [
      '.XXX.',
      '..X..',
      '.X.XX',
      '.XXX.',
      'XX...',
    ],
    blockKeys: ['T', 'J', 'S'],
  ),
];
