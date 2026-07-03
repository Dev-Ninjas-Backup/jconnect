import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/repost/repost_listings/controller/repost_listing_controller.dart';
import 'package:jconnect/routes/approute.dart';

class RepostListingsScreen extends StatelessWidget {
  const RepostListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RepostListingController());

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
                  child: Obx(
                    () => TabBar(
                      controller: controller.tabController,
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
                        Tab(text: "Active (${controller.activeListings.length})"),
                        Tab(text: "Inactive (${controller.inactiveListings.length})"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildListingsList(controller.activeListings),
                  _buildListingsList(controller.inactiveListings),
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
                    Get.toNamed(AppRoute.createEditRepostListingScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
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

  Widget _buildListingsList(RxList<Map<String, dynamic>> listings) {
    final controller = Get.find<RepostListingController>();
    return Obx(
      () => ListView.builder(
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['status'],
                      style: getTextStyle(
                        color: isActive ? Colors.green : Colors.grey,
                        fontsize: 13,
                        fontweight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.toggleStatus(item),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 26,
                        padding: const EdgeInsets.all(3),
                        alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: isActive
                              ? Colors.green.withValues(alpha: 0.15)
                              : const Color(0xFF1E1E1E),
                          border: Border.all(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.8)
                                : const Color(0xFF3A3A3A),
                            width: 1.5,
                          ),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.green : Colors.grey,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
