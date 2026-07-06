import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/repost_start/model/repost_model.dart';
import 'package:jconnect/features/repost/repost_start/service/repost_hub_service.dart';
import 'package:jconnect/routes/approute.dart';

class PlatformMetadata {
  final String name;
  final String? iconPath;
  final String heroTitle;
  final String heroSubtitle;
  final String visualTag;
  // final List<String> highlights;

  const PlatformMetadata({
    required this.name,
    required this.iconPath,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.visualTag,
    //required this.highlights,
  });
}

const Map<String, PlatformMetadata> platformInfoMap = {
  'INSTAGRAM': PlatformMetadata(
    name: 'Instagram',
    iconPath: 'assets/icons/instagram.png',
    heroTitle: 'Instagram Repost',
    heroSubtitle: 'Story, feed and reel repost options',
    visualTag: 'Instagram',
    // highlights: [
    //   'Story-first sharing experience',
    //   'Best for feed and reel boosts',
    //   'Quick selection with clear pricing',
    // ],
  ),
  'TIKTOK': PlatformMetadata(
    name: 'TikTok',
    iconPath: 'assets/icons/tiktok.png',
    heroTitle: 'TikTok Repost',
    heroSubtitle: 'Duet, stitch, and repost formats for short-form content',
    visualTag: 'TikTok',
    // highlights: [
    //   'Built for short-form discovery',
    //   'Perfect for duet and stitch reposting',
    //   'Fast creator-friendly selection',
    // ],
  ),
  'TWITTER': PlatformMetadata(
    name: 'X (Twitter)',
    iconPath: 'assets/icons/twitter.png',
    heroTitle: 'X Repost',
    heroSubtitle: 'Repost and quote repost formats for conversation reach',
    visualTag: 'X',
    // highlights: [
    //   'Conversation-first reposting',
    //   'Strong for quote-style sharing',
    //   'Clean repost actions for fast circulation',
    // ],
  ),
  'X': PlatformMetadata(
    name: 'X (Twitter)',
    iconPath: 'assets/icons/twitter.png',
    heroTitle: 'X Repost',
    heroSubtitle: 'Repost and quote repost formats for conversation reach',
    visualTag: 'X',
    // highlights: [
    //   'Conversation-first reposting',
    //   'Strong for quote-style sharing',
    //   'Clean repost actions for fast circulation',
    // ],
  ),
  'YOUTUBE': PlatformMetadata(
    name: 'YouTube',
    iconPath: 'assets/icons/youtube.png',
    heroTitle: 'YouTube Repost',
    heroSubtitle: 'Community post reposts and Shorts reposts in one place',
    visualTag: 'YouTube',
    // highlights: [
    //   'Great for community distribution',
    //   'Shorts reposts with visual emphasis',
    //   'Structured for creator promotion',
    // ],
  ),
  'FACEBOOK': PlatformMetadata(
    name: 'Facebook',
    iconPath: 'assets/icons/facebook.png',
    heroTitle: 'Facebook Repost',
    heroSubtitle: 'Post and story repost options built for social sharing',
    visualTag: 'Facebook',
    // highlights: [
    //   'Great for broad social sharing',
    //   'Supports post and story reposts',
    //   'Simple actions with familiar layout',
    // ],
  ),
};

class RepostController extends GetxController {
  final RepostHubService _service = RepostHubService(
    client: NetworkClient(
      onUnAuthorize: () {
        if (kDebugMode) print("unauthorized");
      },
    ),
  );

  final platforms = <RepostPlatform>[].obs;
  final isLoading = false.obs;
  final isError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final artistId = Get.arguments as String?;
    if (artistId != null) {
      fetchRepostListings(artistId);
    }
  }

  PlatformMetadata getPlatformMetadata(String rawPlatform) {
    final upper = rawPlatform.toUpperCase();
    for (final key in platformInfoMap.keys) {
      if (upper.startsWith(key)) {
        return platformInfoMap[key]!;
      }
    }
    return PlatformMetadata(
      name: rawPlatform,
      iconPath: null,
      heroTitle: '$rawPlatform Repost',
      heroSubtitle: 'Repost formats for $rawPlatform content',
      visualTag: rawPlatform,
      //highlights: const ['Quick and reliable reposting options'],
    );
  }

  String getRepostTypeLabel(String rawPlatform) {
    final upper = rawPlatform.toUpperCase();
    if (upper.endsWith('_STORY')) return 'Story Repost';
    if (upper.endsWith('_FEED')) return 'Feed Repost';
    if (upper.endsWith('_REEL')) return 'Reel Repost';
    if (upper.endsWith('_SHORTS')) return 'Video Repost (Shorts)';
    if (upper.endsWith('_COMMUNITY_POST')) return 'Community Post Repost';
    if (upper.endsWith('_QUOTE')) return 'Quote Repost';
    if (upper.endsWith('_DUET')) return 'Duet / Stitch Repost';
    if (upper.endsWith('_POST')) return 'Post Repost';
    return 'Repost';
  }

  Future<void> fetchRepostListings(String artistId) async {
    isLoading(true);
    isError(false);
    errorMessage('');

    try {
      final rawListings = await _service.fetchRepostListingsByArtist(artistId);
      final activeListings = rawListings.where((item) {
        final isActive = item['isActive'] as bool? ?? false;
        final isPaused = item['isPaused'] as bool? ?? false;
        return isActive && !isPaused;
      }).toList();

      final Map<String, List<dynamic>> grouped = {};
      for (final item in activeListings) {
        final rawPlatform = item['platform'] as String? ?? '';
        final metadata = getPlatformMetadata(rawPlatform);
        grouped.putIfAbsent(metadata.name, () => []).add(item);
      }

      final parsedPlatforms = <RepostPlatform>[];
      grouped.forEach((platformName, items) {
        final firstItem = items.first;
        final rawPlatform = firstItem['platform'] as String? ?? '';
        final metadata = getPlatformMetadata(rawPlatform);

        final repostOptions = items.map<RepostOption>((item) {
          final rawPlat = item['platform'] as String? ?? '';
          final titleLabel = getRepostTypeLabel(rawPlat);
          final priceVal = item['price'];
          final formattedPrice = '\$${priceVal.toString()}';

          return RepostOption(
            title: titleLabel,
            price: formattedPrice,
            badge: item['isSpotlight'] == true
                ? 'Spotlight'
                : (item['followerCount'] > 1000 ? 'Popular' : 'Active'),
            listingId: item['id'] as String? ?? '',
            followerCount: item['followerCount'] as int? ?? 0,
            description: item['description'] as String? ?? '',
            defaultTurnaround: item['defaultTurnaround'] as String? ?? '',
            rawPlatform: rawPlat,
          );
        }).toList();

        final repostTypes = repostOptions
            .map((opt) => opt.title)
            .toSet()
            .toList();

        parsedPlatforms.add(
          RepostPlatform(
            name: platformName,
            iconPath: metadata.iconPath,
            heroTitle: metadata.heroTitle,
            heroSubtitle: metadata.heroSubtitle,
            visualTag: metadata.visualTag,
            // highlights: metadata.highlights,
            repostTypes: repostTypes,
            repostOptions: repostOptions,
          ),
        );
      });

      platforms.assignAll(parsedPlatforms);
    } catch (e) {
      isError(true);
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void openPlatform(RepostPlatform platform) {
    Get.toNamed(AppRoute.repostProcessOption, arguments: platform);
  }
}
