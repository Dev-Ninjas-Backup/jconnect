import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/artists_screen/controller/artists_controller.dart';
import 'package:jconnect/features/home/home_screen/services/home_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingNetworkClient extends NetworkClient {
  final List<String> requestedUrls = [];
  int delayMs = 0;

  RecordingNetworkClient({required super.onUnAuthorize});

  Map<String, dynamic> _createMockArtist(int index) {
    return {
      'id': 'artist_$index',
      'full_name': 'Artist $index',
      'user_name': 'artist_$index',
      'email': 'artist$index@test.com',
      'phone': '+1234567890',
      'isVerified': true,
      'isTermsAgreed': true,
      'isLogin': true,
      'isDeleted': false,
      'isActive': true,
      'loginAttempts': 0,
      'withdrawnAmount': 0.0,
      'phoneVerified': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'role': 'ARTIST',
      'validationType': 'NONE',
      'services': [],
      'reviewsReceived': [],
      'averageRating': 4.5,
      'totalReviews': 10,
      'followerCount': 100,
      'hashTags': [],
      'highlights': [],
    };
  }

  @override
  Future<NetworkResponse> getRequest({required String url}) async {
    requestedUrls.add(url);
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    final uri = Uri.parse(url);
    final page = int.tryParse(uri.queryParameters['page'] ?? '1') ?? 1;
    final limit = int.tryParse(uri.queryParameters['limit'] ?? '10') ?? 10;
    final search = uri.queryParameters['search'];

    // Generate mock items based on page and limit
    int count = limit;
    if (page == 3 && search == null) {
      // Page 3 has 10 items
      count = limit;
    } else if (page == 4 && search == null) {
      // Page 4 only has 5 items (end of results)
      count = 5;
    } else if (page > 4 && search == null) {
      // Beyond page 4 has 0 items
      count = 0;
    } else if (search != null) {
      if (page == 1) {
        count = 10;
      } else if (page == 2) {
        count = 3; // end of search
      } else {
        count = 0;
      }
    }

    final List<Map<String, dynamic>> items = List.generate(count, (i) {
      final idx = (page - 1) * limit + i + 1;
      final name = search != null ? 'search_${search}_Artist $idx' : 'Artist $idx';
      return _createMockArtist(idx)..['full_name'] = name;
    });

    final bool hasMore = count == limit;

    return NetworkResponse(
      statusCode: 200,
      isSuccess: true,
      responseData: {
        'success': true,
        'data': items,
        'meta': {
          'page': page,
          'limit': limit,
          'total': 35,
          'hasMore': hasMore,
        },
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecordingNetworkClient networkClient;
  late HomeService homeService;
  late ArtistsController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put(SharedPreferencesHelperController());

    networkClient = RecordingNetworkClient(onUnAuthorize: () {});
    homeService = HomeService(client: networkClient);
  });

  tearDown(() {
    Get.reset();
  });

  test('Runtime Pagination Flow: 10 -> 20 -> 30, fast scroll guard, and search', () async {
    controller = ArtistsController(service: homeService);

    // 1. Initial Request
    expect(controller.allArtistsPage, 1);
    expect(controller.hasMoreAll.value, isTrue);

    await controller.fetchAllArtistsMethod(isLoadMore: false);

    expect(networkClient.requestedUrls.length, 1);
    expect(networkClient.requestedUrls.last, contains('page=1&limit=10'));
    expect(controller.artistsItems.length, 10);
    expect(controller.artistsItems.first.fullName, 'Artist 1');
    expect(controller.artistsItems.last.fullName, 'Artist 10');
    expect(controller.allArtistsPage, 1);

    // 2. Scroll near bottom -> triggers page=2&limit=10
    await controller.fetchAllArtistsMethod(isLoadMore: true);

    expect(networkClient.requestedUrls.length, 2);
    expect(networkClient.requestedUrls.last, contains('page=2&limit=10'));
    // Confirm list grows 10 -> 20 and previous items are preserved
    expect(controller.artistsItems.length, 20);
    expect(controller.artistsItems[0].fullName, 'Artist 1');
    expect(controller.artistsItems[9].fullName, 'Artist 10');
    expect(controller.artistsItems[10].fullName, 'Artist 11');
    expect(controller.artistsItems[19].fullName, 'Artist 20');
    expect(controller.allArtistsPage, 2);

    // 3. Scroll again -> triggers page=3&limit=10
    await controller.fetchAllArtistsMethod(isLoadMore: true);

    expect(networkClient.requestedUrls.length, 3);
    expect(networkClient.requestedUrls.last, contains('page=3&limit=10'));
    // Confirm list grows 20 -> 30 without replacing
    expect(controller.artistsItems.length, 30);
    expect(controller.artistsItems[29].fullName, 'Artist 30');
    expect(controller.allArtistsPage, 3);
    expect(controller.hasMoreAll.value, isTrue);

    // 4. Duplicate request guard during in-flight loading (fast scroll)
    networkClient.delayMs = 100;
    // Launch first request
    final future1 = controller.fetchAllArtistsMethod(isLoadMore: true);
    // Launch duplicate requests while first is in-flight
    final future2 = controller.fetchAllArtistsMethod(isLoadMore: true);
    final future3 = controller.fetchAllArtistsMethod(isLoadMore: true);

    await Future.wait([future1, future2, future3]);
    networkClient.delayMs = 0;

    // Only 1 additional request should have been dispatched (for page 4)
    expect(networkClient.requestedUrls.length, 4);
    expect(networkClient.requestedUrls.last, contains('page=4&limit=10'));
    expect(controller.allArtistsPage, 4);

    // Page 4 returned 5 items (< 10), so total is now 35 and hasMoreAll is false
    expect(controller.artistsItems.length, 35);
    expect(controller.hasMoreAll.value, isFalse);

    // 5. Verify hasMore=false prevents any further API requests
    final urlCountBefore = networkClient.requestedUrls.length;
    await controller.fetchAllArtistsMethod(isLoadMore: true);
    expect(networkClient.requestedUrls.length, urlCountBefore); // No request sent!

    // 6. Test a new search starts from page=1&limit=10
    await controller.searchArtistByName('guitar', isLoadMore: false);

    expect(networkClient.requestedUrls.last, contains('search=guitar'));
    expect(networkClient.requestedUrls.last, contains('page=1&limit=10'));
    expect(controller.searchArtistsPage, 1);
    expect(controller.searchArtistItems.length, 10);
    expect(controller.searchArtistItems.first.fullName, contains('search_guitar_'));

    // 7. Search scroll pagination: page 2
    await controller.searchArtistByName('guitar', isLoadMore: true);
    expect(networkClient.requestedUrls.last, contains('search=guitar'));
    expect(networkClient.requestedUrls.last, contains('page=2&limit=10'));
    expect(controller.searchArtistItems.length, 13);
    expect(controller.hasMoreSearch.value, isFalse); // Page 2 only had 3 items (<10)

    // 8. Clear search and start another search -> does not mix previous query
    controller.clearSearch();
    expect(controller.searchArtistItems.isEmpty, isTrue);
    expect(controller.searchArtistsPage, 1);
    expect(controller.hasMoreSearch.value, isTrue);

    await controller.searchArtistByName('piano', isLoadMore: false);
    expect(networkClient.requestedUrls.last, contains('search=piano'));
    expect(networkClient.requestedUrls.last, contains('page=1&limit=10'));
    expect(controller.searchArtistItems.length, 10);
    expect(controller.searchArtistItems.first.fullName, contains('search_piano_'));
    expect(controller.searchArtistItems.any((a) => a.fullName.contains('guitar')), isFalse);
  });

  testWidgets('ScrollController listener triggers page=2&limit=10 on scroll near bottom', (WidgetTester tester) async {
    controller = Get.put(ArtistsController(service: homeService));

    // Wait for onInit initial loads to complete
    await tester.pumpAndSettle();
    expect(controller.artistsItems.length, 10);
    expect(controller.allArtistsPage, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: controller.scrollController,
            child: Column(
              children: [
                for (int i = 0; i < 10; i++)
                  const SizedBox(height: 200, child: Text('Card')),
              ],
            ),
          ),
        ),
      ),
    );

    // Scroll to the bottom
    controller.scrollController.jumpTo(controller.scrollController.position.maxScrollExtent);
    await tester.pumpAndSettle();

    // Verify page 2 was triggered by scroll (4 initial tab requests + 1 scroll page 2 request = 5 total)
    expect(networkClient.requestedUrls.length, 5);
    expect(networkClient.requestedUrls.last, contains('page=2&limit=10'));
    expect(controller.artistsItems.length, 20);
    expect(controller.allArtistsPage, 2);
  });
}
