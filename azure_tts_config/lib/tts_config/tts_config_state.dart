import 'package:azure_tts_config/tts_config/TtsUtil.dart';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsConfigState {
  String apiKey = "";

  String region = "";

  List<Voice> voices = [];
  Map<String,List<Voice>> voiceTabs = {};
  Voice? selected;
  static bool hasInit = false;

  String textInput = "";

  void mapVoice(List<Voice> voices,{bool fromHttp = false}){
    this.voices = voices;
    voiceTabs.clear();

/*    if(fromHttp == true){
      this.voices.forEach((element) {
        TtsUtil.replaceVoiceLocalToChinese(element);
      });
    }*/

    //将含zh/CN/en的移到最前面
    this.voices.forEach((element) {
      if(element.locale.contains("zh-") || element.locale.contains("-CN") ){
        if(voiceTabs.containsKey(element.locale)){
          voiceTabs[element.locale]!.add(element);
        }else{
          voiceTabs[element.locale] = [];
          voiceTabs[element.locale]!.add(element);
        }
      }
    });
    this.voices.forEach((element) {
      if( element.locale.contains("en-")){
        if(voiceTabs.containsKey(element.locale)){
          voiceTabs[element.locale]!.add(element);
        }else{
          voiceTabs[element.locale] = [];
          voiceTabs[element.locale]!.add(element);
        }
      }
    });
    this.voices.forEach((element) {
      if(!element.locale.contains("zh-") && !element.locale.contains("-CN") && !element.locale.contains("en-")){
        if(voiceTabs.containsKey(element.locale)){
          voiceTabs[element.locale]!.add(element);
        }else{
          voiceTabs[element.locale] = [];
          voiceTabs[element.locale]!.add(element);
        }
      }
    });



  }



  TtsConfigState() {
    ///Initialize variables
    //textInput = await SharedPreferences.getInstance().get
  }
}
