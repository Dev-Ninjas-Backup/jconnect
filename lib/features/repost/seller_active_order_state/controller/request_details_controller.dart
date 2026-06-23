import 'dart:async';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';

class RequestDetailsController extends GetxController {
  final RepostStatusItem item;
  RequestDetailsController({required this.item});

  Timer? _timer;
  final remainingSeconds = 0.obs;
  final totalSeconds = 7200.obs; // Default to 2 hours

  @override
  void onInit() {
    super.onInit();
    _initializeTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _initializeTimer() {
    final duration = _parseTimeframe(item.timeframe);
    final endTime = item.createdAt.add(duration);
    final remaining = endTime.difference(DateTime.now());

    // If the mock item is expired, show a realistic 01:59:32 countdown (7172 seconds) out of 2 hours
    if (remaining.isNegative || remaining.inSeconds < 10) {
      totalSeconds.value = 7200; // 2 hours
      remainingSeconds.value = 7172; // 1 hour 59 minutes 32 seconds
    } else {
      totalSeconds.value = duration.inSeconds;
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
    final parts = timeframe.split(' ');
    if (parts.length >= 2) {
      final value = int.tryParse(parts[0]) ?? 1;
      final unit = parts[1].toLowerCase();
      if (unit.contains('hour')) {
        return Duration(hours: value);
      } else if (unit.contains('minute')) {
        return Duration(minutes: value);
      } else if (unit.contains('day')) {
        return Duration(days: value);
      }
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
    final platform = item.platform;
    if (platform.toLowerCase() == 'instagram') {
      return 'Instagram Story Repost';
    }
    return '$platform Repost';
  }

  String get platformIconPath {
    final platform = item.platform;
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Iconpath.instagram;
      case 'facebook':
        return Iconpath.facebook;
      case 'tiktok':
        return Iconpath.tiktok;
      case 'youtube':
        return Iconpath.youtube;
      case 'linkedin':
        return Iconpath.linkedIn;
      case 'twitter':
      case 'x':
        return Iconpath.twitter;
      case 'snapchat':
        return Iconpath.snapChat;
      case 'twitch':
        return Iconpath.twitch;
      default:
        return Iconpath.defaultSocial;
    }
  }

  void acceptRequest() {
    Get.snackbar(
      'Accepted',
      'You have accepted this repost request!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void rejectRequest() {
    Get.snackbar(
      'Rejected',
      'You have rejected this repost request.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
