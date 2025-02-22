import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miti_common/miti_common.dart';
import 'account_setting_logic.dart';

class AccountSettingPage extends StatelessWidget {
  final logic = Get.find<AccountSettingLogic>();

  AccountSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrLibrary.accountSetting,
      ),
      backgroundColor: StylesLibrary.c_F7F8FA,
      body: Obx(() => SingleChildScrollView(
            child: Column(
              children: [
                12.verticalSpace,
                _buildItemView(
                  showBorder: false,
                  label: StrLibrary.notDisturbMode,
                  switchOn: logic.isGlobalNotDisturb,
                  onChanged: (_) => logic.toggleNotDisturbMode(),
                  showSwitchButton: true,
                  showRightArrow: false,
                ),
                _buildItemView(
                  label: StrLibrary.allowRing,
                  switchOn: logic.isAllowBeep,
                  onChanged: (_) => logic.toggleBeep(),
                  showSwitchButton: true,
                  showRightArrow: false,
                ),
                _buildItemView(
                  label: StrLibrary.allowVibrate,
                  switchOn: logic.isAllowVibration,
                  onChanged: (_) => logic.toggleVibration(),
                  showSwitchButton: true,
                  showRightArrow: false,
                ),
                12.verticalSpace,
                _buildItemView(
                  showBorder: false,
                  label: StrLibrary.forbidAddMeToFriend,
                  switchOn: !logic.isAllowAddFriend,
                  onChanged: (_) => logic.toggleForbidAddMeToFriend(),
                  showSwitchButton: true,
                  showRightArrow: false,
                ),
                _buildItemView(
                  label: StrLibrary.blacklist,
                  onTap: logic.blacklist,
                ),
                _buildItemView(
                  label: StrLibrary.languageSetting,
                  value: logic.curLanguage.value,
                  onTap: logic.languageSetting,
                ),
                12.verticalSpace,
                _buildItemView(
                  showBorder: false,
                  label: StrLibrary.unlockSettings,
                  onTap: logic.unlockSetup,
                ),
                _buildItemView(
                  label: StrLibrary.accountAndSecurity,
                  onTap: logic.goAccountAndSecurity,
                ),
                _buildItemView(
                  label: StrLibrary.clearChatHistory,
                  onTap: logic.clearChatHistory,
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildItemView({
    required String label,
    TextStyle? textStyle,
    String? value,
    bool switchOn = false,
    bool showRightArrow = true,
    bool showSwitchButton = false,
    bool showBorder = true,
    ValueChanged<bool>? onChanged,
    Function()? onTap,
  }) =>
      GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: Container(
            decoration: BoxDecoration(
              color: StylesLibrary.c_FFFFFF,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: StylesLibrary.c_F1F2F6,
                    width: showBorder ? 1.h : 0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  label.toText
                    ..style = textStyle ?? StylesLibrary.ts_333333_16sp,
                  const Spacer(),
                  if (null != value)
                    value.toText..style = StylesLibrary.ts_333333_14sp,
                  if (showSwitchButton)
                    CupertinoSwitch(
                      value: switchOn,
                      activeColor: StylesLibrary.c_07C160,
                      onChanged: onChanged,
                    ),
                  if (showRightArrow)
                    ImageLibrary.appRightArrow.toImage
                      ..width = 20.w
                      ..height = 20.h,
                ],
              ),
            ),
          ));
}
