import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

// This script checks for available models.
// Ensure you have a .env file or manually set the key below to test.
const String _apiKey = 'YOUR_API_KEY_HERE';

void main() async {
  if (_apiKey.isEmpty) {
    print('No API key provided.');
    return;
  }
  
  print('Using API Key: ${_apiKey.substring(0, 10)}...');

  try {
    print('Testing models...');
    
    // List of models to try
    final candidates = [
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'gemini-1.0-pro',
      'gemini-pro',
      'gemini-3-pro-preview',
    ];

    for (final m in candidates) {
        print('Trying $m...');
        try {
            final testModel = GenerativeModel(model: m, apiKey: _apiKey);
            final content = [Content.text('Hello')];
            await testModel.generateContent(content);
            print('SUCCESS: $m is working!');
            exit(0);
        } catch (e) {
            print('Failed $m: ${e.toString().split('\n').first}');
        }
    }
    
    print('No common models worked. Ensure Generative Language API is enabled.');

  } catch (e) {
    print('Error: $e');
  }
}
