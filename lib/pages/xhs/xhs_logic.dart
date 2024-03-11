import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:miti/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_working_circle/openim_working_circle.dart';
import 'package:openim_working_circle/src/w_apis.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// import '../publish/publish_logic.dart';
// import 'preview_picture/preview_picture_view.dart';
// import 'preview_video/preview_video_view.dart';

enum OpEvent { delete, publish, update }

// abstract class RefreshIndicatorController extends GetxController
//     with GetTickerProviderStateMixin {
//   final scrollController = ScrollController();
//
//   late AnimationController translationController;
//   late Animation<double> translationAnimation;
//
//   late AnimationController rotationController;
//   late Animation<double> rotationAnimation;
//
//   bool isLoading = false;
//   bool isRefreshing = false;
//   bool canRefresh = false;
//
//   final hasMore = true.obs;
//
//   bool pointerUp = false;
//
//   @override
//   void onInit() {
//     scrollController.addListener(_scrollListener);
//     translationController = AnimationController(
//       duration: 500.milliseconds,
//       vsync: this,
//     )..addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           // reverseTranslationAnimation();
//         } else if (status == AnimationStatus.dismissed) {
//           resetRotationAnimation();
//         }
//       });
//
//     translationAnimation =
//         Tween(begin: -24.h, end: 100.0).animate(CurvedAnimation(
//       parent: translationController,
//       curve: Curves.easeOut,
//     ));
//
//     rotationController =
//         AnimationController(duration: 500.milliseconds, vsync: this)
//           ..addStatusListener((status) {
//             if (status == AnimationStatus.completed) {
//               // reverseTranslationAnimation();
//               if (isRefreshing) {
//                 rotationController.reset();
//                 rotationController.forward();
//               }
//             }
//           });
//     rotationAnimation =
//         Tween<double>(begin: 0, end: 2 * pi).animate(rotationController);
//     super.onInit();
//   }
//
//   @override
//   void onClose() {
//     scrollController.dispose();
//     translationController.dispose();
//     rotationController.dispose();
//     super.onClose();
//   }
//
//   void _scrollListener() async {
//     canRefresh = scrollController.offset < -100;
//     if (canRefresh && !pointerUp) {
//       forwardTranslationAnimation();
//     }
//     if (!isLoading &&
//         hasMore.value &&
//         scrollController.position.pixels ==
//             scrollController.position.maxScrollExtent) {
//       isLoading = true;
//       await onLoad();
//       isLoading = false;
//     }
//   }
//
//   forwardTranslationAnimation() {
//     if (!translationController.isAnimating) {
//       translationController.forward();
//     }
//   }
//
//   reverseTranslationAnimation() {
//     if (translationController.isCompleted) {
//       translationController.reverse();
//     }
//   }
//
//   forwardRotationAnimation() {
//     if (!rotationController.isAnimating) {
//       rotationController.forward();
//     }
//   }
//
//   reverseRotationAnimation() {
//     if (rotationController.isCompleted) {
//       rotationController.reverse();
//     }
//   }
//
//   stopRotationAnimation() {
//     if (rotationController.isAnimating) {
//       rotationController.stop();
//     }
//   }
//
//   resetRotationAnimation() {
//     if (rotationController.isCompleted) {
//       rotationController.reset();
//     }
//   }
//
//   startRefresh() async {
//     if (!canRefresh) {
//       reverseTranslationAnimation();
//       return;
//     }
//     if (isRefreshing) return;
//     isRefreshing = true;
//     forwardRotationAnimation();
//     try {
//       await Future.delayed(500.milliseconds);
//       await onRefresh();
//     } finally {
//       stopRotationAnimation();
//       reverseTranslationAnimation();
//       isRefreshing = false;
//     }
//   }
//
//   Future<bool> onRefresh();
//
//   Future<bool> onLoad();
// }
class Category {
  String label;
  String value;

  Category({required String this.label, required String this.value});
}

class XhsLogic extends GetxController {
  final headerIndex = 0.obs;

  void startXhsMomentDetail(WorkMoments xhsMoment) {
    AppNavigator.startXhsMomentDetail(xhsMoment: xhsMoment);
    Apis.addActionRecord(actionRecordList: [
      ActionRecord(
          category: ActionCategory.discover,
          actionName: ActionName.read,
          workMomentID: xhsMoment.workMomentID)
    ]);
  }

