import 'package:azure_tts_config/tts_config/TtsUtil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:styled_widget/styled_widget.dart';

import 'demo_page_logic.dart';

class DemoPagePage extends StatelessWidget {
  final logic = Get.put(DemoPageLogic());
  final state = Get.find<DemoPageLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("demo"),
      ),
      body: GetBuilder<DemoPageLogic>(
        builder: (controller) {
          return Column(
            children: [
              Text("老王掉进了水井里，在村民的热心帮助下，老王终于适应了水井里面的生活。"),
              SizedBox(height: 5,),
              Row(
                children: [
                  Expanded(child: ElevatedButton(
                      onPressed: () async {
                        String text = "老王掉进了水井里，在村民的热心帮助下，老王终于适应了水井里面的生活。";
                        state.widget =
                        await TtsUtil.play(text, returnWidget: true);
                        logic.update();
                      },
                      child: Text("play some text"))),
                  SizedBox(
                    width: 10,
                  ),
                  state.widget == null ? SizedBox() : state.widget!,
                ],
              ).width(double.infinity),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                      onPressed: () {
                        TtsUtil.changeVoice((voice) {
                          state.selectedVoice = voice;
                          logic.update();
                        });
                      },
                      child: Text(
                          "change voice : ${state.selectedVoice?.shortName}"))
                  .width(double.infinity),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                      onPressed: () {
                        TtsUtil.goVoiceSettingPage();
                      },
                      child: Text("open config page"))
                  .width(double.infinity),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                      onPressed: () {
                        Locale myLocale = Localizations.localeOf(Get.context!);
                        String languageCode =
                            myLocale.languageCode; // 例如：'en' 表示英语
                        String? countryCode =
                            myLocale.countryCode; // 例如：'US' 表示美国
                        String str =
                            "languageCode->$languageCode, countryCode: $countryCode";
                        debugPrint(str);
                        showToast(str);
                      },
                      child: Text("language code/countrycode"))
                  .width(double.infinity),
            ],
          ).marginAll(16);
        },
      ),
    );
  }
}
