import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:miti_common/miti_common.dart';

class ChatFacePreview extends StatelessWidget {
  const ChatFacePreview({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrLibrary.emoji),
      backgroundColor: StylesLibrary.c_FFFFFF,
      body: Center(
        child: _networkGestureImage(url),
      ),
    );
  }

  Widget _networkGestureImage(String url) => ExtendedImage.network(
        url,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        clearMemoryCacheWhenDispose: true,
        clearMemoryCacheIfFailed: true,
        handleLoadingProgress: true,
        enableSlideOutPage: true,
        initGestureConfigHandler: (ExtendedImageState state) {
          return GestureConfig(
            //you must set inPageView true if you want to use ExtendedImageGesturePageView
            inPageView: true,
            initialScale: 1.0,
            maxScale: 20,
            animationMaxScale: 21,
            initialAlignment: InitialAlignment.center,
          );
        },
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              {
                final ImageChunkEvent? loadingProgress = state.loadingProgress;
                final double? progress =
                    loadingProgress?.expectedTotalBytes != null
                        ? loadingProgress!.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null;
                // CupertinoActivityIndicator()
                return SizedBox(
                  width: 15.0,
                  height: 15.0,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: StylesLibrary.c_8443F8,
                      strokeWidth: 1.5,
                      value: progress ?? 0,
                    ),
                  ),
                );
              }
            case LoadState.completed:
              return null;
            case LoadState.failed:
              // remove memory cached
              state.imageProvider.evict();
              return ImageLibrary.pictureError.toImage;
          }
        },
      );
}