  late List<RefreshController> refreshCtrlList;
  final inputCtrl = TextEditingController();
  final workMoments = <WorkMoments>[].obs;
  final commentHintText = ''.obs;
  final popMenuID = ''.obs;
  final newMessageCount = 0.obs; // 是否有新消息提醒
  Offset? popMenuPosition;
  Size? popMenuSize;
  String? commentWorkMomentsID;
  String? replyUserID;
  int pageNo = 1;
  int pageSize = 20;
  String? userID;
  late String nickname;
  late String faceURL;
  StreamSubscription? opEventSub;
  Rx<Category> activeCategory =
      Rx(Category(label: StrRes.recommend, value: ""));

  List<Category> get categoryList => [
        Category(label: StrRes.recommend, value: ""),
        Category(label: StrRes.life, value: "life"),
        Category(label: StrRes.aigc, value: "aigc"),
        Category(label: StrRes.web3, value: "web3"),
        Category(label: StrRes.news, value: "news"),
      ];

  int get activeCategoryIndex =>
      categoryList.indexWhere((e) => e.value == activeCategory.value.value);

  ViewUserProfileBridge? get bridge => PackageBridge.viewUserProfileBridge;

  // WorkingCircleBridge? get wcBridge => PackageBridge.workingCircleBridge;

  bool get isMyself => userID == OpenIM.iMManager.userID || userID == null;

  final hasMore = true.obs;
  final ScrollController scrollController = ScrollController();
  final RxDouble scrollHeight = 0.0.obs;
  final PageController pageController = PageController();
  bool switching = false;

  @override
  void onClose() {
    // GetTags.caches.removeLast();
    opEventSub?.cancel();
    inputCtrl.dispose();
    scrollController.dispose();
    pageController.removeListener(_pageListener);
    pageController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    refreshCtrlList = categoryList.map((e) => RefreshController()).toList();
    userID = Get.arguments['userID'] /*?? OpenIM.iMManager.uid*/;
    nickname = Get.arguments['nickname'] ?? OpenIM.iMManager.userInfo.nickname;
    faceURL =
        Get.arguments['faceURL'] ?? OpenIM.iMManager.userInfo.faceURL ?? "";
    // wcBridge?.onRecvNewMessageForWorkingCircle = _recvNewMessage;
    WApis.getUnreadCount(momentType: 2)
        .then((value) => newMessageCount.value = value);
    // opEventSub = wcBridge?.opEventSub.listen(_opEventListener);
    scrollController.addListener(_scrollListener);
    pageController.addListener(_pageListener);
    super.onInit();
  }

  void _scrollListener() {
    scrollHeight.value = scrollController.offset;
  }

  void _pageListener() async {
    if (switching || activeCategoryIndex == pageController.page!.round())
      return;
    activeCategory.value = categoryList[pageController.page!.round()];
    refreshWorkingCircleList(silence: false);
  }

  clickCategory(Category category) {
    final newRefresh = activeCategory.value.value != category.value;
    activeCategory.value = category;
    if (newRefresh) {
      switching = true;
      pageController
          .animateToPage(activeCategoryIndex,
              duration: Duration(milliseconds: 50), curve: Curves.easeInOut)
          .then((value) {
        switching = false;
        refreshWorkingCircleList(silence: false);
      });
    }
  }

  @override
  void onReady() {
    refreshWorkingCircleList(silence: false);
    super.onReady();
  }

  void refreshWorkingCircleList({bool silence = true}) {
    if (!silence) {
      LoadingView.singleton.wrap(
        asyncFunction: () => queryWorkingCircleList(silence: silence),
      );
    } else {
      queryWorkingCircleList(silence: silence);
    }
  }

  /// {'opEvent': OpEvent.delete, 'data': moments}
  _opEventListener(dynamic event) {
    if (event is Map) {
      final opEvent = event['opEvent'];
      final data = event['data'];
      if (opEvent == OpEvent.delete) {
        workMoments.remove(data as WorkMoments);
      } else if (opEvent == OpEvent.publish) {
        queryWorkingCircleList();
      } else if (opEvent == OpEvent.update) {
        final detail = data as WorkMoments;
        final index = workMoments.indexOf(detail);
        workMoments.replaceRange(index, index + 1, [detail]);
      }
    }
  }

