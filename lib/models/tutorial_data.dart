/// 튜토리얼 한 장에 들어갈 정보
class TutorialPage {
  final String asset; // gif 경로
  final String caption; // 설명 텍스트
  const TutorialPage(this.asset, this.caption);
}

/// 5장짜리 리스트
const pages = [
  TutorialPage('assets/gif/score.gif', '제한 시간 내 목표를 달성하고,\n 남은 시간을 점수로 획득하세요.'),
  TutorialPage('assets/gif/rotation.gif', '블록을 두 번 탭해 회전하세요.'),
  TutorialPage('assets/gif/overlap.gif', '겹친 셀은 사라집니다.'),
  TutorialPage('assets/gif/undo.gif', '잘못 놓은 블록은 되돌리세요.'),
];
