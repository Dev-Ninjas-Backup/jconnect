import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
//import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';
//import 'package:jconnect/features/my_orders/order_details/controller/order_details_controller.dart';

class ReviewerDetails extends StatelessWidget {
  ReviewerDetails({super.key, required this.order});

  final OrderDetailsModel? order;
  final arguments = Get.arguments;

  @override
  Widget build(BuildContext context) {
    //final odController = Get.find<OrderDetailsController>();
    // CHANGED: Use seller image URL from order model instead of profile controller
    final sellerImageUrl = order?.sellerimageUrl ?? '';
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
                '\$${(order!.servicePrice / 100).toStringAsFixed(2)}',
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
                          Text(
                            order!.sellerName,
                            style: getTextStyle(
                              color: AppColors.primaryTextColor,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            order!.sellerUsername,
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // CHANGED: Display seller image on the right side
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.secondaryTextColor,
                      backgroundImage: sellerImageUrl.isNotEmpty
                          ? NetworkImage(sellerImageUrl)
                          : null,
                      child: sellerImageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              color: AppColors.primaryTextColor,
                              size: 20,
                            )
                          : null,
                    ),
                    // Row(
                    //   children: [
                    //     Icon(Icons.star, color: Colors.amber, size: 18),
                    //     const SizedBox(width: 4),
                    //     Obx(() {
                    //       final avg = odController.sellerAverage.value;
                    //       String display;
                    //       if (avg != null) {
                    //         // show integer when whole number, otherwise 1 decimal
                    //         display = (avg % 1 == 0)
                    //             ? avg.toInt().toString()
                    //             : avg.toStringAsFixed(1);
                    //       } else {
                    //         display = order!.rating.toString();
                    //       }
                    //       return Text(
                    //         display,
                    //         style: getTextStyle(
                    //           color: Colors.amber,
                    //           fontsize: 13,
                    //         ),
                    //       );
                    //     }),
                    //   ],
                    // ),
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
