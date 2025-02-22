import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:miti_common/miti_common.dart';

Future<void> requestBackgroundPermission(
    {bool isRetry = false,
    bool shouldRequestBatteryOptimizationsOff = false}) async {
  if (!Platform.isAndroid) return;
  try {
    bool hasPermissions = await FlutterBackground.hasPermissions;
    final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "miti",
        notificationText: "running....",
        notificationImportance: AndroidNotificationImportance.Default,
        showBadge: false,
        notificationIcon:
            const AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
        shouldRequestBatteryOptimizationsOff:
            shouldRequestBatteryOptimizationsOff);
    if (!isRetry) {
      hasPermissions =
          await FlutterBackground.initialize(androidConfig: androidConfig);
    }
    if (hasPermissions && !FlutterBackground.isBackgroundExecutionEnabled) {
      await FlutterBackground.enableBackgroundExecution();
    }
  } catch (e) {
    // The battery optimizations are not turned off.
    myLogger.e({"message": "后台服务权限错误", "error": e});
    if (e is PlatformException && (e.message ?? "").contains("battery")) {
      return await Future<void>.delayed(
          const Duration(seconds: 3),
          () => requestBackgroundPermission(
              isRetry: false, shouldRequestBatteryOptimizationsOff: false));
    } else if (!isRetry) {
      return await Future<void>.delayed(const Duration(seconds: 3),
          () => requestBackgroundPermission(isRetry: true));
    }
  }
  myLogger.i(
      {"message": "启动后台服务, ${FlutterBackground.isBackgroundExecutionEnabled}"});
}
