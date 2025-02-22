import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti_common/miti_common.dart';

class ChatDisableInputBox extends StatelessWidget {
  const ChatDisableInputBox({Key? key, this.type = 0}) : super(key: key);

  /// 0：不在群里
  final int type;

  @override
  Widget build(BuildContext context) {
    return type == 0
        ? Container(
            height: 56.h,
            color: StylesLibrary.c_F7F8FA,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageLibrary.warn.toImage
                  ..width = 14.w
                  ..height = 14.h,
                6.horizontalSpace,
                StrLibrary.notSendMessageNotInGroup.toText
                  ..style = StylesLibrary.ts_999999_14sp,
              ],
            ),
          )
        : Container();
  }
}
