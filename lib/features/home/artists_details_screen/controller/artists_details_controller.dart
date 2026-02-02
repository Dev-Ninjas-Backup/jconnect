// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../home_screen/model/artists_model.dart';

class ArtistsDetailsController extends GetxController {
  final NetworkClient networkClient;

  ArtistsDetailsController({required this.networkClient});

  RxnString userId = RxnString();

  final SharedPreferencesHelperController pref =
      Get.find<SharedPreferencesHelperController>();

  // Observables
  var isLoading = false.obs;
  var artistsDetails = Rxn<ArtistsModel>();

  var socialPosts = <ServiceModel>[].obs;
  var services = <ServiceModel>[].obs;

  final RxString selectSocialOrService = "social".obs;
  var followingUsers = <String, bool>{}.obs;

  /// Launch external URL
  Future<void> launchURL(String url) async {
    if (!url.startsWith('http')) url = 'https://$url';
    final Uri uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Could not launch URL');
      }
    } catch (e) {
      print('Error URL launch failed: $e');
    }
  }

  /// Fetch artist by ID from API
  Future<void> fetchArtistById(String id) async {
    try {
      isLoading(true);

      final response = await networkClient.getRequest(
        url: '${Endpoint.viewArtists}/$id',
      );

      if (response.isSuccess &&
          response.responseData != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        artistsDetails.value = ArtistsModel.fromJson(response.responseData!);
        _filterServices();

        // ✅ Add this line — checks follow status every time page loads
        await checkFollowStatus(id);
      } else {
        Get.snackbar(
          'Error',
          response.errorMessage ?? 'Failed to fetch artist',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Filter services into SOCIAL_POST and SERVICE lists
  void _filterServices() {
    if (artistsDetails.value == null) return;

    socialPosts.value = artistsDetails.value!.services
        .where((s) => s.serviceType == "SOCIAL_POST")
        .toList();

    services.value = artistsDetails.value!.services
        .where((s) => s.serviceType == "SERVICE")
        .toList();
  }

  Future<void> checkFollowStatus(String artistId) async {
    try {
      final token = await pref.getAccessToken();

      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/follow-function/followings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );

      print('Check follow response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List followingList = data['data']['following'] ?? [];

        final isFollowing = followingList.any(
          (item) => item['followingId'] == artistId,
        );

        followingUsers[artistId] = isFollowing;
        followingUsers.refresh();
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> followUser(String followingId) async {
    if (userId.value == followingId) {
      EasyLoading.showError("You can't follow yourself");
      return;
    }

    try {
      EasyLoading.show(status: 'Following...');

      final token = await pref.getAccessToken();
      final isCurrentlyFollowing = followingUsers[followingId] ?? false;


      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/follow-function/follow'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: json.encode({'followingID': followingId}),
      );

      print('Follow response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        followingUsers[followingId] = !isCurrentlyFollowing;
        followingUsers.refresh();
        EasyLoading.showSuccess(
          isCurrentlyFollowing ? 'Unfollowed' : 'Successfully followed',
        );

        // // Refresh artist details to update followerCount
        final artistId = artistsDetails.value?.id;
        if (artistId != null) {
          await Future.delayed(Duration(milliseconds: 300));
          await fetchArtistById(artistId);
        }
      } else {
        EasyLoading.showError('Failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error following user: $e');
      EasyLoading.showError('Error: ${e.toString()}');
    }
  }

  bool isOwnProfile(String artistId) {
    return userId.value == artistId;
  }

  @override
  void onInit() {
    super.onInit();
    loadUserId();

    final String? id = Get.parameters['id'];

    if (id != null) {
      fetchArtistById(id);
    } else {
      Get.snackbar('Error', 'Artist ID not found');
      Get.back();
    }
  }

  Future<void> loadUserId() async {
    userId.value = await pref.getUserId();
  }
}
