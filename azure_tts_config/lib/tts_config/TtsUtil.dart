
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
    String fileName = "${DateTime.now().millisecondsSinceEpoch}-${voice.localName}-${replaceVoiceLocalToChinese(voice.locale)}.mp3";
    File file = File(savePath+fileName);
    debugPrint("file path: ${file.path}");
    await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    hideLoadingDialog();
    //然后播放:
    final player = AudioPlayer();
    await player.play(DeviceFileSource(file.path));

    //await player.dispose();
  }


  static String replaceVoiceLocalToChinese(String locale){
    Locale myLocale = Localizations.localeOf(Get.context!);
    String languageCode = myLocale.languageCode; // 例如：'en' 表示英语
    String? countryCode = myLocale.countryCode;   // 例如：'US' 表示美国
    debugPrint("languageCode->$languageCode, countryCode: $countryCode");
    //if(languageCode.contains("zh") || languageCode.contains("CN")){
      //中文环境
      Map<String,String> languageCodes = {
        "ae": "阿拉伯联合酋长国",
        "al": "阿尔巴尼亚",
        "am": "亚美尼亚",
        "ar": "阿根廷",
        "at": "奥地利",
        "az": "阿塞拜疆",
        "ba": "波斯尼亚和黑塞哥维那",
        "be": "比利时",
        "bg": "保加利亚",
        "bh": "巴林",
        "bo": "玻利维亚",
        "br": "巴西",
        "ca": "加拿大",
        "ch": "瑞士",
        "cl": "智利",
        "cn": "中国",
        "co": "哥伦比亚",
        "cr": "哥斯达黎加",
        "cz": "捷克共和国",
        "de": "德国",
        "dk": "丹麦",
        "do": "多米尼加共和国",
        "dz": "阿尔及利亚",
        "ec": "厄瓜多尔",
        "ee": "爱沙尼亚",
        "es": "西班牙",
        "eg": "埃及",
        "fi": "芬兰",
        "fr": "法国",
        "gb": "英国",
        "ge": "格鲁吉亚",
        "gr": "希腊",
        "gt": "危地马拉",
        "hk": "香港特别行政区",
        "hn": "洪都拉斯",
        "hr": "克罗地亚",
        "hu": "匈牙利",
        "id": "印度尼西亚",
        "ie": "爱尔兰",
        "il": "以色列",
        "in": "印度",
        "iq": "伊拉克",
        "ir": "伊朗",
        "is": "冰岛",
        "it": "意大利",
        "jo": "约旦",
        "jp": "日本",
        "ke": "肯尼亚",
        "kr": "朝鲜",
        "kw": "科威特",
        "lb": "黎巴嫩",
        "lt": "立陶宛",
        "lv": "拉脱维亚",
        "lu": "卢森堡",
        "ly": "利比亚",
        "ma": "摩洛哥",
        "mk": "前南斯拉夫马其顿共和国",
        "mt": "马耳他",
        "my": "马来西亚",
        "mx": "墨西哥",
        "ni": "尼加拉瓜",
        "nl": "荷兰",
        "nz": "新西兰",
        "no": "挪威",
        "om": "阿曼",
        "pa": "巴拿马",
        "pe": "秘鲁",
        "ph": "菲律宾共和国",
        "pk": "巴基斯坦伊斯兰共和国",
        "pr": "波多黎各",
        "pt": "葡萄牙",
        "py": "巴拉圭",
        "qa": "卡塔尔",
        "ro": "罗马尼亚",
        "ru": "俄罗斯",
        "sa": "沙特阿拉伯",
        "se": "瑞典",
        "sg": "新加坡",
        "sk": "斯洛伐克",
        "sl": "斯洛文尼亚",
        "sp": "塞尔维亚",
        "sv": "萨尔瓦多",
        "sy": "叙利亚",
        "tw": "台湾",
        "th": "泰国",
        "tn": "突尼斯",
        "tr": "土耳其",
        "ua": "乌克兰",
        "us": "美国",
        "vn": "越南",
        "ye": "也门",
        "za": "南非"
      };
      String title = locale;
      title = title.replaceFirst("wuu", "吴语/上海话");
      title = title.replaceFirst("yue", "粤语");
      title = title.replaceFirst("guangxi", "广西话");
      title = title.replaceFirst("henan", "河南");
      title = title.replaceFirst("liaoning", "东北话");
      title = title.replaceFirst("shaanxi", "陕西秦腔");
      title = title.replaceFirst("shandong", "山东");
      title = title.replaceFirst("sichuan", "四川");
      title = title.replaceFirst("HK", "香港");
      title = title.replaceFirst("TW", "台湾腔");

      //title = title.toLowerCase();
      if(title.contains("-")){
        var split = title.split("-");
        if(split.isNotEmpty){
          String code = split[split.length-1].toLowerCase();
          if(languageCodes.containsKey(code)){
            title = title.replaceAll("-"+code.toUpperCase(), "-"+languageCodes[code]!);
          }
        }
      }
     // voice.shortName.replaceAll(voice.locale, title);
     // voice.locale.replaceAll(voice.locale, title);
    return title;
    }


  //}
}