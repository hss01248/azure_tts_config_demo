import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsConfigState {
  String apiKey = "";

  String region = "";

  List<Voice> voices = [];
  Voice? selected;
  static bool hasInit = false;

  String textInput = "";



  TtsConfigState() {
    ///Initialize variables
    //textInput = await SharedPreferences.getInstance().get
  }
}
