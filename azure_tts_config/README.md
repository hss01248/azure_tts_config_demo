# azure tts config 

>  flutter ui for azure tts config and test

support by [flutter_azure_tts](https://pub.dev/packages/flutter_azure_tts)

this is a flutter package

full runnable demo is here: 

[azure_tts_config_demo](https://github.com/hss01248/azure_tts_config_demo)

# Usage 

```yaml
  azure_tts_config: ^1.0.4
  get: ^4.6.5
  oktoast: ^3.4.0
  load: ^1.0.0
  flutter_azure_tts: ^0.1.6
```



```dart
runApp(MaterialApp(
    builder: (context, widget) {
      return LoadingProvider(
          themeData: LoadingThemeData(),
          child: OKToast(
            child: GetMaterialApp(home: DemoPagePage()),
          ));
    },
  ));
```

Use the page/widget TtsConfigPage to do azure config and test

### static util method:

```dart
TtsUtil:


 static Future<Voice?> selectedVoice()
   
 static Future<void> initTtsOutSide(String? apiKey, String? region) 
   
 static void changeVoice(Function(Voice voice) callback)
   
 static void goVoiceSettingPage()
   
 static void showTTSFiles()
   
 static Future<Widget?> play(String? text,{bool? returnWidget})
   
 AudioPlayerIconWidget({super.key,
     required this.path,
     this.size = 35,
     this.playImmediately = false,
   })
   
```



# ui

![image-20240424152328608](https://cdn.jsdelivr.net/gh/shuiniuhss/myimages@main/imagemac3/image-20240424152328608.png)



![image-20240424152401823](https://cdn.jsdelivr.net/gh/shuiniuhss/myimages@main/imagemac3/image-20240424152401823.png)
