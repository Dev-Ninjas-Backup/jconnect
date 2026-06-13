import 'package:get/get.dart';
import 'package:jconnect/features/user_profile/repost_status/model/repost_status_model.dart';

enum RepostStatusType { pending, active, completed, cancelled }

class RepostStatusController extends GetxController {
  // 0 = My Repost Status, 1 = Paid Repost Status
  final selectedTab = 0.obs;
  final isLoading = false.obs;

  // My repost status — I am the seller
  final myReposts = <RepostStatusItem>[
    RepostStatusItem(
      id: '1',
      platform: 'Instagram',
      contentUrl: 'https://www.instagram.com/p/abc123xyz/',
      sellerName: 'You',
      amount: 1.00,
      status: RepostStatusType.active,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      timeframe: '2 Hours',
    ),
    RepostStatusItem(
      id: '2',
      platform: 'X',
      contentUrl: 'https://twitter.com/janedoe/status/987654321/',
      sellerName: 'You',
      amount: 2.50,
      status: RepostStatusType.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      timeframe: '6 Hours',
    ),
    RepostStatusItem(
      id: '3',
      platform: 'TikTok',
      contentUrl: 'https://www.tiktok.com/@creator_x/video/1122334455/',
      sellerName: 'You',
      amount: 3.00,
      status: RepostStatusType.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      timeframe: '1 Hour',
    ),
  ].obs;

  // Paid repost status — I am the buyer
  final paidReposts = <RepostStatusItem>[
    RepostStatusItem(
      id: '4',
      platform: 'Instagram',
      contentUrl: 'https://www.instagram.com/p/mybrandpromo456/',
      sellerName: '@top_influencer',
      amount: 5.00,
      status: RepostStatusType.active,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      timeframe: '12 Hours',
    ),
    RepostStatusItem(
      id: '5',
      platform: 'YouTube',
      contentUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      sellerName: '@tech_reviewer',
      amount: 10.00,
      status: RepostStatusType.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      timeframe: '24 Hours',
    ),
  ].obs;

  void selectTab(int index) => selectedTab.value = index;

  List<RepostStatusItem> get currentList =>
      selectedTab.value == 0 ? myReposts : paidReposts;

  String statusLabel(RepostStatusType status) {
    switch (status) {
      case RepostStatusType.pending:
        return 'Pending';
      case RepostStatusType.active:
        return 'Active';
      case RepostStatusType.completed:
        return 'Completed';
      case RepostStatusType.cancelled:
        return 'Cancelled';
    }
  }
}
