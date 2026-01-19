import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionState {
  final String? selectedAudience;
  final String? selectedGoal;
  final String? transcript;

  SessionState({this.selectedAudience, this.selectedGoal, this.transcript});

  SessionState copyWith({String? selectedAudience, String? selectedGoal, String? transcript}) {
    return SessionState(
      selectedAudience: selectedAudience ?? this.selectedAudience,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      transcript: transcript ?? this.transcript,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    return SessionState();
  }

  void setAudience(String audience) {
    state = state.copyWith(selectedAudience: audience);
  }

  void setGoal(String goal) {
    state = state.copyWith(selectedGoal: goal);
  }
  
  void setTranscript(String transcript) {
    state = state.copyWith(transcript: transcript);
  }
  
  void reset() {
    state = SessionState();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
