import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class SpeechToTextService extends GetxController {
  final SpeechToText _speech = SpeechToText();

  RxBool _hasSpeech = false.obs;
  RxString _lastWords = ''.obs;
  RxString _lastError = ''.obs;
  RxString _lastStatus = ''.obs;
  RxString _currentLocaleId = ''.obs;
  RxList<LocaleName> _localeNames = <LocaleName>[].obs;
  RxDouble _level = 0.0.obs;

  bool get hasSpeech => _hasSpeech.value;
  String get lastWords => _lastWords.value;
  String get lastError => _lastError.value;
  String get lastStatus => _lastStatus.value;
  String get currentLocaleId => _currentLocaleId.value;
  List<LocaleName> get localeNames => _localeNames;
  double get level => _level.value;

  Future<SpeechToTextService> init() async {
    try {
      _hasSpeech.value = await _speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true,
      );

      if (_hasSpeech.value) {
        _localeNames.value = await _speech.locales();

        var systemLocale = await _speech.systemLocale();
        _currentLocaleId.value = systemLocale?.localeId ?? '';
      }
    } on PlatformException catch (e) {
      developer.log('Failed to initialize speech recognition', error: e);
      _lastError.value = 'Speech recognition failed: ${e.message}';
    }

    return this;
  }

  Future<void> startListening() async {
    _lastWords.value = '';
    _lastError.value = '';

    try {
      await _speech.listen(
        onResult: resultListener,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId.value,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } on PlatformException catch (e) {
      developer.log('Failed to start listening', error: e);
      _lastError.value = 'Failed to start listening: ${e.message}';
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _level.value = 0.0;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _level.value = 0.0;
  }

  void resultListener(SpeechRecognitionResult result) {
    _lastWords.value = '${result.recognizedWords} - ${result.finalResult}';
  }

  void soundLevelListener(double level) {
    _level.value = level;
  }

  void errorListener(SpeechRecognitionError error) {
    _lastError.value = '${error.errorMsg} - ${error.permanent}';
  }

  void statusListener(String status) {
    _lastStatus.value = status;
  }

  void switchLang(String? selectedVal) {
    if (selectedVal != null) {
      _currentLocaleId.value = selectedVal;
    }
  }
}
