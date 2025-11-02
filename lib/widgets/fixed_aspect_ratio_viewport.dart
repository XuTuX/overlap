import 'package:flutter/material.dart';
import 'package:overlap/constants/app_colors.dart';

class FixedAspectRatioViewport extends StatelessWidget {
  const FixedAspectRatioViewport({
    super.key,
    required this.child,
    required this.aspectRatio,
  }) : assert(aspectRatio > 0, 'aspectRatio must be positive');

  final Widget child;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;

        if (!maxWidth.isFinite ||
            !maxHeight.isFinite ||
            maxWidth <= 0 ||
            maxHeight <= 0) {
          return SizedBox.expand(child: child);
        }

        double width = maxWidth;
        double height = width / aspectRatio;

        if (height > maxHeight) {
          height = maxHeight;
          width = height * aspectRatio;
        }

        final mediaQuery = MediaQuery.maybeOf(context);
        if (mediaQuery == null) {
          return ColoredBox(
            color: AppColors.background,
            child: Center(
              child: SizedBox(width: width, height: height, child: child),
            ),
          );
        }

        double safeScale(double original, double scaled) {
          if (original == 0) {
            return 1.0;
          }
          return scaled / original;
        }

        double widthScale = safeScale(mediaQuery.size.width, width);
        double heightScale = safeScale(mediaQuery.size.height, height);

        EdgeInsets scaleInsets(EdgeInsets insets) {
          return EdgeInsets.fromLTRB(
            insets.left * widthScale,
            insets.top * heightScale,
            insets.right * widthScale,
            insets.bottom * heightScale,
          );
        }

        final mediaData = mediaQuery.copyWith(
          size: Size(width, height),
          padding: scaleInsets(mediaQuery.padding),
          viewPadding: scaleInsets(mediaQuery.viewPadding),
          viewInsets: scaleInsets(mediaQuery.viewInsets),
        );

        return ColoredBox(
          color: AppColors.background,
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: MediaQuery(
                data: mediaData,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
