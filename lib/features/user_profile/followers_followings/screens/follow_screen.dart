import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import '../controller/follower_following_controller.dart';

class FollowScreen extends StatelessWidget {
  FollowScreen({super.key});
  final FollowController controller = Get.put(FollowController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backGroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backGroundColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Connections",
            style: getTextStyle(
              fontsize: sp(20),
              fontweight: FontWeight.w600,
              color: AppColors.primaryTextColor,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            textScaler: const TextScaler.linear(1.25),
            onTap: (index) {
              if (index == 0) {
                controller.loadFollowers();
              } else {
                controller.loadFollowings();
              }
            },
            tabs: const [
              Tab(text: "Followers"),
              Tab(text: "Followings"),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: controller.followers.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text(
                            "No followers yet",
                            style: getTextStyle(
                              fontsize: sp(20),
                              fontweight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: controller.followers.map((user) {
                          return ListTile(
                            title: Text(
                              user.fullName,
                              style: getTextStyle(
                                fontsize: sp(16),
                                fontweight: FontWeight.w500,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            subtitle: Text(
                              user.email,
                              style: getTextStyle(
                                fontsize: sp(12),
                                fontweight: FontWeight.w400,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),

              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: controller.followings.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text(
                            "No followings yet",
                            style: getTextStyle(
                              fontsize: sp(20),
                              fontweight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: controller.followings.map((user) {
                          return ListTile(
                            title: Text(
                              user.fullName,
                              style: getTextStyle(
                                fontsize: sp(16),
                                fontweight: FontWeight.w500,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            subtitle: Text(
                              user.email,
                              style: getTextStyle(
                                fontsize: sp(12),
                                fontweight: FontWeight.w400,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
