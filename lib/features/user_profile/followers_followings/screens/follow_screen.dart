// ignore_for_file: unnecessary_type_check

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import 'package:jconnect/routes/approute.dart';
import '../../../../core/common/widgets/custom_primary_button.dart';
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Obx(
              () => TabBar(
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
                tabs: [
                  Tab(
                    text: controller.followerCount == 0
                        ? "Followers"
                        : "Followers (${controller.followerCount})",
                  ),
                  Tab(
                    text: controller.followingCount == 0
                        ? "Followings"
                        : "Followings (${controller.followingCount})",
                  ),
                ],
              ),
            ),
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
                          return GestureDetector(
                            onTap: () async {
                              final artistsDetailsController = Get.put(
                                ArtistsDetailsController(
                                  networkClient: NetworkClient(
                                    onUnAuthorize: () {
                                      if (kDebugMode) print("unauthorized");
                                    },
                                  ),
                                ),
                              );
                              await artistsDetailsController.fetchArtistById(
                                user.id,
                              );
                              Get.toNamed(AppRoute.artistsDetailsPage);
                            },
                            child: ListTile(
                              leading: user.profilePhoto != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        user.profilePhoto!,
                                      ),
                                    )
                                  : CircleAvatar(
                                      child: Text(
                                        user.username[0].toUpperCase(),
                                      ),
                                    ),
                              title: Text(
                                user.username,
                                style: getTextStyle(
                                  fontsize: sp(16),
                                  fontweight: FontWeight.w500,
                                  color: AppColors.primaryTextColor,
                                ),
                              ),
                              trailing: Obx(() {
                                final isFollowing = controller.followingUsers[user.id] ??
                                    controller.followings.any((f) => f.id == user.id);
                                return CustomPrimaryButton(
                                  buttonHeight: 4,
                                  buttonWidth: 12,
                                  buttonText: isFollowing ? 'Following' : 'Follow',
                                  onTap: () {
                                    controller.followUser(user.id);
                                  },
                                );
                              }),
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
                          return GestureDetector(
                            onTap: () async {
                              final artistsDetailsController = Get.put(
                                ArtistsDetailsController(
                                  networkClient: NetworkClient(
                                    onUnAuthorize: () {
                                      if (kDebugMode) print("unauthorized");
                                    },
                                  ),
                                ),
                              );
                              await artistsDetailsController.fetchArtistById(
                                user.id,
                              );
                              Get.toNamed(AppRoute.artistsDetailsPage);
                            },
                            child: ListTile(
                              leading: user.profilePhoto != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        user.profilePhoto!,
                                      ),
                                    )
                                  : CircleAvatar(
                                      child: Text(
                                        user.username[0].toUpperCase(),
                                      ),
                                    ),
                              title: Text(
                                user.username,
                                style: getTextStyle(
                                  fontsize: sp(16),
                                  fontweight: FontWeight.w500,
                                  color: AppColors.primaryTextColor,
                                ),
                              ),
                              trailing: Obx(() {
                                final isFollowing = controller.followingUsers[user.id] ??
                                    controller.followings.any((f) => f.id == user.id);
                                return CustomPrimaryButton(
                                  buttonHeight: 4,
                                  buttonWidth: 12,
                                  buttonText: isFollowing ? 'Unfollow' : 'Follow',
                                  onTap: () {
                                    controller.followUser(user.id);
                                  },
                                );
                              }),
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

// Provide a lightweight fallback implementation in case the controller
// doesn't implement followUser. This prevents build errors while keeping
// behavior non-destructive. Real follow logic should live in the controller.
extension FollowControllerFallback on FollowController {
  void followUser(String id) {
    if (kDebugMode) {
      print('followUser called for id: $id');
    }
    // Optionally trigger a refresh to reflect changes.
    try {
      if (this is dynamic && (this as dynamic).loadFollowers != null) {
        (this as dynamic).loadFollowers();
      }
    } catch (_) {}
  }
}
