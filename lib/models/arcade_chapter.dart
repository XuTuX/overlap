import 'package:flutter/material.dart';
import 'package:overlap/models/stage_data.dart';

class ArcadeChapter {
  final String id;
  final String title;
  final int startStageId;
  final int stageCount;
  final int stepCount;
  final Color primaryColor;
  final Color secondaryColor;

  const ArcadeChapter({
    required this.id,
    required this.title,
    required this.startStageId,
    required this.stageCount,
    this.stepCount = 7,
    required this.primaryColor,
    required this.secondaryColor,
  });

  List<int> get stageIds => List<int>.generate(
        stageCount,
        (index) => startStageId + index,
      );

  List<StageData> get stages => stageIds
      .map((id) => arcadeStageMap[id])
      .whereType<StageData>()
      .toList(growable: false);

  bool containsStage(int stageId) {
    return stageId >= startStageId && stageId <= startStageId + stageCount - 1;
  }

  LinearGradient get gradient => LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

final List<ArcadeChapter> arcadeChapters = [
  const ArcadeChapter(
    id: 'january',
    title: '2025 January',
    startStageId: 1,
    stageCount: 20,
    primaryColor: Color(0xFF4E5AFE),
    secondaryColor: Color(0xFF7B5BFF),
  ),
  // const ArcadeChapter(
  //   id: 'february',
  //   title: 'February',
  //   startStageId: 21,
  //   stageCount: 20,
  //   primaryColor: Color(0xFFFF6F91),
  //   secondaryColor: Color(0xFFFF9671),
  // ),
  // const ArcadeChapter(
  //   id: 'march',
  //   title: 'March',
  //   startStageId: 41,
  //   stageCount: 20,
  //   primaryColor: Color(0xFF2DD4BF),
  //   secondaryColor: Color(0xFF20A4F3),
  // ),
  // const ArcadeChapter(
  //   id: 'april',
  //   title: 'April',
  //   startStageId: 61,
  //   stageCount: 20,
  //   primaryColor: Color(0xFF6EE7B7),
  //   secondaryColor: Color(0xFF3FA7D6),
  // ),
  // const ArcadeChapter(
  //   id: 'may',
  //   title: 'May',
  //   startStageId: 81,
  //   stageCount: 20,
  //   primaryColor: Color(0xFFFFA45B),
  //   secondaryColor: Color(0xFFFF764C),
  // ),
  // const ArcadeChapter(
  //   id: 'june',
  //   title: 'June',
  //   startStageId: 101,
  //   stageCount: 20,
  //   primaryColor: Color(0xFFFA8BFF),
  //   secondaryColor: Color(0xFF2BD2FF),
  // ),
  // const ArcadeChapter(
  //   id: 'july',
  //   title: 'July',
  //   startStageId: 121,
  //   stageCount: 20,
  //   primaryColor: Color(0xFFFF5F7E),
  //   secondaryColor: Color(0xFFFF99AC),
  // ),
  // const ArcadeChapter(
  //   id: 'august',
  //   title: 'August',
  //   startStageId: 141,
  //   stageCount: 20,
  //   primaryColor: Color(0xFF54D3C2),
  //   secondaryColor: Color(0xFF3A8FB7),
  // ),
  // const ArcadeChapter(
  //   id: 'september',
  //   title: 'September',
  //   startStageId: 161,
  //   stageCount: 20,
  //   primaryColor: Color(0xFF9F7AEA),
  //   secondaryColor: Color(0xFF7F5AF0),
  // ),
  // const ArcadeChapter(
  //   id: 'october',
  //   title: 'October',
  //   startStageId: 181,
  //   stageCount: 20,
  //   primaryColor: Color(0xFFFF8C42),
  //   secondaryColor: Color(0xFFFB4A4D),
  // ),
  // const ArcadeChapter(
  //   id: 'november',
  //   title: 'November',
  //   startStageId: 201,
  //   stageCount: 20,
  //   primaryColor: Color(0xFF5E81FF),
  //   secondaryColor: Color(0xFF50C9C3),
  // ),
  // const ArcadeChapter(
  //   id: 'december',
  //   title: 'December',
  //   startStageId: 221,
  //   stageCount: 20,
  //   primaryColor: Color(0xFF61C0FF),
  //   secondaryColor: Color(0xFF3A47D5),
  // ),
];
