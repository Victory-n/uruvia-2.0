import 'package:speech_to_text/speech_to_text.dart';

class VoiceExpenseService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;
  bool get isInitialized => _isInitialized;

  Future<bool> initialize({
    void Function(String)? onStatus,
    void Function(String)? onError,
  }) async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) => onStatus?.call(status),
        onError: (errorNotification) => onError?.call(errorNotification.errorMsg),
      );
    } catch (e) {
      _isInitialized = false;
      print("VoiceExpenseService: initialization error: $e");
    }
    return _isInitialized;
  }

  Future<void> startListening({
    required void Function(String) onResult,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) {
        throw Exception("Speech recognition could not be initialized");
      }
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 4),
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }
}
