import 'package:get/get.dart';
import '../model/follower_following_model.dart';
import '../services/follower_following_services.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';

class FollowController extends GetxController {
  final FollowService _service = FollowService();
  final SharedPreferencesHelperController _prefs = Get.find();

  var isLoading = false.obs;
  var followers = <FollowModel>[].obs;
  var followings = <FollowModel>[].obs;

  void loadFollowers() async {
    try {
      isLoading.value = true;
      final token = await _prefs.getAccessToken();
      if (token != null && token.isNotEmpty) {
        followers.value = await _service.fetchFollowers(token);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void loadFollowings() async {
    try {
      isLoading.value = true;
      final token = await _prefs.getAccessToken();
      if (token != null && token.isNotEmpty) {
        followings.value = await _service.fetchFollowings(token);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    loadFollowers();
    super.onInit();
  }
}
