import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';

import '../audio_player_icon.dart';
import 'tts_files_logic.dart';

class TtsFilesPage extends StatelessWidget {
  final logic = Get.put(TtsFilesLogic());
  final state = Get.find<TtsFilesLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TTS Files(点击播放,长按分享)"),
      ),
      body: GetBuilder<TtsFilesLogic>(
        builder: (controller) {
          return ListView.builder(
              itemCount: state.files.length,
              itemBuilder: (context, index) {
                return buildItem(index);
              });
        },
      ),
    );
  }

  Widget buildItem(int index) {
    String path = state.files[index];

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            AudioPlayerIconWidget(
              path: path,
            ).marginOnly(left: 10),
            Flexible(child: buildRight(path)),
          ],
        ),
        Divider(thickness: 1,height: 1,color: Color(0xffe8e8e8),).marginSymmetric(horizontal: 16)
      ],
    );
  }

  Widget buildRight(String path) {
    File file = File(path);
    String name = path.substring(path.lastIndexOf("/") + 1);
    String size =
        "${NumberFormat('###.0').format(file.lengthSync() / 1024.0)}KB";
    String duration =
        "${NumberFormat('###.0').format(file.lengthSync() / 6 / 1024)}s"; //48k bit/s
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDateTime = dateFormat.format(file.lastModifiedSync());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                flex: 1,
                child: Text(
                  name,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          children: [
            Text(size),
            const SizedBox(
              width: 10,
            ),
            Text(duration),
          ],
        )
      ],
    ).marginAll(10).gestures(
        behavior: HitTestBehavior.opaque,
        onLongPress: () async {
          //长按分享
          final result = await Share.shareXFiles([XFile(path)],
              text: 'amazing azure tts:');
          if (result.status == ShareResultStatus.success) {
            print('Thank you for sharing the tts');
          }
        });
  }
}
