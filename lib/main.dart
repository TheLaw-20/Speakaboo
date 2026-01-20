import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/session/session_config_screen.dart';
import 'features/record/recording_screen.dart';
import 'features/analysis/analysis_screen.dart';
import 'package:speakaboo/features/topic_practice/topic_practice_screen.dart';
import 'package:speakaboo/features/topic_practice/topic_analysis_result_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: SpeakabooApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/config',
      builder: (context, state) => const SessionConfigScreen(),
    ),
    GoRoute(
      path: '/record',
      builder: (context, state) => const RecordingScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) => const AnalysisScreen(),
    ),
    GoRoute(
        path: '/topic-practice',
        builder: (context, state) => const TopicPracticeScreen(),
    ),
    GoRoute(
      path: '/topic-result',
      builder: (context, state) {
        // Safe casting of extra
        final data = state.extra as Map<String, String>?;
        final videoPath = data?['videoPath'] ?? '';
        final topic = data?['topic'] ?? '';
        return TopicAnalysisResultScreen(videoPath: videoPath, topic: topic);
      },
    ),
  ],
);

class SpeakabooApp extends StatelessWidget {
  const SpeakabooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Speakaboo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
