# azure tts config 

>  flutter ui for azure tts config and test

support by [flutter_azure_tts](https://pub.dev/packages/flutter_azure_tts)

this is a flutter package

full demo is here: 



# Usage 

```yaml
  azure_tts_config: ^0.0.1
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
            child: GetMaterialApp(home: TtsConfigPage()),
          ));
    },
  ));
```

Use the page/widget TtsConfigPage to do azure config and test

### static method:

```dart
TtsConfigLogic:


 static Future<Voice?> selectedVoice()
   
 static Future<void> initTtsOutSide(String? apiKey, String? region) 
```







# ui

![image-20240423160839009](https://cdn.jsdelivr.net/gh/shuiniuhss/myimages@main/imagemac3/image-20240423160839009.png)



