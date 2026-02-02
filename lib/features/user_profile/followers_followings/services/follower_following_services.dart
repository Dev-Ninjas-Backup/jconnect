import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/follower_following_model.dart';
import 'package:jconnect/core/endpoint.dart';

class FollowService {
  Future<List<FollowModel>> fetchFollowers(String token) async {
    try {
      // ignore: avoid_print
      print("Fetching followers");

      final res = await http.get(
        Uri.parse(Endpoint.followers),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      // ignore: avoid_print
      print("Status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final List<dynamic> list = decoded['data']['followers'] ?? [];

        // ignore: avoid_print
        print("Found ${list.length} followers");

        return list
            .map<FollowModel>((e) => FollowModel.fromJson(e['followers']))
            .toList();
      } else {
        // ignore: avoid_print
        print("Failed: ${res.body}");
        return [];
      }
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print("Error: $e");
      // ignore: avoid_print
      print("Stack: $stackTrace");
      return [];
    }
  }

  Future<List<FollowModel>> fetchFollowings(String token) async {
    try {
      // ignore: avoid_print
      print("Fetching followings...");

      final res = await http.get(
        Uri.parse(Endpoint.followings),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      // ignore: avoid_print
      print("Status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        final List<dynamic> list = decoded['data']['following'] ?? [];

        // ignore: avoid_print
        print("Found ${list.length} followings");

        return list
            .map<FollowModel>((e) => FollowModel.fromJson(e['following']))
            .toList();
      } else {
        // ignore: avoid_print
        print("Failed: ${res.body}");
        return [];
      }
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print("Error: $e");
      // ignore: avoid_print
      print("Stack: $stackTrace");
      return [];
    }
  }
}
