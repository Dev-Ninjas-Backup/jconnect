import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/features/repost/repost_listings/controller/repost_listing_controller.dart';
import 'package:jconnect/features/repost/repost_listings/model/repost_listing_model.dart';
import 'package:jconnect/features/repost/repost_listings/widgets/repost_listing_card.dart';
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
                        Tab(
                          text: "Active (${controller.activeListings.length})",
                        ),
                        Tab(
                          text:
                              "Inactive (${controller.inactiveListings.length})",
                        ),
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
                  onPressed: () async {
                    await Get.toNamed(AppRoute.createEditRepostListingScreen);
                    controller.fetchListings();
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

  Widget _buildListingsList(RxList<RepostListingModel> listings) {
    final controller = Get.find<RepostListingController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
        );
      }
      if (controller.isError.value) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: getTextStyle(color: Colors.white),
          ),
        );
      }
      if (listings.isEmpty) {
        return Center(
          child: Text(
            "No listings found",
            style: getTextStyle(color: Colors.grey),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final item = listings[index];
          final isActive = item.isActive;
          return GestureDetector(
            onTap: () async {
              await Get.toNamed(
                AppRoute.createEditRepostListingScreen,
                arguments: item.id,
              );
              controller.fetchListings();
            },
            child: RepostListingCard(
              item: item,
              isActive: isActive,
              controller: controller,
            ),
          );
        },
      );
    });
  }
}
