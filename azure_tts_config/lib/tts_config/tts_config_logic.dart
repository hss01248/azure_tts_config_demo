import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:get/get.dart';
import 'package:load/load.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tts_config_state.dart';

class TtsConfigLogic extends GetxController {
  final TtsConfigState state = TtsConfigState();
  SharedPreferences? prefs ;



  @override
  Future<void> onReady() async {
    // TODO: implement onReady
    super.onReady();
    prefs = await SharedPreferences.getInstance();
    initTts(false);
    String? selected = prefs!.getString("tts-voice-selected");
    if(selected !=null && selected.isNotEmpty){
      state.selected = Voice.fromJson(jsonDecode(selected));
    }
    state.textInput = prefs!.getString("tts-demoStr")??"";

    String? vos = prefs!.getString("tts-voices");
    List<Voice> voices = [];
    if(vos !=null && vos.isNotEmpty){
      List<dynamic> list = jsonDecode(vos);
      list.forEach((element) {
        Map<String,dynamic> e = element;
        Voice voice = Voice.fromJson(e);
        if(voice.localName == state.selected?.localName
        && voice.locale == state.selected?.locale){
          state.selected = voice;
        }
        voices.add(voice);
      });
      state.mapVoice(voices) ;
    }
    Future.delayed(Duration(seconds: 1)).then((value) => update());
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<void> fetchVoices(bool fromUI) async {
    /*String? vos = prefs!.getString("tts-voices");
    List<Voice> voices = [];
    if(vos !=null && vos.isNotEmpty){
      List<dynamic> list = jsonDecode(vos);
      list.forEach((element) {
        Map<String,dynamic> e = element;
        voices.add(Voice.fromJson(e));
      });
    }else{
      final voicesResponse = await AzureTts.getAvailableVoices();
      voices = voicesResponse.voices;
      prefs!.setString("tts-voices", jsonEncode(voices));
    }*/
    // Get available voices
    if(state.voices.isEmpty){
      if(fromUI){
        showLoadingDialog();
      }
      List<Voice> voices = [];
      final voicesResponse = await AzureTts.getAvailableVoices();
      voices = voicesResponse.voices;

      //Print all available voices
      print("$voices");
      if(fromUI){
        hideLoadingDialog();
      }
      state.mapVoice(voices,fromHttp: true);
      prefs!.setString("tts-voices", jsonEncode(voices));
      update();
    }
  }

  void onVoiceSelected(Voice e) {
    state.selected = e;
    update();
    prefs!.setString("tts-voice-selected", jsonEncode(e));
  }

  void onTextInputChanged(String value) {
    state.textInput = value;
    prefs!.setString("tts-demoStr", value);
  }





  Future<void> initTts(bool fromUI) async {
    if(!fromUI){
      String? apikey = prefs!.getString("tts-apikey");
      String? region = prefs!.getString("tts-region");
      if(apikey !=null && apikey.isNotEmpty){
        state.apiKey = apikey;
      }
      if(region !=null && region.isNotEmpty){
        state.region = region;
      }
    }
    if(state.apiKey.isEmpty){
      if(fromUI){
        showToast("apiKey isEmpty");
      }
        return;
    }
    if(state.region.isEmpty){
      if(fromUI){
        showToast("region isEmpty");

      }
      return;
    }
    try{
      if(!TtsConfigState.hasInit){
        AzureTts.init(
            subscriptionKey: state.apiKey,
            region: state.region,
            withLogs: true);
        TtsConfigState.hasInit = true;
      }

      update();
      if(fromUI){
        showToast("azure tts init success");
        prefs!.setString("tts-apikey",state.apiKey);
        prefs!.setString("tts-region",state.region);
      }
       fetchVoices(fromUI);
    }catch(e,s){
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      if(fromUI){
        showToast(e.toString());
      }
    }
  }


}
