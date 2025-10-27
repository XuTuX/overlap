import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/screen/game_screen.dart';
import 'package:overlap/screen/home_screen.dart';
import 'package:overlap/screen/login_screen.dart';
import 'package:overlap/screen/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 세로 방향으로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // 상태바 투명
    systemNavigationBarColor: Colors.transparent, // 네비게이션 바 투명
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await Hive.initFlutter(); // Hive 초기화
  await Hive.openBox('gameBox'); // 박스 열기
  final hiveGameBox = HiveGameBox();

  // 튜토리얼 완료 여부에 따라 시작 화면 결정
  final initialRoute =
      hiveGameBox.isTutorialCompleted() ? '/home' : '/tutorial';
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'overlap',
      theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xF1F0E8), // AppBar 배경색 일치
            elevation: 0, // 그림자 없애서 더 깔끔하게
            iconTheme: IconThemeData(color: Colors.black), // 아이콘 컬러 설정 (필요시)
            titleTextStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(), // 여기서 notoSans로 통일
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color(0xFFF7F1E0), // 부드러운 크림 톤 (따뜻하고 편안한 느낌)
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.amber)),
      initialRoute: initialRoute,
      getPages: [
        GetPage(
          name: '/game',
          page: () => GameScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => HomeScreen(),
        ),
        GetPage(
          name: '/tutorial',
          page: () => TutorialScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
        ),
      ],
    );
  }
}
