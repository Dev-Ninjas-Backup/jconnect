import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/features/repost/model/repost_model.dart';

class RepostController extends GetxController {
  final platforms = <RepostPlatform>[
    RepostPlatform(
      name: 'Instagram',
      iconPath: Iconpath.instagram,
      repostTypes: const [
        'Story Repost',
        'Feed Repost',
        'Reel Repost',
      ],
    ),
    RepostPlatform(
      name: 'TikTok',
      iconPath: Iconpath.tiktok,
      repostTypes: const ['Repost', 'Duet / Stitch Repost'],
    ),
    RepostPlatform(
      name: 'X (Twitter)',
      iconPath: null,
      repostTypes: const ['Repost', 'Quote Repost'],
    ),
    RepostPlatform(
      name: 'YouTube',
      iconPath: Iconpath.youtube,
      repostTypes: const ['Community Post Repost', 'Video Repost (Shorts)'],
    ),
    RepostPlatform(
      name: 'Facebook',
      iconPath: Iconpath.facebook,
      repostTypes: const ['Post Repost', 'Story Repost'],
    ),
  ].obs;

  final selectedPlatformIndex = 0.obs;

  RepostPlatform get selectedPlatform => platforms[selectedPlatformIndex.value];

  void selectPlatform(int index) {
    if (index < 0 || index >= platforms.length) return;
    selectedPlatformIndex.value = index;
  }
}

