import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/constants/app_colors.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withFraction(0.08),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withFraction(0.15),
                  Colors.white.withFraction(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withFraction(0.25)),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🧩 상단 아이콘
                const Icon(
                  Icons.power_settings_new_rounded,
                  color: AppColors.accent,
                  size: 58,
                ),
                const SizedBox(height: 20),

                // 💬 제목 텍스트
                const Text(
                  '정말 종료하시겠어요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // ⚠️ 보조 텍스트
                const Text(
                  '진행 중인 게임 기록은 저장되지 않습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // 🕹 버튼 섹션
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: Get.back,
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: Colors.white.withFraction(0.4)),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '계속하기',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed('/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shadowColor: AppColors.accent.withFraction(0.5),
                          elevation: 8,
                        ),
                        child: const Text(
                          '종료하기',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
