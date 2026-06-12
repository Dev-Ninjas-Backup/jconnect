import 'package:get/get.dart';
import 'package:jconnect/routes/approute.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/features/repost/repost_start/model/repost_model.dart';

class RepostController extends GetxController {
  final platforms = <RepostPlatform>[
    RepostPlatform(
      name: 'Instagram',
      iconPath: Iconpath.instagram,
      heroTitle: 'Instagram Repost',
      heroSubtitle: 'Story, feed, reel, and IGTV repost options',
      visualTag: 'Instagram',
      highlights: const [
        'Story-first sharing experience',
        'Best for feed and reel boosts',
        'Quick selection with clear pricing',
      ],
      repostTypes: const ['Story Repost', 'Feed Repost', 'Reel Repost'],
      repostOptions: const [
        RepostOption(title: 'Story Repost', price: '\$1.00', badge: 'Popular'),
        RepostOption(
          title: 'Feed Repost',
          price: '\$1.00',
          badge: 'Best Reach',
        ),
        RepostOption(title: 'Reel Repost', price: '\$1.00', badge: 'Trending'),
        RepostOption(title: 'IGTV Repost', price: '\$1.00', badge: 'Archive'),
      ],
    ),
    RepostPlatform(
      name: 'TikTok',
      iconPath: Iconpath.tiktok,
      heroTitle: 'TikTok Repost',
      heroSubtitle: 'Duet, stitch, and repost formats for short-form content',
      visualTag: 'TikTok',
      highlights: const [
        'Built for short-form discovery',
        'Perfect for duet and stitch reposting',
        'Fast creator-friendly selection',
      ],
      repostTypes: const ['Repost', 'Duet / Stitch Repost'],
      repostOptions: const [
        RepostOption(title: 'Repost', price: '\$1.00', badge: 'Fast'),
        RepostOption(
          title: 'Duet / Stitch Repost',
          price: '\$1.00',
          badge: 'Creative',
        ),
      ],
    ),
    RepostPlatform(
      name: 'X (Twitter)',
      iconPath: null,
      heroTitle: 'X Repost',
      heroSubtitle: 'Repost and quote repost formats for conversation reach',
      visualTag: 'X',
      highlights: const [
        'Conversation-first reposting',
        'Strong for quote-style sharing',
        'Clean repost actions for fast circulation',
      ],
      repostTypes: const ['Repost', 'Quote Repost'],
      repostOptions: const [
        RepostOption(title: 'Repost', price: '\$1.00', badge: 'Fast'),
        RepostOption(
          title: 'Quote Repost',
          price: '\$1.00',
          badge: 'Discussion',
        ),
      ],
    ),
    RepostPlatform(
      name: 'YouTube',
      iconPath: Iconpath.youtube,
      heroTitle: 'YouTube Repost',
      heroSubtitle: 'Community post reposts and Shorts reposts in one place',
      visualTag: 'YouTube',
      highlights: const [
        'Great for community distribution',
        'Shorts reposts with visual emphasis',
        'Structured for creator promotion',
      ],
      repostTypes: const ['Community Post Repost', 'Video Repost (Shorts)'],
      repostOptions: const [
        RepostOption(
          title: 'Community Post Repost',
          price: '\$1.00',
          badge: 'Community',
        ),
        RepostOption(
          title: 'Video Repost (Shorts)',
          price: '\$1.00',
          badge: 'Shorts',
        ),
      ],
    ),
    RepostPlatform(
      name: 'Facebook',
      iconPath: Iconpath.facebook,
      heroTitle: 'Facebook Repost',
      heroSubtitle: 'Post and story repost options built for social sharing',
      visualTag: 'Facebook',
      highlights: const [
        'Great for broad social sharing',
        'Supports post and story reposts',
        'Simple actions with familiar layout',
      ],
      repostTypes: const ['Post Repost', 'Story Repost'],
      repostOptions: const [
        RepostOption(title: 'Post Repost', price: '\$1.00', badge: 'Reach'),
        RepostOption(title: 'Story Repost', price: '\$1.00', badge: 'Stories'),
      ],
    ),
  ].obs;

  void openPlatform(RepostPlatform platform) {
    Get.toNamed(AppRoute.repostProcessOption, arguments: platform);
  }
}
