import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';

class HomeService {
  final NetworkClient client;
  HomeService({required this.client});

  Future<List<ArtistsModel>> fetchRecentArtist() async {
    const String url = Endpoint.recentArtis;

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final List data = response.responseData!['data'];

        return data.map((json) => ArtistsModel.fromJson(json)).toList();
      } else {
        throw response.errorMessage ?? "Failed to load recent Artists";
      }
    } catch (e) {
      throw "Something went wrong while fetching recent Artist: $e";
    }
  }

  Future<List<ArtistsModel>> fetchTopRatedArtist() async {
    const String url = Endpoint.topRatedArtis;

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final List data = response.responseData!['data'];

        return data.map((json) => ArtistsModel.fromJson(json)).toList();
      } else {
        throw response.errorMessage ?? "Failed to load Toprated Artists";
      }
    } catch (e) {
      throw "Something went wrong while fetching Top Rated Artist: $e";
    }
  }

  Future<List<ArtistsModel>> fetchSuggestedArtist() async {
    const String url = Endpoint.suggestedtArtis;

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final List data = response.responseData!['data'];

        return data.map((json) => ArtistsModel.fromJson(json)).toList();
      } else {
        throw response.errorMessage ?? "Failed to load Suggested Artists";
      }
    } catch (e) {
      throw "Something went wrong while fetching Suggested Artist: $e";
    }
  }
}
