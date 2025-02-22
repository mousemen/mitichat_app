import 'package:get/get.dart';
import 'package:miti_common/miti_common.dart';

class InviteFriendsHistoryLogic extends GetxController {
  final users = <UserFullInfo>[].obs;
  final applyTimes = <int>[].obs;

  @override
  void onInit() {
    loadingData();
    super.onInit();
  }

  loadingData() {
    LoadingView.singleton.start(fn: () async {
      final res = await ClientApis.queryInvitedUsers();
      if (null != res?["users"]) {
        users.value = List<UserFullInfo>.from(
            res?["users"]!.map((e) => UserFullInfo.fromJson(e)).toList());
      }
      if (null != res?["applyTimes"]) {
        applyTimes.value = List<int>.from(res?["applyTimes"]);
      }
    });
  }
}
