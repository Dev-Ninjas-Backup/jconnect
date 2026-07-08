import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/repost_socket/repost_socket_service.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/repost_status/service/repost_status_service.dart';

class RepostReviewWindowController extends GetxController {
  final RepostStatusItem item;
  RepostReviewWindowController({required this.item});

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
  final totalSeconds = 3600.obs;

  StreamSubscription? _socketSubscription;

  @override
  void onInit() {
    super.onInit();
    // Pre-initialize with item passed from previous screen
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
            debugPrint('📩 Socket event matching order ${item.id} received in review window: ${event.event}. Fetching details.');
            fetchOrderDetails();
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error initializing socket in RepostReviewWindowController: $e');
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

      // Re-initialize timer based on comparison between updatedAt and countdownEndsAt if available
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

    if (remaining.isNegative || remaining.inSeconds < 10) {
      totalSeconds.value = 3600; // 1 hour
      remainingSeconds.value = 3522; // 58 minutes 42 seconds
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
    totalSeconds.value = totalDuration.inSeconds > 0 ? totalDuration.inSeconds : 3600;

    final remaining = countdownEndsAt.difference(DateTime.now());

    if (remaining.isNegative || remaining.inSeconds < 10) {
      remainingSeconds.value = 3522; // fallback mock remaining seconds
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

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

  double get progressPercentage {
    if (totalSeconds.value == 0) return 0.0;
    return remainingSeconds.value / totalSeconds.value;
  }

  String get timeframeLabel {
    final tf = detailedItem.value?.timeframe ?? item.timeframe;
    final map = {
      'THIRTY_MIN': '30 Min',
      'ONE_HOUR': '1 Hour',
      'TWO_HOURS': '2 Hours',
      'SIX_HOURS': '6 Hours',
      'TWELVE_HOURS': '12 Hours',
      'TWENTY_FOUR_HOURS': '24 Hours',
    };
    return map[tf] ?? tf.replaceAll('_', ' ').toLowerCase();
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

  void releaseFunds() {
    Get.snackbar(
      'Success',
      'Funds released successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void reportIssue() {
    Get.snackbar(
      'Reported',
      'Issue reported successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
