import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login Screen',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: Text('Google Login'),
            ),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: Text('Apple Login'),
            ),
          ],
        ),
      )),
    );
  }
}
