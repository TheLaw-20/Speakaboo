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
}

final aiServiceProvider = Provider<AiAnalysisService>((ref) {
  // TODO: Retrieve key from secure storage or user input
  return AiAnalysisService(_apiKey);
});
