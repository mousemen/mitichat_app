import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:openim_common/openim_common.dart';

class Apis {
  static Options get imTokenOptions => Options(headers: {'token': DataSp.imToken});

  static Options get chatTokenOptions => Options(headers: {'token': DataSp.chatToken});

  /// login
  static Future<LoginCertificate> login({
    String? areaCode,
    String? phoneNumber,
    String? email,
    String? password,
    String? verificationCode,
  }) async {
    try {
      var data = await HttpUtil.post(Urls.login, data: {
        "areaCode": areaCode,
        'phoneNumber': phoneNumber,
        'email': email,
        'password': null != password ? IMUtils.generateMD5(password) : null,
        'platform': IMUtils.getPlatform(),
        'verifyCode': verificationCode,
        // 'operationID': operationID,
      });
      return LoginCertificate.fromJson(data!);
    } catch (e, s) {
      Logger.print('e:$e s:$s');
      return Future.error(e);
    }
  }

  /// register
  static Future<LoginCertificate> register({
    required String nickname,
    required String password,
    String? faceURL,
    String? areaCode,
    String? phoneNumber,
    String? email,
    int birth = 0,
    int gender = 1,
    required String verificationCode,
    String? invitationCode,
  }) async {
    assert(phoneNumber != null || email != null);
    try {
      var data = await HttpUtil.post(Urls.register, data: {
        'deviceID': DataSp.getDeviceID(),
        'verifyCode': verificationCode,
        'platform': IMUtils.getPlatform(),
        // 'operationID': operationID,
        'invitationCode': invitationCode,
        'autoLogin': true,
        'user': {
          "nickname": nickname,
          "faceURL": faceURL,
          'birth': birth,
          'gender': gender,
          'email': email,
          "areaCode": areaCode,
          'phoneNumber': phoneNumber,
          'password': IMUtils.generateMD5(password),
        },
      });
      return LoginCertificate.fromJson(data!);
    } catch (e, s) {
      Logger.print('e:$e s:$s');
      return Future.error(e);
    }
  }

  /// reset password
  static Future<dynamic> resetPassword({
    String? areaCode,
    String? phoneNumber,
    String? email,
    required String password,
    required String verificationCode,
  }) async {
    return HttpUtil.post(
      Urls.resetPwd,
      data: {
        "areaCode": areaCode,
        'phoneNumber': phoneNumber,
        'email': email,
        'password': IMUtils.generateMD5(password),
        'verifyCode': verificationCode,
        'platform': IMUtils.getPlatform(),
        // 'operationID': operationID,
      },
      options: chatTokenOptions,
    );
  }

  /// change password
  static Future<bool> changePassword({
    required String userID,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await HttpUtil.post(
        Urls.changePwd,
        data: {
          "userID": userID,
          'currentPassword': IMUtils.generateMD5(currentPassword),
          'newPassword': IMUtils.generateMD5(newPassword),
          'platform': IMUtils.getPlatform(),
          // 'operationID': operationID,
        },
        options: chatTokenOptions,
      );
      return true;
    } catch (e, s) {
      Logger.print('e:$e s:$s');
      return false;
    }
  }

  /// update user info
  static Future<dynamic> updateUserInfo({
    required String userID,
    String? account,
    String? phoneNumber,
    String? areaCode,
    String? email,
    String? nickname,
    String? faceURL,
    int? gender,
    int? birth,
    int? level,
    int? allowAddFriend,
    int? allowBeep,
    int? allowVibration,
  }) async {
    Map<String, dynamic> param = {'userID': userID};
    void put(String key, dynamic value) {
      if (null != value) {
        param[key] = value;
      }
    }

    put('account', account);
    put('phoneNumber', phoneNumber);
    put('areaCode', areaCode);
    put('email', email);
    put('nickname', nickname);
    put('faceURL', faceURL);
    put('gender', gender);
    put('gender', gender);
    put('level', level);
    put('birth', birth);
    put('allowAddFriend', allowAddFriend);
    put('allowBeep', allowBeep);
    put('allowVibration', allowVibration);

    return HttpUtil.post(
      Urls.updateUserInfo,
      data: {
        ...param,
        'platform': IMUtils.getPlatform(),
        // 'operationID': operationID,
      },
      options: chatTokenOptions,
    );
  }

  static Future<List<FriendInfo>> searchFriendInfo(
    String keyword, {
    int pageNumber = 1,
    int showNumber = 10,
  }) async {
    final data = await HttpUtil.post(
      Urls.searchFriendInfo,
      data: {
        'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
        'keyword': keyword,
      },
      options: chatTokenOptions,
    );
    if (data['users'] is List) {
      return (data['users'] as List).map((e) => FriendInfo.fromJson(e)).toList();
    }
    return [];
  }

