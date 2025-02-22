import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miti_common/miti_common.dart';
import 'change_bot_info_logic.dart';

class ChangeBotInfoPage extends StatelessWidget {
  final logic = Get.find<ChangeBotInfoLogic>();

  ChangeBotInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: TitleBar.back(
            title: StrLibrary.nicknameAndAvatar,
            right: StrLibrary.save.toText..style = StylesLibrary.ts_8443F8_16sp
            // ..onTap = logic.save,
            ),
        backgroundColor: StylesLibrary.c_F7F8FA,
        body: IntrinsicHeight(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                color: StylesLibrary.c_FFFFFF,
                height: 195.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageLibrary.appBot.toImage
                      ..onTap = logic.openPhotoSheet
                      ..width = 88.w
                      ..height = 88.h,
                    20.verticalSpace,
                    StrLibrary.changeAvatar.toText
                      ..onTap = logic.openPhotoSheet
                      ..style = StylesLibrary.ts_8443F8_16sp
                  ],
                ),
              ),
              12.verticalSpace,
              Container(
                color: StylesLibrary.c_FFFFFF,
                child: InputBox(
                  controller: logic.name,
                  border: false,
                  textStyle: StylesLibrary.ts_333333_14sp,
                ),
              )
            ],
          ),
        ));
  }
}
