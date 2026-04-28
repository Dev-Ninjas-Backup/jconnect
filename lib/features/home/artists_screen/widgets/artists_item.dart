// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button_2.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/home/artists_details_screen/controller/artists_details_controller.dart';
import 'package:jconnect/features/home/artists_details_screen/screen/artists_service_list.dart';
import 'package:jconnect/features/home/artists_details_screen/screen/artists_social_post_list.dart';
import 'package:jconnect/features/home/artists_screen/controller/artists_controller.dart';
import 'package:jconnect/features/home/home_screen/controller/home_controller.dart';
import 'package:jconnect/features/home/home_screen/model/artists_model.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';
import 'package:jconnect/routes/approute.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../../../../core/common/widgets/gradient_border_container.dart';

// ignore: must_be_immutable
class ArtistsItem extends StatelessWidget {
  final ArtistsController controller;
  ArtistsItem({required this.controller, super.key});
  final HomeController homeController = Get.find<HomeController>();
  var artistsDetailsController = Get.put(
    ArtistsDetailsController(
      networkClient: NetworkClient(
        onUnAuthorize: () {
          if (kDebugMode) {
            print("unauthorized");
          }
        },
      ),
    ),
  );

  // List<ArtistsModel> get currentList {
  //   if (controller.searchArtistItems.isNotEmpty &&
  //       controller.searchTextController.text.trim().isNotEmpty) {
  //     return controller.searchArtistItems;
  //   }

  //   if (controller.selectArtistsItemIndex.value == 0) {
  //     return controller.artistsItems;
  //   }
  //  else if (controller.selectArtistsItemIndex.value == 1) {
  //     return homeController.recentArtistsList;
  //   }

  //  else if (controller.selectArtistsItemIndex.value == 2) {
  //     return homeController.topRatedArtistsList;
  //   }

  //   return homeController.suggestedForYouList;
  // }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<ArtistsModel> currentList;

      //  Search first
      if (controller.searchArtistItems.isNotEmpty &&
          controller.searchTextController.text.trim().isNotEmpty) {
        currentList = controller.searchArtistItems;
      }
      //  Tab index selection
      else if (controller.selectArtistsItemIndex.value == 0) {
        currentList = controller.artistsItems;
      } else if (controller.selectArtistsItemIndex.value == 1) {
        currentList = homeController.recentArtistsList;
      } else if (controller.selectArtistsItemIndex.value == 2) {
        currentList = homeController.topRatedArtistsList;
      } else {
        currentList = homeController.suggestedForYouList;
      }

      if (currentList.isEmpty) {
        return Center(
          child: Text(
            "No artists found",
            style: getTextStyle(
              fontsize: sp(14),
              color: AppColors.secondaryTextColor,
            ),
          ),
        );
      }

      final rowCount = (currentList.length + 1) ~/ 2;

      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rowCount,
        itemBuilder: (context, rowIndex) {
          final leftIndex = rowIndex * 2;
          final rightIndex = leftIndex + 1;

          return Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildArtistCard(currentList[leftIndex])),
                const SizedBox(width: 8),
                if (rightIndex < currentList.length)
                  Expanded(child: _buildArtistCard(currentList[rightIndex]))
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildArtistCard(ArtistsModel artist) {
    // Service info
    final firstService = artist.services.isNotEmpty
        ? artist.services.first
        : null;
    final serviceDesc = firstService?.description.trim().isNotEmpty == true
        ? firstService!.description
        : "No service description available";
    final servicePrice = (firstService?.price ?? 0).toDouble();

    // Rating
    final reviews = artist.reviewsReceived;
    final avgRating = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating!.toDouble()).reduce((a, b) => a + b) /
              reviews.length;

