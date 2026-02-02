import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../session/session_provider.dart';
import 'ai_service.dart';

// Future Provider to fetch analysis
final analysisFutureProvider = FutureProvider.autoDispose<String>((ref) async {
  final session = ref.watch(sessionProvider);
  final aiService = ref.watch(aiServiceProvider);

  // Fallback for demo if no transcript provided
  final transcript = (session.transcript == null || session.transcript!.isEmpty) 
      ? 'I am so happy to be here today to speak about our quarterly results.'
      : session.transcript!;

  return aiService.analyzeSpeech(
    transcript: transcript,
    audience: session.selectedAudience ?? 'General Audience',
    goal: session.selectedGoal ?? 'Inform',
  );
});

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisFutureProvider);
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () => context.go('/'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Analysis Results"),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Icon(Icons.psychology, size: 48, color: Colors.white),
                       const SizedBox(height: 10),
                       Text("AI Coach", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: analysisAsync.when(
                data: (analysisText) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeedbackCard(
                      context,
                      title: "Audience: ${session.selectedAudience}",
                      content: analysisText,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/'),
                        child: const Text("Back to Home"),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text("Analyzing your speech pattern...", style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
                error: (err, stack) => Center(
                  child: Text("Error: $err", style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, {required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          const Divider(color: Colors.white24, height: 30),
          Text(content, style: const TextStyle(color: AppColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}
