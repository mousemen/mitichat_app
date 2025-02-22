import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miti_common/miti_common.dart';

import 'group_manage_logic.dart';

class GroupManagePage extends StatelessWidget {
  final logic = Get.find<GroupManageLogic>();

  GroupManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrLibrary.groupManage,
      ),
      backgroundColor: StylesLibrary.c_F8F9FA,
      body: Obx(() => Column(
            children: [
              10.verticalSpace,
              _itemView(
                text: StrLibrary.muteAllMember,
                switchOn: logic.groupInfo.value.status == 3,
                onChanged: (_) => logic.toggleGroupMute(),
                showSwitchButton: true,
                isTopRadius: true,
                isBottomRadius: true,
              ),
              10.verticalSpace,
              _itemView(
                text: StrLibrary.notAllowSeeMemberProfile,
                switchOn: logic.allowLookProfiles,
                onChanged: (_) => logic.toggleMemberProfiles(),
                showSwitchButton: true,
                isTopRadius: true,
              ),
              _itemView(
                text: StrLibrary.notAllAddMemberToBeFriend,
                switchOn: logic.allowAddFriend,
                onChanged: (_) => logic.toggleAddMemberToFriend(),
                showSwitchButton: true,
              ),
              _itemView(
                text: StrLibrary.joinGroupSet,
                value: logic.joinGroupOption,
                onTap: logic.modifyJoinGroupSet,
                showRightArrow: true,
                isBottomRadius: true,
              ),
              10.verticalSpace,
              _itemView(
                text: StrLibrary.transferGroupOwnerRight,
                onTap: logic.transferGroupOwnerRight,
                showRightArrow: true,
                isTopRadius: true,
                isBottomRadius: true,
              ),
            ],
          )),
    );
  }

  Widget _itemView({
    required String text,
    TextStyle? textStyle,
    String? value,
    bool switchOn = false,
    bool isTopRadius = false,
    bool isBottomRadius = false,
    bool showRightArrow = false,
    bool showSwitchButton = false,
    ValueChanged<bool>? onChanged,
    Function()? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Container(
          height: 46.h,
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: StylesLibrary.c_FFFFFF,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(isTopRadius ? 6.r : 0),
              topLeft: Radius.circular(isTopRadius ? 6.r : 0),
              bottomLeft: Radius.circular(isBottomRadius ? 6.r : 0),
              bottomRight: Radius.circular(isBottomRadius ? 6.r : 0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: text.toText
                  ..style = textStyle ?? StylesLibrary.ts_333333_16sp,
              ),
              if (null != value)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 150.w),
                  child: value.toText
                    ..style = StylesLibrary.ts_999999_14sp
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                ),
              if (showSwitchButton)
                CupertinoSwitch(
                  value: switchOn,
                  activeColor: StylesLibrary.c_07C160,
                  onChanged: onChanged,
                ),
              if (showRightArrow)
                ImageLibrary.appRightArrow.toImage
                  ..width = 24.w
                  ..height = 24.h,
            ],
          ),
        ),
      );
}
