import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class SpeechToTextService extends GetxService {
  final SpeechToText _speech = SpeechToText();

  bool _hasSpeech = false;
  String _lastWords = '';
  String _lastError = '';
  String _lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  double _level = 0.0;

  bool get hasSpeech => _hasSpeech;
  String get lastWords => _lastWords;
  String get lastError => _lastError;
  String get lastStatus => _lastStatus;
  String get currentLocaleId => _currentLocaleId;
  List<LocaleName> get localeNames => _localeNames;
  double get level => _level;

  Future<SpeechToTextService> init() async {
    try {
      _hasSpeech = await _speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true,
      );

      if (_hasSpeech) {
        _localeNames = await _speech.locales();

        var systemLocale = await _speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
    } on PlatformException catch (e) {
      developer.log('Failed to initialize speech recognition', error: e);
      _lastError = 'Speech recognition failed: ${e.message}';
    }

    return this;
  }

  Future<void> startListening() async {
    _lastWords = '';
    _lastError = '';

    try {
      await _speech.listen(
        onResult: resultListener,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } on PlatformException catch (e) {
      developer.log('Failed to start listening', error: e);
      _lastError = 'Failed to start listening: ${e.message}';
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _level = 0.0;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _level = 0.0;
  }

  void resultListener(SpeechRecognitionResult result) {
    _lastWords = '${result.recognizedWords} - ${result.finalResult}';
    update();
  }

  void soundLevelListener(double level) {
    _level = level;
    update();
  }

  void errorListener(SpeechRecognitionError error) {
    _lastError = '${error.errorMsg} - ${error.permanent}';
    update();
  }

  void statusListener(String status) {
    _lastStatus = status;
    update();
  }

  void switchLang(String? selectedVal) {
    if (selectedVal != null) {
      _currentLocaleId = selectedVal;
      update();
    }
  }
}
