import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakaboo/features/analysis/ai_service.dart';
import 'dart:io';

class TopicAnalysisResultScreen extends ConsumerStatefulWidget {
  final String videoPath;
  final String topic;

  const TopicAnalysisResultScreen({
    super.key,
    required this.videoPath,
    required this.topic,
  });

  @override
  ConsumerState<TopicAnalysisResultScreen> createState() => _TopicAnalysisResultScreenState();
}

class _TopicAnalysisResultScreenState extends ConsumerState<TopicAnalysisResultScreen> {
  String? _analysisResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _analyzeVideo();
  }

  Future<void> _analyzeVideo() async {
    try {
      final file = File(widget.videoPath);
      if (!await file.exists()) {
        setState(() {
          _analysisResult = "Error: Video file not found.";
          _isLoading = false;
        });
        return;
      }

      final videoBytes = await file.readAsBytes();
      final result = await ref.read(aiServiceProvider).analyzeVideo(
        videoBytes: videoBytes,
        topic: widget.topic,
      );

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysisResult = "Error analyzing video: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis Result"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/topic-practice'),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Analyzing your video response..."),
                  Text("Checking facial expressions and content...",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Topic: ${widget.topic}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    _analysisResult ?? "No result.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/topic-practice'),
                      child: const Text("Practice Another Topic"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
