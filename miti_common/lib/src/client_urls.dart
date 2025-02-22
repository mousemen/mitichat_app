import 'client_config.dart';

class ClientUrls {
  static String get onlineStatus =>
      "${Config.imApiUrl}/manager/get_users_online_status";
  static String get userOnlineStatus =>
      "${Config.imApiUrl}/user/get_users_online_status";
  static String get queryAllUsers =>
      "${Config.imApiUrl}/manager/get_all_users_uid";
  static String get updateUserInfo => "${Config.appAuthUrl}/user/update";
  static String get searchFriendInfo => "${Config.appAuthUrl}/friend/search";
  static String get getUsersFullInfo => "${Config.appAuthUrl}/user/find/full";
  static String get searchUserFullInfo =>
      "${Config.appAuthUrl}/user/search/full";
  static String get updateEmail => "${Config.appAuthUrl}/account/update_email";
  static String get updatePhone => "${Config.appAuthUrl}/account/update_phone";

  static String get getVerificationCode =>
      "${Config.appAuthUrl}/account/code/send";
  static String get checkVerificationCode =>
      "${Config.appAuthUrl}/account/code/verify";
  static String get register => "${Config.appAuthUrl}/account/register";
  static String get oauth => "${Config.appAuthUrl}/account/oauth";

  static String get resetPwd => "${Config.appAuthUrl}/account/password/reset";
  static String get changePwd => "${Config.appAuthUrl}/account/password/change";
  static String get login => "${Config.appAuthUrl}/account/login";

  static String get upgrade => "${Config.appAuthUrl}/app/check";

  /// office
  static String get tag => "${Config.appAuthUrl}/office/tag";
  // static String get getUserTags => "$tag/find/user";
  static String get createTag => "$tag/add";
  static String get deleteTag => "$tag/del";
  static String get updateTag => "$tag/set";
  static String get sendTagNotification => "$tag/send";
  // static String get getTagNotificationLog => "$tag/send/log";
  static String get delTagNotificationLog => "$tag/send/log/del";

  /// 全局配置
  static String get getClientConfig => '${Config.appAuthUrl}/client_config/get';

  /// 小程序
  // static String get uniMPUrl => '${Config.appAuthUrl}/applet/list';

  // 翻译
  static String get translate => "${Config.appAuthUrl}/translate/do";

  static String get findTranslate => "${Config.appAuthUrl}/translate/find";

  static String get getTranslateConfig =>
      "${Config.appAuthUrl}/translate/config/get";

  static String get setTranslateConfig =>
      "${Config.appAuthUrl}/translate/config/set";

  // tts
  static String get tts => "${Config.appAuthUrl}/transcribe/url";

  // 删除用户
  static String get deleteUser => "${Config.appAuthUrl}/account/delete";

  static String get complain => "${Config.appAuthUrl}/user/report";

  static String get complainXhs =>
      "${Config.appAuthUrl}/office/work_moment/report";

  static String get blockMoment =>
      "${Config.appAuthUrl}/office/work_moment/block_moment";

  static String get getBlockMoment =>
      "${Config.appAuthUrl}/office/work_moment/get_block_moment";

  static String get checkServerValid => '/client_config/get';

  static String get getBots => '${Config.appAuthUrl}/bot/find/public';

  static String get getMyAi => '${Config.appAuthUrl}/bot/find/mine';

  static String get getKnowledgeFiles =>
      '${Config.appAuthUrl}/bot/get_knowledge_files';

  static String get addKnowledge => '${Config.appAuthUrl}/bot/add_knowledge';

  static String get getMyAiTask => '${Config.appAuthUrl}/bot/task/get/mine';

  static String get getBotKnowledgebases =>
      '${Config.appAuthUrl}/knowledgebase/get_bot_knowledgebases';

  static String get addActionRecord => '${Config.appAuthUrl}/action_record/add';

  static String get updateMitiID => '${Config.appAuthUrl}/account/update_mitiid';

  static String get queryUpdateMitiIDRecords =>
      '${Config.appAuthUrl}/account/query_update_mitiid_records';

  static String get applyActive =>
      '${Config.appAuthUrl}/invite/apply_active';

  static String get responseApplyActive =>
      '${Config.appAuthUrl}/invite/response_apply_active';

  static String get directActive =>
      '${Config.appAuthUrl}/invite/direct_active';

  static String get queryApplyActiveList =>
      '${Config.appAuthUrl}/invite/query_apply_active_list';

  static String get querySelfApplyActive =>
      '${Config.appAuthUrl}/invite/query_self_apply_active';

  static String get queryInvitedUsers =>
      '${Config.appAuthUrl}/invite/query_invited_users';

  static String get querySupportRegistTypes =>
      '${Config.appAuthUrl}/account/query_support_regist_types';

  static String get queryThirdAppInfo =>
      '${Config.appAuthUrl}/account/query_third_app_info';
}
