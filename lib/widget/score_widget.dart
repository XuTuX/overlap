import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constant.dart';
import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget {
  final String score;
  final String highScore;

  const ScoreWidget({super.key, required this.score, required this.highScore});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: AppColors.highlightGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            score,
            style: TextStyle(
              fontSize: ResponsiveSizes.scoreTextSize(),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: ResponsiveSizes.highScoreTextSize() * 1.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30, // .w 제거
                width: 30, // .w 제거
                child: Image.asset(
                  'assets/image/highscore.png',
                  fit: BoxFit.contain,
                  color: AppColors.accent,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                highScore,
                style: TextStyle(
                  fontSize: ResponsiveSizes.highScoreTextSize(),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
