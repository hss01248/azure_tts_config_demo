
import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:get/get.dart';
import 'package:load/load.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tts_config_state.dart';
import 'tts_config_view.dart';

class TtsUtil{

  static SharedPreferences? prefs;

  static Future<SharedPreferences> init() async {
    prefs ??= await SharedPreferences.getInstance();
    return prefs!;
  }


  /// 全局获取当前的voice
  static Future<Voice?> selectedVoice() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selected = prefs.getString("tts-voice-selected");
    if(selected !=null && selected.isNotEmpty){
      return Voice.fromJson(jsonDecode(selected));
    }
    return null;
  }


  static void changeVoice(Function(Voice voice) callback){
    Get.dialog(TtsConfigPage(changeVoiceCallback: callback));
  }

  static void goVoiceSettingPage(){
    Get.dialog(TtsConfigPage());
  }



  static Future<void> initTtsOutSide({String? apiKey, String? region,bool toastIfInitFailed= false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(apiKey !=null && region !=null && apiKey.isNotEmpty && region.isNotEmpty){
      prefs.setString("tts-apikey",apiKey);
      prefs.setString("tts-region",region);
    }

    String? apiKey2 = prefs.getString("tts-apikey");
    String? region2 = prefs.getString("tts-region");
    if(TtsConfigState.hasInit){
      return;
    }
    if(apiKey2 !=null && region2 !=null && apiKey2.isNotEmpty && region2.isNotEmpty){
      try{
        AzureTts.init(
            subscriptionKey: apiKey2,
            region: region2,
            withLogs: true);
        TtsConfigState.hasInit = true;
      }catch(e,s){
        debugPrint(e.toString());
        if(toastIfInitFailed == true){
          showToast(e.toString());
        }
      }
    }else{
      debugPrint("prefs.getString(tts-apikey)  is null , tts init failed");
      if(toastIfInitFailed == true){
        showToast("apikey or region is empty");
      }
    }
  }

  static Future<void> play(String? text) async {
    if(text ==null || text.isEmpty){
      showToast("text is empty");
      return;
    }
   await  initTtsOutSide(toastIfInitFailed: true);

    Voice? voice = await selectedVoice();
    if(voice ==null){
      showToast("please go settings page and select voice");
      return;
    }
    await startGenTts(voice, text);
  }


  static   Future<void> startGenTts(Voice? voice,String textInput) async {
    if(voice ==null){
      showToast("voice not selected");
      return;
    }
    if(textInput.isEmpty){
      showToast("text input is empty");
      return;
    }
    showLoadingDialog();
    try{
      TtsParams params = TtsParams(
          voice: voice,
          audioFormat: AudioOutputFormat.audio24khz48kBitrateMonoMp3,
          rate: 1.0, // optional prosody rate (default is 1.0)
          text: textInput);

      final ttsResponse = await AzureTts.getTts(params);

      //Get the audio bytes.
      final audioBytes = ttsResponse.audio.buffer
          .asByteData(); // you can save to a file for playback
      String str = "Audio size: ${(audioBytes.lengthInBytes / (1024 )).toStringAsPrecision(2)} kB";
      print(str);

      // showToast(str);
      save(audioBytes,voice);
    }catch(e,s){
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      hideLoadingDialog();
    }
  }


  static Future<void> save(ByteData bytes,Voice voice) async {

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
    String fileName = "${DateTime.now().millisecondsSinceEpoch}-${voice.localName}-${voice.locale}.mp3";
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