import 'package:miti_common/miti_common.dart';
import 'package:rxdart/rxdart.dart';

class MitiBridge {
  MitiBridge._();

  static SelectContactsBridge? selectContactsBridge;
  static ViewUserProfileBridge? viewUserProfileBridge;
  // static OrganizationMultiSelBridge? organizationBridge;
  static FriendCircleBridge? friendCircleBridge;
  static ScanBridge? scanBridge;
  // static MeetingBridge? meetingBridge;
  static RTCBridge? rtcBridge;
}

abstract class ScanBridge {
  scanOutUserID(String userID);

  scanOutGroupID(String groupID);

  Future scanActiveAccount({required String useInviteMitiID});
}

// abstract class OrganizationMultiSelBridge {
//   Widget get checkedConfirmView;

//   bool get isMultiModel;

//   bool isChecked(dynamic info);

//   bool isDefaultChecked(dynamic info);

//   Function()? onTap(dynamic info);

//   toggleChecked(dynamic info);

//   removeItem(dynamic info);

//   updateDefaultCheckedList(List<String> userIDList);
// }

abstract class ViewUserProfileBridge {
  viewUserProfile(
    String userID,
    String? nickname,
    String? faceURL, [
    String? groupID,
  ]);
}

abstract class SelectContactsBridge {
  /// [type] 0：谁可以看 1：提醒谁看 2: 分享视频会议
  Future<T?>? selectContacts<T>(
    int type, {
    List<String>? defaultCheckedIDList,
    List<dynamic>? checkedList,
    List<String>? excludeIDList,
    bool openSelectedSheet = false,
    String? groupID,
    String? ex,
  });
}

abstract class FriendCircleBridge {
  Function(WorkMomentsNotification notification)?
      onRecvNewMessageForWorkingCircle;

  /// 发布朋友圈，删除朋友圈
  final opEventSub = PublishSubject<dynamic>();
}

// abstract class MeetingBridge {
//   bool get hasConnection;
//   void dismiss();
// }

abstract class RTCBridge {
  bool get hasConnection;
  void dismiss();
}

/// 解决重复启动同一个页面问题
class GetTags {
  static final List<String> _chatTags = <String>[];
  static final List<String> _momentsTags = <String>[];
  static final List<String> _userMomentsTags = <String>[];
  static final List<String> _momentsDetailTags = <String>[];
  static final List<String> _userProfileTags = <String>[];

  static void createChatTag() {
    _chatTags.add('_${DateTime.now().millisecondsSinceEpoch}');
  }

  static void createMomentsTag() {
    _momentsTags.add('_${DateTime.now().millisecondsSinceEpoch}');
  }

  static void createUserMomentsTag() {
    _userMomentsTags.add('_${DateTime.now().millisecondsSinceEpoch}');
  }

  static void createMomentsDetailTag() {
    _momentsDetailTags.add('_${DateTime.now().millisecondsSinceEpoch}');
  }

  static void createUserProfileTag() {
    _userProfileTags.add('_${DateTime.now().millisecondsSinceEpoch}');
  }

  static void destroyChatTag() {
    _chatTags.removeLast();
  }

  static void destroyMomentsTag() {
    _momentsTags.removeLast();
  }

  static void destroyUserMomentsTag() {
    _userMomentsTags.removeLast();
  }

  static void destroyMomentsDetailTag() {
    _momentsDetailTags.removeLast();
  }

  static void destroyUserProfileTag() {
    _userProfileTags.removeLast();
  }

  static String? get chat => _chatTags.isNotEmpty ? _chatTags.last : null;

  static String get moments => _momentsTags.last;

  static String get userMoments => _userMomentsTags.last;

  static String get momentsDetail => _momentsDetailTags.last;

  static String get userProfile => _userProfileTags.last;
}
