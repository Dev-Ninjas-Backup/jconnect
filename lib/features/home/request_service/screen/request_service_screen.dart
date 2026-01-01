// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/core/common/widgets/custom_secondary_button.dart';
import 'package:jconnect/features/home/request_service/controller/request_service_controller.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';
import 'package:jconnect/features/messages/model/message_model2.dart';
import 'package:jconnect/routes/approute.dart';
import '../../../../core/common/style/global_text_style.dart';
import '../widgets/customize_your_order.dart';
import '../widgets/request_service_card.dart';

class RequestServiceScreen extends StatelessWidget {
  final RequestServiceController controller = Get.put(
    RequestServiceController(),
  );
  RequestServiceScreen({super.key});

  final service = Get.arguments;

  bool get isSocialPost {
    return service.serviceType != null && service.serviceType == 'SOCIAL_POST';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 74.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar2(
                title: isSocialPost ? "Buy Post" : "Request Service",
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () {
                  Get.back();
                },
              ),
              SizedBox(height: 40.h),
              ReqestServiceCard(service: service),
              SizedBox(height: 40.h),
              Text(
                "Customize Your Order",
                style: getTextStyle(
                  fontsize: sp(16),
                  fontweight: FontWeight.w600,
                  color: AppColors.primaryTextColor.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 16.h),
              CustomizeYourOrder(controller: controller),
              SizedBox(height: 40.h),

              // RequestCustomServiceCard(),

              //   SizedBox(height: 40.h),
              // Text(
              //   "Payment Summary",
              //   style: getTextStyle(
              //     fontsize: sp(16),
              //     fontweight: FontWeight.w600,
              //     color: AppColors.primaryTextColor.withValues(alpha: 0.7),
              //   ),
              // ),

              // SizedBox(height: 16.h),

              // GradientBorderContainer(
              //   borderRadius: 6.r,
              //   borderWidth: .6,
              //   padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       //1st row
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             "Service Price",
              //             style: getTextStyle(
              //               fontsize: sp(14),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //           Text(
              //             "\$150.00",
              //             style: getTextStyle(
              //               fontsize: sp(14),
              //               fontweight: FontWeight.w500,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 12.h),
              //       //2nd row
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             "Platform Fee (10%)",
              //             style: getTextStyle(
              //               fontsize: sp(14),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //           Text(
              //             "\$7.00",
              //             style: getTextStyle(
              //               fontsize: sp(14),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 12.h),
              //       Divider(thickness: .6),
              //       SizedBox(height: 6),

              //       //total row
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             "Total",
              //             style: getTextStyle(
              //               fontsize: sp(16),
              //               fontweight: FontWeight.w600,
              //               color: AppColors.primaryTextColor,
              //             ),
              //           ),

              //           Text(
              //             "\$157.00",
              //             style: getTextStyle(
              //               fontsize: sp(16),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor,
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 16.h),

              //       GradientBorderContainer(
              //         color: Color(0xFF353434),

              //         borderRadius: 4.r,
              //         borderWidth: .6,
              //         padding: EdgeInsets.symmetric(
              //           horizontal: 10.w,
              //           vertical: 10.h,
              //         ),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           spacing: 10.w,
              //           children: [
              //             Image.asset(
              //               Iconpath.securityIcon,
              //               height: 20.h,
              //               width: 20.w,
              //             ),

              //             Expanded(
              //               child: Text(
              //                 "Payment is securely held until both parties confirm completion",
              //                 overflow: TextOverflow.ellipsis,
              //                 maxLines: 2,
              //                 style: getTextStyle(
              //                   fontsize: sp(12),
              //                   color: AppColors.primaryTextColor.withValues(
              //                     alpha: .7,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       SizedBox(height: 12.h),

              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Image.asset(
              //             Iconpath.stripeIcon,
              //             height: 8.h,
              //             width: 18.w,
              //             color: AppColors.primaryTextColor,
              //           ),
              //           SizedBox(width: 8.w),
              //           Text(
              //             "Secured by Stripe",
              //             style: getTextStyle(
              //               fontsize: sp(10),
              //               fontweight: FontWeight.w400,
              //               color: AppColors.primaryTextColor.withValues(
              //                 alpha: .7,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 40.h),
              CustomPrimaryButton(
                buttonText: "Send Request",
                onTap: () async {
                  try {
                    // Submit the service request first
                    await controller.submitServiceRequest(
                      serviceId: service.id,
                      price: service.price.toDouble(),
                    );

                    // // Show success dialog
                    // Get.dialog(
                    //   AlertDialog(
                    //     title: const Text('Success'),
                    //     content: const Text('Service request sent successfully!'),
                    //     actions: [
                    //       TextButton(
                    //         onPressed: () => Get.back(),
                    //         child: const Text('OK'),
                    //       ),
                    //     ],
                    //   ),
                    // );

                    // Send message with service ID to the service provider
                    final messagesController = Get.find<MessagesController>();

                    print('🔥 [REQUEST SERVICE] Starting message send process');
                    print('🔥 [REQUEST SERVICE] Service ID: ${service.id}');
                    print(
                      '🔥 [REQUEST SERVICE] Service Name: ${service.serviceName}',
                    );
                    print(
                      '🔥 [REQUEST SERVICE] Service Creator ID: ${service.creatorId}',
                    );

                    // Check if we have a creator ID before proceeding
                    if (service.creatorId == null ||
                        service.creatorId!.isEmpty) {
                      print(
                        '❌ [REQUEST SERVICE] Service creator ID is missing',
                      );
                      return;
                    }

                    // Debug the creatorId type and value
                    print(
                      '🔥 [REQUEST SERVICE] Service Creator ID type: ${service.creatorId.runtimeType}',
                    );
                    print(
                      '🔥 [REQUEST SERVICE] Service Creator ID value: "${service.creatorId}"',
                    );
                    print(
                      '🔥 [REQUEST SERVICE] Service Creator ID length: ${service.creatorId?.length}',
                    );

                    // Ensure creatorId is a proper string
                    final String recipientIdStr = service.creatorId
                        .toString()
                        .trim();
                    print(
                      '🔥 [REQUEST SERVICE] Converted recipientId: "$recipientIdStr"',
                    );
                    print(
                      '🔥 [REQUEST SERVICE] Converted recipientId length: ${recipientIdStr.length}',
                    );

                    if (recipientIdStr.isEmpty) {
                      print(
                        '❌ [REQUEST SERVICE] Converted recipientId is empty',
                      );
                      return;
                    }

                    // Check if there's an existing conversation
                    final existingChat = messagesController.allChats
                        .firstWhereOrNull(
                          (chat) => chat.participant?.id == recipientIdStr,
                        );

                    print(
                      '🔥 [REQUEST SERVICE] Existing chat found: ${existingChat != null}',
                    );
                    if (existingChat != null) {
                      print(
                        '🔥 [REQUEST SERVICE] Existing chat ID: ${existingChat.chatId}',
                      );
                    }

                    // Send message with service information (empty content, service data only)
                    print(
                      '🔥 [REQUEST SERVICE] Sending message with serviceId: ${service.id}',
                    );

                    // Navigate to chat to continue conversation
                    if (existingChat != null && existingChat.chatId != null) {
                      // Navigate to existing conversation
                      print(
                        '🔥 [REQUEST SERVICE] Navigating to existing conversation: ${existingChat.chatId}',
                      );
                      Get.toNamed(
                        AppRoute.chatDetailsScreen,
                        arguments: {
                          'chatItem': existingChat,
                          'recipientId': recipientIdStr,
                          'isNewConversation': false,
                          'sendInitialServiceRequest': true,
                          'initialServiceId': service.id,
                        },
                      );
                    } else {
                      // Navigate to new conversation
                      print(
                        '🔥 [REQUEST SERVICE] Creating new conversation with user: $recipientIdStr',
                      );
                      print(
                        '🔥 [REQUEST SERVICE] Service creator name: ${service.creator?.full_name}',
                      );
                      print(
                        '🔥 [REQUEST SERVICE] Service creator object: ${service.creator}',
                      );
                      
                      // Get creator name with better fallback
                      final creatorName = service.creator?.full_name?.isNotEmpty == true
                          ? service.creator!.full_name!
                          : (service.creator?.email?.isNotEmpty == true 
                              ? service.creator!.email!
                              : 'User');
                      
                      print('🔥 [REQUEST SERVICE] Using creator name: $creatorName');
                      
                      final chatItem = ChatItem(
                        type: 'private',
                        chatId: null,
                        participant: ChatParticipant(
                          id: recipientIdStr,
                          fullName: creatorName,
                          profilePhoto: service.creator?.profilePhoto,
                        ),
                      );
                      Get.toNamed(
                        AppRoute.chatDetailsScreen,
                        arguments: {
                          'chatItem': chatItem,
                          'recipientId': recipientIdStr,
                          'isNewConversation': true,
                          'sendInitialServiceRequest': true,
                          'initialServiceId': service.id,
                        },
                      );
                    }
                    print('🔥 [REQUEST SERVICE] Navigation completed');
                  } catch (e, stackTrace) {
                    print('❌ [REQUEST SERVICE] Error occurred: $e');
                    print('❌ [REQUEST SERVICE] Error type: ${e.runtimeType}');
                    print('❌ [REQUEST SERVICE] Stack trace: $stackTrace');
                    print('❌ [REQUEST SERVICE] Full error: ${e.toString()}');
                  }
                },
              ),
              SizedBox(height: 16.h),
              Row(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomSecondaryButton(
                      buttonText: "Cancel",
                      onTap: () {},
                    ),
                  ),
                  Expanded(
                    child: CustomSecondaryButton(
                      buttonText: "Message Seller",
                      onTap: () {
                        print('🔥 [MESSAGE SELLER] Button pressed');
                        print(
                          '🔥 [MESSAGE SELLER] Service Provider ID: ${service.creatorId}',
                        );

                        // Ensure creatorId is a proper string
                        final String sellerIdStr = service.creatorId
                            .toString()
                            .trim();
                        print(
                          '🔥 [MESSAGE SELLER] Converted sellerId: "$sellerIdStr"',
                        );

                        final messagesController =
                            Get.find<MessagesController>();

                        // Check if there's an existing conversation
                        final existingChat = messagesController.allChats
                            .firstWhereOrNull(
                              (chat) => chat.participant?.id == sellerIdStr,
                            );

                        print(
                          '🔥 [MESSAGE SELLER] Existing chat found: ${existingChat != null}',
                        );
                        if (existingChat != null) {
                          print(
                            '🔥 [MESSAGE SELLER] Existing chat ID: ${existingChat.chatId}',
                          );
                        }

                        if (existingChat != null &&
                            existingChat.chatId != null) {
                          // Navigate to existing conversation
                          print(
                            '🔥 [MESSAGE SELLER] Navigating to existing chat: ${existingChat.chatId}',
                          );
                          Get.toNamed(
                            AppRoute.chatDetailsScreen,
                            arguments: {
                              'chatItem': existingChat,
                              'recipientId': sellerIdStr,
                              'isNewConversation': false,
                            },
                          );
                        } else {
                          // Navigate to new conversation
                          print(
                            '🔥 [MESSAGE SELLER] Creating new conversation',
                          );
                          
                          // Get creator name with better fallback
                          final creatorName = service.creator?.full_name?.isNotEmpty == true
                              ? service.creator!.full_name!
                              : (service.creator?.email?.isNotEmpty == true 
                                  ? service.creator!.email!
                                  : 'Service Provider');
                          
                          final chatItem = ChatItem(
                            type: 'private',
                            chatId: null,
                            participant: ChatParticipant(
                              id: sellerIdStr,
                              fullName: creatorName,
                              profilePhoto: service.creator?.profilePhoto,
                            ),
                          );
                          Get.toNamed(
                            AppRoute.chatDetailsScreen,
                            arguments: {
                              'chatItem': chatItem,
                              'recipientId': sellerIdStr,
                              'isNewConversation': true,
                            },
                          );
                        }
                        print('🔥 [MESSAGE SELLER] Navigation completed');
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Text(
                "Your payment is protected until the service is completed. DJ Connect ensures both sides confirm delivery before funds are released.",
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontsize: sp(10),
                  color: AppColors.primaryTextColor.withValues(alpha: .4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
