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
}


// home_service.dart
// import 'package:jconnect/core/service/network_service/network_client.dart';
// import 'package:jconnect/features/home/home_screen/model/artists_model.dart';

// class HomeService {
//   final NetworkClient client;
//   HomeService({required this.client});

//   Future<List<ArtistsModel>> fetchRecentArtist() async {
//     try {
//       final response = await client.getRequest(
//         url: "http://103.174.189.183:5050/users/artist?filter=recently-updated",
//         // or full URL if your client doesn't use base URL:
//         // url: "http://103.174.189.183:5050/users/artist?filter=recently-updated",
//       );

//       if (response.isSuccess && response.responseData != null) {
//         final artistResponse = ArtistsModel.fromJson(response.responseData!);
//         return artistResponse.data;
//       } else {
//         throw response.errorMessage ?? "Failed to load artists";
//       }
//     } catch (e) {
//       throw "Failed to fetch recent artists: $e";
//     }
//   }
// }