import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti_common/miti_common.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatVideoView extends StatefulWidget {
  const ChatVideoView({
    Key? key,
    required this.message,
    required this.isISend,
    this.sendProgressStream,
  }) : super(key: key);
  final bool isISend;
  final Stream<MsgStreamEv<int>>? sendProgressStream;
  final Message message;

  @override
  State<ChatVideoView> createState() => _ChatVideoViewState();
}

class _ChatVideoViewState extends State<ChatVideoView> {
  late double _trulyWidth;
  late double _trulyHeight;
  String? _snapshotUrl;
  String? _snapshotPath;
  Widget? _child;

  Message get _message => widget.message;
  @override
  void initState() {
    final video = _message.videoElem;
    _snapshotUrl = video?.snapshotUrl?.adjustThumbnailUrl(540);
    _snapshotPath = video?.snapshotPath;

    var w = video?.snapshotWidth?.toDouble() ?? 1.0;
    var h = video?.snapshotHeight?.toDouble() ?? 1.0;

    _trulyWidth = pictureWidth;
    _trulyHeight = _trulyWidth * h / w;

    if (Platform.isIOS) {
      if (_snapshotPath?.contains('/Library/Caches/') == true) {
        getApplicationCacheDirectory().then((value) {
          final path = _snapshotPath!.split('/Library/Caches').last;
          _snapshotPath = value.path + path;
          _createThumbView();
        });
      } else {
        _createThumbView();
      }
    } else {
      _createThumbView();
    }
    super.initState();
  }

  Future<bool> _checkingPath() async {
    var valid = MitiUtils.isNotNullEmptyStr(_snapshotPath);
    if (!valid) {
      return false;
    }
    if (Platform.isIOS) {
      final exist = File(_snapshotPath!).existsSync();
      valid = valid && exist;
    } else {
      valid = valid &&
          await Permissions.checkStorageV2([Permission.videos]) &&
          File(_snapshotPath!).existsSync();
    }
    _message.exMap['validPath_$_snapshotPath'] = valid;

    return valid;
  }

  bool? get isValidPath => _message.exMap['validPath_$_snapshotPath'];

  _createThumbView() async {
    if (widget.isISend &&
        (isValidPath == true || isValidPath == null && await _checkingPath())) {
      _child = ImageUtil.fileImage(
        file: File(_snapshotPath!),
        height: _trulyHeight,
        width: _trulyWidth,
        fit: BoxFit.fitWidth,
      );
    } else if (MitiUtils.isNotNullEmptyStr(_snapshotUrl)) {
      _child = ImageUtil.networkImage(
        url: _snapshotUrl!,
        width: _trulyWidth,
        height: _trulyHeight,
        fit: BoxFit.fitWidth,
      );
    }
    if (null != _child) {
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: borderRadius(widget.isISend),
        child: SizedBox(
          width: _trulyWidth,
          height: _trulyHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (null != _child) _child!,
              ImageLibrary.videoPause.toImage
                ..width = 40.w
                ..height = 40.h,
              ChatProgressView(
                height: _trulyHeight,
                width: _trulyWidth,
                id: _message.clientMsgID!,
                stream: widget.sendProgressStream,
                isISend: widget.isISend,
                type: ProgressType.video,
              ),
              if (null != _message.videoElem?.duration)
                Positioned(
                  bottom: 2.h,
                  right: 3.w,
                  child: MitiUtils.seconds2HMS(_message.videoElem!.duration!)
                      .toText
                    ..style = StylesLibrary.ts_FFFFFF_12sp,
                ),
            ],
          ),
        ),
      );
}
