import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../shared/glass_card.dart';
import 'session_provider.dart';

class SessionConfigScreen extends ConsumerWidget {
  const SessionConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.go('/'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Who are you speaking to?",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ).animate().fade().slideX(),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: AppConstants.audiences.length,
                    itemBuilder: (context, index) {
                      final audience = AppConstants.audiences[index];
                      final isSelected = sessionState.selectedAudience == audience;
                      
                      return GlassCard(
                        isSelected: isSelected,
                        onTap: () => ref.read(sessionProvider.notifier).setAudience(audience),
                        child: Center(
                          child: Text(
                            audience,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ).animate().fade(delay: (100 * index).ms).scale();
                    },
                  ),
                ),
                const SizedBox(height: 20),
                 if (sessionState.selectedAudience != null) ...[
                    Text(
                      "What is your goal?",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                          ),
                    ).animate().fade(),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConstants.goals.length,
                        itemBuilder: (context, index) {
                          final goal = AppConstants.goals[index];
                          final isSelected = sessionState.selectedGoal == goal;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ActionChip(
                              label: Text(goal),
                              backgroundColor: isSelected ? AppColors.accent : AppColors.surface,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                              onPressed: () => ref.read(sessionProvider.notifier).setGoal(goal),
                            ),
                          );
                        },
                      ),
                    ).animate().fade(),
                 ],
                 const SizedBox(height: 30),
                 Center(
                   child: ElevatedButton(
                     onPressed: (sessionState.selectedAudience != null && sessionState.selectedGoal != null)
                         ? () => context.go('/record')
                         : null,
                     style: ElevatedButton.styleFrom(
                       minimumSize: const Size(double.infinity, 56),
                       backgroundColor: AppColors.primary,
                     ),
                     child: const Text("Start Session"),
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
