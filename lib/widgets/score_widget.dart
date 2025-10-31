import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget {
  final double score;
  final double highScore;

  const ScoreWidget({super.key, required this.score, required this.highScore});

  @override
  Widget build(BuildContext context) {
    final metrics = GameConfig.layoutOf(context);
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
            score.toStringAsFixed(1),
            style: TextStyle(
              fontSize: metrics.scoreTextSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: metrics.highScoreTextSize * 1.5,
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
                highScore.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: metrics.highScoreTextSize,
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
