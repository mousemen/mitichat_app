import 'dart:convert';
import 'dart:io';
import 'package:dart_date/dart_date.dart';
import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart' as imSdk;
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:miti/routes/app_navigator.dart';
// import 'package:miti/firebase_options.dart';
import 'package:miti_common/miti_common.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:sprintf/sprintf.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

// import '../../utils/upgrade_manager.dart';
import 'im_ctrl.dart';

mixin AppControllerGetx on GetxController {
  final isGoogleServerRunning = false.obs;
  final supportLoginTypes =
      [SupportLoginType.email, SupportLoginType.phone].obs;
  final thirdAppInfoMap = ThirdAppInfoMap().obs;
  final Rx<String?> inviteMitiID = Rx<String?>(null);

  get useGoogleLogin =>
      supportLoginTypes.contains(SupportLoginType.google) &&
      ((Platform.isIOS &&
              thirdAppInfoMap.value.ios?.googleApp?["appGoolgeID"] != null) ||
          (!Platform.isIOS &&
              thirdAppInfoMap.value.android?.googleApp?["appGoolgeID"] !=
                  null &&
              thirdAppInfoMap.value.android?.googleApp?["webGoolgeID"] !=
                  null));

  get useAppleLogin =>
      supportLoginTypes.contains(SupportLoginType.apple) &&
      ((Platform.isIOS &&
              thirdAppInfoMap.value.ios?.appleApp?["clientID"] != null) ||
          (!Platform.isIOS &&
              thirdAppInfoMap.value.android?.appleApp?["serviceID"] != null));

  get useFacebookLogin => supportLoginTypes.contains(SupportLoginType.facebook);

  String get googleClientId =>
      (Platform.isIOS
          ? thirdAppInfoMap.value.ios?.googleApp
          : thirdAppInfoMap.value.android?.googleApp)?["appGoolgeID"] ??
      "";

  String get webGoogleClientId =>
      (Platform.isIOS
          ? thirdAppInfoMap.value.ios?.googleApp
          : thirdAppInfoMap.value.android?.googleApp)?["webGoolgeID"] ??
      "";

  String get appleClientId =>
      (Platform.isIOS
          ? thirdAppInfoMap.value.ios?.appleApp
          : thirdAppInfoMap.value.android?.appleApp)?["clientID"] ??
      "";

  String get appleServiceId =>
      (Platform.isIOS
          ? thirdAppInfoMap.value.ios?.appleApp
          : thirdAppInfoMap.value.android?.appleApp)?["serviceID"] ??
      "";

  String get requestAppleClientId =>
      Platform.isIOS ? appleClientId : appleServiceId;
}

