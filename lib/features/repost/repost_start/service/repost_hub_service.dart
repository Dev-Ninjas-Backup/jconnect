import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';

class RepostHubService {
  final NetworkClient client;

  RepostHubService({required this.client});

  Future<List<dynamic>> fetchRepostListingsByArtist(String artistId) async {
    final String url = Endpoint.getReposListingByArtist(artistId);

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return response.responseData as List;
      } else {
        throw response.errorMessage ?? "Failed to load repost listings";
      }
    } catch (e) {
      throw "Something went wrong while fetching repost listings: $e";
    }
  }
}
