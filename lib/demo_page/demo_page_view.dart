import 'package:azure_tts_config/tts_config/TtsUtil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              ElevatedButton(onPressed: (){
                String text = "小米创办人、董事长兼CEO雷军在小米集团投资者大会上表示，"
                    "目前智驾团队一年预算大概15亿人民币左右，大概超过1000名工程师，"
                    "下一步阶段今年将扩充到1500人，明年扩充到2000人，进一步加大在智驾的投入。"
                    "海外市场规划方面，雷军表示，从业务部署来说，未来三年里会100%聚焦在国内市场，把中国市场做好是小米汽车的第一步。";
                TtsUtil.play(text);
              }, child: Text("play some text")),
              ElevatedButton(onPressed: (){
                TtsUtil.changeVoice((voice){
                  state.selectedVoice = voice;
                  logic.update();
                });
              }, child: Text("change voice : ${state.selectedVoice?.shortName}")),
              ElevatedButton(onPressed: (){
                TtsUtil.goVoiceSettingPage();
              }, child: Text("open config page")),
            ],
          ).marginAll(16);
        },
      ),
    );
  }
}