// 下载0, 后台1, 消息message.seq
class AppCtrl extends SuperController with AppControllerGetx {
  bool onBackground = false;
  // bool isAppBadgeSupported = false;
  int notificationSeq = 3000;
  var hadShowMessageIdList = [];
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  final androidConfig =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings iosConfig =
      const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: false,
          requestSoundPermission: true);

  late AndroidNotificationDetails androidSpecificsInPush;

  late NotificationDetails platformSpecificsInPush;

  // MeetingBridge? meetingBridge = MitiBridge.meetingBridge;

  RTCBridge? rtcBridge = MitiBridge.rtcBridge;

  // bool get shouldMuted =>
  //     meetingBridge?.hasConnection == true || rtcBridge?.hasConnection == true;

  bool get shouldMuted => rtcBridge?.hasConnection == true;

  late BaseDeviceInfo deviceInfo;

  /// discoverPageURL
  /// ordinaryUserAddFriend,
  /// bossUserID,
  /// adminURL ,
  /// allowSendMsgNotFriend
  /// needInvitationCodeRegister
  /// robots
  final clientConfig = <String, dynamic>{}.obs;

  Future<void> handleBackground(bool switchBackground) async {
    onBackground = switchBackground;
    getIMCtrl()?.switchBackgroundSub.sink.add(switchBackground);
    if (!switchBackground) clearNotifications();
  }

  IMCtrl? getIMCtrl() => Get.isRegistered<IMCtrl>() ? Get.find<IMCtrl>() : null;

  AppCtrl() {
    initFirebase();
  }

  Future<void> initFirebase() async {
    // GooglePlayServicesAvailability? availability;
    // if (Platform.isAndroid) {
    //   availability = await GoogleApiAvailability.instance
    //       .checkGooglePlayServicesAvailability();
    // }
    // if (Platform.isIOS || availability?.value == 0) {
    //   try {
    //     await Firebase.initializeApp(
    //         options: DefaultFirebaseOptions.currentPlatform);
    //     isGoogleServerRunning.value = true;
    //     myLogger.i({"message": "Firebase初始化成功"});
    //   } catch (e, s) {
    //     myLogger.e({"message": "google服务不可用", "error": e, "stack": s});
    //   }
    // }

    GooglePlayServicesAvailability? availability;
    if (Platform.isAndroid) {
      availability = await GoogleApiAvailability.instance
          .checkGooglePlayServicesAvailability();
    }
    if (Platform.isIOS || availability?.value == 0) {
      isGoogleServerRunning.value = true;
    }
    myLogger.i({
      "message": isGoogleServerRunning.value ? "设备支持google" : "设备不支持google"
    });
  }

  @override
  void onInit() async {
    getDeviceInfo();
    getClientConfig();
    await initNotificationPlugin();
    initAndroidNotificationConfig();
    // isAppBadgeSupported = await FlutterAppBadger.isAppBadgeSupported();
    super.onInit();
  }

  initAndroidNotificationConfig() {
    androidSpecificsInPush = const AndroidNotificationDetails('push', 'push',
        channelDescription: 'message push',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        // 启动后通知要很久才消失
        // fullScreenIntent: true,
        silent: false,
        // 无效
        channelShowBadge: false,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        // 无效
        number: 0,
        ticker: 'one message');
    platformSpecificsInPush =
        NotificationDetails(android: androidSpecificsInPush);
  }

  Future<void> updateSupportRegistTypes() async {
    try {
      final data = await ClientApis.querySupportRegistTypes();
      supportLoginTypes.value = List<int>.from(data["types"])
          .map((value) => SupportLoginTypeMap[value])
          .cast<SupportLoginType>()
          .toList();
    } catch (e) {
      myLogger.e({"message": "获取支持的注册方式失败", "error": e});
    }
  }

  Future<void> updateThirdAppInfo() async {
    try {
      final data = await ClientApis.queryThirdAppInfo();
      var android = (List.from(data?["platforms"] ?? []))
          .firstWhereOrNull((element) => element["platformId"] == 2);
      var ios = (List.from(data?["platforms"] ?? []))
          .firstWhereOrNull((element) => element["platformId"] == 1);
      var web = (List.from(data?["platforms"] ?? []))
          .firstWhereOrNull((element) => element["platformId"] == 5);

      thirdAppInfoMap.value = ThirdAppInfoMap(
          android: null != android ? ThirdAppInfo.fromJson(android) : null,
          ios: null != ios ? ThirdAppInfo.fromJson(ios) : null,
          web: null != web ? ThirdAppInfo.fromJson(web) : null);
      myLogger.i(
          "useAppleLogin: $useAppleLogin, useGoogleLogin: $useGoogleLogin, useFacebookLogin: $useFacebookLogin");
      // myLogger.e(googleClientId);
      // myLogger.e(webGoogleClientId);
      // myLogger.e(appleClientId);
      // myLogger.e(appleServiceId);
      // myLogger.e(requestAppleClientId);
    } catch (e) {
      myLogger.e({"message": "获取ThirdAppInfo异常", "error": e});
    }
  }

  Future updateThirdConfig() async {
    return await Future.wait(
        [updateSupportRegistTypes(), updateThirdAppInfo()]);
  }

  Future<void> initNotificationPlugin() async {
    notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    notificationPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
            alert: true, badge: false, sound: true, critical: true);
    final notificationConfig = InitializationSettings(
      android: androidConfig,
      iOS: iosConfig,
    );
    await notificationPlugin.initialize(
      notificationConfig,
      onDidReceiveNotificationResponse: (notification) {
        myLogger.i({
          "message": "点击本地通知",
          "data": {
            "id": notification.id,
            "actionId": notification.actionId,
            "input": notification.input,
            "notificationResponseType": notification.notificationResponseType,
            "payload": notification.payload,
          }
        });
      },
    );
  }

  Future<void> showNotification(imSdk.Message message,
      {bool show = true}) async {
    if (_isGlobalNotDisturb() ||
        message.attachedInfoElem?.notSenderNotificationPush == true ||
        message.contentType == imSdk.MessageType.typing ||
        message.sendID == OpenIM.iMManager.userID) return;

    // 开启免打扰的不提示
    var sourceID = message.sessionType == ConversationType.single
        ? message.sendID
        : message.groupID;
    if (sourceID != null && message.sessionType != null) {
      final conversation =
          await OpenIM.iMManager.conversationManager.getOneConversation(
        sourceID: sourceID,
        sessionType: message.sessionType!,
      );
      if (conversation.recvMsgOpt != 0) return;
    }

    if (show && Platform.isAndroid) {
      promptNotification(message);
    }
  }

  Future<void> promptLiveNotification(SignalingInfo signalingInfo) async {
    if (Platform.isAndroid && onBackground) {
      const androidPlatformSpecifics =
          AndroidNotificationDetails('push', 'push',
              channelDescription: 'message push',
              importance: Importance.max,
              priority: Priority.max,
              playSound: false,
              enableVibration: false,
              // 启动后通知超时才消失
              // fullScreenIntent: true,
              silent: false,
              // 无效
              channelShowBadge: false,
              category: AndroidNotificationCategory.call,
              visibility: NotificationVisibility.public,
              // 无效
              number: 0,
              ticker: 'one message');
      const NotificationDetails platformSpecifics =
          NotificationDetails(android: androidPlatformSpecifics);
      final isGroup = signalingInfo.invitation?.sessionType == 2;
      final isAudio = signalingInfo.invitation?.mediaType == 'audio';
      final id = isGroup
          ? signalingInfo.invitation?.groupID
          : signalingInfo.invitation?.inviterUserID;
      try {
        final list =
            await OpenIM.iMManager.friendshipManager.getFriendListMap();
        final friendJson = list.firstWhereOrNull((element) {
          final fullUser = FullUserInfo.fromJson(element);
          return fullUser.userID == id;
        });
        ISUserInfo? friendInfo;
        if (null != friendJson) {
          final info = FullUserInfo.fromJson(friendJson);
          friendInfo = info.friendInfo != null
              ? ISUserInfo.fromJson(info.friendInfo!.toJson())
              : ISUserInfo.fromJson(info.publicInfo!.toJson());
        }

        if (isGroup) {
          final list = await OpenIM.iMManager.groupManager.getJoinedGroupList();
          final groupInfo =
              list.firstWhereOrNull((element) => element.groupID == id);
          GroupMembersInfo? member;
          if (null != groupInfo) {
            final memberList =
                await OpenIM.iMManager.groupManager.getGroupMemberList(
              groupID: groupInfo.groupID,
              count: 999,
            );
            member = memberList.firstWhereOrNull((element) =>
                element.userID == signalingInfo.invitation?.inviterUserID);
          }

          await notificationPlugin.show(
              notificationSeq + DateTime.now().secondsSinceEpoch,
              groupInfo?.groupName ?? StrLibrary.defaultNotificationTitle4,
              "${(null != friendInfo && friendInfo.showName.isNotEmpty) ? friendInfo.showName : member?.nickname ?? StrLibrary.friend}: ${isAudio ? '[${StrLibrary.callVoice}]' : '[${StrLibrary.callVideo}]'}",
              platformSpecifics,
              payload: null);
        } else {
          await notificationPlugin.show(
              notificationSeq + DateTime.now().secondsSinceEpoch,
              friendInfo?.showName ?? StrLibrary.defaultNotificationTitle3,
              isAudio
                  ? '[${StrLibrary.callVoice}]'
                  : '[${StrLibrary.callVideo}]',
              platformSpecifics,
              payload: null);
        }
      } catch (e, s) {
        myLogger.e({
          "message": "通话消息本地通知出错",
          "data": signalingInfo.toJson(),
          "error": e,
          "stack": s
        });
        await notificationPlugin.show(
            notificationSeq + DateTime.now().secondsSinceEpoch,
            StrLibrary.defaultNotificationTitle3,
            isAudio ? '[${StrLibrary.callVoice}]' : '[${StrLibrary.callVideo}]',
            platformSpecifics,
            payload: null);
      }
    }
  }

  Future<void> promptNotification(imSdk.Message message) async {
    if (hadShowMessageIdList.contains(message.clientMsgID)) {
      myLogger.e({"message": "出现重复通知", "data": message.toJson()});
      return;
    }
    hadShowMessageIdList.add(message.clientMsgID);
    if (!onBackground) {
      beepAndVibrate();
    } else {
      const androidSpecifics = AndroidNotificationDetails('push', 'push',
          channelDescription: 'message push',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          // 启动后通知要很久才消失
          // fullScreenIntent: true,
          silent: false,
          // 无效
          channelShowBadge: false,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          // 无效
          number: 0,
          ticker: 'one message');
      const NotificationDetails platformSpecifics =
          NotificationDetails(android: androidSpecifics);

      try {
        // final id = message.seq!;
        notificationSeq = notificationSeq + 1;
        String text = StrLibrary.defaultNotification;
        String? noticeTypeMsgGroupName;
        if (message.isTextType) {
          text = message.textElem!.content!;
        } else if (message.isAtTextType) {
          text = MitiUtils.replaceMessageAtMapping(message, {});
        } else if (message.isQuoteType) {
          text = message.quoteElem?.text ?? text;
        } else if (message.isTextWithPromptType) {
          text = message.customData?["welcome"] ?? "welcome";
        } else if (message.isPictureType) {
          text = StrLibrary.defaultImgNotification;
        } else if (message.isVideoType) {
          text = StrLibrary.defaultVideoNotification;
        } else if (message.isVoiceType) {
          text = StrLibrary.defaultVoiceNotification;
        } else if (message.isFileType) {
          text = StrLibrary.defaultFileNotification;
        } else if (message.isLocationType) {
          text = StrLibrary.defaultLocationNotification;
        } else if (message.isMergerType) {
          text = StrLibrary.defaultMergeNotification;
        } else if (message.isCardType) {
          text = StrLibrary.defaultCardNotification;
        } else if (message.contentType! >= 1000) {
          // 尝试解析通知类型
          noticeTypeMsgGroupName =
              MitiUtils.parseNtfMap(message)?["group"]?["groupName"];
          String? str = MitiUtils.parseNtf(message, isConversation: true);
          if (null == str) {
            text = StrLibrary.defaultNotificationTitle;
            myLogger.e({
              "message": "contentType>=1000的消息解析失败",
              "data": message.toJson()
            });
          } else {
            text = str;
          }
        } else {
          // 其他类型暂时不展示
          myLogger.w(
              {"message": "sdk收到一条消息, 未匹配需要暂时的情况", "data": message.toJson()});
        }

        final list =
            await OpenIM.iMManager.friendshipManager.getFriendListMap();
        final friendJson = list.firstWhereOrNull((element) {
          final fullUser = FullUserInfo.fromJson(element);
          return fullUser.userID == message.sendID;
        });
        ISUserInfo? friendInfo;
        if (null != friendJson) {
          final info = FullUserInfo.fromJson(friendJson);
          friendInfo = info.friendInfo != null
              ? ISUserInfo.fromJson(info.friendInfo!.toJson())
              : ISUserInfo.fromJson(info.publicInfo!.toJson());
        }
        if (message.isSingleChat) {
          if (null == friendInfo) {
            myLogger.e({"message": "收到单聊消息, 找不到好友信息, ${message.sendID}"});
          }
          await notificationPlugin.show(
              notificationSeq,
              friendInfo?.showName ?? StrLibrary.defaultNotificationTitle3,
              text,
              platformSpecifics,
              payload: json.encode(message.toJson()));
        } else if (message.isGroupChat) {
          final list = await OpenIM.iMManager.groupManager.getJoinedGroupList();
          final groupInfo = list.firstWhereOrNull(
              (element) => element.groupID == message.groupID);
          if (null == groupInfo) {
            myLogger.e({"message": "收到群聊消息, 找不到群组信息, ${message.groupID}"});
          }
          await notificationPlugin.show(
              notificationSeq,
              groupInfo?.groupName ??
                  noticeTypeMsgGroupName ??
                  StrLibrary.defaultNotificationTitle4,
              message.isNoticeType
                  ? "${StrLibrary.groupAc}: ${text}"
                  : ("${(null != friendInfo && friendInfo.showName.isNotEmpty) ? friendInfo.showName : message.senderNickname ?? StrLibrary.friend}: ${text}"),
              platformSpecifics,
              payload: json.encode(message.toJson()));
        } else {
          myLogger.w({
            "message": "收到意外通知类型的消息, 消息类型(sessionType: ${message.sessionType})",
            "data": message.toJson(),
          });
          await notificationPlugin.show(notificationSeq,
              StrLibrary.defaultNotificationTitle2, text, platformSpecifics,
              payload: json.encode(message.toJson()));
        }
      } catch (e, s) {
        myLogger.e({
          "message": "message消息本地通知出错",
          "data": message.toJson(),
          "error": e,
          "stack": s
        });
        await notificationPlugin.show(
            notificationSeq, "error", "error", platformSpecifics,
            payload: null);
      }
    }
  }

  Future<void> clearNotifications() async {
    await notificationPlugin.cancelAll();
  }

  Future<void> promptInviteNotification(Map<String, dynamic> data) async {
    final content =
        sprintf(StrLibrary.inviteDialogTips, [data["user"]["nickname"]]);
    // Get.dialog(CustomDialog(
    //   title: content,
    //   leftText: StrLibrary.reject,
    //   rightText: StrLibrary.accept,
    //   onTapLeft: () => agreeOrReject(data["user"]["userID"], 2),
    //   onTapRight: () => agreeOrReject(data["user"]["userID"], 1),
    // ));

    promptAndroidNotification(
        platformSpecifics: platformSpecificsInPush,
        title: StrLibrary.activeAccountNotificationTitle,
        content: content,
        payload: json.encode(data));
  }

  Future<void> promptInviteHandleNotification(Map<String, dynamic> data) async {
    final content = data["handleResult"] != 2
        ? sprintf(StrLibrary.inviteDialogSuccessTips,
            [data["inviteUser"]["nickname"]])
        : sprintf(
            StrLibrary.inviteDialogFailTips, [data["inviteUser"]["nickname"]]);
    Get.dialog(CustomDialog(
      title: content,
      centerBigText:
          data["handleResult"] != 2 ? StrLibrary.goStart : StrLibrary.confirm,
      onTapCenter: () => AppNavigator.startMain(),
    ));
    promptAndroidNotification(
        platformSpecifics: platformSpecificsInPush,
        title: StrLibrary.activeAccountResultNotificationTitle,
        content: content,
        payload: json.encode(data));
  }

  agreeOrReject(String invtedUserID, int result) {
    LoadingView.singleton.start(fn: () async {
      await ClientApis.responseApplyActive(
          invtedUserID: invtedUserID, result: result);
      Get.back();
    });
  }

  promptAndroidNotification({
    required NotificationDetails platformSpecifics,
    String? title,
    String? content,
    String? payload,
  }) {
    if (Platform.isAndroid) {
      title = title ?? StrLibrary.defaultNotificationTitle;
      if (!onBackground) {
        beepAndVibrate();
      } else {
        notificationSeq = notificationSeq + 1;
        notificationPlugin.show(
            notificationSeq, title, content, platformSpecifics,
            payload: payload);
      }
    }
  }

  Future requestActiveAccount({required String useInviteMitiID}) async {
    if (Get.isRegistered<IMCtrl>()) {
      final imCtrl = Get.find<IMCtrl>();
      if (imCtrl.userInfo.value.isAlreadyActive != true) {
        await ClientApis.applyActive(inviteMitiID: useInviteMitiID);
        showToast(StrLibrary.submitActiveSuccess);
      }
    } else {
      // 重新启动时, 先记录
      inviteMitiID.value = useInviteMitiID;
    }
  }

  // void showBadge(count) {
  //   if (isAppBadgeSupported) {
  //     OpenIM.iMManager.messageManager.setAppBadge(count);

  //     if (count == 0) {
  //       removeBadge();
  //       PushCtrl.resetBadge();
  //     } else {
  //       FlutterAppBadger.updateBadgeCount(count);
  //       PushCtrl.setBadge(count);
  //     }
  //   }
  // }

  // void removeBadge() {
  //   FlutterAppBadger.removeBadge();
  // }

  @override
  void onClose() {
    getIMCtrl()?.close();
    super.onClose();
  }

  Locale? getCurLocale(BuildContext context) {
    Locale? locale = Get.locale;
    String windowLocaleStr =
        View.of(context).platformDispatcher.locale.toString();

    int? lang = DataSp.getLanguage();
    int index = (lang != null && lang != 0)
        ? lang
        : (windowLocaleStr.startsWith("zh_")
            ? 1
            : windowLocaleStr.startsWith("en_")
                ? 2
                : windowLocaleStr.startsWith("ja_")
                    ? 3
                    : windowLocaleStr.startsWith("ko_")
                        ? 4
                        : windowLocaleStr.startsWith("es_")
                            ? 5
                            : 0);
    switch (index) {
      case 1:
        locale = const Locale('zh', 'CN');
        break;
      case 2:
        locale = const Locale('en', 'US');
        break;
      case 3:
        locale = const Locale('ja', 'JP');
        break;
      case 4:
        locale = const Locale('ko', 'KR');
        break;
      case 5:
        locale = const Locale('es', 'ES');
        break;
    }
    return locale;
  }

  @override
  void onReady() {
    clearNotifications();
    // autoCheckVersionUpgrade();
    super.onReady();
  }

  /// 全局免打扰
  bool _isGlobalNotDisturb() {
    return getIMCtrl()?.userInfo.value.globalRecvMsgOpt == 2;
  }

  /// 播放提示音
  void beepAndVibrate() async {
    if (shouldMuted) {
      return;
    }
    bool isAllowVibration = true;
    // 获取系统静音、震动状态
    RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;
    isAllowVibration =
        getIMCtrl() == null || getIMCtrl()?.userInfo.value.allowVibration == 1;
    FlutterRingtonePlayer().playNotification();
    if (isAllowVibration &&
        (ringerStatus == RingerModeStatus.normal ||
            ringerStatus == RingerModeStatus.vibrate ||
            ringerStatus == RingerModeStatus.unknown)) {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate();
      }
    }
  }

  void getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    deviceInfo = await deviceInfoPlugin.deviceInfo;
  }

  Future getClientConfig() async {
    myLogger.i({"message": "获取客户端配置"});
    Map<String, dynamic> defaultConfig = {
      "allowSendMsgNotFriend": "0",
      "needInvitationCodeRegister": "1"
    };
    Map<String, dynamic> map = defaultConfig;
    try {
      map = await ClientApis.getClientConfig();
    } catch (e, s) {
      myLogger.e({
        "message": "获取客户端配置异常, 使用默认配置",
        "error": {"error": e, "defalutConfig": defaultConfig},
        "stack": s
      });
    } finally {
      clientConfig.assignAll(map);
    }
    return clientConfig;
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
    // autoCheckVersionUpgrade();
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