  static Future<List<UserFullInfo>?> getUserFullInfo({
    int pageNumber = 0,
    int showNumber = 10,
    required List<String> userIDList,
  }) async {
    final data = await HttpUtil.post(
      Urls.getUsersFullInfo,
      data: {
        'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
        'userIDs': userIDList,
        'platform': IMUtils.getPlatform(),
        // 'operationID': operationID,
      },
      options: chatTokenOptions,
    );
    if (data['users'] is List) {
      return (data['users'] as List).map((e) => UserFullInfo.fromJson(e)).toList();
    }
    return null;
  }

  static Future<List<UserFullInfo>?> searchUserFullInfo({
    required String content,
    int pageNumber = 1,
    int showNumber = 10,
  }) async {
    final data = await HttpUtil.post(
      Urls.searchUserFullInfo,
      data: {
        'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
        'keyword': content,
        // 'operationID': operationID,
      },
      options: chatTokenOptions,
    );
    if (data['users'] is List) {
      return (data['users'] as List).map((e) => UserFullInfo.fromJson(e)).toList();
    }
    return null;
  }

  static Future<UserFullInfo?> queryMyFullInfo() async {
    final list = await Apis.getUserFullInfo(
      userIDList: [OpenIM.iMManager.userID],
    );
    return list?.firstOrNull;
  }

  /// 获取验证码
  /// [usedFor] 1：注册，2：重置密码 3：登录
  static Future<bool> requestVerificationCode({
    String? areaCode,
    String? phoneNumber,
    String? email,
    required int usedFor,
    String? invitationCode,
  }) async {
    return HttpUtil.post(
      Urls.getVerificationCode,
      data: {"areaCode": areaCode, "phoneNumber": phoneNumber, "email": email, 'usedFor': usedFor, 'invitationCode': invitationCode},
    ).then((value) {
      IMViews.showToast(StrRes.sentSuccessfully);
      return true;
    }).catchError((e, s) {
      Logger.print('e:$e s:$s');
      return false;
    });
  }

  /// 校验验证码
  static Future<dynamic> checkVerificationCode({
    String? areaCode,
    String? phoneNumber,
    String? email,
    required String verificationCode,
    required int usedFor,
    String? invitationCode,
  }) {
    return HttpUtil.post(
      Urls.checkVerificationCode,
      data: {
        "phoneNumber": phoneNumber,
        "areaCode": areaCode,
        "email": email,
        "verifyCode": verificationCode,
        "usedFor": usedFor,
        // 'operationID': operationID,
        'invitationCode': invitationCode
      },
    );
  }

  /// 蒲公英更新检测
  static Future<UpgradeInfoV2> checkUpgradeV2() {
    return dio.post<Map<String, dynamic>>(
      'https://www.pgyer.com/apiv2/app/check',
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
      data: {
        '_api_key': '6f43600074306e8bc506ed0cd3275e9e',
        'appKey': '90045f1bca740e2083cd3251f4c5731a',
      },
    ).then((resp) {
      Map<String, dynamic> map = resp.data!;
      if (map['code'] == 0) {
        return UpgradeInfoV2.fromJson(map['data']);
      }
      return Future.error(map);
    });
  }

  static void queryUserOnlineStatus({
    required List<String> uidList,
    Function(Map<String, String>)? onlineStatusDescCallback,
    Function(Map<String, bool>)? onlineStatusCallback,
  }) async {
    var resp = await HttpUtil.post(
      Urls.userOnlineStatus,
      data: <String, dynamic>{"userIDList": uidList},
      options: imTokenOptions,
    );
    Map<String, dynamic> map = resp.data!;
    if (map['errCode'] == 0 && map['data'] is List) {
      _handleStatus(
        (map['data'] as List).map((e) => OnlineStatus.fromJson(e)).toList(),
        onlineStatusCallback: onlineStatusCallback,
        onlineStatusDescCallback: onlineStatusDescCallback,
      );
    }
  }

  /// discoverPageURL
  /// ordinaryUserAddFriend,
  /// bossUserID,
  /// adminURL ,
  /// allowSendMsgNotFriend
  /// needInvitationCodeRegister
  /// robots
  static Future<Map<String, dynamic>> getClientConfig() async {
    var result = await HttpUtil.post(
      Urls.getClientConfig,
      data: {
        // 'operationID': operationID,
      },
      options: chatTokenOptions,
      showErrorToast: false,
    );
    return result['config'] ?? {};
  }

