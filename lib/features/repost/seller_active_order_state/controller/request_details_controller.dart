import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/repost_socket/repost_socket_service.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/repost_status/service/repost_status_service.dart';
import 'package:jconnect/features/repost/seller_active_order_state/screen/seller_active_order_screen.dart';

class RequestDetailsController extends GetxController {
  final RepostStatusItem item;
  RequestDetailsController({required this.item});

  final RepostStatusService _service = RepostStatusService(
    client: NetworkClient(
      onUnAuthorize: () {
        if (kDebugMode) {
          print('unauthorized');
        }
      },
    ),
  );

  final isLoading = false.obs;
  final isError = false.obs;
  final errorMessage = ''.obs;

  // Detailed item loaded from API
  final detailedItem = Rxn<RepostStatusItem>();

  Timer? _timer;
  final remainingSeconds = 0.obs;
  final totalSeconds = 7200.obs;

  StreamSubscription? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    // Pre-initialize detailedItem with item passed from previous screen
    detailedItem.value = item;
    _initializeTimer(item);
    fetchOrderDetails();
    _initSocket();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _socketSubscription?.cancel();
    _leaveOrderRoom();
    super.onClose();
  }

  Future<void> _initSocket() async {
    try {
      final prefs = Get.find<SharedPreferencesHelperController>();
      final token = await prefs.getAccessRowToken();
      if (token != null && token.isNotEmpty) {
        final socketService = RepostSocketService();
        if (!socketService.isConnected) {
          socketService.connect(token: token);
        }
        
        // Join the specific order room
        socketService.joinOrder(item.id);

        _socketSubscription = socketService.eventStream.listen((event) {
          final data = event.data;
          String? eventOrderId;
          if (data is Map) {
            eventOrderId = data['id'] ?? data['orderId'];
          }

          if (eventOrderId == item.id) {
            debugPrint('📩 Socket event matching order ${item.id} received: ${event.event}. Fetching details.');
            fetchOrderDetails();
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error initializing socket in RequestDetailsController: $e');
    }
  }

  void _leaveOrderRoom() {
    try {
      RepostSocketService().leaveOrder(item.id);
    } catch (e) {
      debugPrint('⚠️ Error leaving order room: $e');
    }
  }

  Future<void> fetchOrderDetails() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      final details = await _service.fetchRepostOrderDetail(item.id);
      detailedItem.value = details;

      // Initialize/Start timer based on countdownEndsAt if available
      if (details.countdownEndsAt != null) {
        startTimer(details.updatedAt, details.countdownEndsAt!);
      } else {
        _initializeTimer(details);
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeTimer(RepostStatusItem targetItem) {
    final duration = _parseTimeframe(targetItem.timeframe);
    final endTime = targetItem.createdAt.add(duration);
    final remaining = endTime.difference(DateTime.now());

    // If the mock item is expired, show a realistic countdown (7172 seconds) out of 2 hours
    if (remaining.isNegative || remaining.inSeconds < 10) {
      totalSeconds.value = 7200; // 2 hours
      remainingSeconds.value = 7172; // 1 hour 59 minutes 32 seconds
    } else {
      totalSeconds.value = duration.inSeconds;
      remainingSeconds.value = remaining.inSeconds;
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  void startTimer(DateTime updatedAt, DateTime countdownEndsAt) {
    _timer?.cancel();

    final totalDuration = countdownEndsAt.difference(updatedAt);
    totalSeconds.value = totalDuration.inSeconds > 0
        ? totalDuration.inSeconds
        : 7200;

    final remaining = countdownEndsAt.difference(DateTime.now());

    if (remaining.isNegative || remaining.inSeconds < 10) {
      remainingSeconds.value = 7172; // fallback mock remaining seconds
    } else {
      remainingSeconds.value = remaining.inSeconds;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  Duration _parseTimeframe(String timeframe) {
    // Handle API enum format: THIRTY_MIN, ONE_HOUR, TWO_HOURS, etc.
    switch (timeframe) {
      case 'THIRTY_MIN':
        return const Duration(minutes: 30);
      case 'ONE_HOUR':
        return const Duration(hours: 1);
      case 'TWO_HOURS':
        return const Duration(hours: 2);
      case 'SIX_HOURS':
        return const Duration(hours: 6);
      case 'TWELVE_HOURS':
        return const Duration(hours: 12);
      case 'TWENTY_FOUR_HOURS':
        return const Duration(hours: 24);
    }
    // Fallback: try parsing legacy human-readable format e.g. "2 Hours"
    final parts = timeframe.split(' ');
    if (parts.length >= 2) {
      final value = int.tryParse(parts[0]) ?? 1;
      final unit = parts[1].toLowerCase();
      if (unit.contains('hour')) return Duration(hours: value);
      if (unit.contains('minute')) return Duration(minutes: value);
      if (unit.contains('day')) return Duration(days: value);
    }
    return const Duration(hours: 1);
  }

  String get formattedTime {
    final hours = remainingSeconds.value ~/ 3600;
    final minutes = (remainingSeconds.value % 3600) ~/ 60;
    final seconds = remainingSeconds.value % 60;

    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  String get optionText {
    final currentItem = detailedItem.value ?? item;
    final p = currentItem.platform.toUpperCase();

    final exactMap = {
      'FACEBOOK_STORY': 'Facebook Story',
      'FACEBOOK_POST': 'Facebook Post',
      'TWITTER_QUOTE': 'X (Twitter) Quote',
      'TWITTER_RETWEET': 'X (Twitter) Retweet',
      'TIKTOK_DUET': 'TikTok Duet',
      'TIKTOK_STITCH': 'TikTok Stitch',
      'INSTAGRAM_STORY': 'Instagram Story',
      'INSTAGRAM_POST': 'Instagram Post',
      'INSTAGRAM_FEED': 'Instagram Feed',
      'INSTAGRAM_REEL': 'Instagram Reel',
      'YOUTUBE_SHORT': 'YouTube Short',
      'YOUTUBE_SHORTS': 'YouTube Shorts',
      'YOUTUBE_COMMUNITY_POST': 'YouTube Community Post',
    };

    if (exactMap.containsKey(p)) {
      return exactMap[p]!;
    }

    if (p.contains('INSTAGRAM')) return 'Instagram Repost';
    if (p.contains('FACEBOOK')) return 'Facebook Repost';
    if (p.contains('TIKTOK')) return 'TikTok Repost';
    if (p.contains('TWITTER')) return 'X (Twitter) Repost';
    if (p.contains('YOUTUBE')) return 'YouTube Repost';

    return '${currentItem.platform.replaceAll('_', ' ')} Repost';
  }

  String get platformIconPath {
    final currentItem = detailedItem.value ?? item;
    final p = currentItem.platform.toUpperCase();
    if (p.contains('INSTAGRAM')) return Iconpath.instagram;
    if (p.contains('FACEBOOK')) return Iconpath.facebook;
    if (p.contains('TIKTOK')) return Iconpath.tiktok;
    if (p.contains('YOUTUBE')) return Iconpath.youtube;
    if (p.contains('LINKEDIN')) return Iconpath.linkedIn;
    if (p.contains('TWITTER')) return Iconpath.twitter;
    if (p.contains('SNAPCHAT')) return Iconpath.snapChat;
    if (p.contains('TWITCH')) return Iconpath.twitch;
    return Iconpath.defaultSocial;
  }

  Future<void> acceptRequest() async {
    final orderId = detailedItem.value?.id ?? item.id;
    try {
      EasyLoading.show(status: 'Accepting request...');
      final updatedItem = await _service.acceptRepostOrder(orderId);
      final mergedItem = updatedItem.copyWith(
        listing: detailedItem.value?.listing ?? item.listing,
        seller: detailedItem.value?.seller ?? item.seller,
        buyer: detailedItem.value?.buyer ?? item.buyer,
      );
      EasyLoading.dismiss();
      Get.snackbar(
        'Success',
        'Request accepted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.off(() => SellerActiveOrderScreen(item: mergedItem));
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> rejectRequest() async {
    final orderId = detailedItem.value?.id ?? item.id;
    try {
      EasyLoading.show(status: 'Rejecting request...');
      await _service.rejectRepostOrder(orderId);
      EasyLoading.dismiss();
      Get.snackbar(
        'Rejected',
        'You have rejected this repost request.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
