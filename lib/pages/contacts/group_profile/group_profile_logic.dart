import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';

import '../../../core/ctrl/im_ctrl.dart';
import '../../../routes/app_navigator.dart';
import '../../conversation/conversation_logic.dart';

enum JoinGroupMethod { search, qrcode, invite }

class GroupProfileLogic extends GetxController {
  final conversationLogic = Get.find<ConversationLogic>();
  final imCtrl = Get.find<IMCtrl>();
  final isJoined = false.obs;
  final members = <GroupMembersInfo>[].obs;
  late Rx<GroupInfo> groupInfo;
  late JoinGroupMethod joinGroupMethod;

  late StreamSubscription sub;
  late StreamSubscription joinedGroupAddedSub;
  late StreamSubscription memberAddedSub;

  @override
  void onInit() {
    super.onInit();
    groupInfo = Rx(GroupInfo(groupID: Get.arguments['groupID']));
    joinGroupMethod = Get.arguments['joinGroupMethod'];
    sub = imCtrl.groupApplicationChangedSubject.listen(_onChanged);
    joinedGroupAddedSub = imCtrl.joinedGroupAddedSubject.listen(_onChanged);
    memberAddedSub = imCtrl.memberAddedSubject.listen(_onChanged);
    _checkGroup();
    _getGroupInfo();
    _getMembers();
  }

  _onChanged(dynamic value) {
    if (value is GroupApplicationInfo) {
      if (value.groupID == groupInfo.value.groupID && value.handleResult == 1) {
        if (!isJoined.value) {
          isJoined.value = true;
          _getGroupInfo();
          _getMembers();
        }
      }
    } else if (value is GroupInfo) {
      if (value.groupID == groupInfo.value.groupID) {
        if (!isJoined.value) {
          isJoined.value = true;
          _getGroupInfo();
          _getMembers();
        }
      }
    } else if (value is GroupMembersInfo) {
      if (value.groupID == groupInfo.value.groupID &&
          value.userID == OpenIM.iMManager.userID) {
        if (!isJoined.value) {
          isJoined.value = true;
          _getGroupInfo();
          _getMembers();
        }
      }
    }
  }

  _getGroupInfo() async {
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      groupIDList: [groupInfo.value.groupID],
    );
    var info = list.firstOrNull;
    if (null != info) {
      groupInfo.update((val) {
        val?.groupName = info.groupName;
        val?.faceURL = info.faceURL;
        val?.memberCount = info.memberCount;
        val?.groupType = info.groupType;
        val?.createTime = info.createTime;
      });
    }
  }

  _checkGroup() async {
    isJoined.value = await OpenIM.iMManager.groupManager.isJoinedGroup(
      groupID: groupInfo.value.groupID,
    );
  }

  _getMembers() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMemberList(
      groupID: groupInfo.value.groupID,
      count: 10,
    );
    members.assignAll(list);
  }

  enterGroup() async {
    if (isJoined.value) {
      conversationLogic.toChat(
        groupID: groupInfo.value.groupID,
        nickname: groupInfo.value.groupName,
        faceURL: groupInfo.value.faceURL,
        sessionType: groupInfo.value.sessionType,
      );
    } else {
      AppNavigator.startSendApplication(
        groupID: groupInfo.value.groupID,
        joinGroupMethod: joinGroupMethod,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
    sub.cancel();
    joinedGroupAddedSub.cancel();
    memberAddedSub.cancel();
  }
}
