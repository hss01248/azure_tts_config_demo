import 'package:azure_tts_config/tts_config/TtsUtil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'demo_page_logic.dart';

class DemoPagePage extends StatelessWidget {
  final logic = Get.put(DemoPageLogic());
  final state = Get.find<DemoPageLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("demo"),),
      body: GetBuilder<DemoPageLogic>(
        builder: (controller) {
          return Column(
            children: [
              Row(
                children: [
                  ElevatedButton(onPressed: () async {
                    String text = "小米创办人、董事长兼CEO雷军在小米集团投资者大会上表示，"
                        "目前智驾团队一年预算大概15亿人民币左右，大概超过1000名工程师.";
                    state.widget = await TtsUtil.play(text,returnWidget: true);
                    logic.update();
                  }, child:  Text("play some text")),
                  SizedBox(width: 10,),
                  state.widget==null  ? SizedBox() :  state.widget!,
                ],
              ),

              ElevatedButton(onPressed: (){
                TtsUtil.changeVoice((voice){
                  state.selectedVoice = voice;
                  logic.update();
                });
              }, child: Text("change voice : ${state.selectedVoice?.shortName}")),
              ElevatedButton(onPressed: (){
                TtsUtil.goVoiceSettingPage();
              }, child: Text("open config page")),
              ElevatedButton(onPressed: (){
                Locale myLocale = Localizations.localeOf(Get.context!);
                String languageCode = myLocale.languageCode; // 例如：'en' 表示英语
                String? countryCode = myLocale.countryCode;   // 例如：'US' 表示美国
                String str = "languageCode->$languageCode, countryCode: $countryCode";
                debugPrint(str);
                showToast(str);
              }, child: Text("language code/countrycode")),
            ],
          ).marginAll(16);
        },
      ),
    );
  }
}
