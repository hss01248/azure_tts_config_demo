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

  /// 全局获取当前的voice
  static Future<Voice?> selectedVoice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selected = prefs.getString("tts-voice-selected");
    if(selected !=null && selected.isNotEmpty){
      return Voice.fromJson(jsonDecode(selected));
    }
    return null;
  }
  static Future<void> initTtsOutSide(String? apiKey, String? region) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(apiKey !=null && region !=null && apiKey.isNotEmpty && region.isNotEmpty){
      prefs.setString("tts-apikey",apiKey);
      prefs.setString("tts-region",region);
    }

    String? apiKey2 = prefs.getString("tts-apikey");
    String? region2 = prefs.getString("tts-region");
    if(apiKey2 !=null && region2 !=null && apiKey2.isNotEmpty && region2.isNotEmpty){
      AzureTts.init(
          subscriptionKey: apiKey2,
          region: region2,
          withLogs: true);
      TtsConfigState.hasInit = true;
    }else{
      debugPrint("prefs.getString(tts-apikey)  is null , tts init failed");
    }
  }
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
      state.voices = voices;
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
      prefs!.setString("tts-voices", jsonEncode(voices));
      //Print all available voices
      print("$voices");
      if(fromUI){
        hideLoadingDialog();
      }
      state.voices = voices;
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
  }

  Future<void> startGenTts() async {
    if(state.selected ==null){
      showToast("voice not selected");
      return;
    }
    if(state.textInput.isEmpty){
      showToast("text input is empty");
      return;
    }
    showLoadingDialog();
    try{
      TtsParams params = TtsParams(
          voice: state.selected!,
          audioFormat: AudioOutputFormat.audio24khz48kBitrateMonoMp3,
          rate: 1.0, // optional prosody rate (default is 1.0)
          text: state.textInput);

      final ttsResponse = await AzureTts.getTts(params);

      //Get the audio bytes.
      final audioBytes = ttsResponse.audio.buffer
          .asByteData(); // you can save to a file for playback
      String str = "Audio size: ${(audioBytes.lengthInBytes / (1024 )).toStringAsPrecision(2)} kB";
      print(str);

      // showToast(str);
      save(audioBytes);
    }catch(e,s){
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      hideLoadingDialog();
    }
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
      AzureTts.init(
          subscriptionKey: state.apiKey,
          region: state.region,
          withLogs: true);
      TtsConfigState.hasInit = true;
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

  Future<void> save(ByteData bytes) async {

    ///手机储存目录
    Directory appDocDir = await getApplicationDocumentsDirectory();
    if(Platform.isAndroid){
      Directory? result = await getExternalStorageDirectory();
      if(result != null){
        appDocDir = result;
      }
    }
    String savePath = "${appDocDir.path}/audio_tts/";
    Directory directory = Directory(savePath);
    if(!directory.existsSync()){
      directory.createSync();
    }
    String fileName = "${DateTime.now().millisecondsSinceEpoch}-${state.selected?.localName}-${state.selected?.locale}.mp3";
    File file = File(savePath+fileName);
    debugPrint("file path: ${file.path}");
   await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    hideLoadingDialog();
    //然后播放:
    final player = AudioPlayer();
    await player.play(DeviceFileSource(file.path));

    //await player.dispose();
  }
}