  Future<WorkMomentsList> _request(int pageNo) => userID == null
      ? WApis.getMomentsList(
          pageNumber: pageNo,
          showNumber: pageSize,
          momentType: 2,
          category: activeCategory.value.value)
      : WApis.getUserMomentsList(
          userID: userID!,
          pageNumber: pageNo,
          showNumber: pageSize,
          momentType: 2,
          category: activeCategory.value.value);

  queryWorkingCircleList({bool silence = true}) async {
    final curActiveCategoryIndex = activeCategoryIndex;
    try {
      if (!silence) workMoments.clear();
      final result = await _request(pageNo = 1);
      final list = result.workMoments ?? [];
      hasMore.value = list.isNotEmpty && list.length == pageSize;
      if (silence) workMoments.clear();
      workMoments.assignAll(list);
    } catch (_) {}
    refreshCtrlList.map((e) => e.refreshCompleted()).toList();
    if (hasMore.value) {
      refreshCtrlList[curActiveCategoryIndex].loadComplete();
    } else {
      refreshCtrlList[curActiveCategoryIndex].loadNoData();
    }
  }

  loadMore() async {
    final curActiveCategoryIndex = activeCategoryIndex;
    try {
      final result = await _request(++pageNo);
      final list = result.workMoments ?? [];
      hasMore.value = list.isNotEmpty && list.length == pageSize;
      workMoments.addAll(result.workMoments ?? []);
    } catch (_) {
      pageNo--;
    }
    if (hasMore.value) {
      refreshCtrlList[curActiveCategoryIndex].loadComplete();
    } else {
      refreshCtrlList[curActiveCategoryIndex].loadNoData();
    }
  }

  /// 我点赞了
  bool iIsLiked(WorkMoments moments) =>
      moments.likeUsers
          ?.firstWhereOrNull((e) => e.userID == OpenIM.iMManager.userID) !=
      null;

  /// 点赞/取消点赞 朋友圈
  likeMoments(WorkMoments moments) async {
    hiddenLikeCommentPopMenu();
    final workMomentID = moments.workMomentID!;
    if (!iIsLiked(moments)) {
      Apis.addActionRecord(actionRecordList: [
        ActionRecord(
            category: ActionCategory.discover,
            actionName: ActionName.click_like,
            workMomentID: workMomentID)
      ]);
    }
    await LoadingView.singleton.wrap(
      asyncFunction: () async {
        await WApis.likeMoments(
            workMomentID: workMomentID, like: !iIsLiked(moments));
        await _updateData(workMomentID);
      },
    );
  }

  /// 提交评论
  submitComment() async {
    final text = inputCtrl.text.trim();
    if (text.isNotEmpty && null != commentWorkMomentsID) {
      await LoadingView.singleton.wrap(asyncFunction: () async {
        await WApis.commentMoments(
          workMomentID: commentWorkMomentsID!,
          text: text,
          replyUserID: replyUserID,
        );
        await _updateData(commentWorkMomentsID!);
      });
      cancelComment();
    }
  }

  /// 评论朋友圈
  commentMoments(WorkMoments moments) async {
    hiddenLikeCommentPopMenu();
    commentHintText.value = '${StrRes.comment}：';
    commentWorkMomentsID = moments.workMomentID!;
    replyUserID = null;
  }

  /// 回复评论
  replyComment(WorkMoments moments, Comments comments) async {
    hiddenLikeCommentPopMenu();
    if (comments.userID == OpenIM.iMManager.userID) {
      final del = await Get.bottomSheet(
        barrierColor: Styles.c_191919_opacity50,
        BottomSheetView(items: [SheetItem(label: StrRes.delete, result: 1)]),
      );
      if (del == 1) {
        delComment(moments, comments);
      }
    } else {
      commentHintText.value = '${StrRes.reply} ${comments.nickname}：';
      commentWorkMomentsID = moments.workMomentID!;
      replyUserID = comments.userID;
    }
  }

