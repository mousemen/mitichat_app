import 'dart:convert';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:miti_common/miti_common.dart';
import 'package:miti_circle/src/circle_urls.dart';
import 'package:uuid/uuid.dart';

class CircleApis {
  /// 发布工作圈动态
  /// [type] 0 picture  1 video
  static Future publishMoments(
      {String? text,
      int type = 0,
      List<Map<String, String>>? metas,
      List<UserInfo> permissionUserList = const [],
      List<GroupInfo> permissionGroupList = const [],
      List<UserInfo> atUserList = const [],
      int permission = 0,
      int momentType = 1,
      String? title,
      String? author,
      String? originLink,
      String? category}) async {
    var metasUrl = [];
    // if (metas != null && metas.isNotEmpty) {
    //   const thumbKey = 'thumb'; // 缩率图
    //   const originalKey = 'original'; // 原文件
    //   // 将所有的多媒体文件取出来， 进行上传
    //   await Future.forEach<Map<String, String>>(metas, (element) async {
    //     var thumbPath = element[thumbKey]!;
    //     var originalPath = element[originalKey]!;
    //     final result = await Future.wait([
    //       OpenIM.iMManager.putFile(
    //         putID: '${DateTime.now().millisecondsSinceEpoch}',
    //         filePath: thumbPath,
    //         fileName: thumbPath,
    //       ),
    //       OpenIM.iMManager.putFile(
    //         putID: '${DateTime.now().millisecondsSinceEpoch}',
    //         filePath: originalPath,
    //         fileName: originalPath,
    //       ),
    //     ]);
    //     metasUrl.add({thumbKey: result[0], originalKey: result[1]});
    //   });
    // }

    if (null != metas && metas.isNotEmpty) {
      const thumbKey = 'thumb'; // 缩率图
      const originalKey = 'original'; // 原文件
      final allMetas = <String>[];
      for (var m in metas) {
        allMetas.add(m[thumbKey]!);
        allMetas.add(m[originalKey]!);
      }
      final result = await Future.wait(allMetas.map((e) {
        final suffix = MitiUtils.getSuffix(e);
        return OpenIM.iMManager.uploadFile(
          id: const Uuid().v4(),
          filePath: e,
          fileName: "${const Uuid().v4()}$suffix",
        );
      }));
      if (result.length.isEven) {
        for (int i = 0; i < result.length; i += 2) {
          final thumb = jsonDecode(result[i])['url'];
          final original = jsonDecode(result[i + 1])['url'];
          metasUrl.add({
            thumbKey: "$thumb?type=image&width=420&height=420",
            originalKey: original
          });
        }
      }
    }

    return HttpUtil.post(
      CircleUrls.createMoments,
      options: ClientApis.chatTokenOptions,
      data: <String, dynamic>{
        "content": {
          "metas": metasUrl,
          "text": text ?? '',
          "type": type,
          "title": title,
          "author": author,
          "category": category,
          "originLink": originLink
        },
        'permissionUserIDs': permissionUserList.map((e) => e.userID).toList(),
        'permissionGroupIDs':
            permissionGroupList.map((e) => e.groupID).toList(),
        'atUserIDs': atUserList.map((e) => e.userID).toList(),
        'permission': permission,
        'momentType': momentType,
      },
    );
  }

  /// 删除
  static Future deleteMoments({
    required String workMomentID,
  }) {
    return HttpUtil.post(
      CircleUrls.deleteMoments,
      options: ClientApis.chatTokenOptions,
      data: <String, dynamic>{'workMomentID': workMomentID},
    );
  }

  /// 一条工作圈详情
  static Future<WorkMoments> getMomentsDetail({
    required String workMomentID,
    int momentType = 1,
  }) async {
    final result = await HttpUtil.post(
      CircleUrls.getMomentsDetail,
      options: ClientApis.chatTokenOptions,
      data: <String, dynamic>{
        'workMomentID': workMomentID,
        'momentType': momentType
      },
    );
    return WorkMoments.fromJson(result['workMoment']);
  }

  /// 获取工作圈列表
  static Future<FriendMomentsList> getMomentsList(
      {int pageNumber = 1,
      int showNumber = 20,
      int momentType = 1,
      String category = ""}) {
    return HttpUtil.post(
      CircleUrls.getMomentsList,
      options: ClientApis.chatTokenOptions,
      data: <String, dynamic>{
        "pagination": {"pageNumber": pageNumber, "showNumber": showNumber},
        'momentType': momentType,
        "category": category
      },
    ).then((value) => FriendMomentsList.fromJson(value));
  }

  static Future<FriendMomentsList> getUserMomentsList({
    required String userID,
    int pageNumber = 1,
    int showNumber = 20,
    int momentType = 1,
    String category = "",
  }) {
    return HttpUtil.post(
      CircleUrls.getUserMomentsList,
      options: ClientApis.chatTokenOptions,
      data: <String, dynamic>{
        "userID": userID,
        "pagination": {"pageNumber": pageNumber, "showNumber": showNumber},
        'momentType': momentType,
        "category": category
      },
    ).then((value) => FriendMomentsList.fromJson(value));
  }

  /// 点赞工作圈
  static Future likeMoments({
    required String workMomentID,
    required bool like,
  }) {
    return HttpUtil.post(
      CircleUrls.likeMoments,
      options: ClientApis.chatTokenOptions,
      data: <String, dynamic>{'workMomentID': workMomentID, "like": like},
    );
  }

  /// 评论工作圈
  static Future commentMoments({
    required String workMomentID,
    String? replyUserID,
    required String text,
  }) {
    return HttpUtil.post(
      CircleUrls.commentMoments,
      options: ClientApis.chatTokenOptions,
      data: <String, dynamic>{
        'workMomentID': workMomentID,
        'replyUserID': replyUserID ?? '',
        'content': text
      },
    );
  }

  /// 删除
  static Future deleteComment({
    required String workMomentID,
    required String commentID,
  }) {
    return HttpUtil.post(
      CircleUrls.deleteComment,
      options: ClientApis.chatTokenOptions,
      data: <String, dynamic>{
        'workMomentID': workMomentID,
        'commentID': commentID
      },
    );
  }

  /// 互动消息
  static Future<List<WorkMoments>> getInteractiveLogs({
    int pageNumber = 1,
    int showNumber = 20,
    int momentType = 1,
  }) async {
    final result = await HttpUtil.post(
      CircleUrls.getInteractiveLogs,
      options: ClientApis.chatTokenOptions,
      data: <String, dynamic>{
        "pagination": {"pageNumber": pageNumber, "showNumber": showNumber},
        'momentType': momentType
      },
    );
    final list = result['workMoments'];
    if (list == null) return [];
    return (list as List).map((e) => WorkMoments.fromJson(e)).toList();
  }

  /// 1:未读数 2:消息列表 3:全部
  static Future clearUnreadCount({
    required int type,
    int momentType = 1,
  }) =>
      HttpUtil.post(
        CircleUrls.clearUnreadCount,
        options: ClientApis.chatTokenOptions,
        data: <String, dynamic>{"type": type, 'momentType': momentType},
      );

  static Future<int> getUnreadCount({
    int momentType = 1,
  }) async {
    final result = await HttpUtil.post(
      CircleUrls.getUnreadCount,
      data: {'momentType': momentType},
      options: ClientApis.chatTokenOptions,
    );
    return result['total'] ?? 0;
  }
}
