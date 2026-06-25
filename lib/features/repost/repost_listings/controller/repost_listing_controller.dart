import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';

class RepostListingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final List<Map<String, dynamic>> activeListings = [
    {
      'title': 'Instagram Story Repost',
      'price': '\$1.00',
      'icon': Iconpath.instagram,
      'status': 'Active',
    },
    {
      'title': 'Instagram Feed Repost',
      'price': '\$1.00',
      'icon': Iconpath.instagram,
      'status': 'Active',
    },
    {
      'title': 'Instagram Reel Repost',
      'price': '\$1.00',
      'icon': Iconpath.instagram,
      'status': 'Active',
    },
    {
      'title': 'TikTok Repost',
      'price': '\$1.00',
      'icon': Iconpath.tiktok,
      'status': 'Active',
    },
    {
      'title': 'TikTok Duet Repost',
      'price': '\$1.00',
      'icon': Iconpath.tiktok,
      'status': 'Active',
    },
    {
      'title': 'X (Twitter) Repost',
      'price': '\$1.00',
      'icon': Iconpath.twitter,
      'status': 'Active',
    },
  ];

  final List<Map<String, dynamic>> inactiveListings = [
    {
      'title': 'YouTube Repost',
      'price': '\$1.00',
      'icon': Iconpath.youtube,
      'status': 'Inactive',
    },
    {
      'title': 'Facebook Repost',
      'price': '\$1.00',
      'icon': Iconpath.facebook,
      'status': 'Inactive',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
