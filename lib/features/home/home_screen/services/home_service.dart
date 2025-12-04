import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';

class HomeService {
  final NetworkClient client;
  HomeService({required this.client});

  Future<List<ArtistsModel>> fetchRecentArtist() async {
    const String url =
        "http://103.174.189.183:5050/users/artist?filter=recently-updated";

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
    const String url =
        "http://103.174.189.183:5050/users/artist?filter=top-rated";

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
    const String url =
        "http://103.174.189.183:5050/users/artist?filter=suggested";

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
