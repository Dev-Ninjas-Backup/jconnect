import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';

class ReviewerDetails extends StatelessWidget {
  ReviewerDetails({super.key, required this.order});

  final OrderDetailsModel? order;
  final arguments = Get.arguments;

  ImageProvider _buildReviewerImage(String? path) {
    // Fallback asset used when reviewer image path is empty or null
    const fallback = AssetImage('assets/images/profile_image.png');

    if (path == null || path.isEmpty) return fallback;

    // If it's a URL use network image, otherwise assume it's an asset path
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }

    return AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
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
              Row(
                children: [
                  Image.asset(Iconpath.instagram, width: 24),
                  SizedBox(width: 8),
                  Text(
                    order!.platform,
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${order!.servicePrice.toStringAsFixed(0)}',
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontweight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order!.serviceTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  color: AppColors.secondaryTextColor,
                  fontsize: 13,
                ),
              ),
              SizedBox(height: 4),
              Text(
                order!.subServiceTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  color: Colors.white54,
                  fontsize: 13,
                  fontweight: FontWeight.w400,
                ),
              ),
            ],
          ),
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
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: _buildReviewerImage(
                        order!.reviewerImage,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order!.reviewerName,
                            style: getTextStyle(
                              color: AppColors.primaryTextColor,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            order!.reviewerHandle,
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          order!.rating.toString(),
                          style: getTextStyle(
                            color: Colors.amber,
                            fontsize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(order!.status, style: getTextStyle(fontsize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
