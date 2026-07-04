import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/repost_listings/model/repost_listing_model.dart';

class RepostListingService {
  final NetworkClient client;

  RepostListingService({required this.client});

  Future<List<RepostListingModel>> fetchMyRepostListings() async {
    final String url = Endpoint.myRepostListing;

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final List data = response.responseData as List;
        return data.map((json) => RepostListingModel.fromJson(json)).toList();
      } else {
        throw response.errorMessage ?? "Failed to load repost listings";
      }
    } catch (e) {
      throw "Something went wrong while fetching repost listings: $e";
    }
  }

  Future<RepostListingModel> toggleActiveRepostListing(String id, bool isActive) async {
    final String url = Endpoint.toggleActiveRepost(id);

    try {
      final response = await client.patchRequest(
        url: url,
        body: {'isActive': isActive},
      );

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return RepostListingModel.fromJson(response.responseData!);
      } else {
        throw response.errorMessage ?? "Failed to toggle active status";
      }
    } catch (e) {
      throw "Something went wrong while toggling active status: $e";
    }
  }
}
