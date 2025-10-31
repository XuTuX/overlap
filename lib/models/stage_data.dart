import 'package:overlap/enum/bord_enum.dart';

/// 퍼즐 스테이지에 대한 정적 데이터 모델.
///
/// Firestore나 Hive 등에 저장하기 위해 JSON <-> 객체 변환 메서드를 함께 제공한다.
class StageData {
  const StageData({
    required this.id,
    required this.title,
    required this.minMoves,
    required this.solutionPattern,
    required this.blockNames,
    this.background,
    this.order,
  });

  /// 전역에서 고유한 스테이지 식별자.
  final int id;

  /// UI에 표시될 스테이지 이름.
  final String title;

  /// 3별 달성을 위한 최소 이동 수.
  final int minMoves;

  /// 정답 보드를 0/1 그리드로 표현한 값.
  final List<List<int>> solutionPattern;

  /// 스테이지에서 사용해야 하는 블록 ID 목록.
  final List<String> blockNames;

  /// 배경 이미지/색상 등의 추가 리소스 키.
  final String? background;

  /// 챕터 내 정렬 순서를 명시적으로 고정하고 싶을 때 사용.
  final int? order;

  /// JSON(Map) -> StageData 변환.
  factory StageData.fromJson(Map<String, dynamic> json) {
    final pattern = (json['solutionPattern'] as List<dynamic>? ?? const <dynamic>[])
        .map<List<int>>(
          (row) => List<int>.from(
            (row as List<dynamic>).map((value) => (value as num).toInt()),
            growable: false,
          ),
        )
        .toList(growable: false);

    return StageData(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      minMoves: (json['minMoves'] as num).toInt(),
      solutionPattern: pattern,
      blockNames: (json['blockNames'] as List<dynamic>? ?? const <dynamic>[])
          .map((name) => name.toString())
          .toList(growable: false),
      background: json['background'] as String?,
      order: json['order'] == null ? null : (json['order'] as num).toInt(),
    );
  }

  /// StageData -> JSON(Map) 변환.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'minMoves': minMoves,
      'solutionPattern': solutionPattern
          .map((row) => row.toList(growable: false))
          .toList(growable: false),
      'blockNames': blockNames.toList(growable: false),
      if (background != null) 'background': background,
      if (order != null) 'order': order,
    };
  }
}

/// 0/1 패턴을 게임 보드에 필요한 셀 리스트로 변환한다.
List<Cellstate> patternToCells(List<List<int>> pattern) {
  final flattened = <Cellstate>[];
  for (final row in pattern) {
    for (final value in row) {
      flattened.add(value == 1 ? Cellstate.occupied : Cellstate.empty);
    }
  }
  return flattened;
}
