import 'package:flutter_azure_tts/flutter_azure_tts.dart';

class TtsConfigState {
  String apiKey = "";

  String region = "";

  List<Voice> voices = [];
  Voice? selected;
  static bool hasInit = false;

  String textInput = "";



  TtsConfigState() {
    ///Initialize variables
  }
}
