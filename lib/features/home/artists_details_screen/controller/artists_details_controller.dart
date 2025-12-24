// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../home_screen/model/artists_model.dart';

class ArtistsDetailsController extends GetxController {
  final NetworkClient networkClient;

  ArtistsDetailsController({required this.networkClient});

  // Observables
  var isLoading = false.obs;
  var artistsDetails = Rxn<ArtistsModel>();

  var socialPosts = <ServiceModel>[].obs;
  var services = <ServiceModel>[].obs;

  final RxString selectSocialOrService = "social".obs;

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

        // Automatically filter services after fetching
        _filterServices();
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
}
