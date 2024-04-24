import 'dart:io';

import 'package:azure_tts_config/tts_config/TtsUtil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'tts_files_state.dart';

class TtsFilesLogic extends GetxController {
  final TtsFilesState state = TtsFilesState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    loadDir();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<void> loadDir() async {
    Directory directory = await TtsUtil.ttsDir();
    var listSync = directory.listSync();
    listSync.forEach((element) {
      state.files.add(element.path);
    });
    update();
  }
}
