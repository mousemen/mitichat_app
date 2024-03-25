import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miti_common/miti_common.dart';

import 'friend_requests_logic.dart';

class FriendRequestsPage extends StatelessWidget {
  final logic = Get.find<FriendRequestsLogic>();

  FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrLibrary.newFriend),
      backgroundColor: Styles.c_F8F9FA,
      body: Obx(() => ListView.builder(
            padding: EdgeInsets.only(top: 10.h),
            itemCount: logic.applicationList.length,
            itemBuilder: (_, index) =>
                _buildItemView(logic.applicationList[index]),
          )),
    );
  }

  Widget _buildItemView(FriendApplicationInfo info) {
    final isISendRequest = info.fromUserID == OpenIM.iMManager.userID;
    String? name = isISendRequest ? info.toNickname : info.fromNickname;
    String? faceURL = isISendRequest ? info.toFaceURL : info.fromFaceURL;
    String? reason = info.reqMsg;

    return Container(
      height: 68.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Styles.c_FFFFFF,
        border: BorderDirectional(
          bottom: BorderSide(
            color: Styles.c_F8F9FA,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          AvatarView(url: faceURL, text: name),
          10.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (name ?? '').toText
                  ..style = Styles.ts_333333_17sp
                  ..maxLines = 1
                  ..overflow = TextOverflow.ellipsis,
                4.verticalSpace,
                if (MitiUtils.isNotNullEmptyStr(reason))
                  (reason ?? '').toText
                    ..style = Styles.ts_999999_14sp
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
              ],
            ),
          ),
          if (/*info.isWaitingHandle && */ isISendRequest)
            ImageRes.sendRequests.toImage
              ..width = 20.w
              ..height = 20.h,
          if (info.isWaitingHandle && !isISendRequest)
            Button(
              text: StrLibrary.lookOver,
              textStyle: Styles.ts_FFFFFF_14sp,
              onTap: () => logic.acceptFriendApplication(info),
              height: 28.h,
              padding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
          if (info.isWaitingHandle && isISendRequest)
            StrLibrary.waitingForVerification.toText
              ..style = Styles.ts_999999_14sp,
          if (info.isRejected)
            StrLibrary.rejected.toText..style = Styles.ts_999999_14sp,
          if (info.isAgreed)
            StrLibrary.approved.toText..style = Styles.ts_999999_14sp,
        ],
      ),
    );
  }
}
