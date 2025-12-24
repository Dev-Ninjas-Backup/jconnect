class Endpoint {
  static const String baseUrl = 'https://neva-unlamentable-judson.ngrok-free.dev';

  // Auth endpoints
  static const String register = '$baseUrl/auth/register';
  static const String sendPhoneOtp = '$baseUrl/auth/register';
  static const String verifyPhoneOtp = '$baseUrl/auth/phone/verify-otp';
  static const String verifyEmailOtp = '$baseUrl/auth/signup-verify-otp';
  static const String login = '$baseUrl/auth/login';
  static const String orders = '$baseUrl/orders/my-orders';
  static const String recentArtis =
      "$baseUrl/users/artist?filter=recently-updated";
  static const String topRatedArtis = "$baseUrl/users/artist?filter=top-rated";
  static const String suggestedtArtis =
      "$baseUrl/users/artist?filter=suggested";
  static const String allArtists = "$baseUrl/users/artist";

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
  static const String addService = '$baseUrl/services';

  static String serviceRequest =
      "$baseUrl/service-requests";

  //chat
  static const String chatSocketIO =
      '$baseUrl/dj/chat';
  static const String userNotifications =
      "$baseUrl/notification-setting/user-specific-notification";
  static const String allChats =
      "$baseUrl/private-chat";
  //dispute
  static const String dispute = '$baseUrl/disputes/my';
  static const String raiseDispute = '$baseUrl/disputes';


  static const String viewArtists="$baseUrl/users";
}