    return GestureDetector(
      onTap: () async {
        await artistsDetailsController.fetchArtistById(artist.id);
        Get.toNamed(AppRoute.artistsDetailsPage);
      },
      child: GradientBorderContainer(
        width: double.infinity,
        borderRadius: 10.r,
        borderWidth: 1,
        gradientColors: [Colors.white, Colors.white.withOpacity(0.5)],
        padding: EdgeInsetsGeometry.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile photo
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
              ),
              child: Stack(
                children: [
                  artist.profilePhoto != null &&
                          artist.profilePhoto!.trim().isNotEmpty
                      ? Image.network(
                          artist.profilePhoto!,
                          height: 185.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Icon(
                                Icons.broken_image,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 185.h,
                          width: double.infinity,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 100.h,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  if (artist.highlights.isNotEmpty)
                    Positioned(
                      left: 8.w,
                      right: 8.w,
                      bottom: 8.h,
                      child: SizedBox(
                        height: 42.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: artist.highlights.length,
                          separatorBuilder: (_, __) => SizedBox(width: 6.w),
                          itemBuilder: (context, index) {
                            final highlight = artist.highlights[index];
                            return GestureDetector(
                              onTap: () =>
                                  _showHighlightPreview(context, highlight),
                              child: Container(
                                width: 42.w,
                                height: 42.w,
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.redColor,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipOval(
                                      child: highlight.isVideo
                                          ? Container(
                                              color: Colors.black54,
                                              child: Icon(
                                                Icons.play_circle_fill,
                                                size: 22.sp,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Image.network(
                                              highlight.url,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    color: Colors.white
                                                        .withOpacity(0.15),
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 18.sp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            ),
                                    ),
                                    if (highlight.isVideo)
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          width: 14.w,
                                          height: 14.w,
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.play_arrow,
                                            size: 10.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            /// Name + price
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      artist.userName.trim().isEmpty
                          ? "Unknown User"
                          : artist.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getTextStyle(
                        fontsize: sp(16),
                        fontweight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        width: 0.25,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    child: Text(
                      "From \$${servicePrice.toStringAsFixed(2)}",
                      style: getTextStyle(
                        fontsize: sp(8),
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RatingBarIndicator(
                    rating: avgRating,
                    itemBuilder: (_, __) =>
                        const Icon(Icons.star, color: Color(0xffBD001F)),
                    itemCount: 5,
                    itemSize: 14,
                    unratedColor: const Color(0xFFD96B7D),
                  ),
                  Text(
                    "${avgRating.toStringAsFixed(1)} (${reviews.length})",
                    style: getTextStyle(
                      fontsize: sp(10),
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                "Services",
                style: getTextStyle(
                  fontsize: sp(10),
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ),

            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                serviceDesc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  fontsize: sp(10),
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ),

            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: CustomPrimaryButton2(
                buttonText: "Buy A Service",
                onTap: () async {
                  final detailsCtrl = Get.put(
                    ArtistsDetailsController(
                      networkClient: NetworkClient(
                        onUnAuthorize: () {
                          if (kDebugMode) print("unauthorized");
                        },
                      ),
                    ),
                  );
                  await detailsCtrl.fetchArtistById(artist.id);
                  Get.to(() => ArtistsServiceList());
                },
                fontSize: sp(10),
                buttonHeight: 25,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: CustomPrimaryButton2(
                buttonText: "Buy A Social Post",
                onTap: () async {
                  final detailsCtrl = Get.put(
                    ArtistsDetailsController(
                      networkClient: NetworkClient(
                        onUnAuthorize: () {
                          if (kDebugMode) print("unauthorized");
                        },
                      ),
                    ),
                  );
                  await detailsCtrl.fetchArtistById(artist.id);
                  Get.to(() => ArtistsSocialPostList());
                },
                fontSize: sp(10),
                buttonHeight: 25,
              ),
            ),

            /// Message button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: CustomPrimaryButton2(
                fontSize: sp(10),
                buttonText: "Inquiry",
                buttonHeight: 25,
                onTap: () async {
                  await controller.sendInquiry(userID: artist.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHighlightPreview(BuildContext context, HighlightMedia highlight) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: SizedBox(
            width: double.infinity,
            height: 420.h,
            child: highlight.isVideo
                ? _HighlightVideoPreview(url: highlight.url)
                : Stack(
                    children: [
                      PhotoView(
                        imageProvider: NetworkImage(highlight.url),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 72.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: _PreviewCloseButton(),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _HighlightVideoPreview extends StatefulWidget {
  final String url;

  const _HighlightVideoPreview({required this.url});

  @override
  State<_HighlightVideoPreview> createState() => _HighlightVideoPreviewState();
}

class _HighlightVideoPreviewState extends State<_HighlightVideoPreview> {
  late final VideoPlayerController _controller;
  bool _isReady = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
      await _controller.play();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _hasError
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 72.sp,
                          color: Colors.white,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Unable to play this video',
                          textAlign: TextAlign.center,
                          style: getTextStyle(
                            fontsize: sp(16),
                            color: Colors.white,
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            _errorMessage!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: getTextStyle(
                              fontsize: sp(10),
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : !_isReady
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
          ),
        ),
        if (_isReady)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
                setState(() {});
              },
              child: Center(
                child: AnimatedOpacity(
                  opacity: _controller.value.isPlaying ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 34.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(top: 12.h, right: 12.w, child: _PreviewCloseButton()),
      ],
    );
  }
}

class _PreviewCloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, size: 18.sp, color: Colors.white),
      ),
    );
  }
}
