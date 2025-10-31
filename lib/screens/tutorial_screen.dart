import 'package:overlap/models/hive_game_box.dart';
import 'package:overlap/models/tutorial_data.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 튜토리얼 페이지
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _current = index),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            page.asset,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page.caption,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontSize: 20.0, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            if (_current == pages.length - 1)
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFFFF0), // 배경 색상
                    foregroundColor: Colors.black, // 버튼 텍스트 컬러 흰색으로 대비
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3, // 버튼에 약간의 그림자 추가
                  ),
                  onPressed: () {
                    final hiveGameBox = HiveGameBox();
                    hiveGameBox.setTutorialCompleted(true); // 튜토리얼 완료 기록
                    Get.offAllNamed('/home');
                  },
                  child: Text(
                    'Let\'s Start',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // 인디케이터 점
            _buildDots(),

            const SizedBox(height: 24),

            // 마지막 페이지에서만 “시작하기” 버튼 노출
          ],
        ),
      ),
    );
  }

  /// 하단 페이지 인디케이터
  Widget _buildDots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pages.length,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _current == i ? 12 : 8,
            height: _current == i ? 12 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == i ? Colors.black : Colors.grey.shade400,
            ),
          ),
        ),
      );
}
