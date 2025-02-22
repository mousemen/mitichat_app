import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miti_common/miti_common.dart';
import 'chat_setting_logic.dart';

class ChatSettingPage extends StatelessWidget {
  final logic = Get.find<ChatSettingLogic>();

  ChatSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
          title: StrLibrary.chatDetail,
          backgroundColor: StylesLibrary.transparent),
      backgroundColor: StylesLibrary.c_F7F8FA,
      body: SingleChildScrollView(
        child: Obx(() => Column(
              children: [
                _buildBaseInfoView(),
                // _buildContentSearchView(),
                _buildItemView(
                  text: StrLibrary.chatSearch,
                  showRightArrow: true,
                  isTopRadius: true,
                  isBottomRadius: true,
                  onTap: logic.chatHistory,
                ),
                15.verticalSpace,
                _buildItemView(
                    text: StrLibrary.messageNotDisturb,
                    switchOn: logic.isNotDisturb,
                    onChanged: (_) => logic.toggleNotDisturb(),
                    showSwitchButton: true,
                    isTopRadius: true),
                _buildItemView(
                    text: StrLibrary.topContacts,
                    switchOn: logic.isPinned,
                    onChanged: (_) => logic.toggleTopContacts(),
                    showSwitchButton: true,
                    showBorder: true),
                // _buildItemView(
                //   text: StrLibrary .remind,
                //   switchOn: false,
                //   // onChanged: (_) => logic.toggleNotDisturb(),
                //   showSwitchButton: true,
                //   isBottomRadius: true,
                // ),
                // _buildItemView(
                //     text: StrLibrary.chatEncryption,
                //     switchOn: true,
                //     // onChanged: (_) => showDeveloping(),
                //     showSwitchButton: true,
                //     showBorder: true),
                _buildItemView(
                    text: StrLibrary.burnAfterReading,
                    switchOn: logic.isBurnAfterReading,
                    onChanged: (_) => logic.toggleBurnAfterReading(),
                    showSwitchButton: true,
                    isBottomRadius: logic.isBurnAfterReading ? false : true,
                    showBorder: true),
                if (logic.isBurnAfterReading)
                  _buildItemView(
                      text: "  - " + StrLibrary.timeSet,
                      value: logic.getBurnAfterReadingDurationStr,
                      onTap: logic.setBurnAfterReadingDuration,
                      showRightArrow: true,
                      isBottomRadius: true,
                      showBorder: true),
                //   _buildItemView(
                //   text: StrLibrary .autoTranslate,
                //   switchOn: logic.isAutoTranslate,
                //   onChanged: (_) => logic.toggleAutoTranslate(),
                //   showSwitchButton: true,
                //   isTopRadius: true,
                //   isBottomRadius: logic.isAutoTranslate ? false : true,
                // ),
                // _buildItemView(
                //     text: StrLibrary .targetLang,
                //     value: logic.targetLangStr,
                //     onTap: logic.setTargetLang,
                //     showRightArrow: true,
                //     isBottomRadius: true,
                //   ),
                15.verticalSpace,
                _buildItemView(
                  text: StrLibrary.setChatBackground,
                  onTap: logic.backgroundSetting,
                  showRightArrow: true,
                  isTopRadius: true,
                  isBottomRadius: true,
                ),
                15.verticalSpace,
                _buildItemView(
                  text: StrLibrary.clearChatHistory,
                  textStyle: StylesLibrary.ts_333333_16sp,
                  onTap: logic.clearChatHistory,
                  // showRightArrow: true,
                  isTopRadius: true,
                  isBottomRadius: true,
                ),
                15.verticalSpace,
                _buildItemView(
                  text: StrLibrary.complaint,
                  textStyle: StylesLibrary.ts_333333_16sp,
                  onTap: logic.complaint,
                  showRightArrow: true,
                  isTopRadius: true,
                  isBottomRadius: true,
                ),
                // 10.verticalSpace,
                // _buildItemView(
                //   text: StrLibrary .complaint,
                //   showRightArrow: true,
                //   isTopRadius: true,
                //   isBottomRadius: true,
                //   onTap: () => showDeveloping(),
                // ),

                // 10.verticalSpace,
                // _buildItemView(
                //   text: StrLibrary .periodicallyDeleteMessage,
                //   switchOn: logic.isMsgDestruct,
                //   onChanged: (_) => logic.toggleDestructMessage(),
                //   showSwitchButton: true,
                //   isTopRadius: true,
                //   isBottomRadius: logic.isMsgDestruct ? false : true,
                // ),
                // if (logic.isMsgDestruct)
                //   _buildItemView(
                //     text: StrLibrary .timeSet,
                //     value: logic.getDestructDurationStr,
                //     onTap: logic.setDestructMessageDuration,
                //     showRightArrow: true,
                //     isBottomRadius: true,
                //   ),
                // 10.verticalSpace,

                // _buildItemView(
                //   text: StrLibrary .fontSize,
                //   onTap: logic.setFontSize,
                //   showRightArrow: true,
                //   isBottomRadius: true,
                // ),
              ],
            )),
      ),
    );
  }

  Widget _buildBaseInfoView() => Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: logic.viewUserInfo,
              child: SizedBox(
                width: 42.w,
                child: Column(
                  children: [
                    AvatarView(
                      width: 42.w,
                      height: 42.h,
                      text: logic.conversationInfo.value.showName,
                      url: logic.conversationInfo.value.faceURL,
                    ),
                    // 8.verticalSpace,
                    // (logic.conversationInfo.value.showName ?? '').toText
                    //   ..style = StylesLibrary.ts_999999_14sp
                    //   ..maxLines = 1
                    //   ..overflow = TextOverflow.ellipsis,
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 72.w,
              child: Column(
                children: [
                  ImageLibrary.addFriendTobeGroup2.toImage
                    ..width = 42.w
                    ..height = 42.h
                    ..color = StylesLibrary.c_CCCCCC
                    ..onTap = logic.createGroup,
                  // 8.verticalSpace,
                  // ''.toText
                  //   ..style = StylesLibrary.ts_999999_14sp
                  //   ..maxLines = 1
                  //   ..overflow = TextOverflow.ellipsis,
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildContentSearchView() {
    Widget childItemView({
      required String icon,
      required String text,
      Function()? onTap,
    }) =>
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: Column(
            children: [
              icon.toImage
                ..width = 28.w
                ..height = 28.h,
              4.verticalSpace,
              text.toText..style = StylesLibrary.ts_999999_14sp
            ],
          ),
        );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: StylesLibrary.c_FFFFFF,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StrLibrary.chatContent.toText..style = StylesLibrary.ts_999999_14sp,
          12.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              childItemView(
                icon: ImageLibrary.chatSearch,
                text: StrLibrary.search,
                onTap: logic.chatHistory,
              ),
              childItemView(
                icon: ImageLibrary.chatSearchPic,
                text: StrLibrary.picture,
                onTap: logic.chatHistoryPicture,
              ),
              childItemView(
                icon: ImageLibrary.chatSearchVideo,
                text: StrLibrary.video,
                onTap: logic.chatHistoryVideo,
              ),
              childItemView(
                icon: ImageLibrary.chatSearchFile,
                text: StrLibrary.file,
                onTap: logic.chatHistoryFile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemView({
    required String text,
    String? hintText,
    TextStyle? textStyle,
    String? value,
    bool switchOn = false,
    bool isTopRadius = false,
    bool isBottomRadius = false,
    bool showRightArrow = false,
    bool showSwitchButton = false,
    bool showBorder = false,
    ValueChanged<bool>? onChanged,
    Function()? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: StylesLibrary.c_FFFFFF,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(isTopRadius ? 10.r : 0),
              topLeft: Radius.circular(isTopRadius ? 10.r : 0),
              bottomLeft: Radius.circular(isBottomRadius ? 10.r : 0),
              bottomRight: Radius.circular(isBottomRadius ? 10.r : 0),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: StylesLibrary.c_FFFFFF,
              border: showBorder
                  ? Border(
                      top:
                          BorderSide(color: StylesLibrary.c_F1F2F6, width: 1.h))
                  : null,
            ),
            height: hintText == null ? 52.h : 68.h,
            padding: EdgeInsets.only(right: 15.w),
            margin: EdgeInsets.only(left: 15.w),
            child: Row(
              children: [
                null != hintText
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          text.toText
                            ..style = textStyle ?? StylesLibrary.ts_333333_16sp,
                          hintText.toText..style = StylesLibrary.ts_999999_14sp,
                        ],
                      )
                    : (text.toText
                      ..style = textStyle ?? StylesLibrary.ts_333333_16sp),
                const Spacer(),
                if (null != value)
                  value.toText..style = StylesLibrary.ts_999999_14sp,
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
        ),
      );
}
