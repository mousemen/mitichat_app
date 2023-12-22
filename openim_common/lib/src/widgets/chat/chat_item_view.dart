import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_common/src/widgets/chat/chat_quote_view.dart';
import 'package:rxdart/rxdart.dart';

double maxWidth = 247.w;
double pictureWidth = 120.w;
double videoWidth = 120.w;
double locationWidth = 220.w;

BorderRadius borderRadius(bool isISend) => BorderRadius.only(
      topLeft: Radius.circular(isISend ? 6.r : 0),
      topRight: Radius.circular(isISend ? 0 : 6.r),
      bottomLeft: Radius.circular(6.r),
      bottomRight: Radius.circular(6.r),
    );

class MsgStreamEv<T> {
  final String id;
  final T value;

  MsgStreamEv({required this.id, required this.value});

  @override
  String toString() {
    return 'MsgStreamEv{msgId: $id, value: $value}';
  }
}

class CustomTypeInfo {
  final Widget customView;
  final bool needBubbleBackground;
  final bool needChatItemContainer;

  CustomTypeInfo(
    this.customView, [
    this.needBubbleBackground = true,
    this.needChatItemContainer = true,
  ]);
}

typedef CustomTypeBuilder = CustomTypeInfo? Function(
  BuildContext context,
  Message message,
);
typedef NotificationTypeBuilder = Widget? Function(
  BuildContext context,
  Message message,
);
typedef ItemViewBuilder = Widget? Function(
  BuildContext context,
  Message message,
);
typedef ItemVisibilityChange = void Function(
  Message message,
  bool visible,
);

class ChatItemView extends StatefulWidget {
  const ChatItemView({
    Key? key,
    this.mediaItemBuilder,
    this.itemViewBuilder,
    this.customTypeBuilder,
    this.notificationTypeBuilder,
    // required this.clickSubject,
    this.sendStatusSubject,
    this.sendProgressSubject,
    this.visibilityChange,
    this.timelineStr,
    this.leftNickname,
    this.leftFaceUrl,
    this.rightNickname,
    this.rightFaceUrl,
    required this.message,
    this.textScaleFactor = 1.0,
    this.readingDuration = 30,
    // required this.isBubbleMsg,
    this.isMultiSelMode = false,
    this.enabledReadStatus = true,
    this.isPrivateChat = false,
    this.showLongPressMenu = true,
    this.isPlayingSound = false,
    this.canReEdit = false,
    this.ignorePointer = false,
    this.enabledAddEmojiMenu = true,
    this.enabledCopyMenu = true,
    this.enabledDelMenu = true,
    this.enabledForwardMenu = true,
    this.enabledMultiMenu = true,
    this.enabledReplyMenu = true,
    this.enabledRevokeMenu = true,
    this.showLeftNickname = true,
    this.showRightNickname = false,
    this.onTapAddEmojiMenu,
    this.highlightColor,
    this.allAtMap = const {},
    this.patterns = const [],
    this.checkedList = const [],
    this.onTapLeftAvatar,
    this.onTapRightAvatar,
    this.onLongPressLeftAvatar,
    this.onLongPressRightAvatar,
    this.onTapMultiMenu,
    this.onTapCopyMenu,
    this.onTapDelMenu,
    this.onTapForwardMenu,
    this.onTapReplyMenu,
    this.onTapRevokeMenu,
    this.onVisibleTrulyText,
    this.onPopMenuShowChanged,
    this.onTapQuoteMessage,
    this.onMultiSelChanged,
    this.onDestroyMessage,
    this.onViewMessageReadStatus,
    this.onFailedToResend,
    this.onReEit,
    this.closePopMenuSubject,
    this.onClickItemView,
    this.fileDownloadProgressView,
  }) : super(key: key);
  final ItemViewBuilder? mediaItemBuilder;
  final ItemViewBuilder? itemViewBuilder;
  final CustomTypeBuilder? customTypeBuilder;
  final NotificationTypeBuilder? notificationTypeBuilder;

  // final Subject<Message> clickSubject;
  final Subject<MsgStreamEv<bool>>? sendStatusSubject;
  final Subject<MsgStreamEv<int>>? sendProgressSubject;

  // final Subject<MsgStreamEv<double>> downloadProgressSubject;
  final ItemVisibilityChange? visibilityChange;
  final String? timelineStr;
  final String? leftNickname;
  final String? leftFaceUrl;
  final String? rightNickname;
  final String? rightFaceUrl;
  final Message message;

