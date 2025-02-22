import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:miti_common/miti_common.dart';

class LiveLoadingView extends StatelessWidget {
  const LiveLoadingView({
    Key? key,
    this.assetsName = 'assets/anim/live_loading.json',
    this.package = 'miti_common',
    this.status = false,
  }) : super(key: key);
  final bool status;
  final String assetsName;
  final String? package;

  Widget get _loadingAnimView => Center(
        child: Lottie.asset(assetsName, width: 50.w, package: package),
      );

  @override
  Widget build(BuildContext context) => status
      ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StrLibrary.connecting.toText
              ..style = StylesLibrary.ts_FFFFFF_opacity70_17sp,
            _loadingAnimView,
          ],
        )
      : _loadingAnimView;
}
