import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';

class RepostListingsScreen extends StatefulWidget {
  const RepostListingsScreen({super.key});

  @override
  State<RepostListingsScreen> createState() => _RepostListingsScreenState();
}

class _RepostListingsScreenState extends State<RepostListingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _activeListings = [
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

  final List<Map<String, dynamic>> _inactiveListings = [
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CustomAppBar2(
                title: "Your Repost Listings",
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () => Get.back(),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: getTextStyle(
                      fontsize: 16,
                      fontweight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: "Active (${_activeListings.length})"),
                      Tab(text: "Inactive (${_inactiveListings.length})"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListingsList(_activeListings),
                  _buildListingsList(_inactiveListings),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to add new listing or open bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C), // Deep red color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "+ Add New Listing",
                    style: getTextStyle(
                      color: Colors.white,
                      fontsize: 18,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsList(List<Map<String, dynamic>> listings) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final item = listings[index];
        final isActive = item['status'] == 'Active';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2C2C2C),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                item['icon'],
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: getTextStyle(
                        color: Colors.white,
                        fontsize: 16,
                        fontweight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['price'],
                      style: getTextStyle(
                        color: Colors.white,
                        fontsize: 15,
                        fontweight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['status'],
                  style: getTextStyle(
                    color: isActive ? Colors.green : Colors.grey,
                    fontsize: 13,
                    fontweight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
