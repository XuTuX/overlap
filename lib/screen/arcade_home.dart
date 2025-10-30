import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlap/controller/arcade_controller.dart';
import 'package:overlap/models/arcade_chapter.dart';

class ArcadeHomeScreen extends GetView<ArcadeController> {
  const ArcadeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arcade Mode'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B1124),
              Color(0xFF111A2E),
              Color(0xFF1A2342),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.8),
                    itemCount: controller.chapters.length,
                    itemBuilder: (context, index) {
                      final ArcadeChapter chapter = controller.chapters[index];
                      return _MonthCard(
                        chapter: chapter,
                        isSelected: true, // Always selected in PageView
                        onTap: () {
                          controller.selectMonth(chapter);
                          controller.refreshProgress();
                          Get.toNamed('/arcade/stages');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final ArcadeChapter chapter;
  final bool isSelected;
  final VoidCallback onTap;

  const _MonthCard({
    required this.chapter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isSelected ? 1.02 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: chapter.gradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                chapter.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${chapter.stageIds.length} stages',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
