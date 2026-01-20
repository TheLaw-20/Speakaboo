import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speakaboo/features/topic_practice/topic_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TopicPracticeScreen extends ConsumerStatefulWidget {
  const TopicPracticeScreen({super.key});

  @override
  ConsumerState<TopicPracticeScreen> createState() => _TopicPracticeScreenState();
}

class _TopicPracticeScreenState extends ConsumerState<TopicPracticeScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  String? _currentTopic;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadNewTopic();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (status.isGranted && micStatus.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Use front camera by default if available
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: true,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } else {
      // Handle permission denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera and Microphone permissions are required.')),
        );
      }
    }
  }

  void _loadNewTopic() {
    setState(() {
      _currentTopic = ref.read(topicServiceProvider).getRandomTopic();
    });
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      // Stop recording
      final file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        // Navigate to analysis
        print('Video recorded to: ${file.path}');
        
        // Use GoRouter with extra object or separate params
        // Since GoRouter 'extra' can be tricky with type safety/web refresh,
        // we'll pass state via riverpod or just push for now if standard.
        // But for MVP, let's use extra.
        context.push('/topic-result', extra: {
          'videoPath': file.path, 
          'topic': _currentTopic ?? 'Unknown Topic'
        }); 
      }
    } else {
      // Start recording
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),
          
          // Overlay Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Topic Overlay
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  'Your Topic:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  _currentTopic ?? "Loading...",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: _isRecording ? null : _loadNewTopic,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: "New Topic",
                )
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/'),
            ),
          ),

          // Recording Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: _toggleRecording,
                backgroundColor: _isRecording ? Colors.red : Colors.white,
                child: Icon(
                  _isRecording ? Icons.stop : Icons.videocam,
                  color: _isRecording ? Colors.white : Colors.red,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
