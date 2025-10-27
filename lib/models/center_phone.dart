import 'package:flutter/material.dart';

class CenteredPhoneApp extends StatelessWidget {
  final Widget child;

  const CenteredPhoneApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: constraints.maxWidth > 430 ? 430 : constraints.maxWidth,
            child: child,
          ),
        );
      },
    );
  }
}
