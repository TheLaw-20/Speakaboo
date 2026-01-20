import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicService {
  final List<String> _topics = [
    "Tell me about your favorite hobby and why you love it.",
    "Explain a complex concept you know well to a 5-year-old.",
    "What is the most challenging thing you've ever done?",
    "If you could have dinner with anyone, living or dead, who would it be?",
    "Describe your ideal vacation destination.",
    "Do you think technology brings people closer or drives them apart?",
    "What advice would you give to your younger self?",
    "Discuss a book or movie that changed your perspective.",
    "What are the qualities of a good leader?",
    "How do you handle stress or pressure?",
  ];

  String getRandomTopic() {
    final random = Random();
    return _topics[random.nextInt(_topics.length)];
  }
}

final topicServiceProvider = Provider<TopicService>((ref) {
  return TopicService();
});
