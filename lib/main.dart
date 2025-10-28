import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:overlap/constants/app_colors.dart';
import 'package:overlap/controller/arcade_game_controller.dart';
import 'package:overlap/controller/game_controller.dart';
import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/screen/arcade_game_screen.dart';
import 'package:overlap/screen/arcade_map_screen.dart';
import 'package:overlap/screen/game_screen.dart';
import 'package:overlap/screen/home_screen.dart';
import 'package:overlap/screen/login_screen.dart';
import 'package:overlap/screen/tutorial_screen.dart';

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        dividerColor: AppColors.divider,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          primary: AppColors.accent,
          secondary: AppColors.accentSecondary,
          tertiary: AppColors.accentTertiary,
          surface: AppColors.surface,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.surfaceAlt,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: initialRoute,
      initialBinding: BindingsBuilder(() {
        Get.put(GameController(), permanent: true);
        Get.put(ArcadeGameController(), permanent: true);
      }),
      getPages: [
        GetPage(
          name: '/game',
          page: () => GameScreen(),
        ),
        GetPage(
          name: '/arcade',
          page: () => ArcadeMapScreen(),
        ),
        GetPage(
          name: '/arcade/game',
          page: () => ArcadeGameScreen(),
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
