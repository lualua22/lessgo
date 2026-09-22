import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/session.dart';
import 'screens.dart';
import 'theme/app_theme.dart';

class LessGoApp extends StatefulWidget {
  const LessGoApp({super.key});

  @override
  State<LessGoApp> createState() => _LessGoAppState();
}

class _LessGoAppState extends State<LessGoApp> {
  late final SessionStore session;

  @override
  void initState() {
    super.initState();
    session = SessionStore(ApiClient());
    session.restore();
  }

  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LessGo',
        theme: AppTheme.light,
        home: session.loading
            ? const SplashScreen()
            : !session.onboardingSeen
            ? OnboardingScreen(session: session)
            : session.user == null
            ? LoginScreen(session: session)
            : HomeShell(session: session),
      ),
    );
  }
}
