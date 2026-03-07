class Endpoint {
  static const String baseUrl = 'https://api.theconnectapp.net';
 // static const String baseUrl ="http://10.10.10.2:5050";

  // Auth endpoints
  static const String register = '$baseUrl/auth/register';
  static const String sendPhoneOtp = '$baseUrl/auth/register';
  static const String verifyPhoneOtp = '$baseUrl/auth/phone/verify-otp';
  static const String verifyEmailOtp = '$baseUrl/auth/signup-verify-otp';
  static const String resendEmailOtp = '$baseUrl/auth/resend-email';
  static const String login = '$baseUrl/auth/login';
  static const String forgotPassword = '$baseUrl/auth/forget-password';
  static const String resetVerifyOtp = '$baseUrl/auth/reset-verify-otp';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String orders = '$baseUrl/orders/my-orders';
  static const String recentArtis =
      "$baseUrl/users/artist?filter=recently-updated";
  static const String topRatedArtis = "$baseUrl/users/artist?filter=top-rated";
  static const String suggestedtArtis =
      "$baseUrl/users/artist?filter=suggested";
  static const String allArtists = "$baseUrl/users/artist";
  static const String firebaseGoogleLogin = '$baseUrl/auth/firebase-login';

  // Profile endpoints
  static const String editProfile = '$baseUrl/users/me';
  static const String getProfile = '$baseUrl/users/me';
  static const String earnings = '$baseUrl/payments/earnings-payouts';
  static const String getReview = '$baseUrl/reviews/my-reviews';
  static const String changePassword = '$baseUrl/users/reset_Password';

  // notification
  static const String notificationsIO = '$baseUrl/notification';
  static const String getUserSpecificNotification =
      '$baseUrl/notification-setting/user-specific-notification';
  static const String markAllNotificationsRead =
      '$baseUrl/notification-setting/mark-all-read';
  static const String addService = '$baseUrl/services';

  static String serviceRequest = "$baseUrl/service-requests";

  //chat
  static const String chatSocketIO = '$baseUrl/dj/chat';
  static const String userNotifications =
      "$baseUrl/notification-setting/user-specific-notification";
  static const String allChats = "$baseUrl/private-chat";
  static const String sendMessage = "$baseUrl/private-chat/send-message";
  static const String getSingleChat = "$baseUrl/private-chat";
  static const String markMessageRead =
      "$baseUrl/private-chat/make-private-message-read";
  //dispute
  static const String dispute = '$baseUrl/disputes/my';
  static const String raiseDispute = '$baseUrl/disputes';

  static const String viewArtists = "$baseUrl/users";
  static String updateOrderStatus(String id) => "$baseUrl/orders/$id/status";
  static String proofUpload = "$baseUrl/orders/ProofUpload";
  static String releasePayment = "$baseUrl/payments/approve-payment";
  static String postReview = "$baseUrl/reviews";
  static String getUserById(String id) => "$baseUrl/users/$id";
  static String withdrawalRequests = "$baseUrl/payments";
  static String withdrawalHistory = "$baseUrl/payments/my-withdrawal-history";
  static String getPaymentMethods = "$baseUrl/payments/my-paymentsss-methods";
  static String deleteUserById(String id) => "$baseUrl/users/$id";
  static String markServiceRequestPaid(String id) =>
      "$baseUrl/service-requests/$id/is-paid";
  static String followers = "$baseUrl/follow-function/followers";
  static String followings = "$baseUrl/follow-function/followings";
  static String fileUpload =
      "$baseUrl/aws-file-upload-additional-all/upload-image-single";
  static String cancelProof(String id) =>
      "$baseUrl/orders/$id/cancel-proof?isCancalProofSubmitted=true";
  static String orderDetails(String id) => "$baseUrl/orders/$id";
  static String uploadServiceRequestFiles(String id) =>
      "$baseUrl/service-requests/$id/uploaded-files";
  static String acceptServiceRequest(String id) =>
      "$baseUrl/service-requests/$id/is-declined?isDeclined=false&isAccepted=true";
  static String declineServiceRequest(String id) =>
      "$baseUrl/service-requests/$id/is-declined?isDeclined=true&isAccepted=false";
}
