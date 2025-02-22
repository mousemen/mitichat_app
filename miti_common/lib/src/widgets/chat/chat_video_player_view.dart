import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:miti_common/miti_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../custom_cupertino_controls.dart';

abstract class VideoControllerService {
  Future<VideoPlayerController> getVideo(String videoUrl);
  Future<File?> getCacheFile(String videoUrl);
}

class CachedVideoControllerService extends VideoControllerService {
  final BaseCacheManager _cacheManager;

  CachedVideoControllerService(this._cacheManager);

  @override
  Future<VideoPlayerController> getVideo(String videoUrl) async {
    final file = await getCacheFile(videoUrl);
    myLogger.i({
      "message": "CachedVideoControllerService进行getVideo",
      "data": {"hasFileCache": file != null}
    });

    if (file == null) {
      await (_cacheManager.downloadFile(videoUrl));
      final file = await getCacheFile(videoUrl);

      // return VideoPlayerController.network(videoUrl);
      // return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      if (null != file) {
        return VideoPlayerController.file(file!);
      } else {
        return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      }
    } else {
      return VideoPlayerController.file(file);
    }
  }

  @override
  Future<File?> getCacheFile(String videoUrl) async {
    // TODO: implement getCacheFile
    final fileInfo = await _cacheManager.getFileFromCache(videoUrl);

    return fileInfo?.file;
  }
}

class ChatVideoPlayerView extends StatefulWidget {
  const ChatVideoPlayerView({
    Key? key,
    this.path,
    this.url,
    this.coverUrl,
    this.file,
    this.heroTag,
    this.oDownload,
    this.autoPlay = true,
    this.muted = false,
  }) : super(key: key);
  final String? path;
  final String? url;
  final File? file;
  final String? coverUrl;
  final String? heroTag;
  final bool autoPlay;
  final bool muted;
  final Function(String? url)? oDownload;

  @override
  State<ChatVideoPlayerView> createState() => _ChatVideoPlayerViewState();
}

class _ChatVideoPlayerViewState extends State<ChatVideoPlayerView>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  final _cachedVideoControllerService =
      CachedVideoControllerService(DefaultCacheManager());

  @override
  void initState() {
    initializePlayer();
    super.initState();
  }

  @override
  void dispose() {
    _chewieController?.pause();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    var file = widget.file;

    if (file == null) {
      bool existFile = false;
      if (MitiUtils.isNotNullEmptyStr(_path) &&
          (await Permissions.checkStorageV2([Permission.videos]))) {
        file = File(_path!);
        existFile = await file.exists();
        if (!existFile) {
          file = null;
        }
      }
      myLogger.i({
        "message":
            "initializePlayer, file不存在, 使用${_path}, _path的file${existFile ? '存在' : '不存在'}",
      });
    }

    if (null != file && file.existsSync()) {
      myLogger.i({
        "message": "initializePlayer, file存在, ${file.path}, ${_url}",
      });
      _videoPlayerController = VideoPlayerController.file(file);
    } else {
      myLogger.i({
        "message": "initializePlayer, file不存在使用url, ${_url}",
      });
      _videoPlayerController =
          await _cachedVideoControllerService.getVideo(_url!);
    }

    await _videoPlayerController.initialize();
    if (widget.muted) {
      _videoPlayerController.setVolume(0);
    }
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: widget.autoPlay,
      looping: false,
      allowFullScreen: false,
      allowPlaybackSpeedChanging: false,
      showControlsOnInitialize: true,
      customControls: CustomCupertinoControls(
          backgroundColor: Colors.black.withOpacity(0.7),
          iconColor: Colors.white),
      // hideControlsTimer: const Duration(seconds: 1),
      optionsTranslation: OptionsTranslation(
        playbackSpeedButtonText: StrLibrary.playSpeed,
        cancelButtonText: StrLibrary.cancel,
      ),
      additionalOptions: (context) => [
        OptionItem(
          onTap: () {
            widget.oDownload?.call(widget.url);
            Get.back();
          },
          iconData: Icons.download_outlined,
          title: StrLibrary.download,
        ),
      ],
    );
  }

  Future<void> toggleVideo() async {
    await _videoPlayerController.pause();
    await initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          if (_chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized)
            Chewie(controller: _chewieController!)
          else
            _buildCoverView(context),
        ],
      ),
    );
  }

  Widget _buildCoverView(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          if (null != widget.coverUrl)
            Center(
              child: ImageUtil.networkImage(
                  url: widget.coverUrl!,
                  loadProgress: false,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth),
            ),
          const Center(
            child: CupertinoActivityIndicator(
              color: Colors.white,
            ),
          ),
        ],
      );

  String? get _path => widget.path;

  String? get _url => widget.url;
}
