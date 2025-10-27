import 'package:overlap/constants/game_constant.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HiveGameBox hiveGameBox = HiveGameBox();
    double highScore = hiveGameBox.getHighScore();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset(
                    'assets/image/highscore.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  highScore.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: Image.asset(
                'assets/image/main.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: CELL_HEIGHT,
            ),
            TextButton(
              onPressed: () => Get.offAllNamed('/game'),
              style: TextButton.styleFrom(
                overlayColor:
                    const Color(0xFFFFC1A6), // 눌렀을 때 진해지는 색상 (연한 오렌지톤)
                backgroundColor: Color(0xFFFFFFF0), // 배경 색상
                padding: EdgeInsets.all(10), // 여백 제거
                minimumSize: Size(Get.width * 0.4, 50),
                maximumSize: Size(Get.width * 0.5, 100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      'assets/image/play.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'PLAY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // 글자 색상
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
