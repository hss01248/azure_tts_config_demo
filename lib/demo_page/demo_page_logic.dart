import 'package:azure_tts_config/tts_config/TtsUtil.dart';
import 'package:get/get.dart';

import 'demo_page_state.dart';

class DemoPageLogic extends GetxController {
  final DemoPageState state = DemoPageState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    Future.delayed(Duration(seconds: 1)).then((value) async {
      state.selectedVoice = await TtsUtil.selectedVoice();
      update();
    });
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
