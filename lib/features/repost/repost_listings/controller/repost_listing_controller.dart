import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';

class RepostListingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  final RxList<Map<String, dynamic>> activeListings = <Map<String, dynamic>>[
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
  ].obs;

  final RxList<Map<String, dynamic>> inactiveListings = <Map<String, dynamic>>[
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
  ].obs;

  void toggleStatus(Map<String, dynamic> item) {
    if (item['status'] == 'Active') {
      activeListings.remove(item);
      item['status'] = 'Inactive';
      inactiveListings.add(item);
    } else {
      inactiveListings.remove(item);
      item['status'] = 'Active';
      activeListings.add(item);
    }
  }

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
