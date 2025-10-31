import 'package:flutter/material.dart';
import 'package:overlap/models/stage_data.dart';

/// 아케이드 모드에서 하나의 챕터(월)를 표현하는 데이터 모델.
class ArcadeChapter {
  const ArcadeChapter({
    required this.id,
    required this.title,
    required this.stages,
    this.plannedStageCount,
    this.stepCount = 7,
    this.description,
    this.releaseAt,
    this.order,
    required this.primaryColor,
    required this.secondaryColor,
  });

  /// 고유 ID (예: january, february).
  final String id;

  /// UI에 노출될 챕터 이름.
  final String title;

  /// 챕터에 포함된 스테이지 목록.
  final List<StageData> stages;

  /// 출시 예정 스테이지 수. 실 데이터보다 크면 "곧 공개" 처리에 활용 가능.
  final int? plannedStageCount;

  /// 연속 플레이 시 필요한 단계 수 (UI 용도).
  final int stepCount;

  /// 챕터 설명 문구.
  final String? description;

  /// 챕터 공개 예정일.
  final DateTime? releaseAt;

  /// 정렬 우선순위.
  final int? order;

  /// UI 테마 색상.
  final Color primaryColor;
  final Color secondaryColor;

  /// 현재 등록된 스테이지 수.
  int get stageCount => stages.length;

  /// UI에서 보여줄 전체 슬롯 수.
  int get totalStageSlots => plannedStageCount ?? stageCount;

  /// 챕터에 포함된 스테이지 ID 목록.
  List<int> get stageIds =>
      stages.map((stage) => stage.id).toList(growable: false);

  /// 해당 스테이지 ID가 챕터에 속하는지 확인.
  bool containsStage(int stageId) =>
      stages.any((stage) => stage.id == stageId);

  /// 챕터 전용 그라디언트.
  LinearGradient get gradient => LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// JSON(Map) -> ArcadeChapter 변환.
  factory ArcadeChapter.fromJson(Map<String, dynamic> json) {
    final stagesJson = json['stages'] as List<dynamic>? ?? const <dynamic>[];
    return ArcadeChapter(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      stages: stagesJson
          .map((stage) =>
              StageData.fromJson(stage as Map<String, dynamic>))
          .toList(growable: false),
      plannedStageCount: _readOptionalInt(json['plannedStageCount']) ??
          _readOptionalInt(json['stageCount']),
      stepCount: _readOptionalInt(json['stepCount']) ?? 7,
      description: json['description'] as String?,
      releaseAt: json['releaseAt'] is String
          ? DateTime.tryParse(json['releaseAt'] as String)
          : null,
      order: _readOptionalInt(json['order']),
      primaryColor: _colorFromJson(json['primaryColor']),
      secondaryColor: _colorFromJson(json['secondaryColor']),
    );
  }

  /// ArcadeChapter -> JSON(Map) 변환.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'stages':
          stages.map((stage) => stage.toJson()).toList(growable: false),
      'stageCount': stageCount,
      if (plannedStageCount != null)
        'plannedStageCount': plannedStageCount,
      'stepCount': stepCount,
      if (description != null) 'description': description,
      if (releaseAt != null) 'releaseAt': releaseAt!.toIso8601String(),
      if (order != null) 'order': order,
      'primaryColor': _colorToInt(primaryColor),
      'secondaryColor': _colorToInt(secondaryColor),
    };
  }

  static int? _readOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }

  static Color _colorFromJson(dynamic raw) {
    if (raw is int) {
      return Color(raw);
    }
    if (raw is String) {
      final cleaned = raw.trim().replaceFirst('#', '');
      if (cleaned.isEmpty) {
        throw ArgumentError('색상 문자열이 비어 있습니다.');
      }
      final value = int.parse(cleaned, radix: 16);
      if (cleaned.length <= 6) {
        return Color(0xFF000000 | value);
      }
      return Color(value);
    }
    throw ArgumentError('지원하지 않는 색상 포맷: $raw');
  }

  static int _colorToInt(Color color) {
    int channel(double component) =>
        (component * 255.0).round() & 0xff;
    return (channel(color.a) << 24) |
        (channel(color.r) << 16) |
        (channel(color.g) << 8) |
        channel(color.b);
  }
}