  /// 文字缩放系数
  final double textScaleFactor;

  /// 阅读时长s
  final int readingDuration;

  // final bool isBubbleMsg;
  final bool isMultiSelMode;
  final bool enabledReadStatus;

  /// 是否开启阅后即焚
  final bool isPrivateChat;

  /// 显示长按菜单
  final bool showLongPressMenu;

  /// 当前播放的语音消息
  final bool isPlayingSound;
  final bool canReEdit;

  /// 禁止pop菜单 ，如禁言的时候
  final bool ignorePointer;
  final bool enabledCopyMenu;
  final bool enabledDelMenu;
  final bool enabledForwardMenu;
  final bool enabledReplyMenu;
  final bool enabledRevokeMenu;
  final bool enabledMultiMenu;
  final bool enabledAddEmojiMenu;
  final bool showLeftNickname;
  final bool showRightNickname;

  ///
  final Color? highlightColor;
  final Map<String, String> allAtMap;
  final List<MatchPattern> patterns;
  final List<Message> checkedList;
  final Function()? onTapLeftAvatar;
  final Function()? onTapRightAvatar;
  final Function()? onLongPressLeftAvatar;
  final Function()? onLongPressRightAvatar;
  final Function()? onTapCopyMenu;
  final Function()? onTapDelMenu;
  final Function()? onTapForwardMenu;
  final Function()? onTapReplyMenu;
  final Function()? onTapRevokeMenu;
  final Function()? onTapMultiMenu;
  final Function()? onTapAddEmojiMenu;
  final Function(String? text)? onVisibleTrulyText;
  final Function(bool show)? onPopMenuShowChanged;
  final Function(Message message)? onTapQuoteMessage;
  final Function(bool checked)? onMultiSelChanged;
  final Function()? onClickItemView;

  /// 阅后即焚回调
  final Function()? onDestroyMessage;

  /// 预览群消息已读状态
  final Function()? onViewMessageReadStatus;

  /// 失败重发
  final Function()? onFailedToResend;
  final Function()? onReEit;

  /// 点击系统软键盘返回键关闭菜单
  final Subject<bool>? closePopMenuSubject;

  /// 文件下载精度
  final Widget? fileDownloadProgressView;

  @override
  State<ChatItemView> createState() => _ChatItemViewState();
}

class _ChatItemViewState extends State<ChatItemView> {
  final _popupCtrl = CustomPopupMenuController();

  Message get _message => widget.message;

  bool get _isISend => _message.sendID == OpenIM.iMManager.userID;

  bool get _isChecked => widget.checkedList.contains(_message);
  late StreamSubscription<bool> _keyboardSubs;
  StreamSubscription<bool>? _closeMenuSubs;

