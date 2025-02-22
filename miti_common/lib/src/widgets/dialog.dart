import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miti_common/miti_common.dart';

enum DialogType {
  confirm,
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    this.title,
    this.bigTitle,
    this.url,
    this.content,
    this.rightText,
    this.leftText,
    this.centerBigText,
    this.onTapLeft,
    this.onTapRight,
    this.onTapCenter,
    this.body,
  }) : super(key: key);
  final String? bigTitle;
  final String? title;
  final String? url;
  final Widget? content;
  final String? rightText;
  final String? leftText;
  final String? centerBigText;
  final Widget? body;
  final Function()? onTapLeft;
  final Function()? onTapRight;
  final Function()? onTapCenter;

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 280.w,
              color: StylesLibrary.c_FFFFFF,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  body ??
                      Padding(
                          padding: EdgeInsets.only(
                            top: 16.w,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                ),
                                child: Text(
                                  bigTitle ?? StrLibrary.tips,
                                  textAlign: TextAlign.center,
                                  style: StylesLibrary.ts_333333_16sp_medium,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 27.h,
                                  horizontal: 16.w,
                                ),
                                child: Text(
                                  title ?? '',
                                  textAlign: TextAlign.center,
                                  style: StylesLibrary.ts_333333_14sp,
                                ),
                              ),
                              if (null != content) content!
                            ],
                          )),
                  Divider(
                    color: StylesLibrary.c_EDEDED,
                    height: 1.h,
                  ),
                  Row(
                    children: null == centerBigText
                        ? [
                            _button(
                              bgColor: StylesLibrary.c_FFFFFF,
                              text: leftText ?? StrLibrary.cancel,
                              textStyle: StylesLibrary.ts_8443F8_14sp,
                              onTap: onTapLeft ?? () => Get.back(result: false),
                            ),
                            Container(
                              color: StylesLibrary.c_EDEDED,
                              width: 1.w,
                              height: 43.h,
                            ),
                            _button(
                              bgColor: StylesLibrary.c_FFFFFF,
                              text: rightText ?? StrLibrary.determine,
                              textStyle: StylesLibrary.ts_8443F8_14sp,
                              onTap: onTapRight ?? () => Get.back(result: true),
                            ),
                          ]
                        : [
                            _button(
                              bgColor: StylesLibrary.c_FFFFFF,
                              text: centerBigText!,
                              textStyle: StylesLibrary.ts_999999_14sp,
                              onTap:
                                  onTapCenter ?? () => Get.back(result: false),
                            )
                          ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _button({
    required Color bgColor,
    required String text,
    required TextStyle textStyle,
    Function()? onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(6),
              color: bgColor,
            ),
            height: 48.h,
            alignment: Alignment.center,
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      );
}

class ForwardHintDialog extends StatelessWidget {
  const ForwardHintDialog({
    Key? key,
    required this.title,
    this.checkedList = const [],
    this.controller,
  }) : super(key: key);
  final String title;
  final List<dynamic> checkedList;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final list = MitiUtils.convertCheckedListToForwardObj(checkedList);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            margin: EdgeInsets.symmetric(horizontal: 36.w),
            decoration: BoxDecoration(
              color: StylesLibrary.c_FFFFFF,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                (list.length == 1
                        ? StrLibrary.sentTo
                        : StrLibrary.sentSeparatelyTo)
                    .toText
                  ..style = StylesLibrary.ts_333333_17sp_medium,
                5.verticalSpace,
                list.length == 1
                    ? Row(
                        children: [
                          AvatarView(
                            url: list.first['faceURL'],
                            text: list.first['nickname'],
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: (list.first['nickname'] ?? '').toText
                              ..style = StylesLibrary.ts_333333_17sp
                              ..maxLines = 1
                              ..overflow = TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 120.h),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 0,
                            childAspectRatio: 50.w / 65.h,
                          ),
                          itemCount: list.length,
                          shrinkWrap: true,
                          itemBuilder: (_, index) => Column(
                            children: [
                              AvatarView(
                                url: list.elementAt(index)['faceURL'],
                                text: list.elementAt(index)['nickname'],
                              ),
                              10.horizontalSpace,
                              (list.elementAt(index)['nickname'] ?? '').toText
                                ..style = StylesLibrary.ts_999999_10sp
                                ..maxLines = 1
                                ..overflow = TextOverflow.ellipsis,
                            ],
                          ),
                        ),
                      ),
                5.verticalSpace,
                title.toText
                  ..style = StylesLibrary.ts_999999_14sp
                  ..maxLines = 1
                  ..overflow = TextOverflow.ellipsis,
                10.verticalSpace,
                Container(
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: StylesLibrary.c_E8EAEF,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    style: StylesLibrary.ts_333333_14sp,
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: StrLibrary.leaveMessage,
                      hintStyle: StylesLibrary.ts_999999_14sp,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 7.h,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                16.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StrLibrary.cancel.toText
                      ..style = StylesLibrary.ts_333333_17sp
                      ..onTap = () => Get.back(),
                    26.horizontalSpace,
                    StrLibrary.determine.toText
                      ..style = StylesLibrary.ts_8443F8_17sp
                      ..onTap = () => Get.back(result: true),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog(
      {Key? key, required this.text, this.confirmText, this.onTapConfirm})
      : super(key: key);
  final String text;
  final String? confirmText;
  final Function()? onTapConfirm;

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
                child: Stack(
              children: [
                Container(
                  height: 43.h,
                  width: 256.w,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 43.h),
                    child: Container(
                      width: 256.w,
                      constraints: BoxConstraints(minHeight: 200.h),
                      padding: EdgeInsets.only(
                          left: 10.w, right: 10.w, top: 73.h, bottom: 20.h),
                      decoration: BoxDecoration(
                        color: StylesLibrary.c_FFFFFF,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          text.toText
                            ..style = StylesLibrary.ts_343434_16p_medium
                            ..textAlign = TextAlign.center,
                          30.verticalSpace,
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: Button(
                                text: confirmText ?? StrLibrary.iKnow,
                                textStyle: StylesLibrary.ts_FFFFFF_16sp,
                                height: 42.h,
                                width: 128.w,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                onTap: onTapConfirm ??
                                    () => Get.back(result: true)),
                          )
                        ],
                      ),
                    )),
                Positioned(
                    left: 85.w,
                    child: ImageLibrary.dialogSuccess.toImage
                      ..width = 86.w
                      ..height = 86.h),
              ],
            ))));
  }

  Widget _button({
    required Color bgColor,
    required String text,
    required TextStyle textStyle,
    Function()? onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(6),
              color: bgColor,
            ),
            height: 48.h,
            alignment: Alignment.center,
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      );
}
