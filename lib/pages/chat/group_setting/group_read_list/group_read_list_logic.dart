import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../core/ctrl/im_ctrl.dart';

class GroupReadListLogic extends GetxController {
  final imCtrl = Get.find<IMCtrl>();
  late StreamSubscription recvGroupReadReceiptSubject;
  late String conversationID;
  late String clientMsgID;
  String groupID = '';
  List<String> hasReadIDList = [];
  int needReadCount = 0;
  final hasReadMemberList = <GroupMembersInfo>[].obs;
  final unreadMemberList = <GroupMembersInfo>[].obs;
  final hasReadRefreshController = RefreshController();
  final unreadRefreshController = RefreshController();
  final index = 0.obs;
  final count = 100000;

  @override
  void onInit() {
    conversationID = Get.arguments['conversationID'];
    clientMsgID = Get.arguments['clientMsgID'];
    queryHasReadMembers();
    queryUnreadMembers();
    recvGroupReadReceiptSubject = imCtrl.recvGroupReadReceiptSubject
        .listen((GroupMessageReceipt receipt) {
      if (receipt.conversationID == conversationID) {
        final msg = receipt.groupMessageReadInfo
            .firstWhereOrNull((element) => element.clientMsgID == clientMsgID);
        if (msg != null) {
          queryHasReadMembers();
          queryUnreadMembers();
        }
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    recvGroupReadReceiptSubject.cancel();
    super.onClose();
  }

  void queryHasReadMembers() async {
    final list = await OpenIM.iMManager.messageManager
        .getGroupMessageReaderList(conversationID, clientMsgID, count: count);
    hasReadMemberList.assignAll(list);
  }

  void queryUnreadMembers() async {
    final list = await OpenIM.iMManager.messageManager
        .getGroupMessageReaderList(conversationID, clientMsgID,
            filter: 1, count: count);

    unreadMemberList.assignAll(list);

    list.length == count? unreadRefreshController.loadComplete(): unreadRefreshController.loadNoData();
  }

  void switchTab(i) {
    if (i == 0) {
      queryHasReadMembers();
    } else if(i == 1){
      queryUnreadMembers();
    }
    index.value = i;
  }

  int get unreadCount => unreadMemberList.length;

  int get hasReadCount => hasReadMemberList.length;
}
