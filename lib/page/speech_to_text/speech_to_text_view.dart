import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextView extends StatelessWidget {
  const SpeechToTextView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stateless View'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This is a stateless view',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20),
            MyStatefulWidget(), // Embedding the stateful widget
          ],
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  late stt.SpeechToText _speech;
  bool _isAvailable = false;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      print('Initializing speech recognition...');
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          print('onStatus: $status');
          if (status == 'done') {
            _resetListening();
          }
        },
        onError: (error) {
          print('onError: ${error.errorMsg}');
          print('Error permanent: ${error.permanent}');
          _resetListening();
        },
        debugLogging: true,
      );
      print('Speech recognition initialized. Available: $_isAvailable');
      setState(() {});
    } catch (e) {
      print('Error initializing speech recognition: $e');
      _isAvailable = false;
      setState(() {});
    }
  }

  void _startListening() async {
    if (_isAvailable && !_isListening) {
      print('Starting to listen...');
      setState(() {
        _isListening = true;
        _text = 'Listening...';
      });
      try {
        await _speech.listen(
          onResult: (result) {
            print('onResult: ${result.recognizedWords}');
            setState(() {
              _text = result.recognizedWords;
              if (result.finalResult) {
                _resetListening();
              }
            });
          },
          listenMode: stt.ListenMode.confirmation,
          onSoundLevelChange: (level) => print('Sound level: $level'),
          cancelOnError: true,
        );
        print('Listening started');
      } catch (e) {
        print('Error starting to listen: $e');
        _resetListening();
      }
    } else {
      print(
          'Cannot start listening. Available: $_isAvailable, Already listening: $_isListening');
    }
  }

  void _stopListening() async {
    print('Stopping listening...');
    await _speech.stop();
    _resetListening();
  }

  void _resetListening() {
    print('Resetting listening state...');
    setState(() {
      _isListening = false;
    });
    print('Listening state reset. _isListening: $_isListening');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_isAvailable
            ? 'Speech recognition available'
            : 'Speech recognition not available'),
        Text('Listening: $_isListening'),
        Text(_text),
        ElevatedButton(
          onPressed: _isAvailable && !_isListening ? _startListening : null,
          child: Text('Start Listening'),
        ),
        ElevatedButton(
          onPressed: _isListening ? _stopListening : null,
          child: Text('Stop Listening'),
        ),
        ElevatedButton(
          onPressed: _initSpeech,
          child: Text('Reinitialize Speech'),
        ),
      ],
    );
  }
}
