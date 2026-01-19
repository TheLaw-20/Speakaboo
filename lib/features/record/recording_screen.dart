import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../session/session_provider.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> with TickerProviderStateMixin {
  bool isRecording = false;
  bool anxietyMode = false;
  late AnimationController _breathingController;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${session.selectedGoal} -> ${session.selectedAudience}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient Animation (Simplified)
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: anxietyMode ? 1.5 : 0.8,
                colors: anxietyMode 
                    ? [Colors.blue.withOpacity(0.2), AppColors.background]
                    : [AppColors.primary.withOpacity(0.1), AppColors.background],
              ),
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (anxietyMode) ...[
                 ScaleTransition(
                   scale: Tween(begin: 0.9, end: 1.1).animate(_breathingController),
                   child: Container(
                     padding: const EdgeInsets.all(30),
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(color: Colors.white24),
                     ),
                     child: const Text(
                       "Breathe In...",
                       style: TextStyle(fontSize: 24, color: Colors.white70),
                     ),
                   ),
                 ),
                 const SizedBox(height: 40),
              ] else ...[
                 // Placeholder for Audio Waveform
                 Container(
                   height: 100,
                   margin: const EdgeInsets.symmetric(horizontal: 20),
                   decoration: BoxDecoration(
                     color: Colors.white10,
                     borderRadius: BorderRadius.circular(10),
                   ),
                   child: const Center(child: Text("Audio Waveform Visualization")),
                 ),
                 const SizedBox(height: 40),
              ],

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _textController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white70),
                  decoration: const InputDecoration(
                    hintText: "Enter speech transcript here (or mock recording)...",
                    hintStyle: TextStyle(color: Colors.white30),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(anxietyMode ? Icons.healing : Icons.healing_outlined),
                    color: anxietyMode ? AppColors.success : Colors.white54,
                    iconSize: 32,
                    onPressed: () => setState(() => anxietyMode = !anxietyMode),
                    tooltip: "Anxiety Mode",
                  ),
                  const SizedBox(width: 30),
                  FloatingActionButton.large(
                    onPressed: () {
                      setState(() => isRecording = !isRecording);
                      if (isRecording) {
                        // Mock recording effect
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted && _textController.text.isEmpty) {
                            _textController.text = "Good morning everyone. I am here to talk about the quarterly results. We did great.";
                          }
                        });
                      }
                    },
                    backgroundColor: isRecording ? Colors.red : AppColors.primary,
                    child: Icon(isRecording ? Icons.stop : Icons.mic),
                  ),
                  const SizedBox(width: 30),
                  if (!isRecording)
                    IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        color: AppColors.success,
                        iconSize: 40,
                        onPressed: () {
                           ref.read(sessionProvider.notifier).setTranscript(_textController.text);
                           context.go('/result');
                        },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                isRecording ? "Recording..." : "Tap mic to start",
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
