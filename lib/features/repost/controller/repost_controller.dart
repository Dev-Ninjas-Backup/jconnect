import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/features/repost/model/repost_model.dart';

class RepostController extends GetxController {
  final platforms = <RepostPlatform>[
    RepostPlatform(
      name: 'Instagram',
      iconPath: Iconpath.instagram,
      accent: const Color(0xFFF77737),
      repostTypes: const [
        'Story Repost',
        'Feed Repost',
        'Reel Repost',
      ],
    ),
    RepostPlatform(
      name: 'TikTok',
      iconPath: Iconpath.tiktok,
      accent: const Color(0xFF00F2EA),
      repostTypes: const ['Repost', 'Duet / Stitch Repost'],
    ),
    RepostPlatform(
      name: 'X (Twitter)',
      iconPath: null,
      accent: const Color(0xFFEDEDED),
      repostTypes: const ['Repost', 'Quote Repost'],
    ),
    RepostPlatform(
      name: 'YouTube',
      iconPath: Iconpath.youtube,
      accent: const Color(0xFFFF0033),
      repostTypes: const ['Community Post Repost', 'Video Repost (Shorts)'],
    ),
    RepostPlatform(
      name: 'Facebook',
      iconPath: Iconpath.facebook,
      accent: const Color(0xFF1877F2),
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

