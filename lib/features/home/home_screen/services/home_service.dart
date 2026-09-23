import 'dart:collection';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
import 'package:jconnect/features/home/home_screen/model/spotlight_listings_model.dart';

class PaginatedList<T> with ListMixin<T> {
  final List<T> _inner;
  final bool? hasMore;
  final int? total;
  final int? totalPages;
  final int? currentPage;

  PaginatedList({
    required List<T> items,
    this.hasMore,
    this.total,
    this.totalPages,
    this.currentPage,
  }) : _inner = items;

  @override
  int get length => _inner.length;

  @override
  set length(int newLength) => _inner.length = newLength;

  @override
  T operator [](int index) => _inner[index];

  @override
  void operator []=(int index, T value) => _inner[index] = value;
}

class HomeService {
  final NetworkClient client;
  HomeService({required this.client});

  PaginatedList<ArtistsModel> _parseArtistsResponse(
    dynamic responseData,
    int page,
    int limit,
  ) {
    List rawList = [];
    Map<String, dynamic>? meta;

    if (responseData is Map<String, dynamic>) {
      final dataField = responseData['data'];
      if (dataField is List) {
        rawList = dataField;
      } else if (dataField is Map<String, dynamic>) {
        if (dataField['data'] is List) {
          rawList = dataField['data'];
        } else if (dataField['artists'] is List) {
          rawList = dataField['artists'];
        } else if (dataField['users'] is List) {
          rawList = dataField['users'];
        }
        meta = (dataField['meta'] ?? dataField['metadata'] ?? dataField['pagination']) as Map<String, dynamic>?;
      }

      meta ??= (responseData['meta'] ?? responseData['metadata'] ?? responseData['pagination']) as Map<String, dynamic>?;
    } else if (responseData is List) {
      rawList = responseData;
    }

    final items = rawList.map((json) => ArtistsModel.fromJson(json)).toList();

    bool? hasMore;
    int? total;
    int? totalPages;
    int? currentPage;

    if (meta != null) {
      total = meta['total'] is num
          ? (meta['total'] as num).toInt()
          : (meta['totalCount'] is num ? (meta['totalCount'] as num).toInt() : null);
      totalPages = meta['totalPages'] is num
          ? (meta['totalPages'] as num).toInt()
          : (meta['totalPage'] is num ? (meta['totalPage'] as num).toInt() : null);
      currentPage = meta['page'] is num
          ? (meta['page'] as num).toInt()
          : (meta['currentPage'] is num ? (meta['currentPage'] as num).toInt() : null);

      if (meta['hasMore'] is bool) {
        hasMore = meta['hasMore'] as bool;
      } else if (meta['hasNextPage'] is bool) {
        hasMore = meta['hasNextPage'] as bool;
      } else if (meta['has_more'] is bool) {
        hasMore = meta['has_more'] as bool;
      }

      if (hasMore == null && totalPages != null && currentPage != null) {
        hasMore = currentPage < totalPages;
      } else if (hasMore == null && total != null) {
        hasMore = (page * limit) < total;
      }
    }

    return PaginatedList<ArtistsModel>(
      items: items,
      hasMore: hasMore,
      total: total,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  Future<PaginatedList<ArtistsModel>> fetchRecentArtist({
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    String url = "${Endpoint.recentArtis}&page=$page&limit=$limit";
    if (category != null && category.isNotEmpty) {
      url = "$url&category=$category";
    }

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return _parseArtistsResponse(response.responseData, page, limit);
      } else {
        throw response.errorMessage ?? "Failed to load recent Artists";
      }
    } catch (e) {
      throw "Something went wrong while fetching recent Artist: $e";
    }
  }

  Future<PaginatedList<ArtistsModel>> fetchTopRatedArtist({
    int page = 1,
    int limit = 10,
  }) async {
    final String url = "${Endpoint.topRatedArtis}&page=$page&limit=$limit";

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return _parseArtistsResponse(response.responseData, page, limit);
      } else {
        throw response.errorMessage ?? "Failed to load Toprated Artists";
      }
    } catch (e) {
      throw "Something went wrong while fetching Top Rated Artist: $e";
    }
  }

  Future<PaginatedList<ArtistsModel>> fetchSuggestedArtist({
    int page = 1,
    int limit = 10,
  }) async {
    final String url = "${Endpoint.suggestedtArtis}&page=$page&limit=$limit";

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return _parseArtistsResponse(response.responseData, page, limit);
      } else {
        throw response.errorMessage ?? "Failed to load Suggested Artists";
      }
    } catch (e) {
      throw "Something went wrong while fetching Suggested Artist: $e";
    }
  }

//all

  Future<PaginatedList<ArtistsModel>> fetchAllArtist({
    int page = 1,
    int limit = 10,
  }) async {
    final String url = "${Endpoint.allArtists}?page=$page&limit=$limit";

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return _parseArtistsResponse(response.responseData, page, limit);
      } else {
        throw response.errorMessage ?? "Failed to load All Artists";
      }
    } catch (e) {
      throw "Something went wrong while fetching All Artist: $e";
    }
  }

//search
  Future<PaginatedList<ArtistsModel>> searchArtist(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    final String url =
        "${Endpoint.baseUrl}/users/artist?search=${Uri.encodeQueryComponent(query)}&page=$page&limit=$limit";

    try {
      final response = await client.getRequest(url: url);

      if (response.isSuccess &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        return _parseArtistsResponse(response.responseData, page, limit);
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