  /// 删除评论
  delComment(WorkMoments moments, Comments comments) async {
    LoadingView.singleton.wrap(
      asyncFunction: () async {
        await WApis.deleteComment(
          workMomentID: moments.workMomentID!,
          commentID: comments.commentID!,
        );
        await _updateData(moments.workMomentID!);
      },
    );
  }

  Future<void> delWorkWorkMoments(WorkMoments moments) async {
    var confirm = await Get.dialog(CustomDialog(
      title: StrRes.confirmDelMoment,
    ));
    if (!confirm) return;
    await LoadingView.singleton.wrap(
      asyncFunction: () async {
        await WApis.deleteMoments(workMomentID: moments.workMomentID!);
      },
    );
    workMoments.remove(moments);
    newMessageCount.value = await WApis.getUnreadCount(momentType: 2);
  }

  _updateData(String workMomentID) async {
    final detail =
        await WApis.getMomentsDetail(workMomentID: workMomentID, momentType: 2);
    final index = workMoments.indexOf(detail);
    workMoments.replaceRange(index, index + 1, [detail]);
  }

  showLikeCommentPopMenu(String workMomentID) {
    popMenuID.value = workMomentID;
  }

  hiddenLikeCommentPopMenu() => showLikeCommentPopMenu("");

  popMenuPositionCallback(Offset position, Size size) {
    popMenuPosition = position;
    popMenuSize = size;
  }

  cancelComment() {
    commentHintText.value = '';
    commentWorkMomentsID = null;
    replyUserID = null;
    inputCtrl.clear();
  }

  // publish(int type) => WNavigator.startPublishWorkMoments(
  //       type: type == 0 ? PublishType.picture : PublishType.video,
  //     );

  // previewPicture(int index, List<Metas> metas) {
  //   navigator?.push(TransparentRoute(
  //     builder: (BuildContext context) => GestureDetector(
  //       onTap: () => Get.back(),
  //       child: PreviewPicturePage(
  //         metas: metas,
  //         currentIndex: index,
  //         heroTag: metas.elementAt(index).original,
  //       ),
  //     ),
  //   ));
  // }

  // previewVideo(String url, String? coverUrl) {
  //   navigator?.push(TransparentRoute(
  //     builder: (BuildContext context) => PreviewVideoPage(
  //       heroTag: url,
  //       url: url,
  //       coverUrl: coverUrl,
  //     ),
  //   ));
  // }

  /// 0：公开 1: 仅自己可见 2：部分可见 3：不给谁看
  previewWhoCanWatchList(WorkMoments moments) {
    if (moments.permission == 2 || moments.permission == 3) {
      WNavigator.startVisibleUsersList(workMoments: moments);
    }
  }

  seeNewMessage() async {
    WApis.clearUnreadCount(type: 1, momentType: 2);
    newMessageCount.value = 0;
    await WNavigator.startLikeOrCommentMessage();
  }

  viewUserProfile(WorkMoments moments) => _viewProfilePanel(
        userID: moments.userID!,
        nickname: moments.nickname,
        faceURL: moments.faceURL,
      );

  viewMyProfilePanel() => isMyself
      ? _viewProfilePanel(
          userID: OpenIM.iMManager.userID,
          nickname: OpenIM.iMManager.userInfo.nickname,
          faceURL: OpenIM.iMManager.userInfo.faceURL ?? "",
        )
      : null;

  _viewProfilePanel({
    required String userID,
    String? nickname,
    String? faceURL,
  }) =>
      bridge?.viewUserProfile(userID, nickname, faceURL);

  _recvNewMessage(WorkMomentsNotification notification) async {
    // newMessageCount.value = notification.unreadNum ?? 0;
    final newValue = notification.body;
    if (null != newValue) {
      final index = workMoments.indexOf(newValue);
      if (index != -1) {
        workMoments.replaceRange(index, index + 1, [newValue]);
        workMoments.refresh();
      }
    }
    newMessageCount.value = await WApis.getUnreadCount(momentType: 2);
  }

// @override
// Future<bool> onRefresh() async {
//   await queryWorkingCircleList();
//   return true;
// }
//
// @override
// Future<bool> onLoad() async {
//   await loadMore();
//   return true;
// }
}
