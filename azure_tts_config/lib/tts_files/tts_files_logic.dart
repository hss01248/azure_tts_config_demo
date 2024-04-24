import 'dart:io';

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
    var listSync = directory.listSync();
    listSync.forEach((element) {
      state.files.add(element.path);
    });
    update();
  }
}
