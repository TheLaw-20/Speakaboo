import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// WARN: In a production app, do not store API keys in code.
// Ideally, use --dart-define or a backend proxy.
// For this MVP, we will ask the user to provide it or use a placeholder.
final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; 

class AiAnalysisService {
  final GenerativeModel _model;

  AiAnalysisService(String apiKey) 
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash', 
          apiKey: _apiKey,
        );

  Future<String> analyzeSpeech({
    required String transcript,
    required String audience,
    required String goal,
  }) async {
    if (_apiKey.isEmpty) {
      return "Error: API Key is missing. Please configure your Gemini API Key in `lib/features/analysis/ai_service.dart`.";
    }

    final prompt = '''
    Role: Professional Public Speaking Coach.
    Context: The speaker is addressing an audience of "$audience" with the goal to "$goal".
    
    Speech Transcript:
    "$transcript"
    
    Task: Analyze the speech based on the context.
    1. Score the "Audience Fit" (0-100) and explain why.
    2. Score the "Goal Alignment" (0-100) and explain why.
    3. Provide 3 specific improvements.
    
    Format:
    [Fit Score: X]
    [Goal Score: Y]
    [Feedback]
    ...
    ''';

    try {
      print('DEBUG: Analyzing speech with model: gemini-1.5-flash');
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Analysis failed to generate text.";
    } catch (e) {
      return "Analysis Error: $e";
    }
  }

  Future<String> analyzeVideo({
    required List<int> videoBytes,
    required String topic,
  }) async {
    if (_apiKey.isEmpty) return "Error: API Key Missing";

    final prompt = '''
    Role: Public Speaking Coach.
    Topic: "$topic"
    
    Task: Watch the video response.
    1. Analyze the speaker's facial expressions and body language. Are they confident? engaging? distracted?
    2. Analyze the content (if audible/understandable).
    3. Provide constructive feedback on delivery and presence.
    
    Format:
    [Expression Score: X/100]
    [Content Score: Y/100]
    [Feedback]
    ...
    ''';

    try {
      print('DEBUG: Analyzing video with model: gemini-1.5-flash');
      // Note: For video, we typically use DataPart. 
      // Ensure the mimeType matches the video format (e.g., video/mp4).
      final videoPart = DataPart('video/mp4', videoBytes as dynamic); 
      // Cast to dynamic if type check issues arise, or UnmodifiableUint8ListView, 
      // but standard usage is Uint8List.
      
      final content = [
        Content.multi([TextPart(prompt), videoPart])
      ];

      final response = await _model.generateContent(content);
      return response.text ?? "Video analysis failed.";
    } catch (e) {
      return "Video Analysis Error: $e";
    }
  }
}

final aiServiceProvider = Provider<AiAnalysisService>((ref) {
  // TODO: Retrieve key from secure storage or user input
  return AiAnalysisService(_apiKey);
});
