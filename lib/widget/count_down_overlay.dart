import 'package:overlap/constants/game_constant.dart';
import 'package:flutter/material.dart';

class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({super.key});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int countdown = DURATION; // 3초 카운트다운;

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
      color: Color(0xFFF7F1E0),
      alignment: Alignment.center,
      child: Text(
        countdown.toString(),
        style: TextStyle(
          fontSize: 80,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
