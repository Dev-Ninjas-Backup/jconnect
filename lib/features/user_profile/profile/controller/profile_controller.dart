import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/profile/model/profile_model.dart';

class ProfileController extends GetxController {
  // ───────────────────────────────
  // USER PROFILE DATA
  // ───────────────────────────────
  final Rx<ProfileModel> user = ProfileModel(
    name: 'DJ Kinseki',
    imageUrl: 'assets/images/dj.png',
    followers: 132,
    earnings: 2450,
    rating: 4.9,
  ).obs;

  // ───────────────────────────────
  // RATES SECTION
  // ───────────────────────────────
  final RxList<RateModel> rates = <RateModel>[
    RateModel(
      title: '30 Sec New Track Review',
      description: 'Short review of a new track with quick feedback',
      price: 25.0,
    ),
    RateModel(
      title: 'Social Shoutout',
      description: 'Post your track to my 10k+ audience',
      price: 60.0,
    ),
  ].obs;

  void addNewRate() {
    rates.add(
      RateModel(
        title: 'New Custom Rate',
        description: 'Describe your service...',
        price: 0.0,
      ),
    );
  }

  void updateFromApi(Map<String, dynamic> json) {
    final existing = user.value;
    final name = json['full_name']?.toString() ?? existing.name;
    // If API returns null for profile_image_url use the app default profile image
    final imageUrl = json['profilePhoto']?.toString() ?? Imagepath.profileImage;

    user.value = ProfileModel(
      name: name,
      imageUrl: imageUrl,
      followers: existing.followers,
      earnings: existing.earnings,
      rating: existing.rating,
    );
  }

  @override
  void onInit() {
    super.onInit();
    // Attempt to fetch profile from API on controller init so header shows real data
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = SharedPreferencesHelperController();
      final token = await prefs.getAccessToken();
      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse(Endpoint.getProfile),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> map = json.decode(response.body);
        updateFromApi(map);
      } else {
        // ignore: avoid_print
        print('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching profile: $e');
    }
  }

  final RxBool notificationsEnabled = true.obs;
  final RxBool darkModeEnabled = false.obs;
  final RxBool privacyModeEnabled = false.obs;

  // ───────────────────────────────
  // NAVIGATION + ACCOUNT ACTIONS
  // ───────────────────────────────
  void navigateTo(String route) {
    // You can replace this with Get.toNamed(route) when routing is set up
  }

  void deleteAccount() {
    Get.snackbar(
      'Deleted',
      'Your account has been deleted.',
      backgroundColor: AppColors.redColor.withValues(alpha: .8),
      colorText: AppColors.backGroundColor,
    );
  }
}