  @override
  void dispose() {
    _popupCtrl.dispose();
    _keyboardSubs.cancel();
    _closeMenuSubs?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    final keyboardVisibilityCtrl = KeyboardVisibilityController();
    // Query
    // Logger.print(
    //     'Keyboard visibility direct query: ${keyboardVisibilityCtrl.isVisible}');

    // Subscribe
    _keyboardSubs = keyboardVisibilityCtrl.onChange.listen((bool visible) {
      // Logger.print('Keyboard visibility update. Is visible: $visible');
      _popupCtrl.hideMenu();
    });

    _popupCtrl.addListener(() {
      widget.onPopMenuShowChanged?.call(_popupCtrl.menuIsShowing);
    });

    _closeMenuSubs = widget.closePopMenuSubject?.listen((value) {
      if (value == true) {
        _popupCtrl.hideMenu();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      child: Container(
        color: widget.highlightColor,
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Center(child: _child),
      ),
      onVisibilityLost: () {
        widget.visibilityChange?.call(widget.message, false);
      },
      onVisibilityGained: () {
        widget.visibilityChange?.call(widget.message, true);
      },
    );
  }

  Widget get _child => widget.itemViewBuilder?.call(context, _message) ?? _buildChildView();

  Widget _buildChildView() {
    Widget? child;
    String? senderNickname;
    String? senderFaceURL;
    bool isBubbleBg = false;
    /* if (_message.isCallType) {
    } else if (_message.isMeetingType) {
    } else if (_message.isDeletedByFriendType) {
    } else if (_message.isBlockedByFriendType) {
    } else if (_message.isEmojiType) {
    } else if (_message.isTagType) {
    }*/
    if (_message.isTextType) {
      isBubbleBg = true;
      child = ChatText(
        text: _message.textElem!.content!,
        patterns: widget.patterns,
        textScaleFactor: widget.textScaleFactor,
        onVisibleTrulyText: widget.onVisibleTrulyText,
      );
    } else if (_message.isAtTextType) {
      isBubbleBg = true;
      child = ChatText(
        text: _message.atTextElem!.text!,
        allAtMap: IMUtils.getAtMapping(_message, widget.allAtMap),
        patterns: widget.patterns,
        textScaleFactor: widget.textScaleFactor,
        onVisibleTrulyText: widget.onVisibleTrulyText,
      );
    } else if (_message.isPictureType) {
      child = widget.mediaItemBuilder?.call(context, _message) ??
          ChatPictureView(
            isISend: _isISend,
            message: _message,
            sendProgressStream: widget.sendProgressSubject,
          );
    } else if (_message.isVoiceType) {
      isBubbleBg = true;
      final sound = _message.soundElem;
      child = ChatVoiceView(
        isISend: _isISend,
        soundPath: sound?.soundPath,
        soundUrl: sound?.sourceUrl,
        duration: sound?.duration,
        isPlaying: widget.isPlayingSound,
      );
    } else if (_message.isVideoType) {
      child = widget.mediaItemBuilder?.call(context, _message) ??
          ChatVideoView(
            isISend: _isISend,
            message: _message,
            sendProgressStream: widget.sendProgressSubject,
          );
    } else if (_message.isFileType) {
      child = ChatFileView(
        message: _message,
        isISend: _isISend,
        sendProgressStream: widget.sendProgressSubject,
        fileDownloadProgressView: widget.fileDownloadProgressView,
      );
    } else if (_message.isLocationType) {
      final location = _message.locationElem;
      child = ChatLocationView(
        description: location!.description!,
        latitude: location.latitude!,
        longitude: location.longitude!,
      );
    } else if (_message.isQuoteType) {
      isBubbleBg = true;
      child = ChatText(
        text: _message.quoteElem?.text ?? '',
        allAtMap: IMUtils.getAtMapping(_message, widget.allAtMap),
        patterns: widget.patterns,
        onVisibleTrulyText: widget.onVisibleTrulyText,
      );
    } else if (_message.isMergerType) {
      child = ChatMergeMsgView(
        title: _message.mergeElem?.title ?? '',
        summaryList: _message.mergeElem?.abstractList ?? [],
      );
    } else if (_message.isCardType) {
      child = ChatCarteView(cardElem: _message.cardElem!);
    } else if (_message.isCustomFaceType) {
      final face = _message.faceElem;
      child = ChatCustomEmojiView(
        index: face?.index,
        data: face?.data,
        isISend: _isISend,
        heroTag: _message.clientMsgID,
      );
    } else if (_message.isCustomType) {
      final info = widget.customTypeBuilder?.call(context, _message);
      if (null != info) {
        isBubbleBg = info.needBubbleBackground;
        child = info.customView;
        if (!info.needChatItemContainer) {
          return child;
        }
      }
    } else if (_message.isRevokeType) {
      return child = ChatRevokeView(
        message: _message,
        onReEdit: widget.onReEit,
        canReEdit: widget.canReEdit,
      );
    } else if (_message.isNotificationType) {
      if (_message.contentType == MessageType.groupInfoSetAnnouncementNotification) {
        final map = json.decode(_message.notificationElem!.detail!);
        final ntf = GroupNotification.fromJson(map);
        final noticeContent = ntf.group?.notification;
        senderNickname = ntf.opUser?.nickname;
        senderFaceURL = ntf.opUser?.faceURL;
        child = ChatNoticeView(isISend: _isISend, content: noticeContent!);
      } else {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ChatHintTextView(message: _message),
        );
      }
      // final content = _message.noticeContent;
      // final isNotice = IMUtils.isNotNullEmptyStr(content);
      // child = widget.notificationTypeBuilder?.call(context, _message);
      // if (null == child) {
      //   if (isNotice) {
      //     child = ChatNoticeView(isISend: _isISend, content: content!);
      //   } else {
      //     return ConstrainedBox(
      //       constraints: BoxConstraints(maxWidth: maxWidth),
      //       child: ChatHintTextView(message: _message),
      //     );
      //   }
      // }
    }
    senderNickname ??= widget.leftNickname ?? _message.senderNickname;
    senderFaceURL ??= widget.leftFaceUrl ?? _message.senderFaceUrl;
    return child = ChatItemContainer(
      id: _message.clientMsgID!,
      isISend: _isISend,
      leftNickname: senderNickname,
      leftFaceUrl: senderFaceURL,
      rightNickname: widget.rightNickname ?? OpenIM.iMManager.userInfo.nickname,
      rightFaceUrl: widget.rightFaceUrl ?? OpenIM.iMManager.userInfo.faceURL,
      showLeftNickname: widget.showLeftNickname,
      showRightNickname: widget.showRightNickname,
      timelineStr: widget.timelineStr,
      timeStr: IMUtils.getChatTimeline(_message.sendTime!, 'HH:mm:ss'),
      hasRead: _message.isRead!,
      isSending: _message.status == MessageStatus.sending,
      isSendFailed: _message.status == MessageStatus.failed,
      isMultiSelModel: widget.isMultiSelMode,
      isChecked: _isChecked,
      isBubbleBg: child == null ? true : isBubbleBg,
      menus: widget.showLongPressMenu ? _menusItem : [],
      isPrivateChat: widget.isPrivateChat,
      ignorePointer: widget.ignorePointer,
      onStartDestroy: widget.onDestroyMessage,
      readingDuration: widget.readingDuration,
      sendStatusStream: widget.sendStatusSubject,
      onRadioChanged: widget.onMultiSelChanged,
      onFailedToResend: widget.onFailedToResend,
      popupMenuController: _popupCtrl,
      onLongPressLeftAvatar: widget.onLongPressLeftAvatar,
      onLongPressRightAvatar: widget.onLongPressRightAvatar,
      onTapLeftAvatar: widget.onTapLeftAvatar,
      onTapRightAvatar: widget.onTapRightAvatar,
      quoteView: _quoteMsgView,
      readStatusView: _readStatusView,
      voiceReadStatusView: _voiceReadStatusView,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onClickItemView,
        child: child ?? ChatText(text: StrRes.unsupportedMessage),
      ),
    );
  }

