import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/constants/game_constants.dart';
import 'package:flutter/material.dart';

class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({super.key});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int countdown = GameConfig.countdownDelay.inSeconds; // 3초 카운트다운;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          countdown--;
        });
      }
      return countdown > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.overlayGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        countdown.toString(),
        style: TextStyle(
          fontSize: 80,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              blurRadius: 12,
              color: AppColors.accent.withFraction(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
