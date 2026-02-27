import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
//import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';
//import 'package:jconnect/features/my_orders/order_details/controller/order_details_controller.dart';

class ReviewerDetails extends StatefulWidget {
  const ReviewerDetails({super.key, required this.order});

  final OrderDetailsModel? order;

  @override
  State<ReviewerDetails> createState() => _ReviewerDetailsState();
}

class _ReviewerDetailsState extends State<ReviewerDetails> {
  late bool isSeller = false;

  @override
  void initState() {
    super.initState();
    _determineUserRole();
  }

  Future<void> _determineUserRole() async {
    final prefs = Get.find<SharedPreferencesHelperController>();
    final loggedInUserId = await prefs.getUserId();
    setState(() {
      isSeller = loggedInUserId == widget.order?.sellerId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    // Determine which user's info to show based on logged-in user's role
    final displayUsername = isSeller
        ? (order?.buyerUsername ?? '')
        : (order?.sellerUsername ?? '');
    final displayImageUrl = isSeller
        ? (order?.buyerImageUrl ?? '')
        : (order?.sellerimageUrl ?? '');
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryTextColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order?.serviceTitle ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: getTextStyle(
                        color: AppColors.secondaryTextColor,
                        fontsize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      order?.subServiceTitle ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: getTextStyle(
                        color: Colors.white54,
                        fontsize: 13,
                        fontweight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                '\$${((order?.servicePrice ?? 0) / 100).toStringAsFixed(2)}',
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontweight: FontWeight.w600,
                ),
              ),
            ],
          ),
          //SizedBox(height: 4),
          SizedBox(height: 14),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF242629),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   order!.sellerName,
                          //   style: getTextStyle(
                          //     color: AppColors.primaryTextColor,
                          //     fontweight: FontWeight.w600,
                          //   ),
                          // ),
                          Text(
                            displayUsername,
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // CHANGED: Display image based on user role (buyer or seller)
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.secondaryTextColor,
                      backgroundImage: displayImageUrl.isNotEmpty
                          ? NetworkImage(displayImageUrl)
                          : null,
                      child: displayImageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              color: AppColors.primaryTextColor,
                              size: 20,
                            )
                          : null,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(order?.status ?? '', style: getTextStyle(fontsize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
