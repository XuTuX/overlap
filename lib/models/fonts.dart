import 'package:flutter/material.dart';

class Fonts {
  /// 미리 정의된 스타일
  static const TextStyle highlight = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  /// 커스텀 스타일 생성용 함수
  static TextStyle textstyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    String? fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFamily: fontFamily,
    );
  }
}
