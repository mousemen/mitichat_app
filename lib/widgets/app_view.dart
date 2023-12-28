import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../core/controller/app_controller.dart';

class AppView extends StatelessWidget {
  AppView({Key? key, required this.builder}) : super(key: key);
  final Widget Function(Locale? locale, TransitionBuilder builder) builder;
  final appCommonLogic = Get.find<AppCommonLogic>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      init: AppController(),
      builder: (ctrl) => FocusDetector(
        onForegroundGained: () {
          ctrl.runningBackground(false);
          appCommonLogic.setForeground(true);
          appCommonLogic.tryUpdateAppFromCache();
        },
        onForegroundLost: () {
          ctrl.runningBackground(true);
          appCommonLogic.setForeground(false);
        },
        child: ScreenUtilInit(
          designSize: const Size(Config.uiW, Config.uiH),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) => builder(ctrl.getLocale(), _builder()),
        ),
      ),
    );
  }

  static TransitionBuilder _builder() => EasyLoading.init(
        builder: (context, widget) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // textScaleFactor: Config.textScaleFactor,
              textScaler: TextScaler.linear(Config.textScaleFactor),
            ),
            child: widget!,
          );
        },
      );
}
