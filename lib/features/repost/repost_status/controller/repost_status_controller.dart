import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/repost_socket/repost_socket_service.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/repost_status/service/repost_status_service.dart';

enum RepostTab { myRepost, paidRepost }

class RepostStatusController extends GetxController {
  final selectedTab = RepostTab.myRepost.obs;
  final isLoading = false.obs;
  final isError = false.obs;
  final errorMessage = ''.obs;

  final RepostStatusService _service = RepostStatusService(
    client: NetworkClient(
      onUnAuthorize: () {
        if (kDebugMode) {
          print('unauthorized');
        }
      },
    ),
  );

  // My repost status — I am the seller (fetched from my-seller-orders API)
  final myReposts = <RepostStatusItem>[].obs;

  // Paid repost status — I am the buyer (fetched from my-orders API)
  final paidReposts = <RepostStatusItem>[].obs;

  StreamSubscription? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchMySellerRepostOrders();
    fetchPaidRepostOrders();
    _initSocket();
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    RepostSocketService().disconnect();
    super.onClose();
  }

  Future<void> _initSocket() async {
    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessRowToken();
      if (token != null && token.isNotEmpty) {
        final socketService = RepostSocketService();
        socketService.connect(token: token);

        _socketSubscription = socketService.eventStream.listen((event) {
          if (event.event == 'repost:error') {
            debugPrint('❌ Repost Socket Error: ${event.data}');
          } else if (event.event == 'repost:success') {
            debugPrint('✅ Repost Socket Success: ${event.data}');
          } else {
            debugPrint('📩 Repost Socket Event: ${event.event}. Refreshing lists.');
            fetchMySellerRepostOrders();
            fetchPaidRepostOrders();
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error initializing repost socket: $e');
    }
  }

  Future<void> fetchPaidRepostOrders() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final orders = await _service.fetchMyRepostOrders();
      paidReposts.assignAll(orders);
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMySellerRepostOrders() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final orders = await _service.fetchMySellerRepostOrders();
      myReposts.assignAll(orders);
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void selectTab(RepostTab tab) {
    selectedTab.value = tab;
    if (tab == RepostTab.paidRepost && paidReposts.isEmpty && !isLoading.value) {
      fetchPaidRepostOrders();
    } else if (tab == RepostTab.myRepost && myReposts.isEmpty && !isLoading.value) {
      fetchMySellerRepostOrders();
    }
  }

  List<RepostStatusItem> get currentList =>
      selectedTab.value == RepostTab.myRepost ? myReposts : paidReposts;

  /// Returns a human-readable display label for the platform string from API.
  String platformLabel(String platform) {
    final map = {
      'FACEBOOK_STORY': 'Facebook Story',
      'FACEBOOK_POST': 'Facebook Post',
      'TWITTER_QUOTE': 'X (Twitter) Quote',
      'TWITTER_RETWEET': 'X (Twitter) Retweet',
      'TIKTOK_DUET': 'TikTok Duet',
      'TIKTOK_STITCH': 'TikTok Stitch',
      'INSTAGRAM_STORY': 'Instagram Story',
      'INSTAGRAM_POST': 'Instagram Post',
      'YOUTUBE_SHORT': 'YouTube Short',
      'YOUTUBE_SHORTS': 'YouTube Shorts',
    };
    return map[platform] ?? platform.replaceAll('_', ' ').toLowerCase();
  }

  /// Returns a human-readable display label for the timeframe string from API.
  String timeframeLabel(String timeframe) {
    final map = {
      'THIRTY_MIN': '30 Min',
      'ONE_HOUR': '1 Hour',
      'TWO_HOURS': '2 Hours',
      'SIX_HOURS': '6 Hours',
      'TWELVE_HOURS': '12 Hours',
      'TWENTY_FOUR_HOURS': '24 Hours',
    };
    return map[timeframe] ?? timeframe.replaceAll('_', ' ').toLowerCase();
  }

  /// Returns a human-readable status label.
  String statusLabel(String status) {
    final map = {
      'NEW_REQUEST': 'New Request',
      'ACCEPTED': 'Accepted',
      'IN_PROGRESS': 'In Progress',
      'PROOF_SUBMITTED': 'Proof Submitted',
      'COMPLETED': 'Completed',
      'REFUNDED': 'Refunded',
      'CANCELLED': 'Cancelled',
      'DISPUTED': 'Disputed',
    };
    return map[status] ?? status.replaceAll('_', ' ').toLowerCase();
  }
}
