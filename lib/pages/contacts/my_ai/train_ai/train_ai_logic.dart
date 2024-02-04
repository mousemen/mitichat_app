import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:miti/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TrainAiLogic extends GetxController {
  @override
  void onInit() {
    inputCtrl.addListener(() {
      text.value = inputCtrl.text;
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    super.onClose();
  }

  final arguments = Get.arguments;
  final faceURL = Rx<String>(Get.arguments['faceURL']);
  final showName = Rx<String>(Get.arguments['showName']);
  final ai = Rx<Ai>(Get.arguments['ai']);
  final assetsList = <AssetEntity>[].obs;
  final maxLength = 3200.obs;
  final inputCtrl = TextEditingController();
  final text = "".obs;
  final files = <String>[].obs;

  String get count => "${text.value.length}/${maxLength.value}";

  bool get canTain => text.value.length > 0 || files.value.length > 0;

  List<String> get fileNames => files.map((e) => e.split('/').last).toList();

  void startKnowledgeFiles() =>
      AppNavigator.startKnowledgeFiles(knowledgebaseId: ai.value.botID);

  void train() async {
    await LoadingView.singleton.wrap(asyncFunction: () async {
      await Apis.addKnowledge(
          knowledgebaseId: ai.value.botID,
          text: text.value,
          filePathList: files.value);
      inputCtrl.text = '';
      text.value = '';
      files.value = [];
    });
    final confirm = await Get.dialog(SuccessDialog(
      text: StrRes.trainSuccessTips,
      onTapConfirm: () => Get.back(),
    ));
  }

  void selectFile() async {
    await FilePicker.platform.clearTemporaryFiles();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'json', 'md'],
    );

    if (result != null) {
      files.addAll(result.files.map((item) => item.path!).toList());
    }
  }
}