  static _handleStatus(
    List<OnlineStatus> list, {
    Function(Map<String, String>)? onlineStatusDescCallback,
    Function(Map<String, bool>)? onlineStatusCallback,
  }) {
    final statusDesc = <String, String>{};
    final status = <String, bool>{};
    for (var e in list) {
      if (e.status == 'online') {
        // IOSPlatformStr     = "IOS"
        // AndroidPlatformStr = "Android"
        // WindowsPlatformStr = "Windows"
        // OSXPlatformStr     = "OSX"
        // WebPlatformStr     = "Web"
        // MiniWebPlatformStr = "MiniWeb"
        // LinuxPlatformStr   = "Linux"
        final pList = <String>[];
        for (var platform in e.detailPlatformStatus!) {
          if (platform.platform == "Android" || platform.platform == "IOS") {
            pList.add(StrRes.phoneOnline);
          } else if (platform.platform == "Windows") {
            pList.add(StrRes.pcOnline);
          } else if (platform.platform == "Web") {
            pList.add(StrRes.webOnline);
          } else if (platform.platform == "MiniWeb") {
            pList.add(StrRes.webMiniOnline);
          } else {
            statusDesc[e.userID!] = StrRes.online;
          }
        }
        statusDesc[e.userID!] = '${pList.join('/')}${StrRes.online}';
        status[e.userID!] = true;
      } else {
        statusDesc[e.userID!] = StrRes.offline;
        status[e.userID!] = false;
      }
    }
    onlineStatusDescCallback?.call(statusDesc);
    onlineStatusCallback?.call(status);
  }

  static Future<List<UniMPInfo>> queryUniMPList() async {
    var result = await HttpUtil.post(
      Urls.uniMPUrl,
      data: {
        // 'operationID': operationID,
      },
      options: chatTokenOptions,
      showErrorToast: false,
    );
    return (result as List).map((e) => UniMPInfo.fromJson(e)).toList();
  }

  /// 查询tag组
  static Future<TagGroup> getUserTags({String? userID}) => HttpUtil.post(
        Urls.getUserTags,
        data: {'userID': userID},
        options: chatTokenOptions,
      ).then((value) => TagGroup.fromJson(value));

  /// 创建tag
  static createTag({
    required String tagName,
    required List<String> userIDList,
  }) =>
      HttpUtil.post(
        Urls.createTag,
        data: {'tagName': tagName, 'userIDs': userIDList},
        options: chatTokenOptions,
      );

  /// 创建tag
  static deleteTag({required String tagID}) => HttpUtil.post(
        Urls.deleteTag,
        data: {'tagID': tagID},
        options: chatTokenOptions,
      );

  /// 创建tag
  static updateTag({
    required String tagID,
    required String name,
    required List<String> increaseUserIDList,
    required List<String> reduceUserIDList,
  }) =>
      HttpUtil.post(
        Urls.updateTag,
        data: {
          'tagID': tagID,
          'name': name,
          'addUserIDs': increaseUserIDList,
          'delUserIDs': reduceUserIDList,
        },
        options: chatTokenOptions,
      );

  /// 下发tag通知
  static sendTagNotification({
    // required int contentType,
    TextElem? textElem,
    SoundElem? soundElem,
    PictureElem? pictureElem,
    VideoElem? videoElem,
    FileElem? fileElem,
    CardElem? cardElem,
    LocationElem? locationElem,
    List<String> tagIDList = const [],
    List<String> userIDList = const [],
    List<String> groupIDList = const [],
  }) async {
    return HttpUtil.post(
      Urls.sendTagNotification,
      data: {
        'tagIDs': tagIDList,
        'userIDs': userIDList,
        'groupIDs': groupIDList,
        'senderPlatformID': IMUtils.getPlatform(),
        'content': json.encode({
          'data': json.encode({
            "customType": CustomMessageType.tag,
            "data": {
              // 'contentType': contentType,
              'pictureElem': pictureElem?.toJson(),
              'videoElem': videoElem?.toJson(),
              'fileElem': fileElem?.toJson(),
              'cardElem': cardElem?.toJson(),
              'locationElem': locationElem?.toJson(),
              'soundElem': soundElem?.toJson(),
              'textElem': textElem?.toJson(),
            },
          }),
          'extension': '',
          'description': '',
        }),
      },
      options: chatTokenOptions,
    );
  }

  /// 获取tag通知列表
  static Future<List<TagNotification>> getTagNotificationLog({
    String? userID,
    required int pageNumber,
    required int showNumber,
  }) async {
    final result = await HttpUtil.post(
      Urls.getTagNotificationLog,
      data: {
        'userID': userID,
        'pagination': {'pageNumber': pageNumber, 'showNumber': showNumber},
      },
      options: chatTokenOptions,
    );
    final list = result['tagSendLogs'];
    if (list is List) {
      return list.map((e) => TagNotification.fromJson(e)).toList();
    }
    return [];
  }

  static delTagNotificationLog({
    required List<String> ids,
  }) =>
      HttpUtil.post(
        Urls.delTagNotificationLog,
        data: <String, dynamic>{'ids': ids},
        options: chatTokenOptions,
      );
}
