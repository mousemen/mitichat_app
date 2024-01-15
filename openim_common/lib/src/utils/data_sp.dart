import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';
import 'package:uuid/uuid.dart';

class DataSp {
  static const _loginCertificate = 'loginCertificate';
  static const _loginAccount = 'loginAccount';
  static const _server = "server";
  static const _ip = 'ip';
  static const _deviceID = 'deviceID';
  static const _ignoreUpdate = 'ignoreUpdate';
  static const _language = "language";
  static const _groupApplication = "%s_groupApplication";
  static const _friendApplication = "%s_friendApplication";
  static const _enabledVibration = 'enabledVibration';
  static const _enabledRing = 'enabledRing';
  static const _screenPassword = '%s_screenPassword';
  static const _enabledBiometric = '%s_enabledBiometric';
  static const _chatFontSizeFactor = '%s_chatFontSizeFactor';
  static const _chatBackground = '%s_chatBackground_%s';
  static const _loginType = 'loginType';
  static const _accountLoginInfoMap = 'accountLoginInfo';
  static const _curAccountLoginInfoKey = '_curAccountLoginInfoKey';
  static const _curServerKey = '_curServerKey';
  static const _mainLoginAccount = 'mainLoginAccount';

  DataSp._();

  static init() async {
    await SpUtil().init();
  }

  static String getKey(String key, {String key2 = ""}) {
    return sprintf(key, [OpenIM.iMManager.userID, key2]);
  }

  static String? get imToken => getLoginCertificate()?.imToken;

  static String? get chatToken => getLoginCertificate()?.chatToken;

  static String? get userID => getLoginCertificate()?.userID;

  static Future<bool>? putLoginCertificate(LoginCertificate lc) {
    return SpUtil().putObject(_loginCertificate, lc);
  }

  /// {
  ///   "phone"    :"",
  ///   "areaCode" :"",
  ///   "email"    :"",
  /// }
  static Future<bool>? putLoginAccount(Map map) {
    return SpUtil().putObject(_loginAccount, map);
  }

  static LoginCertificate? getLoginCertificate() {
    return SpUtil()
        .getObj(_loginCertificate, (v) => LoginCertificate.fromJson(v.cast()));
  }

  static Future<bool>? removeLoginCertificate() {
    return SpUtil().remove(_loginCertificate);
  }

  static Map? getLoginAccount() {
    return SpUtil().getObject(_loginAccount);
  }

  static Future<bool>? putServerConfig(Map<String, String> config) {
    return SpUtil().putObject(_server, config);
  }

  static Map? getServerConfig() {
    return SpUtil().getObject(_server);
  }

  static Future<bool>? putServerIP(String ip) {
    return SpUtil().putString(ip, ip);
  }

  static String? getServerIP() {
    return SpUtil().getString(_ip);
  }

  static String getDeviceID() {
    String id = SpUtil().getString(_deviceID) ?? '';
    if (id.isEmpty) {
      id = const Uuid().v4();
      SpUtil().putString(_deviceID, id);
    }
    return id;
  }

  static Future<bool>? putIgnoreVersion(String version) {
    return SpUtil().putString(_ignoreUpdate, version);
  }

  static String? getIgnoreVersion() {
    return SpUtil().getString(_ignoreUpdate);
  }

  static Future<bool>? putLanguage(int index) {
    return SpUtil().putInt(_language, index);
  }

  static int? getLanguage() {
    return SpUtil().getInt(_language);
  }

  static Future<bool>? putHaveReadUnHandleGroupApplication(
      List<String> idList) {
    return SpUtil().putStringList(getKey(_groupApplication), idList);
  }

  static Future<bool>? putHaveReadUnHandleFriendApplication(
      List<String> idList) {
    return SpUtil().putStringList(getKey(_friendApplication), idList);
  }

  static List<String>? getHaveReadUnHandleGroupApplication() {
    return SpUtil().getStringList(getKey(_groupApplication), defValue: []);
  }

  static List<String>? getHaveReadUnHandleFriendApplication() {
    return SpUtil().getStringList(getKey(_friendApplication), defValue: []);
  }

  static Future<bool>? putLockScreenPassword(String password) {
    return SpUtil().putString(getKey(_screenPassword), password);
  }

  static Future<bool>? clearLockScreenPassword() {
    return SpUtil().remove(getKey(_screenPassword));
  }

  static String? getLockScreenPassword() {
    return SpUtil().getString(getKey(_screenPassword), defValue: null);
  }

  static Future<bool>? openBiometric() {
    return SpUtil().putBool(getKey(_enabledBiometric), true);
  }

  static bool? isEnabledBiometric() {
    return SpUtil().getBool(getKey(_enabledBiometric), defValue: null);
  }

  static Future<bool>? closeBiometric() {
    return SpUtil().remove(getKey(_enabledBiometric));
  }

  static Future<bool>? putChatFontSizeFactor(double factor) {
    return SpUtil().putDouble(getKey(_chatFontSizeFactor), factor);
  }

  static double getChatFontSizeFactor() {
    return SpUtil().getDouble(
      getKey(_chatFontSizeFactor),
      defValue: Config.textScaleFactor,
    )!;
  }

  static Future<bool>? putChatBackground(String toUid, String path) {
    return SpUtil().putString(getKey(_chatBackground, key2: toUid), path);
  }

  static String? getChatBackground(String toUid) {
    return SpUtil().getString(getKey(_chatBackground, key2: toUid));
  }

  static Future<bool>? clearChatBackground(String toUid) {
    return SpUtil().remove(getKey(_chatBackground, key2: toUid));
  }

  static Future<bool>? putLoginType(int type) {
    return SpUtil().putInt(_loginType, type);
  }

  static int getLoginType() {
    return SpUtil().getInt(_loginType) ?? 0;
  }

  static String getCurServerKey() {
    return SpUtil().getString(_curServerKey) ?? "";
  }

  // 登录和切换时修改
  static Future<bool>? putCurServerKey(String key) {
    return SpUtil().putString(_curServerKey, key);
  }

  static String getCurAccountLoginInfoKey() {
    return SpUtil().getString(_curAccountLoginInfoKey) ?? "";
  }

  // 完全登录成功后修改
  static Future<bool>? putCurAccountLoginInfoKey(String key) {
    return SpUtil().putString(_curAccountLoginInfoKey, key);
  }

  static Future<bool>? putAccountLoginInfoMap(
      Map<String, AccountLoginInfo> data) {
    final accountLoginInfoMap = getAccountLoginInfoMap() ?? {};
    accountLoginInfoMap.addAll(data);
    return SpUtil().putObject(_accountLoginInfoMap, accountLoginInfoMap);
  }

  static Map<String, AccountLoginInfo>? getAccountLoginInfoMap() {
    return SpUtil().getObj(
        _accountLoginInfoMap,
        (map) => map.map(
            (key, value) => MapEntry(key, AccountLoginInfo.fromJson(value))));
  }

  static Map<String, dynamic>? getAccountLoginInfoMap2() {
    return SpUtil().getObj(
        _accountLoginInfoMap,
        (map) => map.map(
            (key, value) => MapEntry(key, value)));
  }

  static AccountLoginInfo? getAccountLoginInfoByKey(String key) {
    return getAccountLoginInfoMap()?[key];
  }

  // 同getLoginAccount, 只记录主服务器
  static Map? getMainLoginAccount() {
    return SpUtil().getObject(_mainLoginAccount);
  }

  static Future<bool>? putMainLoginAccount(Map map) {
    return SpUtil().putObject(_mainLoginAccount, map);
  }
}
