class SocialProfile {
  final int orderId;
  final String platformName;
  final String platformLink;

  SocialProfile({
    required this.orderId,
    required this.platformName,
    required this.platformLink,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "platformName": platformName,
      "platformLink": platformLink,
    };
  }
}
