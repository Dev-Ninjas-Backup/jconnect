import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
import 'package:jconnect/features/home/home_screen/model/spotlight_listings_model.dart';

class HomeService {
  final NetworkClient client;
  HomeService({required this.client});

  Future<List<ArtistsModel>> fetchRecentArtist({String? category}) async {
    String url = Endpoint.recentArtis;
    if (category != null && category.isNotEmpty) {
      url = "$url&category=$category";
    }

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



//all

  Future<List<ArtistsModel>> fetchAllArtist() async {
    const String url = Endpoint.allArtists;

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final List data = response.responseData!['data'];

        return data.map((json) => ArtistsModel.fromJson(json)).toList();
      } else {
        throw response.errorMessage ?? "Failed to load All Artists";
      }
    } catch (e) {
      throw "Something went wrong while fetching All Artist: $e";
    }
  }


//search
  Future<List<ArtistsModel>> searchArtist(String query) async {
   final String url = "${Endpoint.baseUrl}/users/artist?search=$query";

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final List data = response.responseData!['data'];

        return data.map((json) => ArtistsModel.fromJson(json)).toList();
      } else {
        throw response.errorMessage ?? "Failed to load search Artists";
      }
    } catch (e) {
      throw "Something went wrong while fetching search Artist: $e";
    }
  }

  Future<List<SpotlightListingModel>> fetchSpotlightListings() async {
    const String url = Endpoint.repostSpotlight;

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final dynamic responseData = response.responseData;
        if (responseData is List) {
          return responseData.map((json) => SpotlightListingModel.fromJson(json)).toList();
        } else if (responseData is Map && responseData['data'] != null) {
          final List data = responseData['data'];
          return data.map((json) => SpotlightListingModel.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw response.errorMessage ?? "Failed to load Spotlight Listings";
      }
    } catch (e) {
      throw "Something went wrong while fetching Spotlight Listings: $e";
    }
  }
}
