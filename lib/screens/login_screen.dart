import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/environment.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  static final _googleSignIn = GoogleSignIn(
    clientId: Environment.googleClientId, // 여기를 수정
    scopes: ['email', 'https://www.googleapis.com/auth/adsense.readonly'],
  );

  const LoginScreen({super.key});

  Future<void> _signIn(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        if (auth.accessToken != null && context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DashboardScreen(accessToken: auth.accessToken!),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signIn(context),
          child: const Text('Google로 로그인'),
        ),
      ),
    );
  }
}
