import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/user_profile/profile/model/profile_model.dart';
import 'package:jconnect/routes/approute.dart';

class ProfileController extends GetxController {
  // USER PROFILE DATA
  final Rx<ProfileModel> user = ProfileModel(
    name: '',
    imageUrl: Imagepath.profileImage,
    shortbio: 'No Bio',
    email: " ",
    totaldeals: 0,
    earnings: 0.0,
    rating: 0.0,
  ).obs;

  // RATES SECTION
  // final RxList<RateModel> rates = <RateModel>[
  //   RateModel(
  //     title: '30 Sec New Track Review',
  //     description: 'Short review of a new track with quick feedback',
  //     price: 25.0,
  //   ),
  //   RateModel(
  //     title: 'Social Shoutout',
  //     description: 'Post your track to my 10k+ audience',
  //     price: 60.0,
  //   ),
  // ].obs;

  // void addNewRate() {
  //   rates.add(
  //     RateModel(
  //       title: 'New Custom Rate',
  //       description: 'Describe your service...',
  //       price: 0.0,
  //     ),
  //   );
  // }

  void updateFromApi(Map<String, dynamic> json) {
    final existing = user.value;
    final name = json['full_name']?.toString() ?? existing.name;
    final email = json['email']?.toString() ?? existing.email;
    //final fullName = json['full_name']?.toString() ?? existing.fullName;
    final phone = json['phone']?.toString() ?? existing.phone;
    // If API returns null for profile_image_url use the app default profile image
    final imageUrl = json['profilePhoto']?.toString() ?? Imagepath.profileImage;
    final shortbio =
        json['profile']?['short_bio']?.toString() ?? existing.shortbio;
    final totaldeals =
        json['stats']?['totalDeals'] as int? ?? existing.totaldeals;
    final earnings =
        (json['stats']?['totalEarnings'] as num?)?.toDouble() ??
        existing.earnings;
    final rating =
        (json['stats']?['avgRating'] as num?)?.toDouble() ?? existing.rating;

    // Extract social profiles - try multiple possible keys
    List<SocialProfileModel>? socialProfiles;
    final socialData = json['profile']?['socialProfiles'];

    if (socialData != null) {
      socialProfiles = (socialData as List?)
          ?.map(
            (profile) => SocialProfileModel(
              platformName: profile['platformName']?.toString(),
              platformLink: profile['platformLink']?.toString(),
            ),
          )
          .toList();
    }

    user.value = ProfileModel(
      name: name,
      imageUrl: imageUrl,
      shortbio: shortbio,
      totaldeals: totaldeals,
      earnings: earnings,
      rating: rating,
      //fullName: fullName,
      phone: phone,
      socialProfiles: socialProfiles,
      email: email,
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

  // NAVIGATION + ACCOUNT ACTIONS
  void navigateTo(String route) {
    // You can replace this with Get.toNamed(route) when routing is set up
  }

  void deleteAccount() {
    // Deprecated synchronous stub. Use async deleteAccountAsync instead.
    deleteAccountAsync();
  }

  Future<void> deleteAccountAsync() async {
    try {
      final prefs = SharedPreferencesHelperController();
      final token = await prefs.getAccessToken();
      final userId = await prefs.getUserId();

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        Get.snackbar('Error', 'Unable to delete account: missing credentials');
        return;
      }

      EasyLoading.show(status: 'Deleting account...');

      final resp = await http.delete(
        Uri.parse(Endpoint.deleteUserById(userId)),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      EasyLoading.dismiss();

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // clear local data and navigate to login
        await prefs.clearAllData();
        Get.offAllNamed(AppRoute.loginScreen);
        // Show server message if available
        try {
          final map = json.decode(resp.body) as Map<String, dynamic>?;
          final message = map?['message']?.toString() ?? 'Account deleted';
          Get.snackbar(
            'Deleted',
            message,
            backgroundColor: AppColors.redColor.withValues(alpha: .8),
            colorText: AppColors.backGroundColor,
          );
        } catch (_) {
          Get.snackbar(
            'Deleted',
            'Your account has been deleted.',
            backgroundColor: AppColors.redColor.withValues(alpha: .8),
            colorText: AppColors.backGroundColor,
          );
        }
      } else {
        String msg = 'Failed to delete account (${resp.statusCode})';
        try {
          final map = json.decode(resp.body) as Map<String, dynamic>?;
          if (map != null && map['message'] != null) {
            msg = map['message'].toString();
          }
        } catch (_) {}
        Get.snackbar('Error', msg);
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', 'Failed to delete account: $e');
    }
  }
}
