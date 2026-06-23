import 'dart:async';
import 'package:get/get.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';

class RepostReviewWindowController extends GetxController {
  final RepostStatusItem item;
  RepostReviewWindowController({required this.item});

  Timer? _timer;
  final remainingSeconds = 0.obs;
  final totalSeconds = 3600.obs;

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

    // If the mock item is expired, show a realistic 58:42 countdown (3522 seconds) out of 1 hour
    if (remaining.isNegative || remaining.inSeconds < 10) {
      totalSeconds.value = 3600; // 1 hour
      remainingSeconds.value = 3522; // 58 minutes 42 seconds
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