  Widget? get _quoteMsgView {
    final quoteMsg = _message.quoteMessage;
    return quoteMsg != null ? ChatQuoteView(quoteMsg: quoteMsg, onTap: widget.onTapQuoteMessage) : null;
  }

  Widget? get _readStatusView => widget.enabledReadStatus && _isISend && _message.status == MessageStatus.succeeded
      ? ChatReadTagView(message: _message, onTap: widget.onViewMessageReadStatus)
      : null;

  Widget? get _voiceReadStatusView => _message.isVoiceType && !_message.isRead! ? const ChatVoiceReadStatusView() : null;

  List<MenuInfo> get _menusItem => [
        if (widget.enabledCopyMenu)
          MenuInfo(
            icon: ImageRes.menuCopy,
            text: StrRes.menuCopy,
            enabled: widget.enabledCopyMenu,
            onTap: widget.onTapCopyMenu,
          ),
        if (widget.enabledDelMenu)
          MenuInfo(
            icon: ImageRes.menuDel,
            text: StrRes.menuDel,
            enabled: widget.enabledDelMenu,
            onTap: widget.onTapDelMenu,
          ),
        if (widget.enabledForwardMenu)
          MenuInfo(
            icon: ImageRes.menuForward,
            text: StrRes.menuForward,
            enabled: widget.enabledForwardMenu,
            onTap: widget.onTapForwardMenu,
          ),
        if (widget.enabledReplyMenu)
          MenuInfo(
            icon: ImageRes.menuReply,
            text: StrRes.menuReply,
            enabled: widget.enabledReplyMenu,
            onTap: widget.onTapReplyMenu,
          ),
        if (widget.enabledMultiMenu)
          MenuInfo(
            icon: ImageRes.menuMulti,
            text: StrRes.menuMulti,
            enabled: widget.enabledMultiMenu,
            onTap: widget.onTapMultiMenu,
          ),
        if (widget.enabledRevokeMenu)
          MenuInfo(
            icon: ImageRes.menuRevoke,
            text: StrRes.menuRevoke,
            enabled: widget.enabledRevokeMenu,
            onTap: widget.onTapRevokeMenu,
          ),
        if (widget.enabledAddEmojiMenu)
          MenuInfo(
            icon: ImageRes.menuAddFace,
            text: StrRes.menuAdd,
            enabled: widget.enabledAddEmojiMenu,
            onTap: widget.onTapAddEmojiMenu,
          ),
      ];
}
