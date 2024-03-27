import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miti_common/miti_common.dart';

import 'mine_logic.dart';

class MinePage extends StatelessWidget {
  final logic = Get.find<MineLogic>();

  MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.c_FFFFFF,
      body: Container(
        height: 1.sh,
        color: Styles.c_F7F7F7,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 1.sw,
                    height: 298.h,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage(ImageRes.appHeaderBg,
                          package: 'miti_common'),
                      fit: BoxFit.cover,
                    )),
                  ),
                  Obx(() => _buildMyInfo()),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                transform: Matrix4.translationValues(0, -28.h, 0),
                child: Column(
                  children: [
                    _buildItem(
                      icon: ImageRes.appMyInfo,
                      label: StrLibrary.myInfo,
                      onTap: logic.viewMyInfo,
                    ),
                    // _buildItem(
                    //   icon: ImageRes.appMyPoints,
                    //   label: StrLibrary .myPoints,
                    //   onTap: logic.myPoints,
                    // ),
                    _buildItem(
                      icon: ImageRes.appAccountSetting,
                      label: StrLibrary.accountSetup,
                      onTap: logic.accountSetup,
                    ),
                    _buildItem(
                      icon: ImageRes.appAboutUs,
                      label: StrLibrary.aboutUs,
                      onTap: logic.aboutUs,
                    ),
                    _buildItem(
                      icon: ImageRes.appLogout,
                      label: StrLibrary.logout,
                      onTap: logic.logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyInfo() => Container(
        height: 58.h,
        margin: EdgeInsets.only(left: 30.w, right: 30.w, top: 114.h),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: logic.viewMyQrcode,
          child: Row(
            children: [
              AvatarView(
                  url: logic.imCtrl.userInfo.value.faceURL,
                  text: logic.imCtrl.userInfo.value.nickname,
                  width: 58.w,
                  height: 58.h),
              16.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (logic.imCtrl.userInfo.value.nickname ?? '').toText
                    ..style = Styles.ts_4B3230_18sp,
                  11.verticalSpace,
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: logic.copyID,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (logic.imCtrl.userInfo.value.userID ?? '').toText
                          ..style = Styles.ts_B3AAAA_14sp
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ImageRes.appMineQr.toImage
                      ..width = 16.w
                      ..height = 16.h,
                    ImageRes.appRightArrow.toImage
                      ..width = 20.w
                      ..height = 20.h,
                  ],
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildItem({
    required String icon,
    required String label,
    Function()? onTap,
  }) =>
      GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: Container(
            margin: EdgeInsets.only(bottom: 20.h),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                color: Styles.c_FFFFFF,
                borderRadius: BorderRadius.all(Radius.circular(10.r))),
            child: Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Row(
                children: [
                  icon.toImage
                    ..width = 26.w
                    ..height = 26.h,
                  12.horizontalSpace,
                  Expanded(
                    child: SizedBox(
                      height: 56.h,
                      child: Row(
                        children: [
                          label.toText..style = Styles.ts_333333_15sp,
                          const Spacer(),
                          ImageRes.appRightArrow.toImage
                            ..width = 20.w
                            ..height = 20.h,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
}
