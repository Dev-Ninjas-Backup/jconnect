import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../model/follower_following_model.dart';
import '../services/follower_following_services.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/endpoint.dart';

class FollowController extends GetxController {
  final FollowService _service = FollowService();
  final SharedPreferencesHelperController _prefs = Get.find();

  var isLoading = false.obs;
  var followers = <FollowModel>[].obs;
  var followings = <FollowModel>[].obs;
  final RxMap<String, bool> followingUsers = <String, bool>{}.obs;

  int get followerCount => followers.length;
  int get followingCount => followings.length;

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

        // populate quick lookup map
        followingUsers.clear();
        for (final f in followings) {
          followingUsers[f.id] = true;
        }
        followingUsers.refresh();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle follow/unfollow for a user by id.
  Future<void> followUser(String followingId) async {
    try {
      EasyLoading.show(status: 'Processing...');

      final token = await _prefs.getAccessToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('Not authenticated');
        return;
      }

      final isCurrentlyFollowing = followingUsers[followingId] ?? false;

      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/follow-function/follow'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: json.encode({'followingID': followingId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        followingUsers[followingId] = !isCurrentlyFollowing;
        followingUsers.refresh();

        EasyLoading.showSuccess(isCurrentlyFollowing ? 'Unfollowed' : 'Successfully followed');

        // Refresh lists so UI counts update
        await Future.delayed(const Duration(milliseconds: 250));
        loadFollowers();
        loadFollowings();
      } else {
        EasyLoading.showError('Failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      EasyLoading.showError('Error: ${e.toString()}');
    }
  }

  @override
  void onInit() {
    loadFollowers();
    super.onInit();
  }
}
