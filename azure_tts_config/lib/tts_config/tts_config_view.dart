import 'package:flutter/material.dart';
import 'package:flutter_azure_tts/flutter_azure_tts.dart';
import 'package:get/get.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:styled_widget/styled_widget.dart';

import 'tts_config_logic.dart';
import 'tts_config_state.dart';

class TtsConfigPage extends StatelessWidget {
  final logic = Get.put(TtsConfigLogic());
  final state = Get.find<TtsConfigLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TTS Test"),
      ),
      body: GetBuilder<TtsConfigLogic>(
        builder: (controller) {
          return Column(children: [
            inputAndInit().marginAll(10),
            voices(),
            //输入框
            TextFormField(
              maxLines: 6,
              onChanged: (value) {
                logic.onTextInputChanged(value);
              },
            ).paddingAll(4).border(all: 0.5, color: Colors.blueAccent),
            const SizedBox(
              height: 10,
            ),
            //按钮
            ElevatedButton(
                    onPressed: () {
                      logic.startGenTts();
                    },
                    child: const Text("do tts"))
                .width(double.infinity)
          ]).marginSymmetric(horizontal: 16, vertical: 10).scrollable();
        },
      ),
    );
  }

  Widget inputAndInit() {
    return Column(
      children: [
        Row(
          children: [
            const Text("apiKey:"),
            Expanded(
                child: TextFormField(
              initialValue: state.apiKey,
              onChanged: (value) {
                state.apiKey = value;
              },
            ))
          ],
        ),
        Row(
          children: [
            const Text("region:"),
            Expanded(
                child: TextFormField(
              initialValue: state.region,
              onChanged: (value) {
                state.region = value;
              },
            ))
          ],
        ),
        ElevatedButton(
                onPressed: TtsConfigState.hasInit
                    ? null
                    : () {
                        logic.initTts(true);
                      },
                child: Text(TtsConfigState.hasInit ? "has init" : "do init"))
            .width(double.infinity)
      ],
    );
  }

  Widget voices() {
    String str = "";
    if(state.selected !=null){
      Voice e = state.selected!;
      str = "${e.displayName}/${e.localName}, ${e.gender} ,${e.locale},${e.status}";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("available voices:").marginOnly(bottom: 8),
        /*Column(
          children: state.voices.map((e) {
            return voiceItem(e);
          }).toList(),
        )*/
        ResponsiveGridList(
          horizontalGridSpacing: 5,
          // Horizontal space between grid items
          verticalGridSpacing: 5,
          // Vertical space between grid items
          horizontalGridMargin: 0,
          // Horizontal space around the grid
          verticalGridMargin: 2,
          // Vertical space around the grid
          minItemWidth: 100,
          // The minimum item width (can be smaller, if the layout constraints are smaller)
          minItemsPerRow: 1,
          // The minimum items to show in a single row. Takes precedence over minItemWidth
          maxItemsPerRow: 5,
          // The maximum items to show in a single row. Can be useful on large screens
          listViewBuilderOptions: ListViewBuilderOptions(),
          // Options that are getting passed to the SliverChildBuilderDelegate() function
          children: state.voices.map((e) {
            return voiceItem(e);
          }).toList(), // The list of widgets in the list
        ).height(450).border(all: 0.5,color: Colors.green),
        Text("voice chosen: $str").marginSymmetric(vertical: 8),
      ],
    );
  }

  Widget voiceItem(Voice e) {
    return Text("${e.displayName}/${e.localName}, ${e.gender} ,${e.locale},${e.status}")
        .paddingAll(8)
        .backgroundColor(
            e == state.selected ? Colors.green : Colors.transparent)
        .gestures(onTap: () {
      logic.onVoiceSelected(e);
    });
  }
}
